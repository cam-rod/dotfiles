#!/bin/bash
# Run from this directory
if [[ ! "$(dirname $(pwd))" =~ "/linux_pkgs" ]]; then
    echo "Please run this script from within the \`linux_pkgs\` directory"
    exit 1
fi

# RPM Fusion, other nonfree libraries, and first updates
echo 'max_parallel_downloads=15' | sudo tee -a /etc/dnf/dnf.conf
sudo dnf5 makecache
sudo dnf5 -y upgrade
sudo dnf5 -y install "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
sudo dnf5 -y install fedora-workstation-repositories

# "Languages" - Java, C/C++, NodeJS, Perl, Python, PHP, OpenSSL, Golang, Rust
sudo dnf5 -y install java-latest-openjdk-devel maven cmake meson binutils libtool gcc \
    gcc-c++ clang-devel npm perl-devel python3-devel python3-virtualenv openssl-devel composer \
    golang
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh # Requires manual intervention
mv ~/.cargo ~/.local/share/cargo && sed -i 's/$HOME\/.cargo/$CARGO_HOME/' ~/.local/share/cargo/env
. "$CARGO_HOME/env"
cp ../rust/config.toml $CARGO_HOME/config.toml
rustup component add rust-src rust-analyzer

# PlatformIO Core
curl -fsSL -o get-platformio.py https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py
python3 get-platformio.py && rm get-platformio.py
for pbin in pio platformio piodebuggdb; do ln -s "$HOME/.platformio/penv/bin/$pbin" "$HOME/.local/bin/$pbin"; done
curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules
sudo udevadm control -R && sudo udevadm trigger

# Kernel dev
sudo dnf5 install kernel-devel fedpkg fedora-packager ncurses-devel pesign grubby
sudo dnf5 builddep kernel kernel-devel

# Flatpaks, RPMs, and app packaging
sudo dnf5 -y install flatpak-builder
sudo dnf5 -y group install 'RPM Development Tools'

# The most sane way to setup Ruby on Fedora (removed rust due to user installation)
sudo dnf5 -y install gcc patch make bzip2 openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel perl-FindBin perl-File-Compare
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

# Container stuff
sudo dnf5 -y install podman podman-compose buildah skopeo

# Useful Python packages
sudo dnf5 -y install python3-{requests,beautifulsoup4,gobject}
cargo install --git https://github.com/astral-sh/rye rye
rye self completion -s bash > ~/.local/share/bash-completion/completions/rye
pip install --no-input black 'black[d]' selenium webdriver_manager

# Typescript compiler
sudo npm install -g typescript

# Databases
sudo dnf5 -y install mariadb-server sqlite3

# Disable gnome-keyring-ssh (thanks https://askubuntu.com/a/607563 and https://askubuntu.com/a/585212)
mkdir -p ~/.config/autostart
(cat /etc/xdg/autostart/gnome-keyring-ssh.desktop; echo Hidden=true) > ~/.config/autostart/gnome-keyring-ssh.desktop

# Google Chrome
sudo dnf5 -y config-manager --set-enabled google-chrome
sudo dnf5 makecache
sudo dnf5 -y install google-chrome-stable

# VS Code https://code.visualstudio.com/docs/setup/linux
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf5 makecache
sudo dnf5 -y install code

# PowerShell
curl https://packages.microsoft.com/config/rhel/8/prod.repo | sudo tee /etc/yum.repos.d/microsoft-rhel8.repo
sudo sed -i 's/name=.*$/name=microsoft-prod-rhel8/' /etc/yum.repos.d/microsoft-rhel8.repo
sudo sed -i 's/\[packages.*\]$/[microsoft-prod-rhel8]/' /etc/yum.repos.d/microsoft-rhel8.repo
curl https://packages.microsoft.com/config/rhel/9/prod.repo | sudo tee /etc/yum.repos.d/microsoft-rhel9.repo
sudo sed -i 's/name=.*$/name=microsoft-prod-rhel9/' /etc/yum.repos.d/microsoft-rhel9.repo
sudo sed -i 's/\[packages.*\]$/[microsoft-prod-rhel9]/' /etc/yum.repos.d/microsoft-rhel9.repo
sudo dnf5 makecache
sudo dnf5 -y install powershell

