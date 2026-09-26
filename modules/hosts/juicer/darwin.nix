{
  imports = [
    ./nix-store.nix
  ];

  time.timeZone = "Asia/Seoul";

  # Restrict the ports without enabling SSH or Screen Sharing services.
  pf = {
    screen-sharing = {
      enable = true;
      high-performance = true;
    };
    ssh.enable = true;
  };
}
