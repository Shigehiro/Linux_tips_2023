# Ansible build custom EE iamges

## Description
---

Here is how to build a custom EE(Execution Environments) image with ansible-builder.

## My requirements for the EE
---

- install [community.docker](!https://galaxy.ansible.com/community/docker) into the EE image

## Walthrough logs
---

Here are walkthrough logs.

### Ansible build file
---

Here is an [ansible builder file.](./ee_docker_plugin/builder.yml)
```text
---
version: 1

build_arg_defaults:
  EE_BASE_IMAGE: 'quay.io/ansible/ansible-runner:stable-2.12-latest'

ansible_config: 'ansible.cfg'

dependencies:
  galaxy: requirements.yml # required ansible collections
  system: bindep.txt # required rpm/deb files

additional_build_steps:
  append:
    - COPY docker-ce.repo /etc/yum.repos.d/docker-ce.repo # add docker-ce repo to install docker cli
    - RUN dnf install -y docker-ce-cli # install docker cli
```

### Build the custome EE image
---

Before buiiding an EE image, make sure you have installed podman or docker, ansible-navigator, ansible-builder and ansible-runner. You can install podman via dnf and the others via pip.    
- Build the image
```text
# ansible-builder build -v 3 --container-runtime=podman --file=builder.yml --tag=ee_docker_plugin:20230616
```

- Confirm you have the image
```text
# podman images|grep ee_docker_plugin
localhost/ee_docker_plugin            20230616            4de4eacfe624  About an hour ago  1.19 GB
```

### Run plybook with ansible-navigator
---

There are two nodes up and running as below.\
I will run the playbook againt the docker containers which are running on the remote node from the ansible-navigator node.\
[Here is the sample playbook](./sample_playbook)

```text
ansible-navigator        Docker containers*2
ansible-builder
-----------------  ---- ------------------
  CentOS Stream9         CentOS Stream9
   (podman)               (dockerd)
```

- Two containers are running on the remote node.
```text
# docker ps
CONTAINER ID   IMAGE                    COMMAND        CREATED        STATUS             PORTS     NAMES
92cdb5944e3b   compose_works_alam8-01   "/sbin/init"   16 hours ago   Up About an hour   22/tcp    alma8-01
e03b2d9e2811   compose_works_cnet9-01   "/sbin/init"   16 hours ago   Up About an hour   22/tcp    cent9-01
```

- Make sure you open a TCP port for docker daemon socket.\
To open a TCP port for docker daemon socket, see [my post](https://github.com/Shigehiro/Linux_tips_2023/blob/main/Run_ansible_against_docker_in_remote_nodes/README.md)


```text
# ansible-navigator run main.yml --eei 127.0.0.1:5000/docker_plugin_ee:20230616 -m stdout --pp never -i ./inventory.ini

PLAY [containers] **************************************************************

TASK [debug] *******************************************************************
ok: [cent9-01] => {
    "msg": "hello container!"
}
ok: [alma8-01] => {
    "msg": "hello container!"
}

PLAY RECAP *********************************************************************
alma8-01                   : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
cent9-01                   : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

You can use this EE image with AWX as well.