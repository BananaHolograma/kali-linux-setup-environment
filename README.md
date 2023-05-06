![kali-linux_logo](https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.kali.org%2Fblog%2Fkali-linux-1-1-0-release%2Fimages%2Fkali-wallpaper-2015-v1.1.0.png&f=1&nofb=1&ipt=8e5aeb4006c53e4f19629f2ec24281002fe29a4fc8984c43dc5f96b6a5c1613e&ipo=images)

# Installation

## Using Git

```bash
git clone https://github.com/s3r0s4pi3ns/kali-linux-setup-environment.git \
    && chmod +x kali-linux-setup-environment/install.sh
```

## Using Curl

```bash
curl -O https://github.com/s3r0s4pi3ns/kali-linux-setup-environment/archive/refs/heads/main.zip \
    && unzip main.zip
```

## Usage

The script needs to be executed with `zsh` terminal or you will get some `command not found errors` on your process. We assume that you are running this script using `zsh` as default shell.

```bash
kali-linux-setup.environment/install.sh
#or
cd kali-linux-setup.environment && ./install.sh
#or
zsh kali-linux-setup.environment/install.sh
```

The script create a backup of the configuration files that are going to be tampered and can be runned multiple times without messing up the actual configuration.

# Configuration

The `config` folder contains all the related configurations that are important for the script because it takes this files and move them to the
new system in the correct way.

## Fonts ✍️

This folder contains all the external fonts, the default used is HackNerdFonts from [Nerd-Fonts](https://github.com/ryanoasis/nerd-fonts) to beautify the zsh terminal experience along with kitty.

## Kitty Terminal 🐱

The [Kitty](https://github.com/kovidgoyal/kitty) terminal is the next-gen cross platform shell designed for enjoyment in use, I defined a smooth configuration to start working with it and enjoy the potential gives us.

## Vim 👨🏽‍💻

I use this configuration made from my daily basis experience to get confortable with vim and do everything from a terminal

## Vscode settings 🆚

This only contains the `settings.json` for my daily worklow, it is not included in the automatic installation.

## ZSH 🖥️

The minimalist setup for zsh with plugins that works for me and I use everyday, a ready `.zshrc` configuration file to start being productive in no time.

# Keyboard shorcuts

After the installation I usually create few shortcuts:

- Command `kitty --start-as maximized` with shorcut: `Super + Enter`
- Command `firejail /usr/bin/firefox` with shorcut: `Super + Shift + F`

# DNS Resolvers

A sanitized dns resolvers to use in my recon activities when I need to validate some subdomains from the target. I sanitize this list automatically with a scheduled github action on my repo [https://github.com/s3r0s4pi3ns/clean-dns-resolvers](https://github.com/s3r0s4pi3ns/clean-dns-resolvers)

# Custom scripts

A set of custom scripts for my personal needs

## vpn-down.sh

This one cut the network connection when the vpn is down. I assign this script when I run `openvpn` to avoid leak my real network information in the middle of a process:

```bash
openvpn --script-security 2 --down "$HOME/scripts/vpn-down.sh" --config <openvpn file>
```
