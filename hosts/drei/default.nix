{ config, lib, pkgs, modulesPath, ... }: {
  imports = [
      ./configuration.nix
      ./disko.nix
      ./system.nix
      #./blocky.nix
      #./coturn.nix
      #./database.nix
      #./gitea.nix
      ./impermanence.nix
      #./nextcloud.nix
      #./media.nix
      #./nginx.nix
      #./minecraft.nix
      #./samba.nix
      #./vaultwarden.nix
  ];
}
