#!/bin/sh

sudo virt-install --name rocky91-ks \
--memory 4096 \
--vcpus 1 \
--location /storage/ISO/Rocky-9.1-x86_64-dvd.iso \
--initrd-inject $(pwd)/rocky91_ks.cfg \
--os-variant=rocky9.0 \
--console pty,target_type=serial \
--extra-args "inst.ks=file:/rocky91_ks.cfg console=tty0 console=ttyS0,115200n8" \
--disk size=60,pool=default,sparse=yes \
--network network=default --noautoconsole
