#!/usr/bin/env bash
# ==============================================================================
# MacBook Pro Minimal Developer & iTerm2 Setup Script
# Clean, fast, distraction-free environment for Apple Silicon & Intel Macs
# ==============================================================================

set -euo pipefail

# ------------------------------------------------------------------------------
# Clean Terminal Logging (No emojis, no flashy styles)
# ------------------------------------------------------------------------------
BOLD="\033[1m"
RESET="\033[0m"
DIM="\033[2m"

info()    { printf "  ${DIM}->${RESET} %s\n" "$1"; }
ok()      { printf "  ${BOLD}ok${RESET} %s\n" "$1"; }
warn()    { printf "  ${BOLD}!!${RESET} %s\n" "$1"; }
error()   { printf "  ${BOLD}ERR:${RESET} %s\n" "$1" >&2; }
step()    { printf "\n${BOLD}==> %s${RESET}\n" "$1"; }

# ------------------------------------------------------------------------------
# Parse Arguments
# ------------------------------------------------------------------------------
NON_INTERACTIVE=false
SKIP_MACOS_DEFAULTS=false

for arg in "$@"; do
    case "$arg" in
        -y|--yes) NON_INTERACTIVE=true ;;
        --skip-defaults) SKIP_MACOS_DEFAULTS=true ;;
        -h|--help)
            cat <<EOF
Usage: ./setup.sh [OPTIONS]

Options:
    -y, --yes          Non-interactive mode (accept default prompts)
    --skip-defaults    Skip applying macOS developer system defaults
    -h, --help         Show this help message
EOF
            exit 0
            ;;
    esac
done

if [ "$NON_INTERACTIVE" = true ]; then
    export HOMEBREW_NO_ENV_HINTS=1
    export NONINTERACTIVE=1
fi

confirm() {
    if [ "$NON_INTERACTIVE" = true ]; then
        return 0
    fi
    local prompt="$1 [Y/n]: "
    read -r -p "$prompt" response
    case "$response" in
        [nN][oO]|[nN]) return 1 ;;
        *) return 0 ;;
    esac
}

# ------------------------------------------------------------------------------
# Pre-flight Check
# ------------------------------------------------------------------------------
if [[ "$OSTYPE" != "darwin"* ]]; then
    error "This script is designed specifically for macOS."
    exit 1
fi

# Resolve symlinks so script works when called from any directory or symlink
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
ARCH="$(uname -m)"

printf "${BOLD}macOS Developer Setup${RESET}\n"
printf "${DIM}Setting up a clean, high-contrast, distraction-free environment.${RESET}\n"

# ------------------------------------------------------------------------------
# 1. Xcode Command Line Tools
# ------------------------------------------------------------------------------
step "[1/7] Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
    info "Installing Xcode Command Line Tools..."
    xcode-select --install
    read -r -p "Press Enter to continue once Xcode tools installation completes..."
    ok "Xcode Command Line Tools installed."
else
    ok "Already installed."
fi

# ------------------------------------------------------------------------------
# 2. Homebrew
# ------------------------------------------------------------------------------
step "[2/7] Homebrew Package Manager"
if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ "$ARCH" == "arm64" ]]; then
        BREW_PREFIX="/opt/homebrew"
    else
        BREW_PREFIX="/usr/local"
    fi
    eval "$("$BREW_PREFIX/bin/brew" shellenv)"
    
    if ! grep -q 'eval "$('"$BREW_PREFIX"'/bin/brew shellenv)"' "$HOME/.zprofile" 2>/dev/null; then
        echo 'eval "$('"$BREW_PREFIX"'/bin/brew shellenv)"' >> "$HOME/.zprofile"
    fi
    ok "Homebrew installed."
