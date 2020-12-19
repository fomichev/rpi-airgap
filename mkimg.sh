#!/bin/bash

set -e
set -x

[ -z "$1" ] && { echo "Specify input tar archive!"; exit 1; }
[ -z "$2" ] && { echo "Specify output image name!"; exit 1; }

ROOTFS=$PWD/$1
IMG=$PWD/$2
SIZE_MB=4096

dd if=/dev/zero of=$IMG bs=1MB count=$SIZE_MB

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

kpartx -va $IMG
kpartx -l $IMG

boot_dev=$(kpartx -l $IMG | head -n1 | cut -d' ' -f1)
root_dev=$(kpartx -l $IMG | tail -n1 | cut -d' ' -f1)
echo "root='$root_dev' boot='$boot_dev'"
[ "$boot_dev" = "" ] && exit 1
[ "$root_dev" = "" ] && exit 1

R=$PWD/rootfs
ROOT=$R/root
BOOT=$R/boot

cleanup() {
	umount $BOOT
	umount $ROOT

	kpartx -d $IMG

	rm -rf $R
}
trap cleanup EXIT

mkfs.vfat /dev/mapper/$boot_dev
mkfs.ext4 /dev/mapper/$root_dev

mkdir -p $ROOT
mkdir -p $BOOT

mount /dev/mapper/$root_dev $ROOT
mount /dev/mapper/$boot_dev $BOOT

tar -C $ROOT -xf $ROOTFS
mv $ROOT/boot/* $BOOT
rm $ROOT/usr/bin/qemu-arm-static

sync
