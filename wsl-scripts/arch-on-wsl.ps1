$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

podman run -it --rm -v ${scriptDir}:/workdir -w /workdir archlinux:latest ./setup.sh

New-Item -ItemType Directory "${HOME}/wsl/Arch" -Force
Move-Item -Path "${scriptDir}/root.tar.zst" -Destination "${HOME}/wsl/Arch" -Force

wsl --import Arch "${HOME}/wsl/Arch" "${HOME}/wsl/Arch/root.tar.zst"