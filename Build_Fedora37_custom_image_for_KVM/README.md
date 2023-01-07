# Build Fedora37 custom image for KVM

# Environment

KVM host
```text
$ lsb_release -a 2>/dev/null|grep ^Desc
Description:    Ubuntu 22.04.1 LTS
```

# Walkthrough logs

The precedures are almost the same in my another [post](https://github.com/Shigehiro/Linux_tips_2023/blob/main/Build_Rocky9_custom_image_for_KVM/README.md)
Download a kickstart file from [here](https://pagure.io/fedora-kickstarts), edit the file to meet your environment.

build a image.
```text
$ ./build_fedora37.sh 
```

```text
$ sudo virt-sparsify --compress ./fedora37-ks.qcow2 fedora37-template.qcow2

$ sudo virt-sysprep -a fedora37-template.qcow2
```

