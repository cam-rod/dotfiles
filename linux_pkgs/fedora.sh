#!/bin/bash
# Fedora-specific configuration

# Nvidia drivers https://rpmfusion.org/Howto/NVIDIA#Current_GeForce.2FQuadro.2FTesla
sudo dnf5 install akmod-nvidia akmods # akmods for force-installing to older kernels if needed 
sudo dnf5 install xorg-x11-drv-nvidia-cuda