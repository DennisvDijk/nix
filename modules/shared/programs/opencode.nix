{ config, pkgs, lib, ... }:

# =============================================================================
# OpenCode Configuration Module
# =============================================================================
#
# Declaratively manages the full OpenCode setup via Home Manager symlinks.
#
# Source of truth:  <nix-repo>/config/opencode/
# Target:           ~/.config/opencode/
#
# Managed paths:
#   opencode.json        → config file
#   AGENTS.md            → global instructions
#   skills/*/SKILL.md    → reusable skill definitions
#   agents/*.md          → custom agent definitions
#   rules/               → always-loaded instruction files
#   commands/            → custom slash commands
#
# Every machine running `home-manager switch` gets an identical setup.
# =============================================================================

let
  # Relative path from this module to the config directory in the repo root.
  # Adjust if you move this module to a different depth.
  opencodeConfigDir = ../../../config/opencode;
  configContents = builtins.readDir opencodeConfigDir;

  # ---------------------------------------------------------------------------
  # Helper: generate home.file entries for skills (directory-per-skill)
  # Expected layout: config/opencode/skills/<name>/SKILL.md
  # ---------------------------------------------------------------------------
  skillEntries =
    if configContents ? "skills" && configContents.skills == "directory" then
      let
        entries = builtins.readDir "${opencodeConfigDir}/skills";
        dirs = lib.filterAttrs (_: t: t == "directory") entries;
      in
      lib.mapAttrs'
        (name: _: lib.nameValuePair
          ".config/opencode/skills/${name}"
          { 
            source = "${opencodeConfigDir}/skills/${name}/SKILL.md"; 
            recursive = true;         
          })
        dirs
    else { };

  # ---------------------------------------------------------------------------
  # Helper: generate home.file entries for agents (flat markdown files)
  # Expected layout: config/opencode/agents/<name>.md
  # ---------------------------------------------------------------------------
  agentEntries =
    if configContents ? "agents" && configContents.agents == "directory" then
      let
        entries = builtins.readDir "${opencodeConfigDir}/agents";
        mdFiles = lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".md" n) entries;
      in
      lib.mapAttrs'
        (name: _: lib.nameValuePair
          ".config/opencode/agents/${name}"
          { source = "${opencodeConfigDir}/agents/${name}"; })
        mdFiles
    else { };

  # ---------------------------------------------------------------------------
  # Helper: recursive directory symlink (for rules/ and commands/)
  # ---------------------------------------------------------------------------
  recursiveDirEntry = subdir:
    if configContents ? "${subdir}" && configContents.${subdir} == "directory" then {
      ".config/opencode/${subdir}" = {
        source = "${opencodeConfigDir}/${subdir}";
        recursive = true;
      };
    }
    else { };

  # ---------------------------------------------------------------------------
  # Core config files
  # ---------------------------------------------------------------------------
  coreEntries = {
    ".config/opencode/opencode.json" = {
      source = "${opencodeConfigDir}/opencode.json";
    };
  }
  // lib.optionalAttrs
    (configContents ? "AGENTS.md" && configContents."AGENTS.md" == "regular")
    {
      ".config/opencode/AGENTS.md" = {
        source = "${opencodeConfigDir}/AGENTS.md";
      };
    };

in
{
  home.file =
    coreEntries
    // skillEntries
    // agentEntries
    // recursiveDirEntry "rules"
    // recursiveDirEntry "commands";
}
