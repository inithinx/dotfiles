{
  config,
  lib,
  inputs,
  ...
}:
with lib; {
  imports = [inputs.nixvim.nixosModules.nixvim];

  options.editor = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the custom Nixvim editor configuration.";
    };
  };

  config = mkIf config.editor.enable {
    programs.nixvim = {
      enable = true;
      performance.combinePlugins.enable = true;
      # Theme
      colorschemes.catppuccin.enable = true;

      # Settings
      opts = {
        expandtab = true;
        shiftwidth = 2;
        smartindent = true;
        tabstop = 2;
        number = true;
        clipboard = "unnamedplus";
        relativenumber = true;
        cursorline = true;
      };

      # Keymaps
      globals = {
        mapleader = " ";
      };

      plugins = {
        # UI Enhancements
        web-devicons.enable = true;
        lualine.enable = true;
        bufferline.enable = true;
        treesitter.enable = true;
        which-key = {
          enable = true;
        };
        noice = {
          enable = true;
          settings.presets = {
            bottom_search = true;
            command_palette = true;
            long_message_to_split = true;
          };
        };
        telescope = {
          enable = true;
          keymaps = {
            "<leader>ff" = {
              options.desc = "file finder";
              action = "find_files";
            };
            "<leader>fg" = {
              options.desc = "find via grep";
              action = "live_grep";
            };
          };
          extensions = {
            file-browser.enable = true;
          };
        };

        # Development Tools
        lsp = {
          enable = true;
          servers = {
            gopls.enable = true;
            marksman.enable = true;
            nil_ls.enable = true;
            rust_analyzer = {
              enable = true;
              installCargo = false;
              installRustc = false;
            };
          };
        };
      };
    };
  };
}
