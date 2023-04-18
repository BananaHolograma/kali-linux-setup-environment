![Archlinux_logo](https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.kali.org%2Fblog%2Fkali-linux-1-1-0-release%2Fimages%2Fkali-wallpaper-2015-v1.1.0.png&f=1&nofb=1&ipt=8e5aeb4006c53e4f19629f2ec24281002fe29a4fc8984c43dc5f96b6a5c1613e&ipo=images)

# Configuration

The `config` folder contains all the related configurations that are important for the script because it takes this files and move them to the
new system in the correct way.

## Fonts ✍️

This folder contains all the external fonts, the default used is HackNerdFonts from [Nerd-Fonts](https://github.com/ryanoasis/nerd-fonts) to beautify the zsh terminal experience along with kitty.

## Kitty Terminal 🐱

The [Kitty](https://github.com/kovidgoyal/kitty) terminal is the next-gen cross platform shell designed for enjoyment in use, I defined a smooth configuration to start working with it and enjoy the potential gives us.

## Vim 👨🏽‍💻

I took the basic configuration file from the repository [https://github.com/amix/vimrc](https://github.com/amix/vimrc) with few changes from my part.

## Vscode settings 🆚

This only contains the `settings.json` for my daily worklow and I decided to be optional because some times I don't install vscode

## ZSH 🖥️

The minimalist setup for zsh with plugins that works for me and I use everyday. I only use the initial powerlevel10k assistant with my `.zshrc` modified and adapted for new installations.

# Usage

```bash
# Clone the repository with git
git clone https://github.com/s3r0s4pi3ns/kali-linux-setup-environment.git
# Or download it and unzip
curl -O https://github.com/s3r0s4pi3ns/kali-linux-setup-environment/archive/refs/heads/main.zip \
    && unzip main.zip

# Run the script on home directory
cd ~
bash ./kali-linux-setup-environment/install.sh
```
