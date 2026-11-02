{ ... }:

{
  imports = [ ./theme.nix ];

  programs.firefox = {
    enable = true;

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      FirefoxSuggest = {
        SponsoredSuggestions = false;
        ImproveSuggest = false;
      };
      ExtensionSettings."uBlock0@raymondhill.net" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
      };
    };

    profiles.default.isDefault = true;
  };

  # catppuccin's Firefox theme is read at evaluation time from a built source, which a non-Linux machine cannot evaluate.
  catppuccin.firefox.enable = false;
}
