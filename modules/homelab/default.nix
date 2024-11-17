{ config, lib, pkgs, modulesPath, ... }: {
  imports = [
      ./blocky.nix
      #./coturn.nix
      ./database.nix
      #./gitea.nix
      #./nextcloud.nix
      #./media.nix
      #./nginx.nix
      #./minecraft.nix
  ];
}
