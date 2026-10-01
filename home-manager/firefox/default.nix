# Firefox: shared base config plus the work/personal profile split.
# Bookmarks and the signed-in Mozilla account come from Firefox Sync, not here.
{
  isWorkDevice,
  pkgs,
  ...
}:
let
  addons = pkgs.nur.repos.rycee.firefox-addons;

  sharedExtensions = with addons; [
    ublock-origin
    consent-o-matic
  ];
  personalExtensions = with addons; [ bitwarden ];
  workExtensions = with addons; [
    addons."1password-x-password-manager"
    salesforce-inspector-reloaded
  ];

  extensions = sharedExtensions ++ (if isWorkDevice then workExtensions else personalExtensions);

  # Toolbar widget id for whichever password manager is installed on this
  # device, derived from its addon id the same way Firefox does
  # ("{guid}" -> "_guid_-browser-action").
  passwordManagerWidgetId =
    if isWorkDevice then
      "_d634138d-c276-4fc8-924b-40a0ea21d284_-browser-action"
    else
      "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action";

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
        passwordManagerWidgetId
        "ublock0_raymondhill_net-browser-action"
        "gdpr_cavi_au_dk-browser-action"
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

        # AI/ML features off
        "browser.ai.control.default" = "blocked";
        "browser.ai.control.linkPreviewKeyPoints" = "blocked";
        "browser.ai.control.pdfjsAltText" = "blocked";
        "browser.ai.control.sidebarChatbot" = "blocked";
        "browser.ai.control.smartTabGroups" = "blocked";
        "browser.ai.control.smartWindow" = "blocked";
        "browser.ai.control.translations" = "blocked";
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
        "network.dns.disablePrefetch" = true;
        "network.prefetch-next" = false;
        "network.http.speculative-parallel-limit" = 0;

        # Startup / misc UX
        "browser.startup.page" = 3; # restore previous session
        "findbar.highlightAll" = true;
        "print_printer" = "Mozilla Save to PDF";
        "devtools.toolbox.host" = "right";
      };
    };
  };
}
