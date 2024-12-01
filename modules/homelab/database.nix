{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  services.postgresql = {
    enable = true;
    dataDir = "/data/postgresql/";
    ensureDatabases = [
      "nextcloud"
      "gitlab"
      "secvault"
    ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
      {
        name = "gitlab";
        ensureDBOwnership = true;
      }
      {
        name = "secvault";
        ensureDBOwnership = true;
      }
    ];
  };

}
