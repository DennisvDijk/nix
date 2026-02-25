{ config, lib, username ? "dennisvandijk", homeDirectory ? "/Users/dennisvandijk", ... }:

{
  options.my.identity = {
    username = lib.mkOption {
      type = lib.types.str;
      default = username;
      description = "System username";
    };

    homeDirectory = lib.mkOption {
      type = lib.types.str;
      default = homeDirectory;
      description = "User's home directory";
    };

    fullName = lib.mkOption {
      type = lib.types.str;
      default = "Dennis van Dijk";
      description = "User's full name";
    };

    email = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        personal = "dennis@thenextgen.nl";
        git = "dennis@thenextgen.nl";
      };
      description = "Email addresses for different purposes";
    };
  };

  config = {
    my.user = {
      fullName = config.my.identity.fullName;
      firstName = "Dennis";
      lastName = "van Dijk";
      email = config.my.identity.email;
      username = config.my.identity.username;
      homeDirectory = config.my.identity.homeDirectory;
    };
  };
}
