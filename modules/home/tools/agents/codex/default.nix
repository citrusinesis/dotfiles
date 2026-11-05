{ pkgs, ... }:
{
  # Codex runs only as a worker under the Claude orchestrator: it gets the shared rules, and the task prompt carries the worker contract.
  programs.codex = {
    enable = true;
    package = pkgs.llm-agents.codex;
    settings = {
      model = "gpt-6.1-sol";
      model_reasoning_effort = "medium";
      service_tier = "default";
      approval_policy = "never";
      approvals_reviewer = "user";
      sandbox_mode = "danger-full-access";
      personality = "pragmatic";
    };
    context = ''
      # Codex instructions

      Read and follow these instruction files as applicable. System, developer and task prompt instructions take precedence.

      The instruction files live in `${../rules}`.

      - Before writing or reviewing code: read `code-organization.md`, `code-quality.md`, `comments.md`, `error-escape.md` and `line-breaks.md`.
      - When provisioning or changing development tools: read `dev-environment.md`.
      - Before committing or pushing: read `git.md`.
    '';
    rules.base = ''
      prefix_rule(pattern=["nix", "develop"], decision="allow")
      prefix_rule(pattern=["git", "push"], decision="forbidden")
    '';
  };
}
