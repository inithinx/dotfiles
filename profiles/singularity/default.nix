{inputs, ...}: {
  imports = [
    inputs.self.nixosModules.base
    inputs.self.nixosModules.editor
    inputs.self.nixosModules.k3svm
    inputs.self.nixosModules.mediastack
    inputs.self.nixosModules.proxy
    #inputs.self.nixosModules.selfhosted
    ./disko.nix
  ];

  # Base configuration options
  base = {
    enable = true;
    hostname = "singularity";
    username = "nithin";
    hashedPassword = "$6$D.zKBWhRY7l3Y/DB$Yivmnrz2Tq4sqiNZZQcT7j36/dWyArQP0F7fbdok1X36dPo0w.H/qILyH17Qobc3tEzeEJ0ayzIw02vayCsOm.";
  };

  # Editor (neovim) configuration
  editor = {
    enable = true;
  };

  # K3s Virtual Machine cluster configuration
  k3svm = {
    enable = false;
    # Network configuration
    bridgehosts = ["enp7s0"];

    # VM resource configuration
    numberOfVMs = 3; # Default: 3
    cpusPerVM = 4; # Default: 4
    memoryPerVM = 4096; # Default: 4096 MB
    storagePerVM = 25600; # Default: 25600 MB

    # Tailscale configuration
    tailscale = {
      enable = true; # Enable Tailscale auto-authentication
      authkey = "tskey-auth-kYgJku5tPT11CNTRL-LjxeZzsjWehvGmG5hsMgehHugWUGtqhK"; # Your Tailscale auth key
      domain = "ruffe-tetra.ts.net";
    };
    domain = "nanosec.dev";
  };

  # Media stack configuration (arr* applications)
  mediastack = {
    enable = false;
  };

  # Proxy configuration
  proxy = {
    enable = false;
  };

  # Selfhosted stack configuration (commented out in original)
  #selfhosted = {
  #  enable = false;
  #  domain = config.age.secrets.domain.path;
  #  mail.brevo = {
  #    user = config.age.secrets.brevo-user.path;
  #    passwordFile = config.age.secrets.brevo-password.path;
  #  };
  #};
}
