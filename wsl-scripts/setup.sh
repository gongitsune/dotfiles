#!/bin/bash

if [ ! -f ./bootstrap.tar.zst ]; then
  curl -o bootstrap.tar.zst https://mirrors.cat.net/archlinux/iso/latest/archlinux-bootstrap-x86_64.tar.zst
else
  echo "bootstrap.tar.zst is downloaded."
fi

cd /root
if [ ! -d ./root.x86_64 ]; then
  tar --zstd -xvf /workdir/bootstrap.tar.zst
else
  echo "root.x86_64 is existed."
fi

sed -i '/## Japan/,/## / {/^[^#]*$/!s/^#//}' ./root.x86_64/etc/pacman.d/mirrorlist

cd ./root.x86_64
tar --zstd -cvf /workdir/root.tar.zst *