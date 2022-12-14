#!/bin/bash
# Run from this directory
if [[ ! "$(dirname $(pwd))" =~ "/linux_pkgs" ]]; then
    echo "Please run this script from within the \`linux_pkgs\` directory"
    exit 1
fi

# RPM Fusion, other nonfree libraries, and first updates
sudo dnf -y check-update
sudo dnf -y upgrade
sudo dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf -y install fedora-workstation-repositories

# Java, C/C++, NodeJS, Perl, Rust
sudo dnf -y install java-latest-openjdk-devel cmake meson binutils libtool glibc-devel \
    gcc-c++ clang nodejs npm perl
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -- -y

# Useful Python packages
sudo dnf -y install poetry python3-{requests,beautifulsoup4,gobject}

# Google Chrome
sudo dnf -y config-manager --set-enabled google-chrome
sudo dnf -y check-update
sudo dnf -y install google-chrome-stable

# VS Code https://code.visualstudio.com/docs/setup/linux
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf -y check-update
sudo dnf -y install code

# 1Password Beta https://support.1password.com/betas
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password-beta]\nname=1Password Beta Channel\nbaseurl=https://downloads.1password.com/linux/rpm/beta/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password-beta.repo'
sudo dnf check-update
sudo dnf install 1password 1password-cli

# NVIDIA Container Toolkit https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
curl -s -L https://nvidia.github.io/libnvidia-container/rhel9.0/libnvidia-container.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo # As of November 2022
unset distribution
sudo dnf -y check-update
sudo dnf -y install nvidia-container-toolkit
sudo sed -i 's/^#no-cgroups = false/no-cgroups = true/;' /etc/nvidia-container-runtime/config.toml # rootless

# Other tools
sudo dnf -y install fakeroot flatpak-builder gh dconf-editor screen podman podman-compose buildah skopeo
sudo flatpak install --noninteractive net.werwolv.ImHex

# Environment setup
yes | pip install git+ssh://git@github.com/powerline/powerline.git@develop # pip is out of date, see powerline#2116
sudo dnf -y install vim-enhanced fira-code-fonts kitty neofetch powerline-fonts
gsettings set org.gnome.nautilus.preferences show-hidden-files true
gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden true

cp -r ../powerline_cfg ~/.config/powerline
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

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
cp ../dev_scripts/colocat.py ~/scripts
cp ../dev_scripts/colodiff.py ~/scripts
cp ../dev_scripts/git-unsync.py ~/scripts
cp ../bash_kittyterm/toprc ~/.config/procps/toprc

# Manually installed to /opt as needed: IntelliJ Community Edition, STM32CubeIDE, arm-none-eabi
