# Cara mengembalikan perubahan (5 Okt 2026)
- Dock cepat: defaults delete com.apple.dock autohide-delay; defaults delete com.apple.dock autohide-time-modifier; killall Dock
- AeroSpace: cp ~/.config/sketchybar/sketchybarrc.pre-aerospace ~/.config/sketchybar/sketchybarrc; sketchybar --reload; brew uninstall --cask aerospace; rm ~/.aerospace.toml
- Popup jam/baterai: termasuk di sketchybarrc.pre-aerospace (dibuat sebelum popup)
- Raycast: brew uninstall --cask raycast

## Terminal (iTerm2 + tmux + Neovim + Starship) — 5 Okt 2026
- Prompt: hapus baris `eval "$(starship init zsh)"` di ~/.zshrc (backup: ~/.zshrc.bak-terminal). Config: ~/.config/starship.toml
- tmux: hapus ~/.tmux.conf. Profil iTerm otomatis buka tmux; matikan di iTerm > Settings > Profiles > General > Command.
- iTerm profil: ~/Library/Application Support/iTerm2/DynamicProfiles/catppuccin-mocha.json
- Neovim: hapus ~/.config/nvim dan ~/.local/share/nvim
- Uninstall: brew uninstall --cask iterm2; brew uninstall tmux starship ripgrep fd lazygit
