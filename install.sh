#!/usr/bin/env bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=======================================${NC}"
echo -e "${GREEN}Starting Terminal Setup Installation...${NC}"
echo -e "${BLUE}=======================================${NC}"

# 1. Update and install prerequisites
echo -e "\n${YELLOW}[1/5] Installing prerequisites (curl, git, fontconfig)...${NC}"
sudo apt update
sudo apt install -y curl git fontconfig unzip

# 2. Install JetBrainsMono Nerd Font
echo -e "\n${YELLOW}[2/5] Installing JetBrainsMono Nerd Font...${NC}"
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

if fc-list | grep -iq "JetBrainsMono"; then
    echo -e "${GREEN}JetBrainsMono Nerd Font is already installed.${NC}"
else
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    TMP_DIR=$(mktemp -d)
    
    echo "Downloading JetBrainsMono..."
    curl -fLo "$TMP_DIR/JetBrainsMono.zip" "$FONT_URL"
    
    echo "Extracting fonts..."
    unzip -q "$TMP_DIR/JetBrainsMono.zip" -d "$TMP_DIR"
    
    echo "Moving fonts to $FONT_DIR..."
    find "$TMP_DIR" -name "*.ttf" -exec cp {} "$FONT_DIR/" \;
    
    echo "Updating font cache..."
    fc-cache -fv
    
    rm -rf "$TMP_DIR"
    echo -e "${GREEN}JetBrainsMono Nerd Font installed successfully!${NC}"
fi

# 3. Install WezTerm
echo -e "\n${YELLOW}[3/5] Installing WezTerm...${NC}"
if command -v wezterm >/dev/null 2>&1; then
    echo -e "${GREEN}WezTerm is already installed.${NC}"
else
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
    sudo apt update
    sudo apt install -y wezterm
    echo -e "${GREEN}WezTerm installed successfully!${NC}"
fi

# 4. Install Starship
echo -e "\n${YELLOW}[4/5] Installing Starship...${NC}"
if command -v starship >/dev/null 2>&1; then
    echo -e "${GREEN}Starship is already installed.${NC}"
else
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    echo -e "${GREEN}Starship installed successfully!${NC}"
fi

# 5. Apply Configurations
echo -e "\n${YELLOW}[5/5] Applying Configurations...${NC}"

# Backup existing configs
echo "Backing up existing configurations..."
[ -f ~/.config/starship.toml ] && mv ~/.config/starship.toml ~/.config/starship.toml.backup.$(date +%F_%T)
[ -d ~/.config/wezterm ] && mv ~/.config/wezterm ~/.config/wezterm.backup.$(date +%F_%T)

# Copy new configs
echo "Copying new configurations..."
mkdir -p ~/.config
cp -r config/starship.toml ~/.config/
cp -r config/wezterm ~/.config/

# Inject bashrc hook
BASHRC_HOOK_SCRIPT="bashrc_hook.sh"
if ! grep -q "WezTerm & Starship Dynamic Theme Configuration" ~/.bashrc; then
    echo "Injecting terminal configuration into ~/.bashrc..."
    echo -e "\n" >> ~/.bashrc
    cat "$BASHRC_HOOK_SCRIPT" >> ~/.bashrc
    echo -e "${GREEN}Injected successfully!${NC}"
else
    echo -e "${BLUE}Configuration already exists in ~/.bashrc, skipping injection.${NC}"
fi

echo -e "\n${BLUE}=======================================${NC}"
echo -e "${GREEN}Installation Completed Successfully!${NC}"
echo -e "${YELLOW}Please restart your terminal or run 'exec bash' to apply changes.${NC}"
echo -e "${BLUE}=======================================${NC}"
