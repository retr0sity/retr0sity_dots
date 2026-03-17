#!/bin/bash
# ─────────────────────────────────────────────────────────────────
# retr0sity_dots — install script for Fedora
# ─────────────────────────────────────────────────────────────────

set -e

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

echo -e "${CYAN}  retr0sity_dots — Fedora installer${NC}"
echo ""

if ! command -v dnf &>/dev/null; then
    print_error "This script requires Fedora (dnf not found)."
    exit 1
fi
print_ok "Fedora detected"

# ── Add Hyprland COPR ─────────────────────────────────────────────
print_step "Adding Hyprland COPR repository..."
sudo dnf copr enable -y solopasha/hyprland
print_ok "COPR added"

# ── Install packages ──────────────────────────────────────────────
print_step "Installing packages..."
sudo dnf install -y \
    hyprland \
    swaybg \
    xdg-desktop-portal-hyprland \
    qt5-qtwayland \
    qt6-qtwayland \
    waybar \
    dunst \
    libnotify \
    kitty \
    wofi \
    pipewire \
    pipewire-pulse \
    wireplumber \
    pavucontrol \
    wl-clipboard \
    cliphist \
    grim \
    slurp \
    polkit-gnome \
    playerctl \
    jetbrains-mono-fonts \
    google-noto-fonts-common \
    papirus-icon-theme \
    blueman \
    network-manager-applet \
    qt6ct \
    kvantum \
    tlp \
    dolphin \
    firefox \
    brightnessctl

print_ok "Packages installed"

# ── Build wlogout from source ─────────────────────────────────────
print_step "Building wlogout from source..."
if ! command -v wlogout &>/dev/null; then
    sudo dnf install -y cmake wayland-devel gtk-layer-shell-devel \
        wayland-protocols-devel git
    git clone https://github.com/ArtsyMacaw/wlogout.git /tmp/wlogout
    cd /tmp/wlogout
    cmake -B build && cmake --build build
    sudo cmake --install build
    cd -
    print_ok "wlogout built and installed"
else
    print_ok "wlogout already installed"
fi

# ── grimblast workaround ──────────────────────────────────────────
print_step "Installing grimblast..."
if ! command -v grimblast &>/dev/null; then
    sudo dnf install -y hyprland-contrib 2>/dev/null || \
    (git clone https://github.com/hyprwm/contrib.git /tmp/hypr-contrib && \
     sudo install -m755 /tmp/hypr-contrib/grimblast/grimblast /usr/local/bin/)
    print_ok "grimblast installed"
fi

# ── Enable services ───────────────────────────────────────────────
print_step "Enabling services..."
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
sudo systemctl enable --now bluetooth 2>/dev/null || true
sudo systemctl enable --now tlp 2>/dev/null || true
print_ok "Services enabled"

# ── Copy configs ──────────────────────────────────────────────────
print_step "Installing config files..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/hyprland-backup-$(date +%Y%m%d-%H%M%S)"

for d in hypr waybar dunst kitty wofi wlogout; do
    if [ -d "$HOME/.config/$d" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -r "$HOME/.config/$d" "$BACKUP_DIR/"
    fi
    if [ -d "$SCRIPT_DIR/$d" ]; then
        mkdir -p "$HOME/.config/$d"
        cp -r "$SCRIPT_DIR/$d/"* "$HOME/.config/$d/"
        print_ok "Installed ~/.config/$d"
    fi
done

sed -i "s|/home/hotzas|/home/$USER|g" \
    "$HOME/.config/hypr/hyprland.conf" \
    "$HOME/.config/hypr/hyprpaper.conf" 2>/dev/null || true

# ── GTK dark mode ─────────────────────────────────────────────────
print_step "Setting GTK dark mode..."
gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark 2>/dev/null || true

mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
for v in 3.0 4.0; do
cat > "$HOME/.config/gtk-$v/settings.ini" << 'GTKEOF'
[Settings]
gtk-theme-name=Adwaita-dark
gtk-application-prefer-dark-theme=1
gtk-font-name=Noto Sans 10
gtk-cursor-theme-size=24
GTKEOF
done
print_ok "GTK dark mode configured"

# ── Wallpaper ─────────────────────────────────────────────────────
mkdir -p "$HOME/Pictures"
[ ! -f "$HOME/Pictures/wall.png" ] && \
    print_warn "Place a wallpaper at ~/Pictures/wall.png"

echo ""
echo -e "${GREEN}  Installation complete! Log into Hyprland from your display manager.${NC}"
echo ""

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
