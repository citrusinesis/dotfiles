{ ... }:

{
  system.defaults.loginwindow.GuestEnabled = false;

  security.pam.services.sudo_local.touchIdAuth = true;

  # Application permissions and the host's Tailscale-only PF rules complement
  # each other. Blocking all incoming traffic would also break Screen Sharing.
  networking.applicationFirewall = {
    enable = true;
    blockAllIncoming = false;
    allowSigned = true;
    allowSignedApp = true;
    enableStealthMode = true;
  };
}
