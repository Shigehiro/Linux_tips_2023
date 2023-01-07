#!/bin/sh

sudo virt-install --name fedora37-ks \
--memory 4096 \
--vcpus 1 \
--location /storage/ISO/Fedora-Server-dvd-x86_64-37-1.7.iso \
--initrd-inject $(pwd)/fedora-server-vm-full.ks \
--os-variant=fedora35 \
--console pty,target_type=serial \
--extra-args "inst.ks=file:/fedora-server-vm-full.ks console=tty0 console=ttyS0,115200n8" \
--disk size=60,pool=default,sparse=yes \
--network network=default --noautoconsole

