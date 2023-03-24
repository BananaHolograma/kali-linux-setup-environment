![Archlinux_logo](https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.archlinux.org%2Fstatic%2Flogos%2Farchlinux-logo-black-1200dpi.94d8489023b3.png&f=1&nofb=1&ipt=478b55c74f2437d3bcb6174d0fb5e110e3a930f8ef1e833ef3c7e151d6506b55&ipo=images)

This is my initial configuration I apply on all my ArchLinux installations, it contains a minimal setup to start being productive in no time.

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
# Clone the repository
git clone https://github.com/s3r0s4pi3ns/archlinux-post-install-setup.git
# Run the script
cd archlinux-post-install-setup && bash install.sh
```