else
    ok "Already installed."
    if [[ "$ARCH" == "arm64" && -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# ------------------------------------------------------------------------------
# 3. Typography (JetBrains Mono Nerd Font)
# ------------------------------------------------------------------------------
step "[3/7] Monospace Font"
if brew list --cask font-jetbrains-mono-nerd-font &>/dev/null 2>&1 || [ -f "$HOME/Library/Fonts/JetBrainsMonoNerdFont-Regular.ttf" ] || [ -f "/Library/Fonts/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    ok "JetBrains Mono Nerd Font already installed."
else
    info "Installing font-jetbrains-mono-nerd-font..."
    brew install --cask --quiet font-jetbrains-mono-nerd-font || true
    ok "JetBrains Mono Nerd Font ready."
fi

# ------------------------------------------------------------------------------
# 4. iTerm2 & Clean Profiles (Solid background, 0 blur, 0 transparency)
# ------------------------------------------------------------------------------
step "[4/7] iTerm2 Terminal"
if ! brew list --cask iterm2 &>/dev/null && [ ! -d "/Applications/iTerm.app" ]; then
    info "Installing iTerm2..."
    brew install --cask --quiet iterm2
    ok "iTerm2 installed to /Applications/iTerm.app"
else
    ok "Already installed."
fi

# Install Dynamic Profiles (solid black/slate, zero blur, zero transparency)
DYNAMIC_PROFILES_DIR="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
mkdir -p "$DYNAMIC_PROFILES_DIR"

if [[ -f "$SCRIPT_DIR/config/iterm2/dynamic_profiles.json" ]]; then
    if [ -f "$DYNAMIC_PROFILES_DIR/dev_profiles.json" ] && cmp -s "$SCRIPT_DIR/config/iterm2/dynamic_profiles.json" "$DYNAMIC_PROFILES_DIR/dev_profiles.json"; then
        ok "Dynamic profiles already up to date."
    else
        cp "$SCRIPT_DIR/config/iterm2/dynamic_profiles.json" "$DYNAMIC_PROFILES_DIR/dev_profiles.json"
        ok "Dynamic profiles deployed (Clean Dark, Solid Default, 0% opacity, 0 blur)."
    fi
else
    cat > "$DYNAMIC_PROFILES_DIR/dev_profiles.json" << 'EOF'
{
  "Profiles": [
    {
      "Name": "Default",
      "Guid": "4B5B44E6-D38E-4545-983C-1F0A0E29221D",
      "Normal Font": "JetBrainsMonoNFM-Regular 14",
      "Non Ascii Font": "JetBrainsMonoNFM-Regular 14",
      "Use Non-ASCII Font": false,
      "Use Bold Font": true,
      "Use Italic Font": false,
      "Horizontal Spacing": 1.0,
      "Vertical Spacing": 1.0,
      "Cursor Type": 2,
      "Blinking Cursor": false,
      "Window Type": 0,
      "Columns": 120,
      "Rows": 32,
      "Transparency": 0.0,
      "Blur": false,
      "Blur Radius": 0,
      "Scrollback Lines": 10000,
      "Unlimited Scrollback": false,
      "Show Mark Indicators": false,
      "Prompt Before Closing 2": false,
      "Background Color": { "Red Component": 0.0941, "Green Component": 0.1020, "Blue Component": 0.1216, "Alpha Component": 1 },
      "Foreground Color": { "Red Component": 0.8431, "Green Component": 0.8667, "Blue Component": 0.9020, "Alpha Component": 1 },
      "Bold Color": { "Red Component": 0.9412, "Green Component": 0.9529, "Blue Component": 0.9725, "Alpha Component": 1 },
      "Cursor Color": { "Red Component": 0.7000, "Green Component": 0.7500, "Blue Component": 0.8500, "Alpha Component": 1 },
      "Cursor Text Color": { "Red Component": 0.0941, "Green Component": 0.1020, "Blue Component": 0.1216, "Alpha Component": 1 },
      "Selection Color": { "Red Component": 0.2353, "Green Component": 0.2745, "Blue Component": 0.3529, "Alpha Component": 1 },
      "Selected Text Color": { "Red Component": 0.8431, "Green Component": 0.8667, "Blue Component": 0.9020, "Alpha Component": 1 },
      "Ansi 0 Color": { "Red Component": 0.1490, "Green Component": 0.1647, "Blue Component": 0.1961, "Alpha Component": 1 },
      "Ansi 1 Color": { "Red Component": 0.8980, "Green Component": 0.4510, "Blue Component": 0.4510, "Alpha Component": 1 },
      "Ansi 2 Color": { "Red Component": 0.5490, "Green Component": 0.7529, "Blue Component": 0.4784, "Alpha Component": 1 },
      "Ansi 3 Color": { "Red Component": 0.8980, "Green Component": 0.7529, "Blue Component": 0.4784, "Alpha Component": 1 },
      "Ansi 4 Color": { "Red Component": 0.4784, "Green Component": 0.6510, "Blue Component": 0.8980, "Alpha Component": 1 },
      "Ansi 5 Color": { "Red Component": 0.7490, "Green Component": 0.5490, "Blue Component": 0.8510, "Alpha Component": 1 },
      "Ansi 6 Color": { "Red Component": 0.4784, "Green Component": 0.7843, "Blue Component": 0.7843, "Alpha Component": 1 },
      "Ansi 7 Color": { "Red Component": 0.7843, "Green Component": 0.8157, "Blue Component": 0.8471, "Alpha Component": 1 },
      "Ansi 8 Color": { "Red Component": 0.3529, "Green Component": 0.3843, "Blue Component": 0.4392, "Alpha Component": 1 },
      "Ansi 9 Color": { "Red Component": 0.8980, "Green Component": 0.4510, "Blue Component": 0.4510, "Alpha Component": 1 },
      "Ansi 10 Color": { "Red Component": 0.5490, "Green Component": 0.7529, "Blue Component": 0.4784, "Alpha Component": 1 },
      "Ansi 11 Color": { "Red Component": 0.8980, "Green Component": 0.7529, "Blue Component": 0.4784, "Alpha Component": 1 },
      "Ansi 12 Color": { "Red Component": 0.4784, "Green Component": 0.6510, "Blue Component": 0.8980, "Alpha Component": 1 },
      "Ansi 13 Color": { "Red Component": 0.7490, "Green Component": 0.5490, "Blue Component": 0.8510, "Alpha Component": 1 },
      "Ansi 14 Color": { "Red Component": 0.4784, "Green Component": 0.7843, "Blue Component": 0.7843, "Alpha Component": 1 },
      "Ansi 15 Color": { "Red Component": 0.8980, "Green Component": 0.9176, "Blue Component": 0.9412, "Alpha Component": 1 }
    }
  ]
}
EOF
    ok "Generated solid dynamic profile."
fi

# Download clean color schemes for presets
COLORS_DIR="$HOME/.config/iterm2/colors"
mkdir -p "$COLORS_DIR"

SCHEMES=(
    "Catppuccin%20Mocha"
    "TokyoNight"
    "Dracula"
    "Gruvbox%20Dark"
    "Nord"
)

BASE_COLOR_URL="https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes"
for scheme in "${SCHEMES[@]}"; do
    scheme_name=$(echo "$scheme" | sed 's/%20/ /g')
    target_file="$COLORS_DIR/${scheme_name}.itermcolors"
    if [ ! -f "$target_file" ]; then
        curl -fsSL "$BASE_COLOR_URL/${scheme}.itermcolors" -o "$target_file" || true
    fi
done

PRESETS_FLAG="$COLORS_DIR/.presets_registered"
if [ -d "/Applications/iTerm.app" ] && [ ! -f "$PRESETS_FLAG" ]; then
    for file in "$COLORS_DIR"/*.itermcolors; do
        open -a "/Applications/iTerm.app" "$file" 2>/dev/null || true
    done
    touch "$PRESETS_FLAG"
    ok "Color presets registered in iTerm2."
else
    ok "Color presets ready."
fi

# Container runtime (OrbStack: fast, lightweight Docker replacement for Apple Silicon)
if ! brew list --cask orbstack &>/dev/null && [ ! -d "/Applications/OrbStack.app" ]; then
    info "Installing OrbStack (lightweight Docker & Linux runtime)..."
    brew install --cask --quiet orbstack || warn "OrbStack install deferred."
else
    ok "OrbStack container runtime ready."
fi

# GUI for Jujutsu (GG)
if ! brew list --cask gg &>/dev/null && [ ! -d "/Applications/gg.app" ]; then
    info "Installing GG (GUI for Jujutsu)..."
    brew install --cask --quiet gg || warn "GG install deferred."
else
    ok "GG (Jujutsu GUI) ready."
fi

# Obsidian note-taking application
if ! brew list --cask obsidian &>/dev/null && [ ! -d "/Applications/Obsidian.app" ]; then
    info "Installing Obsidian..."
    brew install --cask --quiet obsidian || warn "Obsidian install deferred."
else
    ok "Obsidian ready."
fi

# ------------------------------------------------------------------------------
# 5. Core CLI Utilities
# ------------------------------------------------------------------------------
step "[5/7] Core CLI Utilities"

PACKAGES=(
    starship
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    eza
    bat
    fzf
    ripgrep
    fd
    zoxide
    btop
    git
    lazygit
    git-delta
    jj
    jjui
    pnpm
    fnm
    uv
    tealdeer
    direnv
    dust
    neovim
)

for pkg in "${PACKAGES[@]}"; do
    if brew list "$pkg" &>/dev/null; then
        info "$pkg is already installed"
    else
        info "Installing $pkg..."
        brew install --quiet "$pkg"
    fi
done

# Initialize tealdeer (tldr) cache
if command -v tldr >/dev/null 2>&1; then
    info "Updating tealdeer tldr cache..."
    tldr --update 2>/dev/null || true
fi

# Ensure Node 22 LTS is available via fnm
if command -v fnm >/dev/null 2>&1; then
    eval "$(fnm env)"
    if ! fnm list 2>/dev/null | grep -q "v22"; then
        info "Installing Node 22 (LTS) via fnm..."
        fnm install 22 || true
        fnm default 22 || true
        ok "Node 22 LTS installed via fnm."
    else
        ok "Node 22 LTS ready via fnm."
    fi
fi

ok "CLI utilities installed."

# ------------------------------------------------------------------------------
# 6. Configurations (Starship & Zsh)
# ------------------------------------------------------------------------------
step "[6/7] Deploying Configurations"

mkdir -p "$HOME/.config"
STARSHIP_SRC="$SCRIPT_DIR/config/starship.toml"
STARSHIP_DEST="$HOME/.config/starship.toml"

if [[ -f "$STARSHIP_SRC" ]]; then
    if [ -f "$STARSHIP_DEST" ]; then
        if ! cmp -s "$STARSHIP_SRC" "$STARSHIP_DEST"; then
            cp "$STARSHIP_DEST" "${STARSHIP_DEST}.backup.$(date +%s)"
            cp "$STARSHIP_SRC" "$STARSHIP_DEST"
            ok "Updated ~/.config/starship.toml (single-line pwd prompt)"
        else
            ok "~/.config/starship.toml is up to date."
        fi
    else
        cp "$STARSHIP_SRC" "$STARSHIP_DEST"
        ok "Configured ~/.config/starship.toml (single-line pwd prompt)"
    fi
else
    cat > "$STARSHIP_DEST" << 'EOF'
format = "$directory$git_branch$git_status$cmd_duration$character"

command_timeout = 500

[directory]
style = "bold cyan"
truncation_length = 0
truncate_to_repo = false
read_only = " [ro]"
read_only_style = "red"

[git_branch]
style = "bold magenta"
format = "[$symbol$branch]($style) "
symbol = "git:"

[git_status]
style = "red"
format = '([$all_status$ahead_behind]($style) )'
conflicted = "="
ahead = ">"
behind = "<"
diverged = "<>"
untracked = "?"
stashed = "$"
modified = "!"
staged = "+"
renamed = "»"
deleted = "x"

[cmd_duration]
min_time = 3_000
format = "[$duration]($style) "
style = "yellow"

[character]
success_symbol = "[❯](green)"
error_symbol = "[❯](red)"
vimcmd_symbol = "[❮](yellow)"
EOF
    ok "Generated minimal single-line ~/.config/starship.toml"
fi

# Bat config: plain ANSI style
mkdir -p "$HOME/.config/bat"
BAT_CONFIG="$HOME/.config/bat/config"
if [ ! -f "$BAT_CONFIG" ]; then
    cat > "$BAT_CONFIG" << 'EOF'
--theme="ansi"
--style="numbers,changes"
EOF
    ok "Configured bat with native ANSI theme."
else
    ok "bat config ready."
fi

# Zsh config
ZSHRC_SRC="$SCRIPT_DIR/config/zshrc"
ZSHRC_DEST="$HOME/.zshrc"

if [[ -f "$ZSHRC_SRC" ]]; then
    if [ -f "$ZSHRC_DEST" ]; then
        if ! cmp -s "$ZSHRC_SRC" "$ZSHRC_DEST"; then
            BACKUP_FILE="${ZSHRC_DEST}.backup.$(date +%s)"
            cp "$ZSHRC_DEST" "$BACKUP_FILE"
            info "Existing ~/.zshrc backed up to $(basename "$BACKUP_FILE")"
            cp "$ZSHRC_SRC" "$ZSHRC_DEST"
            ok "Updated clean ~/.zshrc"
        else
            ok "~/.zshrc is up to date."
        fi
    else
        cp "$ZSHRC_SRC" "$ZSHRC_DEST"
        ok "Deployed clean ~/.zshrc"
    fi
fi

# Global Gitignore (~/.gitignore_global)
GLOBAL_GITIGNORE="$HOME/.gitignore_global"
if [ ! -f "$GLOBAL_GITIGNORE" ]; then
    cat > "$GLOBAL_GITIGNORE" << 'EOF'
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
*.swp
*.swo
*~
.idea/
.vscode/
*.local
EOF
    git config --global core.excludesfile "$GLOBAL_GITIGNORE"
    ok "Created global gitignore (~/.gitignore_global)."
else
    git config --global core.excludesfile "$GLOBAL_GITIGNORE"
    ok "Global gitignore ready."
fi

# Git Delta configuration (syntax-highlighting diff pager)
if command -v delta >/dev/null 2>&1; then
    git config --global core.pager "delta"
    git config --global interactive.diffFilter "delta --color-only"
    git config --global delta.navigate true
    git config --global delta.light false
    git config --global delta.side-by-side false
    git config --global delta.line-numbers true
    ok "Configured Git to use Delta for syntax-highlighted diffs."
fi

# macOS SSH Keychain integration (~/.ssh/config)
SSH_CONFIG="$HOME/.ssh/config"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [ ! -f "$SSH_CONFIG" ] || ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
    cat >> "$SSH_CONFIG" << 'EOF'

Host github.com
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519
EOF
    chmod 600 "$SSH_CONFIG"
    ok "Configured ~/.ssh/config with GitHub Keychain integration."
else
    ok "SSH config for github.com ready."
fi

if [ -f "$HOME/.ssh/id_ed25519" ] && [ -t 0 ] && [ "$NON_INTERACTIVE" = false ]; then
    ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519" 2>/dev/null || true
fi

# Obsidian Git Plugin (Vinzent03/obsidian-git)
OBSIDIAN_CACHE="$HOME/.config/obsidian/plugins/obsidian-git"
mkdir -p "$OBSIDIAN_CACHE"

GIT_RELEASE_URL="https://github.com/Vinzent03/obsidian-git/releases/latest/download"
if [ ! -f "$OBSIDIAN_CACHE/manifest.json" ] || [ ! -f "$OBSIDIAN_CACHE/main.js" ]; then
    info "Downloading latest Obsidian Git plugin..."
    curl -fsSL "$GIT_RELEASE_URL/manifest.json" -o "$OBSIDIAN_CACHE/manifest.json" 2>/dev/null || true
    curl -fsSL "$GIT_RELEASE_URL/main.js" -o "$OBSIDIAN_CACHE/main.js" 2>/dev/null || true
    curl -fsSL "$GIT_RELEASE_URL/styles.css" -o "$OBSIDIAN_CACHE/styles.css" 2>/dev/null || true
fi

install_obsidian_git() {
    local vault_dir="$1"
    if [ -d "$vault_dir" ] && [ -f "$OBSIDIAN_CACHE/main.js" ]; then
        local plugin_dir="$vault_dir/.obsidian/plugins/obsidian-git"
        mkdir -p "$plugin_dir"
        cp "$OBSIDIAN_CACHE/manifest.json" "$plugin_dir/manifest.json"
        cp "$OBSIDIAN_CACHE/main.js" "$plugin_dir/main.js"
        [ -f "$OBSIDIAN_CACHE/styles.css" ] && cp "$OBSIDIAN_CACHE/styles.css" "$plugin_dir/styles.css"

        local comm_plugins="$vault_dir/.obsidian/community-plugins.json"
        if [ -f "$comm_plugins" ]; then
            if ! grep -q '"obsidian-git"' "$comm_plugins" 2>/dev/null; then
                if command -v jq >/dev/null 2>&1; then
                    jq '. + ["obsidian-git"] | unique' "$comm_plugins" > "${comm_plugins}.tmp" && mv "${comm_plugins}.tmp" "$comm_plugins"
                fi
            fi
        else
            echo '["obsidian-git"]' > "$comm_plugins"
        fi
        ok "Obsidian Git plugin configured in $(basename "$vault_dir")"
    fi
}

# Auto-configure git plugin for all registered Obsidian vaults
if [ -f "$HOME/Library/Application Support/obsidian/obsidian.json" ] && command -v jq >/dev/null 2>&1; then
    for vault in $(jq -r '.vaults[].path // empty' "$HOME/Library/Application Support/obsidian/obsidian.json" 2>/dev/null); do
        install_obsidian_git "$vault"
    done
fi

# Also check common workspace vault paths
for potential_vault in "$HOME/dev/banda/guide" "$HOME/dev/guide" "$HOME/Documents/Obsidian Vault"; do
    if [ -d "$potential_vault/.obsidian" ]; then
        install_obsidian_git "$potential_vault"
    fi
done

# ------------------------------------------------------------------------------
# 7. Practical macOS Developer Defaults
# ------------------------------------------------------------------------------
step "[7/7] macOS Developer Defaults"

apply_defaults() {
    info "Applying key repeat and Finder settings..."
    defaults write -g InitialKeyRepeat -int 14
    defaults write -g KeyRepeat -int 2
    defaults write -g ApplePressAndHoldEnabled -bool false
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
    killall Finder 2>/dev/null || true
    ok "Settings applied."
}

if [ "$SKIP_MACOS_DEFAULTS" = true ]; then
    info "Skipping macOS defaults."
elif [ "$NON_INTERACTIVE" = true ]; then
    apply_defaults
else
    if confirm "Apply macOS developer defaults (fast key repeat, Finder path bar, show extensions)?"; then
        apply_defaults
    else
        info "Skipped macOS defaults."
    fi
fi

# ------------------------------------------------------------------------------
# Complete
# ------------------------------------------------------------------------------
printf "\n${BOLD}Setup complete.${RESET}\n\n"
printf "Next steps:\n"
printf "  1. Launch iTerm2 (/Applications/iTerm.app)\n"
printf "  2. Run 'source ~/.zshrc' to activate the shell\n\n"
printf "Key tools & aliases configured:\n"
printf "  ls, ll, la, lt  -> eza (grouped directories, git status)\n"
printf "  cat, catp       -> bat (plain syntax-highlighting)\n"
printf "  cd <dir>        -> z <dir> (zoxide jump)\n"
printf "  lg              -> lazygit\n"
printf "  v, vi           -> nvim (Neovim)\n"
printf "  du              -> dust (interactive disk usage)\n"
printf "  Ctrl + R        -> fzf history search\n"
printf "  Ctrl + T        -> fzf file search\n"
printf "  glog            -> concise one-line git log graph\n"
printf "  fnm             -> Fast Node Manager (Node 22 LTS ready)\n"
printf "  pnpm            -> Fast, disk space efficient package manager\n"
printf "  uv              -> Modern, blazing fast Python package manager\n"
printf "  tldr <cmd>      -> Quick community cheat sheets\n"
printf "  delta           -> Syntax-highlighting git diff pager\n"
printf "  jjui / jju      -> Jujutsu interactive Terminal UI\n"
printf "  gg              -> Jujutsu desktop visual GUI\n"
printf "  obsidian        -> Markdown knowledge base & notes (with git plugin pre-installed)\n\n"
