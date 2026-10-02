# Firefox: shared base config plus the work/personal profile split.
# Bookmarks and the signed-in Mozilla account come from Firefox Sync, not here.
{
  isWorkDevice,
  pkgs,
  lib,
  ...
}:
let
  addons = pkgs.nur.repos.rycee.firefox-addons;

  # Add-ons rycee doesn't package. Same shape as a rycee package for our
  # purposes (all we read is .addonId), but nothing is built.
  amo = addonId: { inherit addonId; };

  viewImageInfo = amo "view-image-info@jeffersonscher.com";
  vueTelescope = amo "{5f7d34a0-81f6-4cda-af10-92514b58d2d2}";
  snahp = amo "{86bdb411-d28b-4284-a009-49e822e8b496}";

  passwordManager = if isWorkDevice then addons."1password-x-password-manager" else addons.bitwarden;

  sharedExtensions = [
    addons.ublock-origin
    addons.consent-o-matic
    passwordManager
  ];
  personalExtensions = [
    addons.download-with-jdownloader
    viewImageInfo
    addons.streetpass-for-mastodon
    vueTelescope
    addons.vue-js-devtools
    addons.buster-captcha-solver
    snahp
    addons.plasma-integration
  ];
  workExtensions = [
    addons.salesforce-inspector-reloaded
  ];

  extensions = sharedExtensions ++ (if isWorkDevice then workExtensions else personalExtensions);

  # Firefox's own widget id scheme for a browser-action button: lowercase
  # the addon id, replace anything outside [a-z0-9_-] with "_", then append
  # "-browser-action".
  toWidgetId =
    addonId:
    let
      allowed = "abcdefghijklmnopqrstuvwxyz0123456789_-";
      chars = lib.stringToCharacters (lib.toLower addonId);
    in
    "${lib.concatMapStrings (c: if lib.hasInfix c allowed then c else "_") chars}-browser-action";

  uiCustomizationState = {
    placements = {
      "widget-overflow-fixed-list" = [ ];
      "unified-extensions-area" = map (e: toWidgetId e.addonId) (
        lib.optionals (!isWorkDevice) [
          addons.download-with-jdownloader
          addons.buster-captcha-solver
          addons.plasma-integration
        ]
      );
      nav-bar = [
        "sidebar-button"
        "back-button"
        "forward-button"
        "stop-reload-button"
        "customizableui-special-spring1"
        "vertical-spacer"
        "urlbar-container"
        "customizableui-special-spring2"
        "downloads-button"
        (toWidgetId passwordManager.addonId)
        (toWidgetId addons.ublock-origin.addonId)
        (toWidgetId addons.consent-o-matic.addonId)
      ]
      ++ map (e: toWidgetId e.addonId) (
        lib.optionals (!isWorkDevice) [
          addons.streetpass-for-mastodon
          vueTelescope
          addons.vue-js-devtools
        ]
      )
      ++ [
        "unified-extensions-button"
        "alltabs-button"
      ];
      TabsToolbar = [ ];
      "vertical-tabs" = [ "tabbrowser-tabs" ];
      PersonalToolbar = [ "personal-bookmarks" ];
    };
    currentVersion = 25;
    newElementCount = 0;
  };
in
{
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";

    # Firefox installs every extension itself from AMO (always the latest
    # version); rycee packages are only used as a source of addon ids.
    policies.ExtensionSettings = {
      "*" = {
        installation_mode = "blocked";
        blocked_install_message = "Add-ons are managed in the Nix config.";
      };
    }
    // lib.listToAttrs (
      map (
        e:
        lib.nameValuePair e.addonId {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/${e.addonId}/latest.xpi";
        }
      ) extensions
    );

    profiles.default = {
      isDefault = true;

      search = {
        force = true;
        default = "google";
      };

      settings = {
        # Language
        "intl.accept_languages" = "en-us,en,de";
        "intl.regional_prefs.use_os_locales" = true;

        # Login/password handling
        "signon.rememberSignons" = false;

        # Sidebar / tabs / toolbar layout
        "sidebar.verticalTabs" = true;
        "sidebar.main.tools" = "history,bookmarks";
        "browser.toolbars.bookmarks.visibility" = "always";
        "browser.tabs.groups.smart.enabled" = false;
        "browser.tabs.groups.smart.userEnabled" = false;
        "browser.uiCustomization.state" = builtins.toJSON uiCustomizationState;

        # AI features off
        "browser.ai.control.default" = "blocked";
        # ML have their own feature flags
        "browser.ml.chat.enabled" = false;
        "browser.ml.chat.page" = false;
        "browser.ml.linkPreview.enabled" = false;
        "extensions.ml.enabled" = false;
        "browser.translations.enable" = false;
        "pdfjs.enableAltText" = false;

        # Privacy
        "dom.security.https_only_mode" = true;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "privacy.clearOnShutdown_v2.formdata" = true;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;

        # New tab
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.pinned" = builtins.toJSON [ ];

        # misc UX
        "browser.startup.page" = 3; # restore previous session
        "findbar.highlightAll" = true;
        "print_printer" = "Mozilla Save to PDF";
        "devtools.toolbox.host" = "right";

        # Sync: Nix owns these, so don't let Sync move them around
        "services.sync.engine.addresses" = false;
        "services.sync.engine.creditcards" = false;
        "services.sync.engine.addons" = false;
        "services.sync.engine.prefs" = false;
        "services.sync.engine.passwords" = false;
      };
    };
  };
}
