# How to change interface name on Rocky8

## Description

Here is how to change interface name on Rocky Linyx8.

## Walkthrough logs

- before changing the interface name

check interface names and MAC addresses.
```
[root@localhost ~]# ip link show | grep ^[1-9] -A1
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:8f:ed:b7 brd ff:ff:ff:ff:ff:ff
--
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:c5:25:db brd ff:ff:ff:ff:ff:ff
--
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:80:a2:09 brd ff:ff:ff:ff:ff:ff
--
5: eth3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:9e:70:01 brd ff:ff:ff:ff:ff:ff
--
6: eth4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:ce:72:a7 brd ff:ff:ff:ff:ff:ff
--
7: eth5: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:e1:6d:84 brd ff:ff:ff:ff:ff:ff
[root@localhost ~]#
```

- change interface names
```
[root@localhost ~]# cat /etc/udev/rules.d/70-custom-ifnames.rules
# eno1, eno2, eno3, eno4
SUBSYSTEM=="net",ACTION=="add",ATTR{address}=="52:54:00:8f:ed:b7",ATTR{type}=="1",NAME="eno1"
SUBSYSTEM=="net",ACTION=="add",ATTR{address}=="52:54:00:c5:25:db",ATTR{type}=="1",NAME="eno2"
SUBSYSTEM=="net",ACTION=="add",ATTR{address}=="52:54:00:80:a2:09",ATTR{type}=="1",NAME="eno3"
SUBSYSTEM=="net",ACTION=="add",ATTR{address}=="52:54:00:9e:70:01",ATTR{type}=="1",NAME="eno4"

# ens2f0 , ens2f01
SUBSYSTEM=="net",ACTION=="add",ATTR{address}=="52:54:00:ce:72:a7",ATTR{type}=="1",NAME="ens2f0"
SUBSYSTEM=="net",ACTION=="add",ATTR{address}=="52:54:00:e1:6d:84",ATTR{type}=="1",NAME="ens2f1"
[root@localhost ~]#
```

- reboot the OS to reflect the config
```
# reboot
```

- after rebooting

```
[root@localhost ~]# ip link show | grep ^[1-9] -A1
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:8f:ed:b7 brd ff:ff:ff:ff:ff:ff
--
3: eno2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:c5:25:db brd ff:ff:ff:ff:ff:ff
--
4: eno3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:80:a2:09 brd ff:ff:ff:ff:ff:ff
--
5: eno4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:9e:70:01 brd ff:ff:ff:ff:ff:ff
--
6: ens2f0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:ce:72:a7 brd ff:ff:ff:ff:ff:ff
--
7: ens2f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:e1:6d:84 brd ff:ff:ff:ff:ff:ff
[root@localhost ~]#
```