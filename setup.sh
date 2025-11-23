#!/bin/bash

set -e

echo "=========================================="
echo "     Mac Setup Script"
echo "=========================================="
echo ""
echo "Choose setup type:"
echo "1) Main Machine (primary macOS)"
echo "2) UTM VM (virtual machine)"
echo ""

read -p "Enter choice (1 or 2): " choice

if [[ "$choice" == "1" ]]; then
    MODE="main"
elif [[ "$choice" == "2" ]]; then
    MODE="vm"
else
    echo "❌ Invalid choice. Exiting."
    exit 1
fi

echo "🖥  Selected mode: $MODE"
echo "---------------------------------------"


###############################################################################
# INSTALL HOMEBREW
###############################################################################
echo "🔧 Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "🔧 Adding Homebrew to PATH..."
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"


###############################################################################
# INSTALL OH-MY-ZSH + PLUGINS
###############################################################################
echo "🎨 Installing Oh My Zsh..."
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "📦 Installing zsh plugins..."
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting || true

echo "⚙️ Updating ~/.zshrc plugins..."
sed -i '' 's/^plugins=(.*)$/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc || \
echo "plugins=(git zsh-autosuggestions zsh-syntax-highlighting)" >> ~/.zshrc


###############################################################################
# GUI APP INSTALLATION (BASED ON MODE)
###############################################################################
echo "🧠 Installing GUI apps via Homebrew..."

if [[ "$MODE" == "main" ]]; then
    brew install --cask clipy
    brew install --cask obsidian
    brew install --cask iterm2
    brew install --cask visual-studio-code
    brew install --cask utm
    brew install --cask arc
    brew install --cask windows-app

elif [[ "$MODE" == "vm" ]]; then
    brew install --cask clipy
    brew install --cask iterm2
    brew install --cask visual-studio-code
    brew install --cask google-chrome
    brew install --cask firefox
fi


###############################################################################
# INSTALL CLI TOOLS (COMMON)
###############################################################################
echo "🔨 Installing CLI tools..."
brew install lsd nvim yazi tmux
brew install lazygit ripgrep fzf tree-sitter node python go


###############################################################################
# LINK DOTFILES
###############################################################################
DOTFILES_DIR=~/dotfiles

echo "📁 Linking dotfiles..."

ln -sf $DOTFILES_DIR/.zshrc ~/.zshrc

mkdir -p ~/.config/nvim
ln -sf $DOTFILES_DIR/nvim/* ~/.config/nvim/

ln -sf $DOTFILES_DIR/tmux/.tmux.conf ~/.tmux.conf

mkdir -p ~/.config/yazi
ln -sf $DOTFILES_DIR/yazi/* ~/.config/yazi/


###############################################################################
# INSTALL NERD FONTS
###############################################################################
echo "🔤 Installing Nerd Fonts..."
mkdir -p ~/Library/Fonts
cp -v $DOTFILES_DIR/fonts/* ~/Library/Fonts/


###############################################################################
# INSTALL TREE-SITTER-CLI
###############################################################################
echo "📦 Installing tree-sitter-cli globally..."
npm install -g tree-sitter-cli


echo "=========================================="
echo "✅ Setup Complete for: $MODE"
echo "➡️ Restart your terminal to apply changes."
echo "=========================================="
