#!/bin/bash

# Exit on error
set -e

echo "🔧 Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "🔧 Adding Homebrew to PATH via ~/.zprofile..."
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "🎨 Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "📦 Installing zsh-autosuggestions and zsh-syntax-highlighting..."
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

echo "🧠 Installing GUI apps via Homebrew..."
brew install --cask clippy
brew install --cask obsidian
brew install --cask iterm2
brew install --cask visual-studio-code
brew install --cask utm
brew install --cask arc
brew install --cask windows-app


echo "🔨 Installing CLI tools via Homebrew..."
brew install lsd nvim yazi tmux
brew install lazygit ripgrep fzf tree-sitter node python go


echo "📁 Linking dotfiles configs..."
DOTFILES_DIR=~/dotfiles

echo "🔗 Linking .zshrc from the repo..."
ln -sf $DOTFILES_DIR/.zshrc ~/.zshrc

echo "🔗 Linking Neovim config..."
mkdir -p ~/.config/nvim
ln -sf $DOTFILES_DIR/nvim/* ~/.config/nvim/

echo "🔗 Linking tmux config..."
ln -sf $DOTFILES_DIR/tmux/.tmux.conf ~/.tmux.conf

echo "🔗 Linking yazi config..."
mkdir -p ~/.config/yazi
ln -sf $DOTFILES_DIR/yazi/* ~/.config/yazi/

echo "🔤 Installing Nerd Fonts..."
mkdir -p ~/Library/Fonts
cp -v $DOTFILES_DIR/fonts/* ~/Library/Fonts/

echo "📦 Installing tree-sitter-cli globally via npm..."
cd ~
npm install -g tree-sitter-cli

echo "✅ All done! Restart your terminal to apply changes."


