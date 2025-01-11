-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`

return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<C-p>", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      local state = require("telescope.state")
      local action_state = require("telescope.actions.state")
      local slow_scroll = function(prompt_bufnr, direction)
        local previewer = action_state.get_current_picker(prompt_bufnr).previewer
        local status = state.get_status(prompt_bufnr)

        -- Check if we actually have a previewer and a preview window
        if type(previewer) ~= "table" or previewer.scroll_fn == nil or status.preview_win == nil then
          return
        end

        previewer:scroll_fn(20 * direction)
      end
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = {
            "node_modules",
            "%.git",
            "%.next",
            ".settings/",
            ".metadata/",
            "vendor",
            "target/",
            ".class$",
            "dist/",
            ".png",
            "package-lock.json",
          },
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              preview_width = 80,
              size = {
                width = "0.8",
                height = "0.8",
              },
            },
          },
          pickers = {
            find_files = {
              theme = "dropdown",
            },
          },
          mappings = {
            i = {
              ["<C-o>"] = function(bufnr)
                slow_scroll(bufnr, -1)
              end,
              ["<C-e>"] = function(bufnr)
                slow_scroll(bufnr, 1)
              end,
              ["<C-d>"] = false,
              ["<C-u>"] = false,
              ["<C-j>"] = require("telescope.actions").move_selection_next,
              ["<C-k>"] = require("telescope.actions").move_selection_previous,
            },
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })
      require("telescope").load_extension("ui-select")
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>sS", builtin.git_status, { desc = "" })
      vim.keymap.set("n", "<leader>sm", ":Telescope harpoon marks<CR>", { desc = "Harpoon [M]arks" })
      -- vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Find Word under Cursor" })
      vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "Search Git Commits" })
      vim.keymap.set("n", "<leader>gb", builtin.git_bcommits, { desc = "Search Git Commits for Buffer" })
      vim.keymap.set("n", "<leader>/", function()
        require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
          layout_strategy = "vertical", -- Set layout strategy to "vertical"
          layout_config = {
            prompt_position = "top", -- Move prompt to the top
            width = 0.4,          -- Set width of the Telescope window
            height = 0.3,         -- Set height of the Telescope window
            anchor = "NE",        -- Anchor the window to the top-right corner
          },
        }))
      end, { desc = "[/] Fuzzily search in current buffer" })
    end,
  },
}
