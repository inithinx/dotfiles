{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.wordpress = {
    webserver = "nginx";
    sites."nanosec.dev" = {
      virtualHost = {
        onlySSL = true;
        forceSSL = true;
        useACMEHost = "${lib.strings.removeSuffix "\n" (builtins.readFile config.age.secrets.domain.path)}";
      };
    };
  };

  #environment.persistence."/persist" = {
  # hideMounts = true;
  #  directories = [
  #    {
  #      directory = "/var/lib/wordpress";
  #      #user = "wordpress";
  #    }
  #    {
  #      directory = "/var/lib/mysql";
  #      user = "mysql";
  #      group = "mysql";
  #    }
  #  ];
  #};

}
