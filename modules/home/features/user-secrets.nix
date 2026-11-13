# modules/home/features/user-secrets.nix
# User identity and personal information from SOPS secrets

{
  lib,
  username ? "",
  homeDirectory ? "",
  ...
}:

let
  inherit (lib) mkOption mkDefault types;
in
{
  options.my.user = {
    # User Identity
    fullName = mkOption {
      type = types.str;
      default = "User";
      description = "User's full name";
    };

    firstName = mkOption {
      type = types.str;
      default = "User";
      description = "User's first name";
    };

    lastName = mkOption {
      type = types.str;
      default = "";
      description = "User's last name";
    };

    # Email addresses
    email = {
      personal = mkOption {
        type = types.str;
        default = "";
        description = "Personal email address";
      };

      work = mkOption {
        type = types.str;
        default = "";
        description = "Work email address";
      };

      git = mkOption {
        type = types.str;
        default = "";
        description = "Email address for Git commits";
      };
    };

    # System info
    username = mkOption {
      type = types.str;
      default = "";
      description = "System username";
    };

    homeDirectory = mkOption {
      type = types.str;
      default = "";
      description = "Home directory path";
    };
  };

  # Defaults for Dennis's machines. A host overrides any field at normal
  # priority (the template host does this; work overrides the git email).
  config.my.user = {
    fullName = mkDefault "Dennis van Dijk";
    firstName = mkDefault "Dennis";
    lastName = mkDefault "van Dijk";
    email.personal = mkDefault "dennis@thenextgen.nl";
    email.git = mkDefault "dennis@thenextgen.nl";
    username = mkDefault username;
    homeDirectory = mkDefault homeDirectory;
  };
}
