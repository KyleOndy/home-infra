{ pkgs, ... }:

# I MAKE ZERO STATMENTS AS TO THE SECURITY OR CORRECTNESS OF THIS ALL

{
  users.users = {
    concourse = {
      isSystemUser = true;
    };
  };
  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_13;
      ensureDatabases = [ "atc" ];
      ensureUsers = [
        {
          name = "concourse";
          ensurePermissions = {
            "DATABASE atc" = "ALL PRIVILEGES";
          };
      }
    ];
    };
    postgresqlBackup = {
      backupAll = true;
    };
  };
}
