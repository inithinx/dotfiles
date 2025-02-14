{inputs, ...}: {
  # You can import other NixOS modules here
  imports = [
    inputs.self.nixosModules.base
    inputs.self.nixosModules.editor

    ./disko.nix
  ];

  # Sets up sane defaults.
  base = {
    enable = true;
    hostname = "pathfinder";
    username = "nithin";
    hashedPassword = "$6$rounds=100000$4VD6TDybh7XM/EUo$EzFPmJENWRfFIqSkc7ZhMuwKZo5XFE0jeHE6hD6qiVvwM6aoGUv3tnDT0PPbDhT8yn/fyHYiP..UeGnSA/Q3r0";
  };
  editor = {
    enable = true;
  };
  virtualisation.virtualbox.guest.enable = true;
}
