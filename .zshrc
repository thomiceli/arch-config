#
# ======================================================================
# ZSH CONFIGURATION (ported from .config/fish/config.fish)
# ======================================================================
#

# ======================================================================
# ENVIRONMENT VARIABLES
# ======================================================================

export EDITOR=nvim

# Wayland environment variables
export ELECTRON_OZONE_PLATFORM_HINT=wayland
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland

export XCURSOR_SIZE=16

# PATH (typeset -U drops duplicates)
typeset -U path
export PNPM_HOME="$HOME/.local/share/pnpm"
export BUN_INSTALL="$HOME/.bun"
path=("$HOME/.local/bin" "$PNPM_HOME" "$BUN_INSTALL/bin" $path "$HOME/go/bin" "$HOME/.cargo/bin")


# ======================================================================
# TMUX AUTOSTART (kitty only, not on TTY/ssh)
# ======================================================================

# Reattach to a detached session if there is one, otherwise start a new one
if [[ -o interactive && -z "$TMUX" && -n "$KITTY_WINDOW_ID" ]] && (( $+commands[tmux] )); then
    _detached=$(tmux list-sessions -F '#{session_attached} #{session_name}' 2>/dev/null | awk '$1 == 0 { print $2; exit }')
    if [[ -n "$_detached" ]]; then
        exec tmux attach-session -t "$_detached"
    else
        exec tmux new-session
    fi
fi


# ======================================================================
# SHELL SETTINGS
# ======================================================================

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt share_history hist_ignore_dups hist_ignore_space
setopt autocd interactive_comments

autoload -Uz compinit && compinit
# fzf-tab replaces the completion menu, so the builtin one is disabled
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

bindkey -e


# ======================================================================
# PLUGINS & PROMPT
# ======================================================================

# fzf-tab: fzf menu on Tab (must load after compinit, before autosuggestions)
[[ -d ~/.local/share/zsh/fzf-tab ]] ||
    git clone --depth 1 https://github.com/Aloxaf/fzf-tab ~/.local/share/zsh/fzf-tab
if [[ -f ~/.local/share/zsh/fzf-tab/fzf-tab.plugin.zsh ]]; then
    source ~/.local/share/zsh/fzf-tab/fzf-tab.plugin.zsh
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always --group-directories-first $realpath'
    zstyle ':fzf-tab:complete:*:*' fzf-flags --height=40%
    zstyle ':fzf-tab:*' switch-group '<' '>'
fi

[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# fzf: Ctrl+R history, Ctrl+T files, Alt+C directories
(( $+commands[fzf] )) && source <(fzf --zsh)
(( $+commands[starship] )) && eval "$(starship init zsh)"
# Don't let zoxide override cd - we handle that below
(( $+commands[zoxide] )) && eval "$(zoxide init --cmd j zsh)"


# ======================================================================
# ALIASES
# ======================================================================

alias ls='ls --color=auto --group-directories-first'
alias ll='ls --color=auto --group-directories-first -lah'
alias l='ls --color=auto --group-directories-first -lh'

alias f='ff'
alias finder='ff'
alias d='fd'
alias dir='fd'
alias folder='fd'

alias z='cd'
alias jump='zi'
alias zls='zoxide query -l'


# ======================================================================
# FUNCTIONS
# ======================================================================

# Fuzzy directory finder (from home)
fd() {
    local selected
    selected=$(
        find ~ -type d \
            -not -path '*/\.*' \
            -not -path '*/node_modules/*' \
            2>/dev/null |
        fzf --height=40% --layout=reverse --border \
            --query="$*" \
            --preview='ls --color=always --group-directories-first -lah {}' \
            --preview-window=right:50%:wrap \
            --header="Search directories (type to filter)" \
            --bind="tab:toggle-preview"
    )
    [[ -z "$selected" ]] && return 0
    cd "$selected" && pwd
}

# Fuzzy file finder: directories cd, text files open in nvim, rest xdg-open
ff() {
    local selected
    selected=$(
        find "${1:-.}" -type f -o -type d 2>/dev/null |
        fzf --height=40% --layout=reverse --border \
            --preview='[ -d {} ] && ls -la {} || head -50 {}' \
            --preview-window=right:50%:wrap \
            --header="Enter: open, Tab: toggle preview" \
            --bind="tab:toggle-preview"
    )
    [[ -z "$selected" ]] && return 0

    if [[ -d "$selected" ]]; then
        cd "$selected" && pwd
    elif file "$selected" 2>/dev/null | grep -q text; then
        nvim "$selected"
    else
        xdg-open "$selected" >/dev/null 2>&1 &!
    fi
}

# Pick one of several directories with fzf
_zpick() {
    printf '%s\n' "$@" |
        fzf --height=40% --layout=reverse --border \
            --header="Select directory:" \
            --preview='ls -la {}' --preview-window=right:50%:wrap
}

# Enhanced cd: real paths as usual, otherwise fall back to zoxide
cd() {
    if [[ $# -eq 0 || "$1" == -* || -d "$1" ]]; then
        builtin cd "$@" && zoxide add "$PWD"
        return
    fi

    local -a matches
    matches=("${(@f)$(zoxide query -l -- "$@" 2>/dev/null)}")
    matches=(${matches:#})

    if (( ${#matches} == 0 )); then
        builtin cd "$@"
    elif (( ${#matches} == 1 )); then
        builtin cd "$matches[1]" && zoxide add "$PWD"
    else
        local selected
        selected=$(_zpick "${matches[@]}")
        [[ -n "$selected" ]] && builtin cd "$selected" && zoxide add "$PWD"
    fi
}

# Interactive zoxide
zi() {
    local selected
    selected=$(zoxide query -l | fzf --height=40% --layout=reverse --border \
        --header="Select directory:" --preview='ls -la {}' \
        --preview-window=right:50%:wrap --query="$*")
    [[ -n "$selected" ]] && cd "$selected"
}

# Add / remove current (or matched) directory in zoxide
za() { zoxide add "$PWD" && echo "Added $PWD to zoxide database"; }

zr() {
    if [[ $# -eq 0 ]]; then
        zoxide remove "$PWD" && echo "Removed $PWD from zoxide database"
        return
    fi
    local -a matches
    matches=("${(@f)$(zoxide query -l -- "$@")}")
    matches=(${matches:#})
    local target
    if (( ${#matches} == 1 )); then
        target="$matches[1]"
    elif (( ${#matches} > 1 )); then
        target=$(_zpick "${matches[@]}")
    else
        echo "zoxide: no match found"; return 1
    fi
    [[ -n "$target" ]] && zoxide remove "$target" && echo "Removed $target from zoxide database"
}

# Original cd behavior (bypass zoxide)
ocd() { builtin cd "$@"; }


# ======================================================================
# KEY BINDINGS
# ======================================================================

# Ctrl+F: fuzzy file finder, Ctrl+G: fuzzy directory finder
_ff_widget() { ff </dev/tty; zle reset-prompt; }
_fd_widget() { fd </dev/tty; zle reset-prompt; }
zle -N _ff_widget
zle -N _fd_widget
bindkey '^F' _ff_widget
bindkey '^G' _fd_widget


# Syntax highlighting must be sourced last
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# No underline on existing paths while typing
ZSH_HIGHLIGHT_STYLES[path]='none'
ZSH_HIGHLIGHT_STYLES[path_prefix]='none'
