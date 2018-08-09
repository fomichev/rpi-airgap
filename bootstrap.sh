#!/bin/bash

set -e
set -x

D=bootstrap
P=$PWD/$D
O=$PWD/bootstrap.tar.gz

gpg --no-default-keyring --keyring ./rpi.gpg --fingerprint
curl -LO https://archive.raspbian.org/raspbian.public.key
gpg --no-default-keyring --keyring ./rpi.gpg --import raspbian.public.key
curl -LO https://archive.raspberrypi.org/debian/raspberrypi.gpg.key
gpg --no-default-keyring --keyring ./rpi.gpg --import raspberrypi.gpg.key

debootstrap \
	    --arch armhf \
	    --keyring ./rpi.gpg \
	    --foreign \
	    --include ca-certificates,apt-transport-https,curl \
	    stable $D https://archive.raspbian.org/raspbian

cp $(which "qemu-arm-static") $P/usr/bin
chmod 0755 $P/usr/bin/qemu-arm-static
chroot $D /debootstrap/debootstrap --second-stage
rm -rf $P/debootstrap

tar -C $P -czvf $O .
chown $USER $O
rm -rf $P raspbian.public.key raspberrypi.gpg.key rpi.gpg
