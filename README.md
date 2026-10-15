# nvim-config

Configuração pessoal do Neovim (>= 0.11), gerida com [lazy.nvim](https://github.com/folke/lazy.nvim).

- **UI:** tokyonight, lualine, bufferline, which-key, treesitter
- **Código:** LSP nativo + mason (lua_ls, pyright, clangd, ts_ls), nvim-cmp + LuaSnip
- **Fluxo:** neo-tree, telescope, gitsigns, lazygit, diffview
- **Debug:** nvim-dap + dap-ui (Python incl. APIs FastAPI/Litestar/Flask/Django, Node/TS, C/C++)
- **IA:** claudecode.nvim (integração com o Claude Code)

**Leader = `Espaço`.** Carrega `Espaço` e espera meio segundo: o which-key mostra todos os atalhos disponíveis.

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
   - Node é usado pelo mason para instalar `pyright`, `ts_ls` e o debugger de JS.
   - Opcional: `winget install Anthropic.ClaudeCode` para o `<leader>ac`.

3. **Clonar a config:**

   ```powershell
   git clone https://github.com/LuisCavada305/nvim-config "$env:LOCALAPPDATA\nvim"
   ```

4. Abre o `nvim`: o lazy.nvim instala os plugins na primeira execução e o mason instala os LSPs
   e debuggers (acompanha com `:Mason`). Depois corre `:checkhealth` para ver se falta algo.

## Instalação no Linux

```sh
git clone https://github.com/LuisCavada305/nvim-config ~/.config/nvim
mkdir -p ~/.local/share/fonts && cp ~/.config/nvim/fonts/*.ttf ~/.local/share/fonts/ && fc-cache -f
```

Precisa de `git`, `gcc`, `make`, `ripgrep`, `fd`, `node`, `python3`, `tree-sitter` (CLI) e `lazygit`.

---

# Atalhos

`<leader>` = `Espaço` · `C-x` = Ctrl+x · `S-x` = Shift+x

## Mapa do leader

| Prefixo | Grupo |
|---|---|
| `<leader>a` | Claude Code |
| `<leader>b` | Buffers |
| `<leader>c` | Código (code action) |
| `<leader>d` | Debug |
| `<leader>e` | Explorador de ficheiros |
| `<leader>f` | Procurar (telescope) |
| `<leader>g` | Git |
| `<leader>h` | Hunks do git |
| `<leader>r` | Renomear |

## Ficheiros e janelas

| Atalho | Ação |
|---|---|
| `<leader>e` | Abrir/fechar o explorador (neo-tree) |
| `S-l` / `S-h` | Buffer (aba) seguinte / anterior |
| `<leader>bd` | Fechar o buffer atual |
| `:w` / `:q` / `:wq` | Guardar / fechar / guardar e fechar |
| `C-w h/j/k/l` | Ir para a janela da esquerda/baixo/cima/direita |
| `C-w v` / `C-w s` | Dividir na vertical / horizontal |
| `C-w q` | Fechar a janela |
| `C-\ C-n` | Sair do modo terminal (ex.: janela do Claude) para poder usar `C-w` |

### Dentro do explorador (neo-tree)

| Tecla | Ação |
|---|---|
| `Enter` / duplo clique | Abrir ficheiro / expandir pasta |
| `Espaço` | Expandir/recolher pasta |
| `s` / `S` / `t` | Abrir em split vertical / horizontal / nova tab |
| `P` | Pré-visualizar |
| `a` | Novo ficheiro (termina com `/` para criar pasta) |
| `A` | Nova pasta |
| `r` / `b` | Renomear / renomear só o nome base |
| `d` | Apagar |
| `c` / `m` | Copiar / mover (pede o destino) |
| `y` / `x` / `p` | Copiar / cortar / colar |
| `H` | Mostrar/esconder ficheiros ocultos |
| `/` | Procurar na árvore |
| `Backspace` / `.` | Subir um nível / tornar a pasta a raiz |
| `[g` / `]g` | Ficheiro modificado (git) anterior / seguinte |
| `i` | Detalhes do ficheiro |
| `C` / `z` | Recolher pasta / recolher tudo |
| `R` | Atualizar |
| `<` / `>` | Alternar entre ficheiros / buffers / git status |
| `<leader>as` | Enviar o ficheiro ao Claude |
| `q` | Fechar |
| `?` | Ajuda com todas as teclas |

## Procurar (telescope)

| Atalho | Ação |
|---|---|
| `<leader>ff` | Procurar ficheiros |
| `<leader>fg` | Procurar texto no projeto (live grep) |
| `<leader>fb` | Buffers abertos |
| `<leader>fs` | Símbolos do ficheiro (funções, classes...) |

Dentro do telescope:

| Tecla | Ação |
|---|---|
| `C-n` / `C-p` (ou setas) | Próximo / anterior |
| `Enter` | Abrir |
| `C-v` / `C-x` / `C-t` | Abrir em split vertical / horizontal / nova tab |
| `C-u` / `C-d` | Rolar a pré-visualização |
| `Tab` | Marcar vários |
| `C-q` | Enviar resultados para a quickfix list |
| `Esc` (duas vezes) / `C-c` | Fechar |

## Código (LSP)

| Atalho | Ação |
|---|---|
| `gd` | Ir para a definição |
| `gr` | Referências (no telescope) |
| `K` | Documentação / tipo do símbolo |
| `<leader>rn` | Renomear símbolo em todo o projeto |
| `<leader>ca` | Code actions (imports, quick fixes...) — também em modo visual |
| `]d` / `[d` | Diagnóstico (erro/aviso) seguinte / anterior |
| `C-w d` | Mostrar o diagnóstico da linha numa janela |
| `C-o` / `C-i` | Voltar / avançar depois de saltar (ex.: após `gd`) |
| `gcc` / `gc` (visual) | Comentar / descomentar linha / seleção |
| `:Mason` | Gerir LSPs, debuggers e formatters |

## Autocomplete e snippets (modo de inserção)

| Tecla | Ação |
|---|---|
| `C-Espaço` | Abrir as sugestões |
| `Tab` / `S-Tab` | Próxima / anterior sugestão; com o menu fechado, salta entre campos do snippet |
| `C-n` / `C-p` (ou setas) | Próxima / anterior sugestão |
| `Enter` | Confirmar a sugestão **selecionada** (sem seleção, só muda de linha) |
| `C-y` | Confirmar |
| `C-e` | Fechar o menu |

## Git

| Atalho | Ação |
|---|---|
| `<leader>gg` | Abrir o LazyGit |
| `<leader>gd` | Abrir/fechar o Diffview (todas as alterações) |
| `]h` / `[h` | Hunk (bloco alterado) seguinte / anterior |
| `<leader>hp` | Pré-visualizar o hunk |
| `<leader>hb` | Blame da linha (quem alterou e em que commit) |

Dentro do **LazyGit**: `Espaço` stage/unstage · `c` commit · `P` push · `p` pull · `Enter` abrir ·
`Tab`/`h`/`l` mudar de painel · `?` ajuda · `q` sair.

Dentro do **Diffview**: `Tab`/`S-Tab` ficheiro seguinte/anterior · `-` ou `s` stage/unstage ·
`S` stage tudo · `X` descartar alterações do ficheiro · `R` atualizar · `g?` ajuda.
Em conflitos de merge: `]x`/`[x` conflito seguinte/anterior · `<leader>co` ours · `<leader>ct` theirs ·
`<leader>ca` ambos · `dx` apagar o conflito.

## Debug

| Atalho | Ação |
|---|---|
| `F5` | Iniciar (escolher configuração) / continuar |
| `F9` | Breakpoint na linha |
| `<leader>dc` | Breakpoint condicional (ex.: `item_id == 99`) |
| `F10` | Step over (próxima linha) |
| `F11` | Step into (entrar na função) |
| `F12` | Step out (sair da função) |
| `<leader>dq` | Parar o debug (e o servidor); em attach só desliga e o servidor continua |
| `<leader>dr` | Repetir a última configuração (útil para reiniciar uma API depois de editar) |
| `<leader>du` | Mostrar/esconder a UI do debug |

Para parar em exceções: `:lua require("dap").set_exception_breakpoints({"raised"})`.

### Configurações do `F5`

Dependem do tipo do ficheiro aberto:

| Linguagem | Configuração | O que faz |
|---|---|---|
| Python | `Run current file` | Corre o ficheiro atual |
| Python | `API: ASGI via uvicorn` | FastAPI, Litestar, Starlette: `uvicorn <app> --port <porta>` (pergunta `main:app` e `8000`) |
| Python | `API: Flask` | `flask --app <app> run` |
| Python | `API: Django` | `manage.py runserver --noreload` |
| Python | `Attach to debugpy (port 5678)` | Liga-se a uma API já a correr (ver abaixo) |
| JS/TS | `Run current file (node)` | Corre o ficheiro atual |
| JS/TS | `API: npm run <script>` | Corre um script do `package.json` (ex.: `dev`), funciona com tsx/ts-node/nodemon |
| JS/TS | `Attach to node process` | Escolhe um processo `node --inspect` em execução |
| C/C++ | `Launch executable` | Pede o executável (compila com `-g -O0`) |

- O Python usa o venv ativo; senão, `.venv/` ou `venv/` na pasta do projeto; senão, o Python do sistema.
- O auto-reload fica desligado nas APIs Python iniciadas pelo nvim (os breakpoints não funcionam no
  processo filho do reloader). Depois de editar, `<leader>dr` reinicia.
- **Debugar uma API que já está a correr:** ela tem de ser iniciada com o debugpy, por exemplo
  `python -m debugpy --listen 5678 -m uvicorn app:app --reload`.
  Depois `F5` → `Attach to debugpy (port 5678)`. Assim o `--reload` pode ficar ligado.
- Se o projeto tiver `.vscode/launch.json`, as configurações dele também aparecem no `F5`.

## Claude Code

| Atalho | Ação |
|---|---|
| `<leader>ac` | Abrir/fechar o Claude num split à direita |
| `<leader>af` | Ir para a janela do Claude |
| `<leader>ar` | Retomar uma sessão anterior |
| `<leader>aC` | Continuar a última sessão |
| `<leader>am` | Escolher o modelo |
| `<leader>ab` | Enviar o ficheiro atual como contexto |
| `<leader>as` (visual) | Enviar a seleção |
| `<leader>as` (no neo-tree) | Enviar o ficheiro sob o cursor |
| `<leader>aa` / `<leader>ad` | Aceitar / rejeitar o diff proposto |

O Claude vê o ficheiro aberto e a seleção atual. Edições propostas abrem como diff no nvim.
Também dá para correr `claude` noutro terminal na mesma pasta e usar `/ide` para ligar ao nvim.

## Plugins

| Comando | Ação |
|---|---|
| `:Lazy` | Gerir plugins (`S` sync, `U` update, `X` limpar) |
| `:Mason` | Gerir LSPs/debuggers (`i` instalar, `X` desinstalar, `U` atualizar) |
| `:checkhealth` | Diagnosticar problemas da instalação |

## Fontes

A pasta `fonts/` traz a **JetBrainsMono Nerd Font Mono** (licença SIL OFL, ver `fonts/OFL.txt`),
necessária para os ícones do neo-tree, bufferline e lualine.
