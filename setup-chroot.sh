#!/bin/sh
# vim: ft=sh ts=2 sw=2 et :

set -ex

# set hostname
echo arch-localhost > /etc/hostname
# set locale settings
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
sed -i.bak -e 's/#\(en_US.UTF-8.*\)/\1/' /etc/locale.gen
rm /etc/locale.gen.bak
locale-gen

# settings of account
useradd -m -G wheel -s /bin/zsh archie
echo -e 'archie\narchie\n' | passwd
echo -e 'archie\narchie\n' | passwd archie
mkdir -p /etc/sudoers.d
cat > /etc/sudoers.d/archie << EOF
archie ALL=(ALL) NOPASSWD: ALL
Defaults env_keep += "SSH_AUTH_SOCK"
EOF
chmod 0440 /etc/sudoers.d/archie
echo "UseDNS no" >> /etc/sshd_config
echo 'sshd: ALL' > /etc/hosts.allow
echo 'ALL: ALL' > /etc/hosts.deny

# shared folder settings
#modprobe -a vboxguest vboxsf
#cat > /etc/modules-load.d/virtualbox.conf << EOF
#vboxguest
#vboxsf
#EOF
#gpasswd -a vagrant vboxsf
#systemctl enable vboxservice

# enable network settings
device_name=$(ip addr | grep "^[0-9]" | awk '{print $2}' | sed -e 's/://' | grep -v '^lo$' | head -n 1)
systemctl enable sshd.service
systemctl enable "dhcpcd@${device_name}.service"

# install bootloader
bootctl --path=/boot install
cat << EOF > /boot/loader/loader.conf
default  arch
timeout  1
editor   0
EOF
cat << EOF > /boot/loader/entries/arch.conf
title    Arch Linux
linux    /vmlinuz-linux
initrd   /initramfs-linux.img
options  root=PARTUUID=$(blkid -s PARTUUID -o value /dev/sda2) rw
EOF
