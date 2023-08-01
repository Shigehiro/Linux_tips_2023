FROM quay.io/centos/centos:stream9

WORKDIR /tmp

ENV ssh_pub id_rsa.pub
ENV ssh_private id_rsa
ENV root_password password
ENV ssh_config ssh_config

COPY ${ssh_pub} /tmp
COPY ${ssh_private} /tmp

WORKDIR /root
RUN dnf install -y cronie passwd 'dnf-command(versionlock)' man bash-completion openssh-server openssh-clients \
https://download.copr.fedorainfracloud.org/results/ansible/Rsyslog/epel-9-x86_64/06076718-rsyslog/rsyslog-8.2102.0-106.el9.x86_64.rpm && \
dnf versionlock add rsyslog-8.2102.0-106.el9 && rm -rf .ssh && mkdir .ssh && cat /tmp/${ssh_pub} > .ssh/authorized_keys && \
mv /tmp/${ssh_pub} .ssh/id_rsa.pub && mv /tmp/${ssh_private} .ssh/id_rsa && echo ${root_password} | passwd --stdin root && \
chmod 0400 .ssh/authorized_keys && chmod 0600 .ssh/id_rsa && chmod 0644 .ssh/id_rsa.pub
COPY ${ssh_config} /etc/ssh/ssh_config

# disable DNS lookup
RUN sed s/.*UseDNS.*/"UseDNS no"/ -i /etc/ssh/sshd_config

# https://access.redhat.com/solutions/6408321
COPY remove_run_nologin /etc/cron.d

EXPOSE 22

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/sbin/init"]
