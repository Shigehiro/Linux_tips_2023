# 1. Build a Rocky Linux 9 custom image for KVM

- [1. Build a Rocky Linux 9 custom image for KVM](#1-build-a-rocky-linux-9-custom-image-for-kvm)
- [2. Description](#2-description)
- [3. Reference](#3-reference)
- [4. Note about virt-install option when building the image](#4-note-about-virt-install-option-when-building-the-image)
- [5. Tested environment](#5-tested-environment)
- [6. Procedure](#6-procedure)
- [7. Walkthrough logs](#7-walkthrough-logs)
- [Error when creating a fresh VM by using the golden image](#error-when-creating-a-fresh-vm-by-using-the-golden-image)
  - [Another workaround](#another-workaround)

# 2. Description

Here is how to build a custom kvm image for KVM.

# 3. Reference

- https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/performing_an_advanced_rhel_9_installation/creating-kickstart-files_installing-rhel-as-an-experienced-user
- https://git.rockylinux.org/rocky/kickstarts/-/tree/r9/

# 4. Note about virt-install option when building the image

As of Rocky9(RHEL9), `ks=file..` is deprecated arguments, so use `ks.inst=file..` instead.
See [this bugzill](https://bugzilla.redhat.com/show_bug.cgi?id=1897657)

- deprecated
```text
--extra-args "ks=file:/rocky91_ks.cfg console=tty0 console=ttyS0,115200n8" \
```

- use `inst.ks`
```text
--extra-args "inst.ks=file:/rocky91_ks.cfg console=tty0 console=ttyS0,115200n8" \
```

# 5. Tested environment

- KVM host

```text
$ tail -1 /etc/lsb-release 
DISTRIB_DESCRIPTION="Ubuntu 22.04.1 LTS"
```

# 6. Procedure

The procedure is almost the same in my previous [post](https://github.com/Shigehiro/Linux_tips_2022/tree/master/Rocky8_create_custom_qcow2_image)

# 7. Walkthrough logs

- build the image
```text
$ ./build_rocky91_legacy_bios.sh
```

- run virt-sparsify, virt-sysprep
```text
$ virsh domblklist rocky91-ks 
 Target   Source
------------------------------------------------
 vda      /storage/kvm_images/rocky91-ks.qcow2
 sda      -

$ virsh undefine rocky91-ks 
Domain 'rocky91-ks' has been undefined

$ sudo mv /storage/kvm_images/rocky91-ks.qcow2 ./

$ sudo virt-sparsify --compress rocky91-ks.qcow2 rocky91-template.qcow2

$ sudo virt-sysprep -a rocky91-template.qcow2 
```

# Error when creating a fresh VM by using the golden image

When I tried to create a fresh with the template image, I saw the VM failed to boot.
Here is the root cause. 
- https://access.redhat.com/solutions/6833751

- KVM host
```text
$ ps aux |grep qemu-system|grep -v grep
libvirt+ 1058070  100  0.7 4872960 484256 ?      Sl   01:17   8:04 /usr/bin/qemu-system-x86_64 -name guest=lab03-rocky9,debug-threads=on -S -object {"qom-type":"secret","id":"masterKey0","format":"raw","file":"/var/lib/libvirt/qemu/domain-10-lab03-rocky9/master-key.aes"} -machine pc-i440fx-jammy,usb=off,dump-guest-core=off,memory-backend=pc.ram -accel kvm -cpu qemu64 -m 4096 -object {"qom-type":"memory-backend-ram","id":"pc.ram","size":4294967296} -overcommit mem-lock=off -smp 1,sockets=1,cores=1,threads=1 -uuid d0cebc46-0436-4e5d-a623-40ca2c938f4f -no-user-config -nodefaults -chardev socket,id=charmonitor,fd=33,server=on,wait=off -mon chardev=charmonitor,id=monitor,mode=control -rtc base=utc -no-shutdown -boot strict=on -device piix3-usb-uhci,id=usb,bus=pci.0,addr=0x1.0x2 -device virtio-serial-pci,id=virtio-serial0,bus=pci.0,addr=0x4 -blockdev {"driver":"file","filename":"/storage/kvm_images/lab03-rocky9-terraform","node-name":"libvirt-1-storage","auto-read-only":true,"discard":"unmap"} -blockdev {"node-name":"libvirt-1-format","read-only":false,"driver":"qcow2","file":"libvirt-1-storage","backing":null} -device virtio-blk-pci,bus=pci.0,addr=0x5,drive=libvirt-1-format,id=virtio-disk0,bootindex=2 -netdev tap,fd=34,id=hostnet0,vhost=on,vhostfd=36 -device virtio-net-pci,netdev=hostnet0,id=net0,mac=52:54:00:62:7d:a1,bootindex=3,bus=pci.0,addr=0x3 -chardev pty,id=charserial0 -device isa-serial,chardev=charserial0,id=serial0 -chardev socket,id=charchannel0,fd=32,server=on,wait=off -device virtserialport,bus=virtio-serial0.0,nr=1,chardev=charchannel0,id=channel0,name=org.qemu.guest_agent.0 -chardev pty,id=charconsole1 -device virtconsole,chardev=charconsole1,id=console1 -audiodev {"id":"audio1","driver":"spice"} -spice port=5900,addr=127.0.0.1,disable-ticketing=on,seamless-migration=on -device qxl-vga,id=video0,ram_size=67108864,vram_size=67108864,vram64_size_mb=0,vgamem_mb=16,max_outputs=1,bus=pci.0,addr=0x2 -device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x6 -object {"qom-type":"rng-random","id":"objrng0","filename":"/dev/urandom"} -device virtio-rng-pci,rng=objrng0,id=rng0,bus=pci.0,addr=0x7 -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny -msg timestamp=on
```

- virsh console logs
```text
Fatal glibc error: CPU does not support x86-64-v2
[    0.825511] Kernel panic - not syncing: Attempted to kill init! exitcode=0x00007f00
[    0.826585] CPU: 0 PID: 1 Comm: init Not tainted 5.14.0-162.6.1.el9_1.x86_64 #1
[    0.827589] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.15.0-1 04/01/2014
[    0.828755] Call Trace:
[    0.829110]  dump_stack_lvl+0x34/0x48
[    0.829617]  panic+0x102/0x2d4
[    0.830053]  do_exit.cold+0x14/0x9f
[    0.830535]  do_group_exit+0x33/0xa0
[    0.831053]  __x64_sys_exit_group+0x14/0x20
[    0.831642]  do_syscall_64+0x5c/0x90
[    0.832119]  ? do_user_addr_fault+0x1d8/0x690
[    0.832731]  ? exc_page_fault+0x62/0x150
[    0.833286]  entry_SYSCALL_64_after_hwframe+0x63/0xcd
[    0.833955] RIP: 0033:0x7fd76378e2d1
[    0.834465] Code: c3 0f 1f 84 00 00 00 00 00 f3 0f 1e fa be e7 00 00 00 ba 3c 00 00 00 eb 0d 89 d0 0f 05 48 3d 00 f0 ff ff 77 1c f4 89 f0 0f 05 <48> 3d 00 f0 ff ff 76 e7 f7 d8 89 05 ff fe 00 00 eb dd 0f 1f 44 00
[    0.836646] RSP: 002b:00007ffe4c48acb8 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
[    0.837522] RAX: ffffffffffffffda RBX: 00007fd763788f30 RCX: 00007fd76378e2d1
[    0.838348] RDX: 000000000000003c RSI: 00000000000000e7 RDI: 000000000000007f
[    0.839175] RBP: 00007ffe4c48ae40 R08: 00007ffe4c48a829 R09: 0000000000000000
[    0.840006] R10: 00000000ffffffff R11: 0000000000000246 R12: 00007fd763767000
[    0.840831] R13: 0000002300000007 R14: 0000000000000007 R15: 00007ffe4c48ae50
[    0.841683] Kernel Offset: 0x9a00000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
[    0.843181] ---[ end Kernel panic - not syncing: Attempted to kill init! exitcode=0x00007f00 ]---
```

- try the [workaround](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/configuring_and_managing_virtualization/optimizing-virtual-machine-performance-in-rhel_configuring-and-managing-virtualization#optimizing-virtual-machine-cpu-performance_optimizing-virtual-machine-performance-in-rhel)

```text
$ virsh destroy lab03-rocky9 

$ virt-xml lab03-rocky9 --edit --cpu host-model
Domain 'lab03-rocky9' defined successfully.

$ virsh dumpxml lab03-rocky9 |grep 'cpu mode'
  <cpu mode='host-model' check='partial'/>

$ virsh start lab03-rocky9 

$ virsh console lab03-rocky9 
Connected to domain 'lab03-rocky9'
Escape character is ^] (Ctrl + ])

localhost login: root
Password: 
cLast login: Fri Jan  6 01:41:01 on ttyS0
[root@localhost ~]# cat /etc/rocky-release
Rocky Linux release 9.1 (Blue Onyx)
[root@localhost ~]# 
```

## Another workaround

- https://access.redhat.com/solutions/539233