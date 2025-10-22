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
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  {
    'goolord/alpha-nvim',
    event = 'VimEnter',
    config = function()
      local alpha = require('alpha')
      local dashboard = require('alpha.themes.dashboard')
      dashboard.section.header.val = {
        "",
        "                              .:-:.                                 ",
        "        .::........-==-.   ...+*+*#=.                               ",
        "      .=###*****###%%%*#%%%%%*.   .#+.                              ",
        "   .=**##%%######%%##%%%%%%%+.      .=.                             ",
        " .::=*###*#%###%%##%%%%=:.:+#+.      ::                             ",
        "  -*##*#%%%##@@%#%%@%: . .. :%=...   ...                            ",
        ".=####%%%#%%@@@%%@%=..--......++..-. ...: .:...                     ",
        "=**#*##%%%%@@@@@@%- . .:+:..:.-==-:+....:.:-..                      ",
        "+***%%#%%%@@@@@@%-:::.:. ==.:--+=::=*..:-.+-:. .                    ",
        "**#@%#%%%%%@@@%%*..---:-:.=+=++**-:=#*=-+-#--...    ::.             ",
        "+#%##%%#%@@@@@@#==..-+==*=-***#*##*=%##***#+-.:...  :*##+:.         ",
        "**##%##%@@%@@@@*=++-.-#*+#+*%%#%##%*%%%%##*#+-:..    -##%%#+-..     ",
        "**#%##%@%%@@@@@+=+*#*=+#%####%%%%%%%%@@%%%#%*=-:-.  .*#%@%%%%%*-.   ",
        "*###%%#%%@@@@@%*++*#####%%%%%%@%%%%@%%@@%%%%%*+#+. ..+%%@@@%%@%##-:::",
        "%#*%%##%@@@@@@@+++#%##%@@%@@@@@%%@%@@@%@%%%@%%*%+=:-. =#%@@@@%#%%%#*=",
        "*+###%%@@@@@@@%**##%%%@@@%%%%%%@%@@%%@%%%%%@@#%%%+==-.+%%@@@@@@%%%=::-=-:",
        "=#%%%%%%@@@@@%%%@@@@@@%%%%@%%%%%%%%%@%@%%%%%%%%@%##++. .*%@@@%%@%%@%#*::. ",
        "%#%%#%%%@@@@@@@@@@@@%%%%@@@@@@%@%@@@%@@@%%%#@@%@@%%#+=:. *%%@@@@%%%%%%#%*=",
        "*%#*#%@%%%@@@@@@@%%###%@@@@@@@@@@@@@@@@%@@@%%%@%%%%%#:..-##%@@@%%%%%%#%**#",
        "%##%@@@@@@@@@@@@%##%%%@@@@@@@@@@@@@@@@%@@@@@@@@%%%%%##:. .##%%%@@@%%%%%%%%#",
        "#%@@%%@@@@@@@%@%#%%%@@@@@@@@@@@@@@@@@@@@@@@@%@@%@@%%##%#=:..*##%%%%%@@@%####",
        "#@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%####%*=-::::::......+#*%%",
        "@%%%%@%@@@@@@@@@@@@@@@@@@@@@@@@@%@@%@@@@@@@@@@%%@@@%%%%#*##*****#####%##*#%@@",
        "%#%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%@%%%%%%%%%%%%%%%%%%%@@%%@",
        "#%%%%%%%@@@@@@@@@@@@@@@@@@@%%@@%%@@@@@@@@@@@@@@@@@@%%@%%%%#%%#%%%%%%##%%##%@%",
        "+#%##%#%@@%%@@@@@@@@@@@@@@@@%%%@@@%@@@@@@@@@@%@@@%%@%@%%%##%%###%%#%#**#*###%",
        "*#*+#%%@@%%%@@@@@@@@@@@@@%%%@%#%@@@@@@@%%@@@@%%%@%#%%%%%#%#%%#*##%###**+**###",
        "+#-*###@@%%@@@@@@@@@@@%%%@@%%@%%%@@@@@##%%#%%%%%@%@%%@@@####%#**######*++**#**",
        "%==*##%%%%#%@@@@@@@@@@@%%%@%#@@@@@%%%####**+#%%%@@@@@%%%%*##%#**+**#*+*#+++***",
        "*:+=##%%%##%@@@@@@@@@@@@@%#%%%%%#%##*+*+***++*%#%@@@@%%%%#*###**++++*++**++=+*",
        ".:-+##%%%##%@@@@@@@@@@@%#@@%%@#*###*=++=++++++*%#%%@@%##%%+*##*+++++++++**+==++",
        ".:.+###%%##*%@@@@@@@@@@@%%@%#**+++*+-++==+++++=*%#%%@@%##%+=***+++==++=+==*++=+",
        "  :*##*%%#+#%@@@@@@%%@@@@@%+++==-=+=-=+-=====+=+###%%%%%#%#-+*++++-==-===::++-",
        " .=**#*%%#+*%@@@%%%###%@%#++*-:=-=-:--=:==+==+=--#*%#+*%%%%-+*+*+=--=:-==-.:==",
        " :=**##%%#+*#%@%#%%%%%#%*.:=-.:-:=:.-:=::=+====:.+####:*%%%+-++=+=::=:.:--..-=:",
        ".-=*+##%##=+%@@%%%@@@%%%:.:...:-.-:.:.= :-+-===::.####.-%%%#:+=--+:-=:..:-:.:=.",
        " .::*=*#%#*-+%@@@@@@@@#%%*:. ..:..:. :.- .-=.-=:.. =##*:.*@%#.==.---.=.. .:..:",
        " ..-*++%%*==*@@@@@@@@%#@@%%=. ... ..  .-  :-.:=... .##*: :@@#.-=..:.--.: .:...",
        "  .-==+%#*=+%@@@@@@%%#%@@@%@%-.   ..  .:  ::..-:   .*#*: .#@*.--. :.-..:. :. .-",
        "  ::=+*%*+=*%@@@%@@###@@@@@%%%*.      ..  ....:.   .=##.  +@=.--. ..:..:. .. .:",
        " ..:-+##+=+%%@@%@@%#%%@@%%@%%##+.     ..  ..  :.    -#*.  =%- -:. ... .:.  :  :",
        "   :=+#++-#%@@@%@%%%@@@%%%%%####:         ..  :.    :##:  =*. -:   ..  ::  :. :",
        "  .-+**=.=#%@@%%@@@@@@@%%%%###*#+             :     .*#:  +=  :..      .:  .. :",
        "  .=+*=.:+*@@%%@%%%%%@@%%####+#%%-                  .+%:  *. ....       :  .: :",
        ".-+*-. ::*%@@%%%%%%#####*****##%%*=-===-.           :%= .:    ..       :   : :",
        ".-+:.    -#@@@@%%@%%%%%#####*##+.:.:-+-:-:           +*.               ..  : .:",
        ".=:      .#%@@@%%@%#=+#%%%####%:      .+.:.           *:               ..  .. .",
        ".=.       +%@@@@%%%#+. .=######=        .             .-.                  .. .",
        ".-.       :%@@@@%%%%+=.  .+%%##=                       ..                  ..  .",
        " ..       :#@@@@@%%%#:.  .+%%#*.                                              ",
        " .:.      .*%@@@@@%%%+.  -%%%#-                                               ",
        "  :.      .*%%#@@@@##%:.:%%%#-.                                               ",
        "  .:       +%%:%%@@%##*:#%#%=                                                  ",
        "  .:       =#%:#@%@@%**=#%%*.                                                  ",
        "   .       =#%:+%%%@@%**%%#:                                                   ",
        "           =*# :#%#%@@%*%%-                                                    ",
        "           ==+ .+%##%@@%%#.                                                    ",
        "          .+:= .=#%*%%%@%#.                                                    ",
        "          := -  :*##*%%%@%#-.                                                  ",
        "         :+. :  .+=**#%*#%%%%*:                                                ",
        "        .-.  .   ==:*+%*+*%@%%%*:.                                            ",
        "       .:.       := =*-%=++*%@@@%%%%%=...                                      ",
        "        .        .= .#-=#--=+#%%%%%@%#%%#=.                                    ",
        "                  :. .*:+#::=+%%%#**%%#**##*-.                                 ",
        "                  ..  :+:+*:.--*%#*-.=#%#+:.=*.                                ",
        "                      .==.=*..-..-++-..:+##-..:                                ",
        "                       .-=.-*:.:. ..==.  .:#-                                  ",
        "                        ..-.-*-...   :=:.  .-.                                 ",
        "                         .::..+-      .::. ...                                 ",
        "                          .-. .-=.      .:.                                    ",
        "                           .=   :=.       ..                                   ",
        "                            ::   .=.       ..                                  ",
        "                             :.   .:-                                          ",
        "                             ..     .:.                                        ",
        "                             ...      ..                                       ",
        "                              ..                                               ",
        "                              ..                                               ",
        "",
      }
      dashboard.section.buttons.val = {
        dashboard.button('e', 'New file', ':ene <BAR> startinsert<CR>'),
        dashboard.button('q', 'Quit', ':qa<CR>'),
      }
      alpha.setup(dashboard.opts)
    end,
  },
  {
    "baliestri/aura-theme",
    lazy = false,
    priority = 1000,
    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. "/packages/neovim")
      vim.cmd([[colorscheme aura-dark]])
    end,
  },
})

-- ---------- LSP: clangd (Neovim 0.11+ style, no lspconfig) ----------
local function clangd_capabilities()
  local ok, cmp = pcall(require, "cmp_nvim_lsp")
  if ok and cmp and cmp.default_capabilities then
    return cmp.default_capabilities()
  end
  return vim.lsp.protocol.make_client_capabilities()
end

local function clangd_root_dir()
  local bufname = vim.api.nvim_buf_get_name(0)
  local start_dir = vim.fs.dirname(bufname)
  local markers = vim.fs.find({ "compile_commands.json", ".git" }, { path = start_dir, upward = true })
  if markers and #markers > 0 then
    return vim.fs.dirname(markers[1])
  end
  return start_dir
end

local function maybe_start_clangd(args)
  local bufnr = args and args.buf or 0
  local existing = vim.lsp.get_clients({ name = "clangd", bufnr = bufnr })
  if existing and #existing > 0 then return end
  vim.lsp.start({
    name = "clangd",
    cmd = { "clangd" },
    root_dir = clangd_root_dir(),
    capabilities = clangd_capabilities(),
  })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "objc", "objcpp" },
  callback = maybe_start_clangd,
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
