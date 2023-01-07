# fedora-server-vm-full.ks (rel. 1.01)
# Kickstart file to build a Fedora Server Edition VM disk image.
# The image aims to resemble as close as technically possible the
# full features of a Fedora Server Edition in a virtual machine.
#
# The image uses GPT partition type as of default in Fedora 37
#
# At first boot it opens a test based basic configuration screen.
#
# This kickstart file is designed to be used with ImageFactory (in Koji).
#
# To build the image locally, you need to install ImageFactory and
# various additional helpers and configuration files.
# See Fedora Server Edition user documentation tutorial.

# Use text mode install
text

# Keyboard layouts
keyboard 'jp106'

# System language
lang en_US.UTF-8

# System timezone
# set time zone to GMT (Etcetera/UTC)
timezone Asia/Tokyo --utc


# Root password
rootpw --plaintext root

# Create User Account
user --name=fedora --password=fedora --plaintext --groups=wheel

# SELinux configuration
selinux --permissive


# System bootloader configuration
bootloader --location=mbr --timeout=1 --append="console=tty1 console=ttyS0,115200n8"

# Network information
network  --bootproto=dhcp --device=link --activate --onboot=on

# Firewall configuration
firewall --enabled --service=mdns


# System services
# message: error enabling initial-setup, initial-setup does not exist
services --enabled="sshd,NetworkManager,chronyd,initial-setup"

# Run the Setup Agent on first boot
firstboot --reconfig

# Partition Information. Use GPT by default (since Fedora 37)
# Resemble the Partitioning used for Fedora Server Install media
clearpart --all --initlabel --disklabel=gpt
reqpart --add-boot
part pv.007     --size=4000  --grow
volgroup  sysvg  pv.007
logvol / --vgname=sysvg --size=4000 --grow --maxsize=60000 --fstype=xfs --name=root --label=sysroot


# Include URLs for network installation dynamically, dependent from Fedora release
# and imagefactory runtime environment
#%include fedora-repo.ks

# Shutdown after installation
shutdown

##### begin package list #############################################
%packages --inst-langs=en

@server-product
@core
@headless-management
@standard
@networkmanager-submodules
##@container-management
@domain-client
@guest-agents

# All arm-tools packages install on aarch64/armhfp only
# TODO: on a x86_64 devel environment are @arm-tools not available
# and cause a build error.
# @arm-tools

# Standard Fedora Package Groups
## dracut-config-generic  ## included in =core=
glibc-all-langpacks
initial-setup
kernel-core
-dracut-config-rescue
-generic-release*
-initial-setup-gui
-kernel
-linux-firmware
-plymouth
# pulled in by @standard
-smartmontools
-smartmontools-selinux

%end
##### end package list ###############################################


##### begin kickstart post script ####################################
%post --erroronfail  --log=/root/anaconda-post-1.log

# Find the architecture we are on
arch=$(uname -m)

# Import RPM GPG key, during installation saved in /etc/pki
echo "Import RPM GPG key"
releasever=$(rpm --eval '%{fedora}')
basearch=$(uname -i)
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch

# See the systemd-random-seed.service man page that says:
#   " It is recommended to remove the random seed from OS images intended
#     for replication on multiple systems"
# The newly installed instance should make it's own
echo "Removing random-seed so it's not the same in every image."
rm -f /var/lib/systemd/random-seed

# When we build the image a networking config file gets left behind.
# Let's clean it up.
echo "Cleanup leftover networking configuration"
rm -f /etc/NetworkManager/system-connections/*.nmconnection

# Truncate the /etc/resolv.conf left over from NetworkManager during the
# kickstart because the DNS server is environment specific.
truncate -s 0 /etc/resolv.conf

echo "Cleaning repodata to save space."
dnf clean all

# linux-firmware is installed by default and is quite large. As of mid 2020:
#   Total download size: 97 M
#   Installed size: 268 M
# Not needed in virtual environment.
echo "Removing linux-firmware package."
rpm -e linux-firmware

# Will ever anybody see this?
echo "Packages within this disk image"
rpm -qa --qf '%{size}\t%{name}-%{version}-%{release}.%{arch}\n' |sort -rn

# Note that running rpm recreates the rpm db files which aren't needed or wanted
rm -f /var/lib/rpm/__db*


# Do we need a serial terminal with a VM?
if [[ $arch == "aarch64" ]] || [[ $arch == "armv7l" ]]; then
 # Anaconda adds console=tty0 to the grub boot line on all images. this is problematic
 # when you are using fedora via serial console as you do not get any output post grub
 # linux does a good job of knowing what consoles need to be enabled.
 # https://bugzilla.redhat.com/show_bug.cgi?id=2022757
 sed -i -e 's|console=tty0||g' /boot/loader/entries/*conf
fi


# Remove machine-id on pre generated images
rm -f /etc/machine-id
touch /etc/machine-id

%end
##### end kickstart post script #####################################


##### begin custom post script (after base) #########################
%post

# allow a root to login the machine over ssh
sed s/".*PermitRootLogin.*"/"PermitRootLogin yes"/ /etc/ssh/sshd_config -i

echo "fedora ALL=NOPASSWD: ALL" | tee -a /etc/sudoers.d/fedora

echo "Zeroing out empty space."
# Create zeros file with nodatacow and no compression
touch /var/tmp/zeros
chattr +C /var/tmp/zeros
# This forces the filesystem to reclaim space from deleted files
dd bs=1M if=/dev/zero of=/var/tmp/zeros || :
echo "(Don't worry -- that out-of-space error was expected.)"
# Force sync to disk
sync /
rm -f /var/tmp/zeros
sync /

# setup systemd to boot to the right runlevel
echo -n "Setting default runlevel to multiuser text mode"
rm -f /etc/systemd/system/default.target
ln -s /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
echo .

%end
##### end custom post script ########################################
