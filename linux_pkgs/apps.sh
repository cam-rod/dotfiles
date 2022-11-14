#!/bin/bash
# Other apps I use, run from this directory

sudo dnf install calibre dconf-editor duplicity ffmpeg gnome-extensions-app openrgb steam thunderbird \
    virt-manager zoom

# Google Chrome
sudo dnf config-manager --set-enabled google-chrome
sudo dnf check-update

# ExpressVPN (see _expressvpn-upgrade.py)
cp ./*expressvpn* ~/scripts # Convenient script to upgrade expressvpn via CLI
sudo chmod ug+x ./*expressvpn*
expressvpn-upgrade --install

# vnStat for cool network info
sudo dnf install vnstat
sudo systemctl enable vnstat
sudo systemctl start vnstat

# Flatpaks (slight brace expansion abuse)
sudo flatpak install \
    cc.arduino.IDE2 \
    com.discordapp.Discord \
    com.github.tchx84.Flatseal \
    com.obsproject.Studio \
    com.slack.Slack \
    com.spotify.Client \
    io.github.trigg.discover_overlay \
    md.obsidian.Obsidian \
    nl.hjdskes.gcolor3 \
    org.gimp.GIMP{,.Plugin.{BIMP,Fourier,Lensfun,LiquidRescale,Resynthesizer}} \
    org.signal.Signal \
    tech.feliciano.pocket-casts

# Snaps
sudo snap install authy kochmorse

# Manually installed as needed: MultiMC, DaVinci Resolve