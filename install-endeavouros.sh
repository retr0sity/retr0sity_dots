#!/bin/bash
# ─────────────────────────────────────────────────────────────────
# retr0sity_dots — install script for EndeavourOS / Garuda Linux
# (Arch-based, identical to Arch install with minor tweaks)
# ─────────────────────────────────────────────────────────────────

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

print_step()  { echo -e "${BLUE}==>${NC} $1"; }
print_ok()    { echo -e "${GREEN} ✓${NC} $1"; }
print_warn()  { echo -e "${YELLOW} !${NC} $1"; }

echo -e "${CYAN}  retr0sity_dots — EndeavourOS / Garuda installer${NC}"
echo ""

if ! command -v pacman &>/dev/null; then
    echo -e "${RED}This script requires an Arch-based distro.${NC}"; exit 1
fi

# EndeavourOS and Garuda both ship with yay by default
AUR_HELPER=""
if command -v paru &>/dev/null; then AUR_HELPER="paru"
elif command -v yay &>/dev/null; then AUR_HELPER="yay"
else
    print_warn "No AUR helper found. Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm && cd -
    AUR_HELPER="yay"
fi
print_ok "AUR helper: $AUR_HELPER"

# ── Backup ────────────────────────────────────────────────────────
BACKUP_DIR="$HOME/.config/hyprland-backup-$(date +%Y%m%d-%H%M%S)"
for d in hypr waybar dunst kitty wofi wlogout; do
    [ -d "$HOME/.config/$d" ] && mkdir -p "$BACKUP_DIR" && \
        cp -r "$HOME/.config/$d" "$BACKUP_DIR/"
done

# ── Packages ──────────────────────────────────────────────────────
print_step "Installing pacman packages..."
sudo pacman -Syu --needed --noconfirm \
    hyprland swaybg xdg-desktop-portal-hyprland \
    qt5-wayland qt6-wayland waybar dunst libnotify kitty wofi \
    pipewire pipewire-pulse wireplumber pavucontrol \
    wl-clipboard cliphist grim slurp polkit-gnome playerctl \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji \
    papirus-icon-theme blueman network-manager-applet \
    qt6ct kvantum tlp dolphin firefox brightnessctl
print_ok "Pacman packages installed"

print_step "Installing AUR packages..."
$AUR_HELPER -S --needed --noconfirm grimblast-git bibata-cursor-theme wlogout swayosd-git swayosd-git
print_ok "AUR packages installed"

# ── Services ──────────────────────────────────────────────────────
print_step "Enabling services..."
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
sudo systemctl enable --now bluetooth 2>/dev/null || true
sudo systemctl enable --now tlp 2>/dev/null || true
print_ok "Services enabled"

# ── Configs ───────────────────────────────────────────────────────
print_step "Installing config files..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for d in hypr waybar dunst kitty wofi wlogout; do
    [ -d "$SCRIPT_DIR/$d" ] && mkdir -p "$HOME/.config/$d" && \
        cp -r "$SCRIPT_DIR/$d/"* "$HOME/.config/$d/" && \
        print_ok "Installed ~/.config/$d"
done

sed -i "s|/home/hotzas|/home/$USER|g" \
    "$HOME/.config/hypr/hyprland.conf" \
    "$HOME/.config/hypr/hyprpaper.conf" 2>/dev/null || true

# ── GTK dark mode ─────────────────────────────────────────────────
gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme Breeze-Dark 2>/dev/null || true
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
for v in 3.0 4.0; do
cat > "$HOME/.config/gtk-$v/settings.ini" << 'GTKEOF'
[Settings]
gtk-theme-name=Breeze-Dark
gtk-application-prefer-dark-theme=1
gtk-font-name=Noto Sans 10
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
GTKEOF
done
print_ok "GTK dark mode configured"

mkdir -p "$HOME/Pictures"
[ ! -f "$HOME/Pictures/wall.png" ] && \
    print_warn "Place a wallpaper at ~/Pictures/wall.png"

echo ""
echo -e "${GREEN}  Done! Log into Hyprland from your display manager.${NC}"
echo ""
