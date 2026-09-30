# Firefox: shared base config plus the work/personal profile split.
# Bookmarks and the signed-in Mozilla account come from Firefox Sync, not here.
{ isWorkDevice, ... }:
let
  # `id` is the addon id (used as the ExtensionSettings key), `slug` is the
  # AMO listing slug used to build the "latest" download URL. Firefox
  # installs these itself from addons.mozilla.org via its policy engine
  sharedExtensions = [
    {
      id = "uBlock0@raymondhill.net";
      slug = "ublock-origin";
    }
    {
      id = "gdpr@cavi.au.dk";
      slug = "consent-o-matic";
    }
  ];

  personalExtensions = [
    {
      id = "{446900e4-71c2-419f-a6a7-df9c091e268b}";
      slug = "bitwarden-password-manager";
    }
  ];

  workExtensions = [
    {
      id = "{d634138d-c276-4fc8-924b-40a0ea21d284}";
      slug = "1password-x-password-manager";
    }
    {
      id = "salesforceinspector@reloaded";
      slug = "salesforce-inspector-reloaded";
    }
  ];

  extensions = sharedExtensions ++ (if isWorkDevice then workExtensions else personalExtensions);

  toExtensionSettings =
    exts:
    builtins.listToAttrs (
      map (e: {
        name = e.id;
        value = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/${e.slug}/latest.xpi";
          installation_mode = "force_installed";
        };
      }) exts
    );
in
{
  programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";

    policies.ExtensionSettings = toExtensionSettings extensions;

    profiles.default = {
      isDefault = true;
      settings = {
        # Never store site logins/passwords in the browser itself.
        "signon.rememberSignons" = false;
      };
    };
  };
}
