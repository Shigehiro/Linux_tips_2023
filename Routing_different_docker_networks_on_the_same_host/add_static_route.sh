#!/bin/sh

docker exec a-c01 ip route add 192.168.100.0/24 via 10.0.0.200

docker exec a-c02 ip route add 10.0.0.0/24 via 192.168.100.200

