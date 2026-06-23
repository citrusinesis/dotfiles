{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

let
  helperPackages = with pkgs; [
    bashInteractive
    coreutils
    getent
    gnugrep
    shadow
    sudo
  ];

  helperPath = lib.makeBinPath helperPackages;

  createUser = pkgs.writeShellScript "create-container-machine-user" ''
    set -eu

    export PATH=${helperPath}:$PATH

    if ! getent group "$CONTAINER_GID" >/dev/null 2>&1; then
      groupadd -g "$CONTAINER_GID" "$CONTAINER_USER"
    fi

    if ! id "$CONTAINER_USER" >/dev/null 2>&1; then
      useradd \
        --uid "$CONTAINER_UID" \
        --gid "$CONTAINER_GID" \
        --groups wheel \
        --home-dir "$CONTAINER_HOME" \
        --create-home \
        --shell /run/current-system/sw/bin/bash \
        "$CONTAINER_USER"
    else
      usermod \
        --append \
        --groups wheel \
        --shell /run/current-system/sw/bin/bash \
        "$CONTAINER_USER"
    fi

    mkdir -p "$CONTAINER_HOME"
    chown "$CONTAINER_UID:$CONTAINER_GID" "$CONTAINER_HOME"

    mkdir -p /etc/sudoers.d
    echo "$CONTAINER_USER ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$CONTAINER_USER"
    chmod 0440 "/etc/sudoers.d/$CONTAINER_USER"
  '';

  machineInit = pkgs.writeShellScript "apple-container-nixos-machine-init" ''
    set -eu

    export container=container
    ${pkgs.coreutils}/bin/mkdir -p /run/systemd
    echo container > /run/systemd/container

    exec ${config.system.build.toplevel}/init "$@"
  '';

  storeContents =
    map
      (object: {
        inherit object;
        symlink = "none";
      })
      (
        [
          config.system.build.toplevel
          createUser
          machineInit
        ]
        ++ helperPackages
      );
in
{
  imports = [
    "${modulesPath}/virtualisation/lxc-container.nix"
  ];

  system.stateVersion = "25.11";

  boot.postBootCommands = ''
    mkdir -p /run/systemd
    echo container > /run/systemd/container
  '';

  system.build.installBootLoader = lib.mkForce (
    pkgs.writeShellScript "install-container-machine-init" ''
      set -eu

      system="$1"

      ${pkgs.coreutils}/bin/install -d -m 0755 /sbin
      printf '%s\n' \
        '#!/bin/sh' \
        'set -eu' \
        "" \
        'export container=container' \
        '${pkgs.coreutils}/bin/mkdir -p /run/systemd' \
        'echo container > /run/systemd/container' \
        "" \
        "exec \"$system/init\" \"\$@\"" \
        > /sbin/init
      chmod 0755 /sbin/init
      cp /sbin/init /init
    ''
  );

  networking.hostName = "nixos-machine";
  networking.useDHCP = lib.mkDefault true;

  users.mutableUsers = true;

  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  services.openssh.enable = true;
  services.openssh.startWhenNeeded = lib.mkForce false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    bashInteractive
    cacert
    coreutils
    curl
    git
    gnugrep
    gnutar
    gzip
    iproute2
    iputils
    less
    nix
    openssh
    shadow
    sudo
    vim
    xz
  ];

  environment.etc."machine/create-user.sh".source = createUser;

  system.build.containerMachineRootfs =
    pkgs.callPackage "${modulesPath}/../lib/make-system-tarball.nix"
      {
        fileName = "apple-container-nixos-machine-${pkgs.stdenv.hostPlatform.system}";
        extraArgs = "--owner=0";

        inherit storeContents;

        contents = [
          {
            source = machineInit;
            target = "/sbin/init";
          }
          {
            source = machineInit;
            target = "/init";
          }
          {
            source = "${config.system.build.toplevel}/etc/os-release";
            target = "/etc/os-release";
          }
          {
            source = createUser;
            target = "/etc/machine/create-user.sh";
          }
        ];

        extraCommands = ''
          mkdir -p bin sbin etc/machine proc sys dev run tmp var usr/local/bin usr/local/sbin

          ln -sfn ${pkgs.bashInteractive}/bin/bash bin/sh
          ln -sfn ${pkgs.bashInteractive}/bin/bash bin/bash

          ln -sfn ${pkgs.coreutils}/bin/chown bin/chown
          ln -sfn ${pkgs.coreutils}/bin/cut bin/cut
          ln -sfn ${pkgs.coreutils}/bin/id bin/id
          ln -sfn ${pkgs.gnugrep}/bin/grep bin/grep

          ln -sfn /run/current-system/sw/bin usr/bin
          ln -sfn /run/current-system/sw/sbin usr/sbin
        '';
      };
}
