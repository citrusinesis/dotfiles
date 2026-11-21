{ lib }:
let
  functionKey = code: builtins.fromJSON ''"\u${code}"'';
  up = functionKey "F700";
  down = functionKey "F701";
  f12 = functionKey "F70F";

  mainMenu = parent: {
    group = "${parent} Menu";
    groupId = "Xcode.IDEKit.MenuDefinition.Main";
    inherit parent;
  };
  sourceEditorMenu = parent: {
    group = "Editor Menu for Source Code";
    groupId = "Xcode.IDEPegasusSourceEditor.MenuDefinition.Editor";
    inherit parent;
  };

  bind =
    {
      id,
      title,
      action,
      menu,
      shortcut,
    }:
    {
      Action = action;
      Alternate = "NO";
      CommandID = id;
      Group = menu.group;
      GroupID = menu.groupId;
      GroupedAlternate = "NO";
      "Keyboard Shortcut" = shortcut;
      Navigation = "NO";
      "Parent Title" = menu.parent;
      Title = title;
    };

  menuBindings = map bind [
    {
      id = "Xcode.IDEKit.CmdDefinition.OpenQuickly";
      title = "Open Quickly…";
      action = "openQuickly:";
      menu = mainMenu "File";
      shortcut = "@p";
    }
    {
      id = "Xcode.IDEKit.CmdDefinition.Print";
      title = "Print…";
      action = "printDocument:";
      menu = mainMenu "File";
      shortcut = "";
    }
    {
      id = "Xcode.IDEKit.CmdDefinition.ShowDocumentItemsMenu";
      title = "Show Document Items";
      action = "topLevelEditorContext_showDocumentItemsMenu:";
      menu = mainMenu "Editor";
      shortcut = "$@o";
    }
    {
      id = "Xcode.IDEKit.CmdDefinition.SelectNextOccurrence";
      title = "Select Next Occurrence";
      action = "selectNextOccurrence:";
      menu = mainMenu "Find";
      shortcut = "@d";
    }
    {
      id = "Xcode.IDEKit.CmdDefinition.UseSelectionForReplace";
      title = "Use Selection for Replace";
      action = "useSelectionForReplace:";
      menu = mainMenu "Find";
      shortcut = "";
    }
    {
      id = "Xcode.IDEKit.CmdDefinition.Duplicate";
      title = "Duplicate";
      action = "duplicate:";
      menu = mainMenu "Edit";
      shortcut = "~\$${down}";
    }
    {
      id = "Xcode.IDEPegasusSourceEditor.CmdDefinition.MoveLineUp";
      title = "Move Line Up";
      action = "moveCurrentLineUp:";
      menu = sourceEditorMenu "Structure";
      shortcut = "~${up}";
    }
    {
      id = "Xcode.IDEPegasusSourceEditor.CmdDefinition.MoveLineDown";
      title = "Move Line Down";
      action = "moveCurrentLineDown:";
      menu = sourceEditorMenu "Structure";
      shortcut = "~${down}";
    }
    {
      id = "Xcode.IDEPegasusSourceEditor.CmdDefinition.Fold";
      title = "Fold";
      action = "fold:";
      menu = sourceEditorMenu "Code Folding";
      shortcut = "~@[";
    }
    {
      id = "Xcode.IDEPegasusSourceEditor.CmdDefinition.Unfold";
      title = "Unfold";
      action = "unfold:";
      menu = sourceEditorMenu "Code Folding";
      shortcut = "~@]";
    }
    {
      id = "Xcode.IDEKit.CmdDefinition.JumpToDefinition";
      title = "Jump to Definition";
      action = "editorContext_jumpToDefinition:";
      menu = mainMenu "Navigate";
      shortcut = f12;
    }
    {
      id = "Xcode.IDEKit.CmdDefinition.GoBack";
      title = "Show Previous Location in History";
      action = "topLevelEditorContext_goBackInHistoryByCommand:";
      menu = mainMenu "Navigate";
      shortcut = "^-";
    }
    {
      id = "Xcode.IDEKit.CmdDefinition.GoForward";
      title = "Show Next Location in History";
      action = "topLevelEditorContext_goForwardInHistoryByCommand:";
      menu = mainMenu "Navigate";
      shortcut = "^$-";
    }
    {
      id = "Xcode.IDEKit.CmdDefinition.RevealInProjectNavigator";
      title = "Reveal in Project Navigator";
      action = "revealInProjectNavigator:";
      menu = mainMenu "Navigate";
      shortcut = "$@e";
    }
    {
      id = "Xcode.IDESourceControlUI.CmdDefinition.RevealInChangesNavigator";
      title = "Reveal in Changes Navigator";
      action = "revealInChangesNavigator:";
      menu = mainMenu "Navigate";
      shortcut = "";
    }
    {
      id = "Xcode.IDEKit.CmdDefinition.MoveFocusToEditor";
      title = "Move Focus to Editor Pane…";
      action = "moveFocusToEditor:";
      menu = mainMenu "Navigate";
      shortcut = "";
    }
    {
      id = "Xcode.IDEKit.CmdDefinition.NavigatorsIssues";
      title = "Issues";
      action = "toggleIssuesNavigator:";
      menu = mainMenu "Navigators";
      shortcut = "$@m";
    }
    {
      id = "Xcode.IDEKit.CmdDefinition.DebuggerToggleVisibility";
      title = "Show Debug Area";
      action = "toggleDebuggerVisibility:";
      menu = mainMenu "Debug Area";
      shortcut = "@j";
    }
  ];
in
lib.generators.toPlist { escape = true; } {
  "Menu Key Bindings" = {
    "Key Bindings" = menuBindings;
    Version = 3;
  };
  "Text Key Bindings" = {
    "Key Bindings" = { };
    Version = 3;
  };
}
