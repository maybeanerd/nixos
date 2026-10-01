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

  ublock = addons.ublock-origin;
  consentOMatic = addons.consent-o-matic;
  passwordManager = if isWorkDevice then addons."1password-x-password-manager" else addons.bitwarden;

  sharedExtensions = [
    ublock
    consentOMatic
    passwordManager
  ];
  personalExtensions = [ ];
  workExtensions = [
    addons.salesforce-inspector-reloaded
  ];

  extensions = sharedExtensions ++ (if isWorkDevice then workExtensions else personalExtensions);

  # Firefox's own widget id scheme for a browser-action button: lowercase
  # the addon id, replace anything outside [a-z0-9_-] with "_", then append
  # "-browser-action". Deriving it from the package's addonId means the
  # toolbar layout below never needs a literal id typed out by hand.
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
      "unified-extensions-area" = [ ];
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
        (toWidgetId ublock.addonId)
        (toWidgetId consentOMatic.addonId)
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

    profiles.default = {
      isDefault = true;
      extensions.packages = extensions;

      settings = {
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
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;

        # Startup / misc UX
        "browser.startup.page" = 3; # restore previous session
        "findbar.highlightAll" = true;
        "print_printer" = "Mozilla Save to PDF";
        "devtools.toolbox.host" = "right";
      };
    };
  };
}
