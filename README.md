# nvim-config

Configuração pessoal do Neovim (>= 0.11), gerida com [lazy.nvim](https://github.com/folke/lazy.nvim).

- **UI:** tokyonight, lualine, bufferline, which-key, treesitter
- **Código:** LSP nativo + mason (lua_ls, pyright, clangd, ts_ls), nvim-cmp + LuaSnip
- **Fluxo:** neo-tree, telescope, gitsigns, lazygit, diffview
- **Debug:** nvim-dap + dap-ui (Python, C/C++ via codelldb)
- **IA:** claudecode.nvim (integração com o Claude Code)

Leader = `Espaço`. Carrega `<leader>` e espera para o which-key mostrar os atalhos.

## Fontes

A pasta `fonts/` traz a **JetBrainsMono Nerd Font Mono** (licença SIL OFL, ver `fonts/OFL.txt`),
necessária para os ícones do neo-tree, bufferline e lualine.

## Instalação no Windows

1. **Fontes:** seleciona os `.ttf` em `fonts/` → botão direito → *Instalar*.
   No Windows Terminal: *Definições → Perfil → Aparência → Tipo de letra* → `JetBrainsMono Nerd Font Mono`.

2. **Dependências** (PowerShell):

   ```powershell
   winget install Neovim.Neovim Git.Git BurntSushi.ripgrep.MSVC sharkdp.fd JesseDuffield.lazygit OpenJS.NodeJS.LTS Python.Python.3.12 tree-sitter.tree-sitter-cli
   winget install BrechtSanders.WinLibs.POSIX.UCRT   # gcc + make (mingw32-make)
   ```

   - `gcc`/`make` compilam o `telescope-fzf-native`, o `jsregexp` do LuaSnip e os parsers do treesitter.
     Se o `make` não for encontrado, cria um alias: `copy (Get-Command mingw32-make).Source "$(Split-Path (Get-Command mingw32-make).Source)\make.exe"`.
   - Node é usado pelo mason para instalar `pyright` e `ts_ls`.
   - Opcional: `winget install Anthropic.ClaudeCode` para o `<leader>ac`.

3. **Clonar a config:**

   ```powershell
   git clone https://github.com/LuisCavada305/nvim-config "$env:LOCALAPPDATA\nvim"
   ```

4. Abre o `nvim`: o lazy.nvim instala os plugins na primeira execução. Depois corre `:checkhealth` para ver se falta algo.

## Instalação no Linux

```sh
git clone https://github.com/LuisCavada305/nvim-config ~/.config/nvim
mkdir -p ~/.local/share/fonts && cp ~/.config/nvim/fonts/*.ttf ~/.local/share/fonts/ && fc-cache -f
```
