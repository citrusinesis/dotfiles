{ ... }:

let
  modelLimit = {
    context = 272000;
    output = 128000;
  };

  modelModalities = {
    input = [
      "text"
      "image"
    ];
    output = [ "text" ];
  };

  mkOpenAIModel = name: effort: summary: {
    inherit name;
    limit = modelLimit;
    modalities = modelModalities;
    options = {
      reasoningEffort = effort;
      reasoningSummary = summary;
      textVerbosity = "medium";
      include = [ "reasoning.encrypted_content" ];
      store = false;
    };
  };

  geminiLimit = {
    context = 1048576;
    output = 65535;
  };

  geminiModalities = {
    input = [
      "text"
      "image"
      "pdf"
    ];
    output = [ "text" ];
  };
in
{
  xdg.configFile = {
    "opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";

      theme = "catppuccin";

      plugin = [
        "oh-my-opencode"
        "opencode-antigravity-auth@1.1.2"
        "opencode-openai-codex-auth@4.2.0"
      ];

      provider = {
        openai = {
          options = {
            reasoningEffort = "medium";
            reasoningSummary = "auto";
            textVerbosity = "medium";
            include = [ "reasoning.encrypted_content" ];
            store = false;
          };
          models = {
            "gpt-5.2-none" = mkOpenAIModel "GPT 5.2 None (OAuth)" "none" "auto";
            "gpt-5.2-low" = mkOpenAIModel "GPT 5.2 Low (OAuth)" "low" "auto";
            "gpt-5.2-medium" = mkOpenAIModel "GPT 5.2 Medium (OAuth)" "medium" "auto";
            "gpt-5.2-high" = mkOpenAIModel "GPT 5.2 High (OAuth)" "high" "detailed";
            "gpt-5.2-xhigh" = mkOpenAIModel "GPT 5.2 Extra High (OAuth)" "xhigh" "detailed";
            "gpt-5.2-codex-low" = mkOpenAIModel "GPT 5.2 Codex Low (OAuth)" "low" "auto";
            "gpt-5.2-codex-medium" = mkOpenAIModel "GPT 5.2 Codex Medium (OAuth)" "medium" "auto";
            "gpt-5.2-codex-high" = mkOpenAIModel "GPT 5.2 Codex High (OAuth)" "high" "detailed";
            "gpt-5.2-codex-xhigh" = mkOpenAIModel "GPT 5.2 Codex Extra High (OAuth)" "xhigh" "detailed";
            "gpt-5.1-none" = mkOpenAIModel "GPT 5.1 None (OAuth)" "none" "auto";
            "gpt-5.1-low" = mkOpenAIModel "GPT 5.1 Low (OAuth)" "low" "auto";
            "gpt-5.1-medium" = mkOpenAIModel "GPT 5.1 Medium (OAuth)" "medium" "auto";
            "gpt-5.1-high" = mkOpenAIModel "GPT 5.1 High (OAuth)" "high" "detailed";
          };
        };

        google = {
          models = {
            "gemini-3-pro-low" = {
              name = "Gemini 3 Pro Low (Antigravity)";
              limit = geminiLimit;
              modalities = geminiModalities;
            };
            "gemini-3-pro-medium" = {
              name = "Gemini 3 Pro Medium (Antigravity)";
              limit = geminiLimit;
              modalities = geminiModalities;
            };
            "gemini-3-pro-high" = {
              name = "Gemini 3 Pro High (Antigravity)";
              limit = geminiLimit;
              modalities = geminiModalities;
            };
            "gemini-3-flash" = {
              name = "Gemini 3 Flash (Antigravity)";
              limit = geminiLimit // {
                output = 65536;
              };
              modalities = geminiModalities;
            };
            "gemini-3-flash-lite" = {
              name = "Gemini 3 Flash Lite (Antigravity)";
              limit = geminiLimit // {
                output = 65536;
              };
              modalities = geminiModalities;
            };
          };
        };
      };
    };

    "opencode/oh-my-opencode.json".text = builtins.toJSON {
      "$schema" =
        "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json";

      google_auth = false;

      # Sisyphus orchestrator settings
      sisyphus_agent = {
        disabled = false;
        default_builder_enabled = false;
        planner_enabled = true;
        replace_plan = true;
      };

      agents = {
        # Main orchestrator - Claude Opus 4.5 (max20 mode)
        Sisyphus = {
          model = "anthropic/claude-opus-4-5";
        };

        # Oracle for architecture/debugging - GPT 5.2
        oracle = {
          model = "openai/gpt-5.2-medium";
        };

        # Librarian for docs/codebase research - Claude Sonnet 4.5
        librarian = {
          model = "anthropic/claude-sonnet-4-5";
        };

        # Frontend specialist - Gemini 3 Pro
        frontend-ui-ux-engineer = {
          model = "google/gemini-3-pro-high";
        };

        # Document writing - Gemini Flash
        document-writer = {
          model = "google/gemini-3-flash";
        };

        # Multimodal analysis - Gemini Flash
        multimodal-looker = {
          model = "google/gemini-3-flash";
        };
      };

      # Experimental features
      experimental = {
        aggressive_truncation = true;
        auto_resume = true;
      };
    };
  };
}
