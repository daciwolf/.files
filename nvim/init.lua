-- Bootstrap lazy.nvim (self-contained)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
})

-- ---------- LSP: clangd ----------
local lspconfig = require("lspconfig")
-- Use default root detection to avoid deprecated lspconfig.util usage
lspconfig.clangd.setup({
  cmd = { "clangd" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
})

-- ---------- Autocomplete ----------
local cmp = require("cmp")
cmp.setup({
  snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  }),
})

-- ---------- Treesitter ----------
require("nvim-treesitter.configs").setup({
  ensure_installed = { "cpp", "c", "lua", "vim", "python" },
  highlight = { enable = true },
})

-- Prefer working compilers on Windows for Treesitter
-- Avoid picking a bare LLVM clang without SDK headers
if vim.fn.has("win32") == 1 then
  local ts_install = require("nvim-treesitter.install")
  -- Order matters: try gcc (MSYS2), then cl (MSVC), then clang/zig
  -- If you install MSYS2 or Build Tools, one of the first two will succeed.
  ts_install.compilers = { "gcc", "cl", "clang", "zig" }
end

-- ---------- UI ----------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
