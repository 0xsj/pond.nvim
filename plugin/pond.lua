if vim.g.loaded_pond then
  return
end
vim.g.loaded_pond = true

-- Don't auto-setup; user calls require("pond").setup(opts)
-- This file exists so lazy.nvim and other managers detect the plugin.
