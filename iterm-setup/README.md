# macOS Developer & iTerm2 Setup

A clean, distraction-free bootstrap script for brand-new or freshly wiped MacBook Pros.

No glassmorphism, no transparency/blur, no emoji clutter, no neon glitter. Just a sharp, high-contrast, fast terminal and developer toolkit.

---

## Quickstart

```bash
cd /Users/eal/dev/guide/iterm-setup
chmod +x setup.sh
./setup.sh
```

> **Tip:** The script is completely idempotent and re-entrant. You can rerun it anytime on any machine to pull down changes and bring the environment up to date without duplicate backups or side-effects.

**Non-interactive mode:**
```bash
./setup.sh -y
```

**Skip macOS system defaults:**
```bash
./setup.sh --skip-defaults
```

---

## Design Principles

- **Zero visual noise**: 0% window transparency, 0px blur, solid high-contrast dark background (`#181a1f` / `#121212`).
- **Clean typography**: Crisp JetBrains Mono Nerd Font 14pt with solid non-blinking block cursor.
- **Distraction-free single-line prompt**: Starship configured with single-line layout where the full PWD directly precedes the prompt symbol (`~/path git:main ❯`), without line breaks or repo truncation.
- **Practical toolchain**:
  - `eza` for directories without icon clutter (`--group-directories-first`, git status).
  - `bat` with native ANSI theme and plain line numbering.
  - `zoxide` for directory jumping (`z <dir>`).
  - `fzf` without bulky borders (`Ctrl+R` for history, `Ctrl+T` for files).
  - `lazygit` for terminal git workflow (`lg`).
  - `delta` for syntax-highlighted git diffs and logs.
  - `fnm` for blazing fast Node version management (pre-configured with Node 22 LTS).
  - `pnpm` fast disk-efficient package manager.
  - `uv` ultra-fast Python package and virtual environment manager.
  - `tealdeer` (`tldr`) instant cheat sheets for shell commands.
  - `direnv` per-directory environment variable isolation.
  - `dust` visual disk usage inspection (`du`).
  - `neovim` (`nvim`) modern terminal text editor.
  - `OrbStack` fast, low-overhead Docker & Linux container runtime.
  - `btop` for resource monitoring.

---

## Aliases Reference

| Command | Action |
| :--- | :--- |
| `ls` | Group directories first, clean output |
| `ll` | Detailed list with human-readable sizes, permissions, and git status |
| `la` | List all files including hidden dotfiles |
| `lt` | Tree view (depth 2) |
| `cat <file>` | Fast syntax-highlighted viewer via `bat` |
| `z <dir>` | Intelligent directory jump via `zoxide` |
| `lg` | Launch LazyGit |
| `v` / `vi` | Open Neovim |
| `du` | Interactive disk usage tree via `dust` |
| `tldr <cmd>` | Instant CLI cheat sheet via `tealdeer` |
| `Ctrl + R` | Fuzzy history search |
| `Ctrl + T` | Fuzzy file path search |
| `glog` | Compact one-line Git log graph |
| `mkcd <dir>` | Create directory and cd into it |
| `ports` | Show listening TCP ports |
