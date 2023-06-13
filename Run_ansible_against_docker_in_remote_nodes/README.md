# How to run Ansible playbooks against Docker containers running on remote nodes

- [How to run Ansible playbooks against Docker containers running on remote nodes](#how-to-run-ansible-playbooks-against-docker-containers-running-on-remote-nodes)
  - [Description](#description)
  - [Tested Environment](#tested-environment)
  - [Walkthrough logs](#walkthrough-logs)
    - [Open a TCP port for Docker daemon socket on the managed node](#open-a-tcp-port-for-docker-daemon-socket-on-the-managed-node)
    - [Controller node](#controller-node)
    - [Run the playbook](#run-the-playbook)

## Description
---

Here is how to run ansible playbooks against docker containers running on a remote node.

## Tested Environment
---

```text

                         docker containers
                         -----------------
controller(CentOS) ---- managed node(CentOS)
```

- OS : CentOS Stream9
- install docker engine on the managed node
- install ansible on the controller node

## Walkthrough logs
---

### Open a TCP port for Docker daemon socket on the managed node
---

```text
# systemctl cat docker.service |grep ^ExecStart
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock -H tcp://0.0.0.0:1337
```

- restart docker.service to reflect the config
```text
# systemctl restart docker.service
```

- two containers are up and running on the managed node.
```
# docker ps
CONTAINER ID   IMAGE                    COMMAND        CREATED        STATUS             PORTS     NAMES
844b9bc63607   compose_works_alam8-01   "/sbin/init"   24 hours ago   Up About an hour   22/tcp    alama8-01
19bc303cdc18   compose_works_cnet9-01   "/sbin/init"   24 hours ago   Up About an hour   22/tcp    cent9-01
```

### Controller node
---

- make sure you have installed community.docker collection.
```
$ ansible-galaxy collection list |grep community.docker
community.docker              3.4.6
```

- inventory file will like like this (inventory.ini)
```text
[containers]
cent9-01 ansible_host=cent9-01
alama8-01 ansible_hosst=alma8-01

[containers:vars]
ansible_connection=docker
ansible_docker_extra_args="-H tcp://192.168.123.12:1337"
```

### Run the playbook
---

- ad-hoc mode
```text
# ansible -i inventory.ini all -m ping
cent9-01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
alama8-01 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/libexec/platform-python"
    },
    "changed": false,
    "ping": "pong"
}
```

- sample playbook

main.yml
```text
---
- hosts: containers
  gather_facts: false
  tasks:
  - name: debug
    ansible.builtin.debug:
      msg: "hello container!"
```

- run the playbook
```text
# ansible-playbook -i inventory.ini main.yml

PLAY [containers] ******************************************************************************************************************************

TASK [debug] ***********************************************************************************************************************************ok: [cent9-01] => {
    "msg": "hello container!"
}
ok: [alama8-01] => {
    "msg": "hello container!"
}

PLAY RECAP *************************************************************************************************************************************alama8-01                  : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
cent9-01                   : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
