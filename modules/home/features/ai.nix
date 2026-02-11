# modules/home/features/ai.nix
# AI/ML development tools and assistants

{ config, pkgs, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.my.features.ai;
in
{
  options.my.features.ai = {
    enable = mkEnableOption "AI/ML development tools";
    
    codingAssistants.enable = mkEnableOption "AI coding assistants" // { default = true; };
    llmTools.enable = mkEnableOption "LLM CLI tools" // { default = true; };
    localLLMs.enable = mkEnableOption "Local LLM tools" // { default = true; };
  };

  config = mkIf cfg.enable {
    home.packages = mkMerge [
      (mkIf cfg.codingAssistants.enable (with pkgs; [
        # AI coding assistants from Nix (not Homebrew!)
        # claude-code         # Claude Code CLI - temporarily disabled due to npm registry connection issues
        codex               # OpenAI Codex CLI
        aider-chat          # AI pair programming
        gemini-cli          # Google Gemini CLI
        
        # OpenCode (your own tool!)
        # Note: If it's in your custom tap, better to use Nix directly
        # Check if opencode is available in nixpkgs or build from source
        goose               # Block's AI coding agent
      ]))
      
      (mkIf cfg.llmTools.enable (with pkgs; [
        # LLM CLI tools
        llm                 # Simon Willison's LLM tool
        aichat              # All-in-one LLM CLI
        
        # API clients
        tgpt                # AI chat in terminal
        
        # Ollama is usually better from Homebrew for GPU support
        # But we can include the CLI tools
      ]))
      
      (mkIf cfg.localLLMs.enable (with pkgs; [
        # Local LLM tooling
        llama-cpp           # LLaMA C++ inference
        
        # Note: LM Studio and Ollama are better from Homebrew
        # because they need GUI and macOS frameworks
      ]))
      
      (with pkgs; [
        # Shared tools
        oterm               # Terminal UI for Ollama
        
        # Python ML basics
        # These are heavy - uncomment if needed
        # python3Packages.openai
        # python3Packages.anthropic
      ])
    ];

    # AI tool configurations
    home.file."${config.home.homeDirectory}/.config/opencode/opencode.json" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.config/nix/modules/config/opencode/opencode.json";
    };

    # Shell aliases for AI tools
    programs.zsh.shellAliases = {
      # Claude Code - temporarily disabled
      # cc = "claude-code";
      
      # Aider
      ai = "aider";
      
      # Ollama shortcuts
      oll = "ollama";
      olll = "ollama list";
      olr = "ollama run";
      
      # LLM tool
      llm = "llm";
    };

    programs.zsh.initExtra = ''
      # Claude Code completions (if available)
      if command -v claude &>/dev/null; then
        eval "$(claude --completion zsh 2>/dev/null || true)"
      fi
      
      # Ollama shortcuts
      ollama-serve() {
        if ! pgrep -x "ollama" > /dev/null; then
          echo "Starting Ollama server..."
          open -a Ollama
        fi
      }
    '';
  };
}
