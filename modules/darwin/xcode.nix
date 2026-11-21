{
  config,
  lib,
  pkgs,
  ...
}:
let
  developerDir = "/Applications/Xcode.app/Contents/Developer";
  xcodebuild = "DEVELOPER_DIR=${developerDir} ${developerDir}/usr/bin/xcodebuild";
  simctl = "DEVELOPER_DIR=${developerDir} ${developerDir}/usr/bin/simctl";
  asUser = "/usr/bin/sudo -H -u ${lib.escapeShellArg config.system.primaryUser} --";
in
{
  homebrew.masApps.Xcode = 497799835;

  system.defaults.CustomUserPreferences."com.apple.dt.Xcode" = {
    XCFontAndColorCurrentTheme = "Catppuccin Mocha.xccolortheme";
    XCFontAndColorCurrentDarkTheme = "Catppuccin Mocha.xccolortheme";
    IDEKeyBindingCurrentPreferenceSet = "Zed.idekeybindings";

    DVTTextEditorTrimWhitespaceOnlyLines = true;
    DVTTextEditorWrapsLines = false;
    DVTTextShowMinimap = false;
    DVTTextHighlightCurrentLine = true;
  };

  system.activationScripts.preActivation.text = ''
    if [ -d ${developerDir} ]; then
      if [ "$(/usr/bin/xcode-select -p 2>/dev/null)" != ${developerDir} ]; then
        echo "Selecting Xcode as the active developer directory..."
        /usr/bin/xcode-select -s ${developerDir} || exit 1
      fi
      if ! ${xcodebuild} -license check >/dev/null 2>&1; then
        echo "Accepting the Xcode license..."
        ${xcodebuild} -license accept || exit 1
      fi
      if ! ${xcodebuild} -checkFirstLaunchStatus >/dev/null 2>&1; then
        echo "Installing Xcode first-launch components..."
        ${xcodebuild} -runFirstLaunch || exit 1
      fi
    else
      echo "warning: ${developerDir} is missing; skipping Xcode setup" >&2
    fi
  '';

  system.activationScripts.postActivation.text = ''
    if [ -d ${developerDir} ]; then
      ios_runtimes=$(${asUser} env ${simctl} runtime list -j) || exit 1
      if ! printf '%s' "$ios_runtimes" | ${lib.getExe pkgs.jq} -e 'any(.[]; .platformIdentifier == "com.apple.platform.iphonesimulator")' >/dev/null; then
        echo "Downloading the iOS simulator platform..."
        ${asUser} env ${xcodebuild} -downloadPlatform iOS || exit 1
      fi
    fi
  '';
}
