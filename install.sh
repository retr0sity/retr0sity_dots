#!/bin/bash
# ─────────────────────────────────────────────────────────────────
# hotzas-hyprland — install script
# Arch Linux only
# ─────────────────────────────────────────────────────────────────

set -e

# ── Colors ────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_step()  { echo -e "${BLUE}==>${NC} $1"; }
print_ok()    { echo -e "${GREEN} ✓${NC} $1"; }
print_warn()  { echo -e "${YELLOW} !${NC} $1"; }
print_error() { echo -e "${RED} ✗${NC} $1"; }

# ── Header ────────────────────────────────────────────────────────
echo -e "${CYAN}"
echo "  ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗ "
echo "  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗"
echo "  ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║"
echo "  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║"
echo "  ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝"
echo "  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝"
echo -e "${NC}"
echo -e "  ${CYAN}Minimal Hyprland config — by hotzas${NC}"
echo ""

# ── Check Arch ────────────────────────────────────────────────────
if ! command -v pacman &>/dev/null; then
    print_error "This script requires Arch Linux (pacman not found)."
    exit 1
fi
print_ok "Arch Linux detected"

# ── Check AUR helper ──────────────────────────────────────────────
AUR_HELPER=""
if command -v paru &>/dev/null; then
    AUR_HELPER="paru"
elif command -v yay &>/dev/null; then
    AUR_HELPER="yay"
else
    print_warn "No AUR helper found (paru or yay). AUR packages will be skipped."
    print_warn "Install paru first: https://github.com/Morganamilo/paru"
fi
[ -n "$AUR_HELPER" ] && print_ok "AUR helper found: $AUR_HELPER"

# ── Backup existing configs ───────────────────────────────────────
print_step "Backing up existing configs..."
BACKUP_DIR="$HOME/.config/hyprland-backup-$(date +%Y%m%d-%H%M%S)"
DIRS=(hypr waybar dunst kitty wofi wlogout)
for d in "${DIRS[@]}"; do
    if [ -d "$HOME/.config/$d" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -r "$HOME/.config/$d" "$BACKUP_DIR/"
        print_ok "Backed up ~/.config/$d → $BACKUP_DIR/$d"
    fi
done

# ── Install pacman packages ───────────────────────────────────────
print_step "Installing pacman packages..."
PACMAN_PKGS=(
    hyprland
    swaybg
    xdg-desktop-portal-hyprland
    qt5-wayland
    qt6-wayland
    waybar
    dunst
    libnotify
    kitty
    wofi
    pipewire
    pipewire-pulse
    wireplumber
    pavucontrol
    wl-clipboard
    cliphist
    grim
    slurp
    polkit-gnome
    playerctl
    ttf-jetbrains-mono-nerd
    noto-fonts
    noto-fonts-emoji
    papirus-icon-theme
    blueman
    network-manager-applet
    qt6ct
    kvantum
    tlp
    dolphin
    firefox \
    brightnessctl
)

sudo pacman -Syu --needed --noconfirm "${PACMAN_PKGS[@]}"
print_ok "Pacman packages installed"

# ── Install AUR packages ──────────────────────────────────────────
if [ -n "$AUR_HELPER" ]; then
    print_step "Installing AUR packages..."
    AUR_PKGS=(
        grimblast-git
        bibata-cursor-theme
        wlogout
    )
    $AUR_HELPER -S --needed --noconfirm "${AUR_PKGS[@]}"
    print_ok "AUR packages installed"
else
    print_warn "Skipping AUR packages: grimblast-git, bibata-cursor-theme, wlogout"
fi

# ── Enable services ───────────────────────────────────────────────
print_step "Enabling services..."
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
sudo systemctl enable --now bluetooth 2>/dev/null || true
sudo systemctl enable --now tlp 2>/dev/null || true
print_ok "Services enabled"

# ── Copy config files ─────────────────────────────────────────────
print_step "Installing config files..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIRS=(hypr waybar dunst kitty wofi wlogout)

for d in "${DIRS[@]}"; do
    if [ -d "$SCRIPT_DIR/$d" ]; then
        mkdir -p "$HOME/.config/$d"
        cp -r "$SCRIPT_DIR/$d/"* "$HOME/.config/$d/"
        print_ok "Installed ~/.config/$d"
    fi
done

# ── Set username in configs ───────────────────────────────────────
print_step "Configuring for user: $USER..."
sed -i "s|/home/hotzas|/home/$USER|g" \
    "$HOME/.config/hypr/hyprland.conf" \
    "$HOME/.config/hypr/hyprpaper.conf" \
    2>/dev/null || true
print_ok "Updated username in configs"

# ── Wallpaper setup ───────────────────────────────────────────────
print_step "Setting up wallpaper directory..."
mkdir -p "$HOME/Pictures"
if [ ! -f "$HOME/Pictures/wall.png" ]; then
    print_warn "No wallpaper found at ~/Pictures/wall.png"
    print_warn "Place a PNG image there, or edit the swaybg line in ~/.config/hypr/hyprland.conf"
else
    print_ok "Wallpaper found at ~/Pictures/wall.png"
fi

# ── GTK dark mode ─────────────────────────────────────────────────
print_step "Setting GTK dark mode..."
gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme Breeze-Dark 2>/dev/null || true

mkdir -p "$HOME/.config/gtk-3.0"
cat > "$HOME/.config/gtk-3.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=Breeze-Dark
gtk-icon-theme-name=breeze-dark
gtk-font-name=Noto Sans 10
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF

mkdir -p "$HOME/.config/gtk-4.0"
cat > "$HOME/.config/gtk-4.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=Breeze-Dark
gtk-icon-theme-name=breeze-dark
gtk-font-name=Noto Sans 10
gtk-cursor-theme-name=Bibata-Modern-Classic
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF
print_ok "GTK dark mode configured"

# ── Monitor detection ─────────────────────────────────────────────
print_step "Monitor note..."
print_warn "After first login, run: hyprctl monitors"
print_warn "Then update the monitor= line in ~/.config/hypr/hyprland.conf"
print_warn "Default is set to eDP-1 (laptop internal display)"

# ── Done ──────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Installation complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${CYAN}Next steps:${NC}"
echo -e "  1. Place a wallpaper at ${YELLOW}~/Pictures/wall.png${NC}"
echo -e "  2. Log into Hyprland from your display manager"
echo -e "  3. Press ${YELLOW}Super + Return${NC} to open a terminal"
echo -e "  4. Run ${YELLOW}hyprctl monitors${NC} to verify your monitor name"
echo ""
if [ -d "$BACKUP_DIR" ]; then
    echo -e "  ${CYAN}Your old configs were backed up to:${NC}"
    echo -e "  ${YELLOW}$BACKUP_DIR${NC}"
    echo ""
fi

# ── nmtui-dark wrapper ────────────────────────────────────────────
print_step "Installing nmtui-dark wrapper..."
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/nmtui-dark" << 'NMTUIEOF'
#!/bin/bash
TERM=xterm-256color nmtui
NMTUIEOF
chmod +x "$HOME/.local/bin/nmtui-dark"
grep -q "local/bin" "$HOME/.zshrc" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
grep -q "local/bin" "$HOME/.bashrc" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
print_ok "nmtui-dark installed"
