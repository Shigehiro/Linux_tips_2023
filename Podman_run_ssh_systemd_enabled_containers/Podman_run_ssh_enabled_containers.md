# How to run systemd, sshd, rsyslog enabled containers on CentOS Stream 9(podman)

- [How to run systemd, sshd, rsyslog enabled containers on CentOS Stream 9(podman)](#how-to-run-systemd-sshd-rsyslog-enabled-containers-on-centos-stream-9podman)
  - [Description](#description)
  - [Testing results (as of 2023.10.2)](#testing-results-as-of-2023102)
  - [Tested environment](#tested-environment)
  - [Install podman](#install-podman)
  - [Build and run containers](#build-and-run-containers)
    - [AlmaLinux8 container (enable systemd, rsyslog, sshd), cgroup v2](#almalinux8-container-enable-systemd-rsyslog-sshd-cgroup-v2)
    - [AlmaLinux9 container (enable systemd, rsyslog, sshd), cgroup v2](#almalinux9-container-enable-systemd-rsyslog-sshd-cgroup-v2)
    - [CentOS7 container (enable systemd, rsyslog, sshd), cgroup v2](#centos7-container-enable-systemd-rsyslog-sshd-cgroup-v2)
    - [CentOS Stream9 container (enable systemd, rsyslog, sshd), cgroup v2](#centos-stream9-container-enable-systemd-rsyslog-sshd-cgroup-v2)
    - [CentOS7 container (enable systemd, rsyslog, sshd), cgroup v1](#centos7-container-enable-systemd-rsyslog-sshd-cgroup-v1)

## Description
---

I struggled to run the containers which meet the following conditions on CentOS Stream 9 with podman `cgroup v2`.
I know this is an anti pattern, I however sometimes need those kind of containers to mimic virtual machines like environment.
Here is the notes what I did.

- enable systemd
- enable sshd
- enable rsyslog

## Testing results (as of 2023.10.2)
---

| Container image   | cgroup<br>(Host OS) | systemd<br>(container) | sshd<br>(container) | rsyslog<br>(container) | Added Capabiities       | Note               |
| -------------- | ------ | ------- | ---- | ------- | ----------------------- | ------------------ |
| CentOS Stream9 | v2     | OK      | OK   | OK      | AUDIT_WRITE            | ~~install old rsyslog~~ |
| CentOS7        | v2     | NG      | NG   | NG      | AUDIT_WRITE, privileged | See [2]            |
| CentOS7        | v1     | OK      | OK   | OK      | AUDIT_WRITE             | See [2]            |
| Alma Linux8 | v2     | OK      | OK   | OK      | AUDIT_WRITE             | None               |
| Alma Linux9 | v2     | OK      | OK   | OK  | AUDIT_WRITE             | None               |
<br>

- ~~[1] https://bugzilla.redhat.com/show_bug.cgi?id=1923728#c2~~
- [2] https://github.com/containers/podman/issues/5153#issuecomment-584649533
- ~~Why rsyslog inside the CentOS9 container worked, but Alama9's did not?~~
  - ~~This is caused by compile options of rsyslog provided by RHEL9 repo.~~
  - ~~Before `rsyslog-8.2102.0-106.el9` would work, but the later versions would not, because the compile options have changed after `rsyslog-8.2102.0-106.el9`, which prevents the rsyslog from running inside the container.~~
  - ~~As for CentOS Stream 9 repo, I could find the old rsyslog `rsyslog-8.2102.0-106.el9` via CentOS9 repo, so I intentionally installed the old rsyslog via `dnf install` when building the CentOS Stream9 container. I, however, could not find the older rsyslog on Alma9 and Rocky9 repo, that's the reason why the rsyslog inside the Alma9 container did not work. If you would like to konw more about this, please see the below.~~
    - ~~https://unix.stackexchange.com/questions/747224/unable-to-run-rsyslogd-as-non-root-user-on-centos-stream-9~~
    - ~~https://github.com/rsyslog/rsyslog/blob/master/tools/rsyslogd.c#L2203~~
    - ~~https://github.com/ansible/awx/issues/13394~~

## Tested environment
---

```text
[root@cent9-01 ~]# cat /etc/centos-release ;uname -ri
CentOS Stream release 9
5.14.0-319.el9.x86_64 x86_64

[root@cent9-01 ~]# getenforce 
Permissive

# podman --version 
podman version 4.4.1

# podman info |grep -i cgroupver
  cgroupVersion: v2
```

## Install podman
---

Install podman.
```text
# dnf install container-tools -y
```

```text
# reboot
```

## Build and run containers
---

### AlmaLinux8 container (enable systemd, rsyslog, sshd), cgroup v2
---

[Build alma8 container](./Alma8-systemd-ssh/Dockerfile)
```text
# podman build --tag alma8-systemd-ssh .
```

Run the container. To access to the container over ssh, add a capability AUDIT_WRITE.
- see https://github.com/containers/podman/issues/13012
```text
# podman container run -it -d --cap-add AUDIT_WRITE -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v $(mktemp -d):/run alma8-systemd-ssh:latest 
```

Confirm sshd and rsyslog is up and running.
```text
# podman exec unruffled_kepler systemctl status rsyslog sshd |grep -i Active
   Active: active (running) since Thu 2023-06-01 17:01:08 UTC; 1min 51s ago
   Active: active (running) since Thu 2023-06-01 17:01:08 UTC; 1min 51s ago
```

Confirm you can log into the container over ssh.
```text
[root@cent9-01 Alma8-systemd-ssh]# ssh root@10.88.0.15
root@10.88.0.15's password: 
Last login: Thu Jun  1 17:17:40 2023 from 10.88.0.1
[root@a54b5253c10e ~]# 
```

### AlmaLinux9 container (enable systemd, rsyslog, sshd), cgroup v2
---

[Build alma9 container](./Alma9-systemd-ssh/Dockerfile)
```text
# podman build --tag alma9-systemd-ssh .
```
```text
# podman container run -it -d --cap-add AUDIT_WRITE -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v $(mktemp -d):/run alma9-systemd-ssh:latest 
```

~~If you need rsyslog, add `privileged`. systemd, sshd and rsyslog would work.~~
- ~~https://unix.stackexchange.com/questions/747224/unable-to-run-rsyslogd-as-non-root-user-on-centos-stream-9~~
- ~~https://github.com/rsyslog/rsyslog/blob/master/tools/rsyslogd.c#L2203~~
- ~~https://github.com/ansible/awx/issues/13394~~

### CentOS7 container (enable systemd, rsyslog, sshd), cgroup v2
---

systemd provided by CentOS7 is too old. 
systemd(sshd, rsyslog) did not run on CentOS Stream9 with podman `cgroup v2`
- https://github.com/containers/podman/issues/5153#issuecomment-584649533

[Build CentOS7 container](./Cent7-systemd-ssh/Dockerfile)
```text
# podman build --tag cent7-systemd-ssh .
```

```text
# podman container run -it -d --privileged --cap-add AUDIT_WRITE -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v $(mktemp -d):/run cent7-systemd-ssh:latest
```

You will notice systemd,rsyslog,sshd are not running.
If you would like to run CentOS7 image with systemd,rsyslog,sshd, [use cgroup v1](#centos7-container-enable-systemd-rsyslog-sshd-cgroup-v1)

### CentOS Stream9 container (enable systemd, rsyslog, sshd), cgroup v2
---

[Build CentOS Stream9 container](./CentOS-Stream9-systemd-ssh/Dockerfile)

```text
# podman build --tag cent9-systemd-ssh .
```

```text
# podman container run -it -d --cap-add AUDIT_WRITE -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v $(mktemp -d):/run cent9-systemd-ssh:latest
```

```text
# podman exec suspicious_meitner rpm -qf $(which rsyslogd)
rsyslog-8.2102.0-106.el9.x86_64

# podman exec suspicious_meitner systemctl status sshd rsyslog |grep -i active
     Active: active (running) since Fri 2023-06-02 05:31:38 UTC; 50s ago
     Active: active (running) since Fri 2023-06-02 05:31:37 UTC; 52s ago
```

### CentOS7 container (enable systemd, rsyslog, sshd), cgroup v1
---

change cgroup to v1
- [Mounting cgroups-v1](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/managing_monitoring_and_updating_the_kernel/index#proc_mounting-cgroups-v1_assembly_using-cgroupfs-to-manually-manage-cgroups)

```text
# podman info | grep -i cgroupver
  cgroupVersion: v1
```

```text
# podman container run -it -d --cap-add AUDIT_WRITE -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v $(mktemp -d):/run cent7-systemd-ssh:latest
```

```text
# podman exec agitated_lovelace systemctl status sshd rsyslog |grep -i active
   Active: active (running) since Fri 2023-06-02 05:39:25 UTC; 28s ago
   Active: active (running) since Fri 2023-06-02 05:39:25 UTC; 28s ago
```

```text
[root@cent9-01 ~]# podman inspect agitated_lovelace |grep -i ipa
               "IPAddress": "10.88.0.2",
                         "IPAddress": "10.88.0.2",
                         "IPAMConfig": null,
[root@cent9-01 ~]# ssh root@10.88.0.2
root@10.88.0.2's password:
System is booting up. See pam_nologin(8)
Last login: Fri Jun  2 05:40:36 2023 from host.containers.internal
[root@7491ab99720d ~]# exit
logout
Connection to 10.88.0.2 closed.
[root@cent9-01 ~]#
```
