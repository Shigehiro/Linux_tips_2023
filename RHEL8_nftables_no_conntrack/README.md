# 1. RHEL8 How to disable connection tracking with nftables

- [1. RHEL8 How to disable connection tracking with nftables](#1-rhel8-how-to-disable-connection-tracking-with-nftables)
- [2. Description](#2-description)
- [3. Environment](#3-environment)
- [4. nftables. Disable connection tracking of TCP/UDP 53](#4-nftables-disable-connection-tracking-of-tcpudp-53)

# 2. Description

Here is how to disable connection tracking of specifc UDP/TCP ports by nftables.

# 3. Environment

```
$ cat /etc/redhat-release
Red Hat Enterprise Linux release 8.7 (Ootpa)
```

```text
$ rpm -qf $(which nft)
nftables-0.9.3-26.el8.x86_64

$ iptables --version
iptables v1.8.4 (nf_tables)
```

# 4. nftables. Disable connection tracking of TCP/UDP 53

- install nftables
```text
$ sudo dnf install -y nftables
```

- As described [here](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_networking/getting-started-with-nftables_configuring-and-managing-networking#when-to-use-firewalld-nftables-or-iptables_assembly_migrating-from-iptables-to-nftables), enabling both firewalld.service and nftables.service are not recommended. so enable the one of them(nftables.service), disable the other(firewalld.service).

- stop/disable firewalld, enable/start nftables
```text
$ sudo systemctl stop firewalld.service 
$ sudo systemctl disable firewalld.service
$ sudo systemctl enable nftables.service

$ systemctl is-active firewalld.service nftables.service
inactive
active
```

- edit nftbles.conf
```text
$ sudo grep ^#include /etc/sysconfig/nftables.conf
#include "/etc/nftables/main.nft"

$ echo 'include "/etc/nftables/main.nft"' | sudo tee -a /etc/sysconfig/nftables.conf

$ sudo grep ^include /etc/sysconfig/nftables.conf
include "/etc/nftables/main.nft"
```

- prepare main.nft
```
$ cat main.nft
#!/usr/sbin/nft -f

# Flush the rule set
flush ruleset

define ipv4_my_net= { 127.0.0.1/32, 192.168.0.0/16, 10.0.0.0/8 }
define ipv6_my_net= { ::1/128 }

# ipv4 nftables
table ip filter {
        chain INPUT {
                type filter hook input priority filter; policy accept;
                udp dport 53 counter accept
                udp sport 53 counter accept
                tcp dport 53 counter accept
                tcp sport 53 counter accept
                ct state new,established,related tcp dport 22 ip saddr $ipv4_my_net counter accept
                tcp dport 22 drop
        }

        chain FORWARD {
                type filter hook forward priority filter; policy accept;
        }

        chain OUTPUT {
                type filter hook output priority filter; policy accept;
        }
}

table ip raw {
        chain PREROUTING {
                type filter hook prerouting priority raw; policy accept;
                udp dport 53 counter notrack
                udp sport 53 counter notrack
                tcp dport 53 counter notrack
                tcp sport 53 counter notrack
        }

        chain OUTPUT {
                type filter hook output priority raw; policy accept;
                udp dport 53 counter notrack
                udp sport 53 counter notrack
                tcp dport 53 counter notrack
                tcp sport 53 counter notrack
        }
}

# ipv6 nftables
table ip6 filter {
        chain INPUT {
                type filter hook input priority filter; policy accept;
                udp dport 53 counter accept
                udp sport 53 counter accept
                tcp dport 53 counter accept
                tcp sport 53 counter accept
                ct state new,established,related tcp dport 22 ip6 saddr $ipv6_my_net counter accept
                tcp dport 22 drop
        }

        chain FORWARD {
                type filter hook forward priority filter; policy accept;
        }

        chain OUTPUT {
                type filter hook output priority filter; policy accept;
        }
}

table ip6 raw {
        chain PREROUTING {
                type filter hook prerouting priority raw; policy accept;
                udp dport 53 counter notrack
                udp sport 53 counter notrack
                tcp dport 53 counter notrack
                tcp sport 53 counter notrack
        }

        chain OUTPUT {
                type filter hook output priority raw; policy accept;
                udp dport 53 counter notrack
                udp sport 53 counter notrack
                tcp dport 53 counter notrack
                tcp sport 53 counter notrack
        }
}
```

- put the nftables config
```text
# backup
$ sudo cp /etc/nftables/main.nft /etc/nftables/main.nft.backup

# copy, change owner, permissons
$ sudo cp main.nft /etc/nftables/main.nft
$ sudo chown root:root /etc/nftables/main.nft
$ sudo chmod 0600 /etc/nftables/main.nft
```

- (re)start nftables.service to reflect the config
```text
$ sudo systemctl start nftables.service
```

- check the nftables
```text
$ sudo nft list ruleset | head -10
table ip filter {
        chain INPUT {
                type filter hook input priority filter; policy accept;
                udp dport 53 counter packets 1 bytes 83 accept
                udp sport 53 counter packets 1 bytes 87 accept
                tcp dport 53 counter packets 12 bytes 754 accept
                tcp sport 53 counter packets 8 bytes 554 accept
                ct state established,related,new tcp dport 22 ip saddr { 10.0.0.0/8, 127.0.0.1, 192.168.0.0/16 } counter packets 611 bytes 42096 accept
                tcp dport 22 drop
        }
```

- Confirmation

send UDP/TCP 53 traffic to this server, confirm `notrack` is counted up.
```text
$ sudo nft list ruleset | grep counter
                udp dport 53 counter packets 1 bytes 83 accept
                udp sport 53 counter packets 1 bytes 87 accept
                tcp dport 53 counter packets 12 bytes 754 accept
                tcp sport 53 counter packets 8 bytes 554 accept
                ct state established,related,new tcp dport 22 ip saddr { 10.0.0.0/8, 127.0.0.1, 192.168.0.0/16 } counte
 packets 586 bytes 40408 accept
                udp dport 53 counter packets 1 bytes 83 notrack
                udp sport 53 counter packets 1 bytes 87 notrack
                tcp dport 53 counter packets 12 bytes 754 notrack
                tcp sport 53 counter packets 8 bytes 554 notrack
                udp dport 53 counter packets 1 bytes 83 notrack
                udp sport 53 counter packets 1 bytes 87 notrack
                tcp dport 53 counter packets 12 bytes 754 notrack
                tcp sport 53 counter packets 8 bytes 554 notrack
                udp dport 53 counter packets 0 bytes 0 accept
                udp sport 53 counter packets 0 bytes 0 accept
                tcp dport 53 counter packets 0 bytes 0 accept
                tcp sport 53 counter packets 0 bytes 0 accept
                ct state established,related,new tcp dport 22 ip6 saddr { ::1 } counter packets 0 bytes 0 accept
                udp dport 53 counter packets 0 bytes 0 notrack
                udp sport 53 counter packets 0 bytes 0 notrack
                tcp dport 53 counter packets 0 bytes 0 notrack
                tcp sport 53 counter packets 0 bytes 0 notrack
                udp dport 53 counter packets 0 bytes 0 notrack
                udp sport 53 counter packets 0 bytes 0 notrack
                tcp dport 53 counter packets 0 bytes 0 notrack
                tcp sport 53 counter packets 0 bytes 0 notrack
```

- you can check connection tracking with conntrack-tools as well.
```
$ sudo dnf install -y conntrack-tools

$ sudo conntrack -L
tcp      6 431999 ESTABLISHED src=192.168.122.1 dst=192.168.122.246 sport=35448 dport=22 src=192.168.122.246 dst=192.168.122.1 sport=22 dport=35448 [ASSURED] mark=0 secctx=system_u:object_r:unlabeled_t:s0 use=1
conntrack v1.4.4 (conntrack-tools): 1 flow entries have been shown.
```
