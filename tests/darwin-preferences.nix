{ lib, self }:
let
  # These are the two machines that opted into this particular desktop policy.
  hosts = { inherit (self.darwinConfigurations) juicer mixer; };
  juicer = hosts.juicer.config;
  mixer = hosts.mixer.config;
  overridden =
    (hosts.mixer.extendModules {
      modules = [
        {
          system.defaults.dock.tilesize = 64;
          system.defaults.CustomUserPreferences.".GlobalPreferences".AppleLanguages = [ "ko-KR" ];
        }
      ];
    }).config;
  perHost =
    name: h:
    let
      c = h.config;
      d = c.system.defaults;
    in
    {
      "${name}/common-policy" =
        d.menuExtraClock.ShowAMPM == false
        && d.menuExtraClock.ShowDate == 1
        && d.controlcenter.BatteryShowPercentage == true
        && d.hitoolbox.AppleFnUsageType == 2
        && d.dock.tilesize == 50
        && d.NSGlobalDomain.AppleMetricUnits == 1;
      "${name}/security" =
        c.networking.applicationFirewall == {
          enable = true;
          blockAllIncoming = false;
          allowSigned = true;
          allowSignedApp = true;
          enableStealthMode = true;
        }
        && c.pf.ssh.enable
        && c.pf.screen-sharing.enable
        && c.pf.screen-sharing.high-performance;
      "${name}/no-runtime-state" =
        !(d.CustomUserPreferences."com.apple.HIToolbox" ? AppleSelectedInputSources)
        && d.ActivityMonitor.OpenMainWindow == null
        && d.dock.persistent-apps == null;
    };
  rules = import ../modules/darwin/pf/rules.nix {
    inherit lib;
    cfg = mixer.pf;
  };
in
lib.foldlAttrs
  (
    acc: name: h:
    acc // perHost name h
  )
  {
    desktop-isolation =
      !juicer.system.defaults.dock.autohide
      && !mixer.system.defaults.dock.autohide
      && juicer.system.defaults.WindowManager.GloballyEnabled
      && mixer.system.defaults.WindowManager.GloballyEnabled
      && juicer.system.defaults.NSGlobalDomain."com.apple.trackpad.scaling" == 0.875
      && mixer.system.defaults.NSGlobalDomain."com.apple.trackpad.scaling" == 1.0
      && juicer.system.defaults.".GlobalPreferences"."com.apple.mouse.scaling" == 1.5
      && mixer.system.defaults.".GlobalPreferences"."com.apple.mouse.scaling" == 0.6875
      && juicer.system.defaults.NSGlobalDomain.AppleEnableSwipeNavigateWithScrolls
      && !mixer.system.defaults.NSGlobalDomain.AppleEnableSwipeNavigateWithScrolls
      && juicer.system.defaults.trackpad.Dragging
      && !mixer.system.defaults.trackpad.Dragging;
    power-isolation =
      juicer.power.sleep.display == null
      && juicer.power.sleep.computer == null
      && mixer.power.sleep.display == "never"
      && mixer.power.sleep.computer == "never";
    override-isolation =
      overridden.system.defaults.dock.tilesize == 64
      && overridden.system.defaults.dock.autohide == false
      && juicer.system.defaults.dock.tilesize == 50
      &&
        overridden.system.defaults.CustomUserPreferences.".GlobalPreferences".AppleLanguages == [ "ko-KR" ]
      && overridden.system.defaults.CustomUserPreferences.".GlobalPreferences".AppleLocale == "en_KR";
    pf-rules =
      lib.all (text: lib.hasInfix text rules.passRules) [
        "on $tailscale_if inet proto tcp from $tailscale_v4 to any port 22"
        "on $tailscale_if inet6 proto tcp from $tailscale_v6 to any port 22"
        "on $tailscale_if inet proto tcp from $tailscale_v4 to any port 5900"
        "on $tailscale_if inet6 proto tcp from $tailscale_v6 to any port 5900"
        "on $tailscale_if inet proto udp from $tailscale_v4 to any port 5900:5902"
        "on $tailscale_if inet6 proto udp from $tailscale_v6 to any port 5900:5902"
      ]
      && !(lib.hasInfix "pass in" rules.denyOnlyRules)
      && lib.hasInfix "block drop in quick proto udp from any to any port 5900:5902" rules.denyOnlyRules
      && lib.hasInfix "block drop in quick proto tcp from any to any port 22" rules.denyOnlyRules;
  }
  hosts
