{ ... }:

{
  system.defaults = {
    loginwindow.GuestEnabled = false;

    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 0;
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;
}
