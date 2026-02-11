# modules/home/features/user-secrets.nix
# User identity and personal information from SOPS secrets

{ config, lib, ... }:

let
  inherit (lib) mkOption types;
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
}
