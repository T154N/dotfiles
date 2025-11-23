#!/bin/bash

# Colores para output bonito
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Iniciando Setup de Entorno de Santiago Arias...${NC}"

# ----------------------------------------------------------------------
# 1. Instalación de Paquetes Base (Fedora)
# ----------------------------------------------------------------------
echo -e "${GREEN}📦 Actualizando repositorios e instalando paquetes...${NC}"
sudo dnf update -y
sudo dnf install -y stow git curl wget zsh tar unzip fontconfig

# Instalar paquetes desde la lista generada (si existe)
if [ -f "$HOME/dotfiles/setup/packages.txt" ]; then
    echo -e "${GREEN}📜 Leyendo packages.txt...${NC}"
    # xargs toma la lista y se la pasa a dnf
    sudo dnf install -y $(cat "$HOME/dotfiles/setup/packages.txt")
else
    echo -e "${BLUE}⚠️ No encontré packages.txt, instalando esenciales por defecto...${NC}"
    sudo dnf install -y fzf ripgrep bat zoxide tmux alacritty neovim
fi

# ----------------------------------------------------------------------
# 2. Instalación de Fuentes (Hack Nerd Font)
# ----------------------------------------------------------------------
FONT_DIR="$HOME/.local/share/fonts"
if [ ! -d "$FONT_DIR/Hack" ]; then
    echo -e "${GREEN}abb Instalando Hack Nerd Font...${NC}"
    mkdir -p "$FONT_DIR"
    wget -P /tmp https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip
    unzip -o /tmp/Hack.zip -d "$FONT_DIR"
    rm /tmp/Hack.zip
    fc-cache -fv
    echo -e "${GREEN}✅ Fuentes instaladas.${NC}"
else
    echo -e "${BLUE}ℹ️ Hack Nerd Font ya está instalada.${NC}"
fi

# ----------------------------------------------------------------------
# 3. Oh My Zsh & Plugins
# ----------------------------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${GREEN}abb Instalando Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Powerlevel10k
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo -e "${GREEN}🎨 Instalando Powerlevel10k...${NC}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# Plugins Esenciales (Autosuggestions & Syntax Highlighting)
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo -e "${GREEN}abb Instalando zsh-autosuggestions...${NC}"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo -e "${GREEN}abb Instalando zsh-syntax-highlighting...${NC}"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ----------------------------------------------------------------------
# 4. Aplicar Dotfiles con Stow
# ----------------------------------------------------------------------
echo -e "${GREEN}🔗 Enlazando configuraciones con Stow...${NC}"
cd "$HOME/dotfiles"

# Lista de carpetas a enlazar (¡Agregá aquí si creás más!)
DIRS=("git" "zsh" "atuin" "alacritty")

for dir in "${DIRS[@]}"; do
    # --adopt: Si el archivo ya existe en el sistema, Stow lo adopta en el repo
    # Esto evita conflictos la primera vez
    stow --adopt "$dir"
    echo "✅ $dir enlazado."
done

# Restaurar cambios si --adopt modificó algo que no queríamos (Opcional, pero seguro)
git restore .

# ----------------------------------------------------------------------
# 5. Finalización
# ----------------------------------------------------------------------
echo -e "${GREEN}🎉 ¡Instalación Completa! Reinicia la terminal.${NC}"
# Cambiar shell a zsh si no lo es
if [ "$SHELL" != "/bin/zsh" ]; then
    chsh -s /bin/zsh
fi
