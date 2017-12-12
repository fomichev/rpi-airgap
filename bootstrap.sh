#!/bin/bash

set -e
set -x

D=bootstrap
P=$PWD/$D
O=$PWD/bootstrap.tar.gz

wget https://archive.raspbian.org/raspbian.public.key
gpg --no-default-keyring --keyring rpi.gpg --fingerprint
gpg --no-default-keyring --keyring rpi.gpg --import raspbian.public.key
rm raspbian.public.key

debootstrap \
	    --arch armhf \
	    --keyring ~/.gnupg/rpi.gpg \
	    --foreign \
	    --include ca-certificates,apt-transport-https,curl \
	    stretch $D http://archive.raspbian.org/raspbian

cp $(which "qemu-arm-static") $P/usr/bin
chmod 0755 $P/usr/bin/qemu-arm-static
chroot $D /debootstrap/debootstrap --second-stage

rm -rf $P/debootstrap

tar -C $P -czvf $O .
chown $USER $O
rm -rf $P
