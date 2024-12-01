{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  services.gitea = {
    enable = true;
    package = pkgs.gitea;
    user = "gitea";
    stateDir = "/data/gitea/state";
    repositoryRoot = "/data/gitea";
    lfs = {
      enable = true;
      contentDir = "/data/gitea/lfs";
    };
    settings = {
      server.LANDING_PAGE = "explore";
      session.COOKIE_SECURE = true;
      #service.DISABLE_REGISTRATION = true;
      server.ROOT_URL = "https://git.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
      server.DOMAIN = "git.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
      server.HTTP_PORT = 3001;
      actions.ENABLED = true;
      log.LEVEL = "Warn";
      api.ENABLE_SWAGGER = false;
      other.SHOW_FOOTER_VERSION = false;
      other.SHOW_FOOTER_TEMPLATE_LOAD_TIME = false;
      mailer = {
        ENABLED = true;
        FROM = "";
        PROTOCOL = "STARTTLS";
        SMTP_ADDR = "";
        SMTP_PORT = 587;
        USER = "";
        PASSWD = "";
      };
    };
    database = {
      type = "postgres";
      user = "gitea";
      name = "gitea";
    };
  };

  services.gitea-actions-runner = {
    instances."runner" = {
      #enable = true;
      enable = false;
      name = "runner";
      token = "${lib.strings.removeSuffix "\n" (
        builtins.readFile config.age.secrets.gitea-actions.path
      )}";
      url = "https://git.${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
      labels = [ "native:host" ];
    };
  };

}
