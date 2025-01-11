return {
  "VonHeikemen/lsp-zero.nvim",
  branch = "v2.x",
  dependencies = {
    -- LSP Support
    {
      "neovim/nvim-lspconfig",
      config = function()
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        local lspconfig = require("lspconfig")

        local function organize_imports()
          local parans = {
            command = "_typescript.organizeImports",
            args = { vim.api.nvim_buf_get_name(0) },
          }
          vim.lsp.buf.execute_command(parans)
        end

        lspconfig.html.setup({
          capabilities = capabilities,
          -- filetypes = { "html", "typescriptreact", "javascriptreact" },
        })
        lspconfig.lua_ls.setup({
          capabilities = capabilities,
        })
        -- lspconfig.cssls.setup({
        --   capabilities = capabilities,
        -- })
        lspconfig.tailwindcss.setup({
          capabilities = capabilities,
        })

        lspconfig.gopls.setup({
          capabilities = capabilities,
          cmd = { "gopls" },
          filetypes = { "go", "gomod", "gowork", "gotmpl", "gotexttmpl" },
          root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
          settings = {
            gopls = {
              completeUnimported = true,
              semanticTokens = true,
              analyses = {
                unusedparams = true, -- Enable unused parameter diagnostics
                shadow = true,       -- Detect shadowed variables
              },
              staticcheck = true,    -- Enable more static analysis checks
            },
          },
        })

        -- lspconfig.intelephense.setup({
        --   capabilities = capabilities,
        --   filetypes = { "php", "blade" },
        --   root_dir = lspconfig.util.root_pattern("composer.json", ".git"),
        --   cmd = { "intelephense", "--stdio" },
        -- })

        local home = os.getenv("USERPROFILE")
        local jdtls_dir = home .. "/AppData/Local/nvim-data/mason/packages/jdtls"

        lspconfig.jdtls.setup({
          cmd = {
            'java',
            '-Declipse.application=org.eclipse.jdt.ls.core.id1',
            '-Dosgi.bundles.defaultStartLevel=4',
            '-Declipse.product=org.eclipse.jdt.ls.core.product',
            '-Dlog.protocol=true',
            '-Dlog.level=ALL',
            '-Xms1g',
            '--add-modules=ALL-SYSTEM',
            '--add-opens', 'java.base/java.util=ALL-UNNAMED',
            '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
            '-jar', vim.fn.glob(jdtls_dir .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
            '-configuration', jdtls_dir .. '/config_win',
            '-data', home .. '/.cache/jdtls-workspace',
            '-javaagent:', jdtls_dir .. '/lombok.jar',
            -- '-Xbootclasspath/a:', jdtls_dir .. '/lombok.jar',
          },
          capabilities = capabilities,
        })
      end,
    }, -- Required
    {  -- Optional
      "williamboman/mason.nvim",
      config = function()
        require("mason").setup()
      end,
    },
    {
      "williamboman/mason-lspconfig.nvim",
      opts = {
        auto_install = true,
      },
    }, -- Optional
    { "mfussenegger/nvim-jdtls" },
    -- Autocompletion
    { "hrsh7th/nvim-cmp" },     -- Required
    { "hrsh7th/cmp-nvim-lsp" }, -- Required
    { "L3MON4D3/LuaSnip" },     -- Required
    { "rafamadriz/friendly-snippets" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-cmdline" },
    { "saadparwaiz1/cmp_luasnip" },
    { "nvim-telescope/telescope.nvim" },
  },
  config = function()
    local lsp = require("lsp-zero")

    lsp.on_attach(function(client, bufnr)
      local opts = { buffer = bufnr, remap = false }

      vim.keymap.set("n", "gr", function()
        require('telescope.builtin').lsp_references()
      end, opts, { desc = "LSP Goto Reference (Telescope)" })

      vim.keymap.set("n", "gd", function()
        vim.lsp.buf.definition()
      end, opts, { desc = "LSP Goto Definition" })

      vim.keymap.set("n", "Y", function()
        vim.lsp.buf.hover()
      end, opts, { desc = "LSP Hover" })

      vim.keymap.set("n", "<leader>vws", function()
        vim.lsp.buf.workspace_symbol()
      end, opts, { desc = "LSP Workspace Symbol" })

      vim.keymap.set("n", "<leader>vd", function()
        require('telescope.builtin').diagnostics()
      end, opts, { desc = "LSP Show Diagnostics (Telescope)" })

      vim.keymap.set("n", "[d", function()
        vim.diagnostic.goto_next()
      end, opts, { desc = "Next Diagnostic" })

      vim.keymap.set("n", "]d", function()
        vim.diagnostic.goto_prev()
      end, opts, { desc = "Previous Diagnostic" })

      vim.keymap.set("n", "<leader>vca", function()
        vim.lsp.buf.code_action()
      end, opts, { desc = "LSP Code Action" })

      vim.keymap.set("n", "<leader>vrr", function()
        require('telescope.builtin').lsp_references()
      end, opts, { desc = "LSP References (Telescope)" })


      vim.keymap.set("n", "<leader>vrn", function()
        vim.lsp.buf.rename()
      end, opts, { desc = "LSP Rename" })

      vim.keymap.set("i", "<C-h>", function()
        vim.lsp.buf.signature_help()
      end, opts, { desc = "LSP Signature Help" })
    end)

    require("mason").setup({})
    require("mason-lspconfig").setup({
      ensure_installed = {
        "ts_ls",
        "eslint",
        "rust_analyzer",
        "kotlin_language_server",
        "jdtls",
        "lua_ls",
        "jsonls",
        "html",
        "elixirls",
        "tailwindcss",
        "tflint",
        "pylsp",
        "dockerls",
        "gopls",
        -- "astro",
        "bashls",
        "marksman",
        "cucumber_language_server",
        "prismals",
        "intelephense"
        -- "java_language_server"
        -- "solargraph",
      },
      handlers = {
        lsp.default_setup,
        lua_ls = function()
          local lua_opts = lsp.nvim_lua_ls()
          require("lspconfig").lua_ls.setup(lua_opts)
        end,
      },
    })

    local cmp_action = require("lsp-zero").cmp_action()
    local cmp = require("cmp")
    local cmp_select = { behavior = cmp.SelectBehavior.Select }

    require("luasnip.loaders.from_vscode").lazy_load()

    -- `/` cmdline setup.
    cmp.setup.cmdline("/", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        { name = "buffer" },
      },
    })

    -- `:` cmdline setup.
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        {
          name = "cmdline",
          option = {
            ignore_cmds = { "Man", "!" },
          },
        },
      }),
    })

    cmp.setup({
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      sources = {
        { name = "nvim_lsp" },
        { name = "luasnip", keyword_length = 2 },
        { name = "buffer",  keyword_length = 3 },
        { name = "path" },
        { name = "codeium" },
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
        ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<C-c>"] = cmp.mapping.complete(),
        ["<C-f>"] = cmp_action.luasnip_jump_forward(),
        ["<C-b>"] = cmp_action.luasnip_jump_backward(),
        ["<Tab>"] = cmp_action.luasnip_supertab(),
        ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
      }),
    })
  end,
}
