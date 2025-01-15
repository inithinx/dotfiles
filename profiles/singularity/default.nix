{inputs, ...}: {
  # You can import other NixOS modules here
  imports = [
    inputs.self.nixosModules.base
    inputs.self.nixosModules.editor
    inputs.self.nixosModules.k3svm
    inputs.self.nixosModules.mediastack
    inputs.self.nixosModules.proxy
    #inputs.self.nixosModules.selfhosted

    ./disko.nix
  ];

  # Sets up sane defaults.
  base = {
    enable = true;
    hostname = "singularity";
    username = "nithin";
    hashedPassword = "$6$D.zKBWhRY7l3Y/DB$Yivmnrz2Tq4sqiNZZQcT7j36/dWyArQP0F7fbdok1X36dPo0w.H/qILyH17Qobc3tEzeEJ0ayzIw02vayCsOm.";
  };
  # Sets up neovim with nixvim.
  editor = {
    enable = true;
  };

  # K3sVM
  k3svm = {
    enable = false;
    numberOfVMs = 3;
    cpusPerVM = 4;
    memoryPerVM = 4096;
    storagePerVM = 25600;
    bridgehosts = ["enp7s0"];
  };

  # Set up the arr* stack.
  mediastack.enable = false;
  proxy.enable = false;

  # Set up selfhosted stack, which is maddy, postgres and nextcloud.
  #selfhosted = {
  #  enable = true;
  #  domain = config.age.secrets.domain.path;
  #  mail.brevo = {
  #    user = config.age.secrets.brevo-user.path;
  #    passwordFile = config.age.secrets.brevo-password.path;
  #  };
  #};
}
