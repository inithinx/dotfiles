{pkgs, lib, nixvim, ...}: {
    programs.nixvim = {
      enable = true;
	    globals.mapleader = " ";
      opts = {
        shiftwidth = 2;
        number = true;
        relativenumber = true;
	      foldenable = false;
	      expandtab = true;
	      tabstop = 2;
	      softtabstop =2;
      };
      keymaps = [
	      { action = "<cmd>Neotree toggle left<CR>"; key = "<leader>f"; }
	      { action = "<cmd>vim.lsp.buf.definition<CR>"; key = "<leader>gd"; }
	      { action = "<cmd>vim.lsp.buf.references<CR>"; key = "<leader>gr"; }
	      { action = "<cmd>vim.lsp.buf.code_action<CR>"; key = "<leader>ca"; }
	    ];
      plugins.alpha = {
        enable = true;
        iconsEnabled = true;
        theme = "dashboard";
      };
      #colorschemes.catppuccin.enable = true;
      plugins.lualine = {
        enable = true;
	      iconsEnabled = false;
      };
      plugins.treesitter = {
        enable = true;
        folding = true;
        settings.indent.enable = true;
      };
      plugins.undotree.enable = true;
      plugins.telescope = {
        enable = true;
        extensions.ui-select.enable = true;
        keymaps = {
          "<leader>tf" = {
            action = "find_files";
          };
          "<leader>tg" = {
            action = "live_grep";
          };
        };
      };
      plugins.cmp = {
        enable = true;
        autoEnableSources = true;
      };
      plugins.lsp = {
        enable = true;
        servers = {
          lua-ls = {
            enable = true;
            settings.telemetry.enable = false;
          };
          #golangci-lint-ls.enable = true;
          #bashls.enable = true;
          #sqls.enable = true;
        };
      };
      plugins.none-ls = {
        enable = true;
        enableLspFormat = true; 
      };
	    plugins.lsp-format.enable = true;
        plugins.neo-tree = {
          enable = true;
          enableGitStatus = true;
        };
      };
}
