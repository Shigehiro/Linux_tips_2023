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
RUN yum install -y rsyslog less man bash-completion openssh-server openssh-clients && \
mkdir .ssh && cat /tmp/${ssh_pub} > .ssh/authorized_keys && \
mv /tmp/${ssh_pub} .ssh/id_rsa.pub && mv /tmp/${ssh_private} .ssh/id_rsa && echo ${root_password} | passwd --stdin root && \
chmod 0400 .ssh/authorized_keys && chmod 0600 .ssh/id_rsa && chmod 0644 .ssh/id_rsa.pub
COPY ${ssh_config} /etc/ssh/ssh_config

# disable DNS lookup
RUN sed s/.*UseDNS.*/"UseDNS no"/ -i /etc/ssh/sshd_config

EXPOSE 22

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]
