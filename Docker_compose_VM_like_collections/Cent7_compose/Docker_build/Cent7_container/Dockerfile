FROM centos:7
ENV container docker
ENV ssh_pub id_rsa.pub
ENV ssh_private id_rsa
ENV root_password password
ENV ssh_config ssh_config

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

COPY ${ssh_pub} /tmp
COPY ${ssh_private} /tmp

WORKDIR /root
#RUN yum install -y openssh-server openssh-clients bash-completion bind-utils rsyslog less man bash-completion net-tools iproute iputils && \
RUN yum clean all && yum install -y bind-utils rsyslog less man bash-completion net-tools iproute iputils python3 sudo which openssh-server openssh-clients dialog openssl mcelog sysstat gdb less net-tools mlocate tree && \
mkdir .ssh && cat /tmp/${ssh_pub} > .ssh/authorized_keys && \
mv /tmp/${ssh_pub} .ssh/id_rsa.pub && mv /tmp/${ssh_private} .ssh/id_rsa && echo ${root_password} | passwd --stdin root && \
chmod 0400 .ssh/authorized_keys && chmod 0600 .ssh/id_rsa && chmod 0644 .ssh/id_rsa.pub
COPY ${ssh_config} /etc/ssh/ssh_config

# Disable DNS lookup
sed s/.*UseDNS.*/"UseDNS no"/ -i /etc/ssh/sshd_config

EXPOSE 53/udp
EXPOSE 15003
EXPOSE 15004
EXPOSE 15006
EXPOSE 15009
EXPOSE 15014
EXPOSE 15101
EXPOSE 15103
EXPOSE 15104
EXPOSE 16003
EXPOSE 16004
EXPOSE 16005
EXPOSE 16112
EXPOSE 16113
EXPOSE 20101
EXPOSE 2182
EXPOSE 22
EXPOSE 2379
EXPOSE 2380
EXPOSE 2889
EXPOSE 32769
EXPOSE 38503
EXPOSE 38711
EXPOSE 3889
EXPOSE 38969
EXPOSE 40225
EXPOSE 40645
EXPOSE 4195
EXPOSE 443
EXPOSE 45165
EXPOSE 46315
EXPOSE 4803
EXPOSE 53
EXPOSE 5432
EXPOSE 5433
EXPOSE 5434
EXPOSE 5444
EXPOSE 80
EXPOSE 8008
EXPOSE 8080
EXPOSE 8083
EXPOSE 8086
EXPOSE 8088
EXPOSE 8200
EXPOSE 8201
EXPOSE 8443
EXPOSE 8444
EXPOSE 9090
EXPOSE 9093
EXPOSE 9094
EXPOSE 9193
EXPOSE 9293
EXPOSE 9434
EXPOSE 9998

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]
