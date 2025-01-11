return {
  "olexsmir/gopher.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("gopher").setup()
    vim.api.nvim_set_keymap('n', '<leader>gsj', '<cmd>GoTagAdd json<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>gsy', '<cmd>GoTagAdd yaml<CR>', { noremap = true, silent = true })
  end,
}