# 1Password Beta https://support.1password.com/betas
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Beta Channel\nbaseurl=https://downloads.1password.com/linux/rpm/beta/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
sudo dnf5 makecache
sudo dnf5 -y install 1password 1password-cli

# NVIDIA Container Toolkit https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
curl -s -L https://nvidia.github.io/libnvidia-container/rhel9.0/libnvidia-container.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo # As of November 2022
unset distribution
sudo dnf5 makecache
sudo dnf5 -y install nvidia-container-toolkit
sudo sed -i 's/^#no-cgroups = false/no-cgroups = true/;' /etc/nvidia-container-runtime/config.toml # rootless

# YubiKey Manager, Personalization Tool, Authenticator, PAM
sudo dnf5 -y install yubikey-personalization-gui pam_yubico pam-u2f pamu2fcfg yubikey-manager
mkdir -p ~/.local/bin/yubikey-manager-appimage && install -D yubikey/yubikey-manager.desktop ~/.local/share/applications/ && install -D yubikey/ykman.svg ~/.local/share/icons/hicolor/scalable/apps/ykman.svg
wget -P ~/.local/bin/yubikey-manager-appimage https://developers.yubico.com/yubikey-manager-qt/Releases/yubikey-manager-qt-latest-linux.AppImage && chmod -R +x ~/.local/bin/yubikey-manager-appimage
ln -s ~/.local/bin/yubikey-manager-appimage/yubikey-manager-qt-latest-linux.AppImage ~/.local/bin/yubikey-manager
wget -O yubico-authenticator-latest-linux.tar.gz https://developers.yubico.com/yubioath-flutter/Releases/yubico-authenticator-latest-linux.tar.gz  && tar -xzf yubico-authenticator-latest-linux.tar.gz && rm -f yubico-authenticator-latest-linux.tar.gz
mv "$(find . -maxdepth 1 -regex '.*yubico.*')" ~/.config && ln -s $(realpath "$(find $HOME/.config -maxdepth 1 -regex '.*yubico-auth.*')") ~/.config/yubiauth
chmod +x ~/.config/yubiauth/desktop_integration.sh && bash -c "$HOME/.config/yubiauth/desktop_integration.sh -i"

# Other tools
sudo dnf5 -y install gh dconf-editor screen nmap xeyes ripgrep fd-find colordiff fzf setroubleshoot \
    setools-console policycoreutils-devel 'dnf-command(versionlock)' shellcheck sysstat

# Environment setup
if [[ `stty size | awk '{print $2}'` -ge 256 ]]; then # Larger TTY font for 4K displays
    sudo cp ./ttyfont.sh /etc/profile.d/ttyfont.sh
fi

yes | pip install git+ssh://git@github.com/powerline/powerline.git@develop # pip is out of date, see powerline#2116
sudo dnf5 -y install vim-enhanced jetbrains-mono-fonts-all linux-libertine-biolinum-fonts kitty neofetch powerline-fonts
gsettings set org.gnome.nautilus.preferences show-hidden-files true
gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden true

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

mkdir -p $XDG_CONFIG_HOME/tmux/plugins
git clone git@github.com:tmux-plugins/tpm.git $XDG_CONFIG_HOME/tmux/plugins/tpm

gsettings set org.gnome.desktop.default-applications.terminal exec kitty
mkdir -p ~/.config/kitty/kitty.d
curl -o ~/.config/kitty/kitty.d/nord.conf https://raw.githubusercontent.com/connorholyday/nord-kitty/master/nord.conf
cat <<EOF > ~/.config/kitty/kitty.conf
globinclude kitty.d/**/*.conf
EOF
cp ../bash_kittyterm/click.oga ../bash_kittyterm/kitty-custom.conf ~/.config/kitty/kitty.d/

mkdir ~/develop # Root level folder for all coding stuff
mkdir ~/scripts # Added to PATH
mkdir ~/.config/procps
cp ../bash_kittyterm/xdg-base-setup.sh ../scripts/colocat.py ../scripts/git-unsync ../scripts/pgpcard-reload ../scripts/doi-handler/doi-handler ~/scripts
cp ../bash_kittyterm/toprc ~/.config/procps/toprc
cp ../scripts/doi-handler/doi-handler.desktop $XDG_DATA_HOME/applications/
xdg-mime default doi-handler.desktop x-scheme-handler/doi

# Manually installed to /opt as needed: JetBrains Toolbox & Co.
