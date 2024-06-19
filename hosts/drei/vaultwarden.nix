{ config, lib, pkgs, modulesPath, ... }: {

  services.vaultwarden = {
    enable = true;
    package = pkgs.vaultwarden-postgresql;
    dbBackend = "postgresql";
    config = {
      ADMIN_TOKEN = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.vw-token.path)}";
      SIGNUPS_VERIFY = true;
      DOMAIN = "https://vault.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
      DATABASE_URL = "postgres://vaultwarden@/vaultwarden?host=/run/postgresql&sslmode=disable";
      SMTP_HOST = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.smtp-host.path)}";
      SMTP_FROM = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.smtp-from.path)}";
      SMTP_FROM_NAME = "Vaultwarden";
      SMTP_PORT = 587;
      SMTP_SSL = true;
      SMTP_USERNAME = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.smtp-user.path)}";
      SMTP_PASSWORD = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.smtp-pass.path)}";
      SMTP_TIMEOUT = 15;
      ROCKET_PORT = 8812;
      SIGNUPS_ALLOWED = false;
      INVITATIONS_ALLOWED = false;
      DATA_FOLDER = "/data/vaultwarden";
    };
  };
}
