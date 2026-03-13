<div align="center">

# retr0sity_dots

**A minimal, dark Hyprland desktop configuration for developers and sysadmins.**

![Hyprland](https://img.shields.io/badge/Hyprland-0.53+-blue?style=flat-square)
![Theme](https://img.shields.io/badge/Theme-Catppuccin%20Mocha-pink?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

</div>

---

## ✨ Features

- **Catppuccin Mocha** color palette across all components
- Minimal, clean aesthetic — no bloat
- Vim-style keybindings throughout
- Dev & sysadmin / CTF focused workflow
- Single 1080p monitor optimized
- Master layout with 50/50 split

## 🧩 Components

| Component | Package |
|-----------|---------|
| Window Manager | `hyprland` |
| Status Bar | `waybar` |
| Terminal | `kitty` |
| Shell | `zsh` + `oh-my-zsh` + `powerlevel10k` |
| Launcher | `wofi` |
| Notifications | `dunst` |
| Wallpaper | `swaybg` |
| Logout Menu | `wlogout` |
| File Manager | `dolphin` |
| Bluetooth | `blueman` |
| Screenshots | `grimblast` |
| Clipboard | `cliphist` + `wl-clipboard` |
| Auth Agent | `polkit-gnome` |

---

## 🐧 Supported Distros

| Distro | Support | Install Script |
|--------|---------|---------------|
| **Arch Linux** | ✅ Full | `install.sh` |
| **EndeavourOS** | ✅ Full | `install-endeavouros.sh` |
| **Garuda Linux** | ✅ Full | `install-endeavouros.sh` |
| **Manjaro** | ⚠️ Partial | `install-manjaro.sh` |
| **Fedora** | ⚠️ Partial | `install-fedora.sh` |
| **openSUSE Tumbleweed** | ⚠️ Partial | `install-opensuse.sh` |
| **Debian / Ubuntu** | ❌ Not recommended | Manual only |

> **Partial support** means the config files work perfectly, but the install script may need minor adjustments for package names or missing repos. See per-distro notes below.

### Distro Notes

**Arch / EndeavourOS / Garuda** — Fully supported. All packages available via pacman + AUR.

**Manjaro** — Supported but Hyprland in Manjaro repos may lag behind. If you encounter config parse errors, your Hyprland version may be outdated. Use pamac to install the AUR version instead.

**Fedora** — Hyprland is available via the `solopasha/hyprland` COPR. `wlogout` and `grimblast` are built from source automatically by the install script.

**openSUSE Tumbleweed** — Requires Tumbleweed (rolling). Leap is not supported. Hyprland is available via the X11:Wayland repository. `wlogout` and `grimblast` are built from source.

**Debian / Ubuntu** — Not recommended. Hyprland is not in official repos and packages are too outdated. Manual compilation required. Use a rolling release distro for the best Hyprland experience.

---

## 📦 Dependencies

### Core (all distros)
```
hyprland swaybg xdg-desktop-portal-hyprland
waybar dunst kitty wofi wlogout grimblast
pipewire pipewire-pulse wireplumber pavucontrol
wl-clipboard cliphist grim slurp
polkit-gnome playerctl
JetBrainsMono Nerd Font noto-fonts
papirus-icon-theme
```

### Optional but recommended
```
dolphin firefox blueman network-manager-applet
tlp kvantum qt6ct zsh oh-my-zsh
```

---

## 🚀 Installation

### Arch Linux
```bash
git clone https://github.com/retr0sity/retr0sity_dots.git
cd retr0sity_dots
chmod +x install.sh
./install.sh
```

### EndeavourOS / Garuda
```bash
git clone https://github.com/retr0sity/retr0sity_dots.git
cd retr0sity_dots
chmod +x install-endeavouros.sh
./install-endeavouros.sh
```

### Manjaro
```bash
git clone https://github.com/retr0sity/retr0sity_dots.git
cd retr0sity_dots
chmod +x install-manjaro.sh
./install-manjaro.sh
```

### Fedora
```bash
git clone https://github.com/retr0sity/retr0sity_dots.git
cd retr0sity_dots
chmod +x install-fedora.sh
./install-fedora.sh
```

### openSUSE Tumbleweed
```bash
git clone https://github.com/retr0sity/retr0sity_dots.git
cd retr0sity_dots
chmod +x install-opensuse.sh
./install-opensuse.sh
```

### Manual (any distro)
1. Install the dependencies listed above using your distro's package manager
2. Copy configs:
```bash
mkdir -p ~/.config/{hypr,waybar,dunst,kitty,wofi,wlogout}
cp hypr/*     ~/.config/hypr/
cp waybar/*   ~/.config/waybar/
cp dunst/*    ~/.config/dunst/
cp kitty/*    ~/.config/kitty/
cp wofi/*     ~/.config/wofi/
cp wlogout/*  ~/.config/wlogout/
```
3. Replace `hotzas` with your username in the configs:
```bash
sed -i "s|/home/hotzas|/home/$USER|g" \
    ~/.config/hypr/hyprland.conf \
    ~/.config/hypr/hyprpaper.conf
```
4. Set your monitor name:
```bash
hyprctl monitors  # find your monitor name
nano ~/.config/hypr/hyprland.conf  # update monitor= line
```
5. Place a wallpaper at `~/Pictures/wall.png`
6. Log into Hyprland from your display manager

---

## ⌨️ Keybindings

### Core
| Key | Action |
|-----|--------|
| `Super + Return` | Terminal (kitty) |
| `Super + T` | Terminal (kitty) |
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + Shift + F` | Toggle float |
| `Super + Shift + Q` | Exit Hyprland |
| `Super + Delete` | Log out |
| `Super + End` | Shutdown immediately |

### Apps
| Key | Action |
|-----|--------|
| `Super + Space` | App launcher (wofi) |
| `Super + B` | Firefox |
| `Super + E` | Dolphin file manager |
| `Super + N` | Network manager (nmtui) |
| `Super + D` | Discord |
| `Super + M` | Spotify |
| `Super + Shift + B` | Bluetooth manager |
| `Super + Shift + S` | Screenshot region |
| `Super + V` | Clipboard history |

### Window Focus (vim keys)
| Key | Action |
|-----|--------|
| `Super + H` | Focus left |
| `Super + L` | Focus right |
| `Super + K` | Focus up |
| `Super + J` | Focus down |

### Window Movement
| Key | Action |
|-----|--------|
| `Super + Shift + H` | Move window left |
| `Super + Shift + L` | Move window right |
| `Super + Shift + K` | Move window up |
| `Super + Shift + J` | Move window down |

### Resize Mode (`Super + R`, then:)
| Key | Action |
|-----|--------|
| `H / L / K / J` | Resize window |
| `Escape` | Exit resize mode |

### Workspaces
| Key | Action |
|-----|--------|
| `Super + 1-9` | Switch workspace |
| `Super + Shift + 1-9` | Move window to workspace |
| `Super + S` | Toggle scratchpad |
| `Super + Scroll` | Cycle workspaces |

---

## 🎨 Customization

### Wallpaper
```ini
# Edit in ~/.config/hypr/hyprland.conf:
exec-once = swaybg -i /path/to/your/wallpaper.png -m fill
```

### Colors
All components use **Catppuccin Mocha**. Main accent: `#89b4fa` (blue).
To swap the accent, find and replace `#89b4fa` across all config files.

### Monitor
```ini
# Single monitor
monitor=DP-1,1920x1080@144,0x0,1

# Multi monitor
monitor=DP-1,1920x1080@144,0x0,1
monitor=HDMI-A-1,1920x1080@60,1920x0,1
```

---

## 📝 Notes

- Tested on **Arch Linux** with an AMD Renoir APU
- Flatpak apps (Discord, Spotify) use standard Flatpak app IDs — adjust if yours differ
- Battery management via `tlp` recommended for laptops
- GTK dark mode enforced via `gsettings` and environment variables
- Firefox dark mode must be set manually via `about:addons → Themes → Dark`

## 📄 License

MIT — fork freely, make it yours.
