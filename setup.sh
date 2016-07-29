#!/bin/sh
# vim: ft=sh ts=2 sw=2 et :

set -ex

# Create partitions
sgdisk \
  -n 1::+128m --typecode 1:ef00 \
  -n 2 \
  /dev/sda
mkfs.ext4 /dev/sda2
mkfs.vfat -F32 /dev/sda1

# mount partitions
mount /dev/sda2 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot

# change mirrorlist
sed -e '1iServer = http://ftp.jaist.ac.jp/pub/Linux/ArchLinux/$repo/os/$arch' -i /etc/pacman.d/mirrorlist
sed -e '1iServer = http://ftp.tsukuba.wide.ad.jp/Linux/archlinux/$repo/os/$arch' -i /etc/pacman.d/mirrorlist

# copy base system and kernel images {{{
pacstrap /mnt base base-devel zsh git vim openssh
# }}}
# generate /etc/fstab from mouned conditions
genfstab -U -p /mnt >> /mnt/etc/fstab

# enter target environment and run setup scripts
cp ./setup-chroot.sh /mnt
chmod +x /mnt/setup-chroot.sh
arch-chroot /mnt /setup-chroot.sh
rm /mnt/setup-chroot.sh
