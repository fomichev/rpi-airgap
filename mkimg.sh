#!/bin/bash

set -e
set -x

[ -z "$1" ] && { echo "Specify input tar archive!"; exit 1; }
[ -z "$2" ] && { echo "Specify output image name!"; exit 1; }

ROOTFS=$PWD/$1
IMG=$PWD/$2

dd if=/dev/zero of=$IMG bs=1MB count=2048

fdisk $IMG << EOF
n
p
1

+64M
t
c
n
p
2


w
EOF

devs=$(kpartx -va $IMG | grep add | sed 's/.*\(loop[^ ]*\).*/\1/')
boot_dev=$(echo $devs | cut -f1 -d' ')
root_dev=$(echo $devs | cut -f2 -d' ')
echo $root_dev $boot_dev
[ "$boot_dev" = "" ] && exit 1
[ "$root_dev" = "" ] && exit 1

mkfs.vfat /dev/mapper/$boot_dev
mkfs.ext4 /dev/mapper/$root_dev

R=$PWD/rootfs
ROOT=$R/root
BOOT=$R/boot
mkdir -p $ROOT
mkdir -p $BOOT

mount /dev/mapper/$root_dev $ROOT
mount /dev/mapper/$boot_dev $BOOT

tar -C $ROOT -xf $ROOTFS
mv $ROOT/boot/* $BOOT
rm $ROOT/usr/bin/qemu-arm-static

umount $BOOT
umount $ROOT

kpartx -d $IMG

rm -rf $R

sync
