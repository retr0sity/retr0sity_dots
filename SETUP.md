# Hyprland Manual Setup Guide
## Arch Linux — Minimal Dev/Sysadmin, 1080p

---

## 1. Package Installation

Install everything with pacman + AUR helper (paru or yay):

```bash
# Core Wayland / Hyprland stack
sudo pacman -S hyprland hyprpaper xdg-desktop-portal-hyprland \
               qt5-wayland qt6-wayland

# Status bar
sudo pacman -S waybar

# Notifications
sudo pacman -S dunst libnotify

# Terminal
sudo pacman -S kitty

# App launcher
sudo pacman -S wofi

# Fonts (required for icons in waybar/dunst)
sudo pacman -S ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji

# Audio
sudo pacman -S pipewire pipewire-pulse wireplumber pavucontrol

# Clipboard
sudo pacman -S wl-clipboard cliphist

# Screenshots
sudo pacman -S grim slurp
paru -S grimblast-git           # wrapper that handles region/window

# Wallpaper (already pulled in by hyprpaper above)

# Auth agent (needed for sudo GUI prompts)
sudo pacman -S polkit-gnome

# Media control (for media keys)
sudo pacman -S playerctl

# Power menu (bound to the ⏻ button in waybar)
paru -S wlogout

# File manager inside kitty (optional but recommended)
sudo pacman -S yazi

# Cursor theme
paru -S bibata-cursor-theme

# Icon theme (used by dunst)
sudo pacman -S papirus-icon-theme
```

Enable audio services:
```bash
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

---

## 2. Config File Locations

Copy each config folder to its correct `~/.config/` path:

| Source (this zip)       | Destination                        |
|-------------------------|------------------------------------|
| `hypr/hyprland.conf`    | `~/.config/hypr/hyprland.conf`     |
| `hypr/hyprpaper.conf`   | `~/.config/hypr/hyprpaper.conf`    |
| `waybar/config.jsonc`   | `~/.config/waybar/config.jsonc`    |
| `waybar/style.css`      | `~/.config/waybar/style.css`       |
| `dunst/dunstrc`         | `~/.config/dunst/dunstrc`          |
| `kitty/kitty.conf`      | `~/.config/kitty/kitty.conf`       |
| `wofi/config`           | `~/.config/wofi/config`            |
| `wofi/style.css`        | `~/.config/wofi/style.css`         |

Quick deploy (run from the extracted folder):
```bash
mkdir -p ~/.config/{hypr,waybar,dunst,kitty,wofi}
cp hypr/*     ~/.config/hypr/
cp waybar/*   ~/.config/waybar/
cp dunst/*    ~/.config/dunst/
cp kitty/*    ~/.config/kitty/
cp wofi/*     ~/.config/wofi/
```

---

## 3. Wallpaper Setup

```bash
mkdir -p ~/Pictures/wallpapers
# Drop any .png/.jpg you like there and name it wall.png, or edit
# ~/.config/hypr/hyprpaper.conf to point at your actual filename.
```

---

## 4. Monitor Configuration

Run `hyprctl monitors` after starting Hyprland to get your exact monitor name, then edit `hyprland.conf`:

```ini
# Example — replace DP-1 with your real name
monitor=DP-1,1920x1080@144,0x0,1
```

For multi-monitor later:
```ini
monitor=DP-1,1920x1080@144,0x0,1
monitor=HDMI-A-1,1920x1080@60,1920x0,1
```

---

## 5. SDDM / Login Manager (optional)

```bash
sudo pacman -S sddm
sudo systemctl enable sddm
```

Hyprland will appear as a session option automatically.

---

## 6. Key Bindings Reference

| Shortcut                  | Action                          |
|---------------------------|---------------------------------|
| `Super + Return`          | Open Kitty terminal             |
| `Super + Space`           | Open Wofi launcher              |
| `Super + Q`               | Close focused window            |
| `Super + Shift + Q`       | Exit Hyprland                   |
| `Super + F`               | Fullscreen toggle               |
| `Super + Shift + F`       | Float toggle                    |
| `Super + H/J/K/L`         | Focus window (vim directions)   |
| `Super + Shift + H/J/K/L` | Move window                     |
| `Super + R` → H/J/K/L     | Resize mode (Escape to exit)    |
| `Super + 1-9`             | Switch workspace                |
| `Super + Shift + 1-9`     | Move window to workspace        |
| `Super + S`               | Toggle scratchpad               |
| `Super + Shift + S`       | Screenshot region (to clipboard)|
| `Super + V`               | Clipboard history (wofi)        |
| `Super + E`               | Yazi file manager in kitty      |

---

## 7. Theming Notes

All configs use **Catppuccin Mocha** colors. If you want to swap palettes:
- The main accent color `#89b4fa` (blue) is used throughout all configs.
- A global find+replace across the config files is all you need to recolor.

GTK theme (for apps like Thunar, Firefox):
```bash
paru -S catppuccin-gtk-theme-mocha
# Then set in ~/.config/gtk-3.0/settings.ini and gtk-4.0/settings.ini
# gtk-theme-name=catppuccin-mocha-standard-blue-dark
```

---

## 8. Troubleshooting

**Waybar not showing icons:**
Make sure `ttf-jetbrains-mono-nerd` is installed and your font cache is rebuilt:
```bash
fc-cache -fv
```

**Screen sharing not working:**
```bash
paru -S xdg-desktop-portal-hyprland
# Make sure only ONE xdg portal is running:
systemctl --user list-units | grep xdg
```

**Apps not launching on Wayland:**
Check `env` block in `hyprland.conf` — the `QT_QPA_PLATFORM` and `GDK_BACKEND` vars handle most cases.

**Cursor invisible or wrong size:**
```ini
# In hyprland.conf env block:
env = XCURSOR_SIZE,24
env = XCURSOR_THEME,Bibata-Modern-Classic
```
Also run: `hyprctl setcursor Bibata-Modern-Classic 24`
