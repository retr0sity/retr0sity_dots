#!/bin/bash
# ─────────────────────────────────────────────────────────────────
# retr0sity_dots — install script for openSUSE Tumbleweed
# NOTE: Requires Tumbleweed (rolling). Leap is not supported.
# ─────────────────────────────────────────────────────────────────

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

print_step()  { echo -e "${BLUE}==>${NC} $1"; }
print_ok()    { echo -e "${GREEN} ✓${NC} $1"; }
print_warn()  { echo -e "${YELLOW} !${NC} $1"; }

echo -e "${CYAN}  retr0sity_dots — openSUSE Tumbleweed installer${NC}"
echo ""

if ! command -v zypper &>/dev/null; then
    echo -e "${RED}This script requires openSUSE (zypper not found).${NC}"; exit 1
fi

# Verify Tumbleweed
if ! grep -q "Tumbleweed" /etc/os-release 2>/dev/null; then
    print_warn "openSUSE Leap is not supported — Hyprland requires Tumbleweed."
    exit 1
fi
print_ok "openSUSE Tumbleweed detected"

# ── Add Hyprland repo ─────────────────────────────────────────────
print_step "Adding Hyprland repository..."
sudo zypper addrepo -f https://download.opensuse.org/repositories/X11:Wayland/openSUSE_Tumbleweed/ wayland
sudo zypper --gpg-auto-import-keys refresh
print_ok "Repository added"

# ── Install packages ──────────────────────────────────────────────
print_step "Installing packages..."
sudo zypper install -y \
    hyprland \
    swaybg \
    xdg-desktop-portal-hyprland \
    libqt5-qtwayland \
    qt6-qtwayland \
    waybar \
    dunst \
    libnotify4 \
    kitty \
    wofi \
    pipewire \
    pipewire-pulseaudio \
    wireplumber \
    pavucontrol \
    wl-clipboard \
    grim \
    slurp \
    polkit-gnome \
    playerctl \
    jetbrains-mono-fonts \
    noto-fonts \
    papirus-icon-theme \
    blueman \
    NetworkManager-applet \
    qt6ct \
    kvantum-qt6 \
    tlp \
    dolphin \
    firefox \
    brightnessctl

print_ok "Packages installed"

# ── wlogout from source ───────────────────────────────────────────
print_step "Building wlogout..."
if ! command -v wlogout &>/dev/null; then
    sudo zypper install -y cmake gtk-layer-shell-devel wayland-devel git
    git clone https://github.com/ArtsyMacaw/wlogout.git /tmp/wlogout
    cd /tmp/wlogout && cmake -B build && cmake --build build
    sudo cmake --install build && cd -
    print_ok "wlogout installed"
fi

# ── swayosd from source ──────────────────────────────────────────────
print_step "Building swayosd..."
if ! command -v swayosd-server &>/dev/null; then
    sudo zypper install -y gtk4-devel libadwaita-devel wayland-devel git cargo
    git clone https://github.com/ErikReider/SwayOSD.git /tmp/swayosd
    cd /tmp/swayosd && cargo build --release
    sudo install -m755 target/release/swayosd-server /usr/local/bin/
    sudo install -m755 target/release/swayosd-client /usr/local/bin/
    cd -
    print_ok "swayosd installed"
fi

# ── grimblast ─────────────────────────────────────────────────────
print_step "Installing grimblast..."
if ! command -v grimblast &>/dev/null; then
    git clone https://github.com/hyprwm/contrib.git /tmp/hypr-contrib
    sudo install -m755 /tmp/hypr-contrib/grimblast/grimblast /usr/local/bin/
    print_ok "grimblast installed"
fi

# ── Services ──────────────────────────────────────────────────────
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
sudo systemctl enable --now bluetooth 2>/dev/null || true
sudo systemctl enable --now tlp 2>/dev/null || true
print_ok "Services enabled"

# ── Configs ───────────────────────────────────────────────────────
print_step "Installing config files..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/hyprland-backup-$(date +%Y%m%d-%H%M%S)"

for d in hypr waybar dunst kitty wofi wlogout; do
    [ -d "$HOME/.config/$d" ] && mkdir -p "$BACKUP_DIR" && \
        cp -r "$HOME/.config/$d" "$BACKUP_DIR/"
    [ -d "$SCRIPT_DIR/$d" ] && mkdir -p "$HOME/.config/$d" && \
        cp -r "$SCRIPT_DIR/$d/"* "$HOME/.config/$d/" && \
        print_ok "Installed ~/.config/$d"
done

sed -i "s|/home/hotzas|/home/$USER|g" \
    "$HOME/.config/hypr/hyprland.conf" \
    "$HOME/.config/hypr/hyprpaper.conf" 2>/dev/null || true

gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true
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

mkdir -p "$HOME/Pictures"
[ ! -f "$HOME/Pictures/wall.png" ] && \
    print_warn "Place a wallpaper at ~/Pictures/wall.png"

echo ""
echo -e "${GREEN}  Done! Log into Hyprland from your display manager.${NC}"
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
