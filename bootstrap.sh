#!/bin/bash

set -e
set -x

D=bootstrap
P=$PWD/$D
O=$PWD/bootstrap.tar.gz

rm -f ./trusted.gpg
gpg --no-default-keyring --keyring ./trusted.gpg --fingerprint
curl -LO https://archive.raspbian.org/raspbian.public.key
gpg --no-default-keyring --keyring ./trusted.gpg --import raspbian.public.key
curl -LO https://archive.raspberrypi.org/debian/raspberrypi.gpg.key
gpg --no-default-keyring --keyring ./trusted.gpg --import raspberrypi.gpg.key

debootstrap \
	    --arch armhf \
	    --keyring ./trusted.gpg \
	    --foreign \
	    --include ca-certificates,apt-transport-https,curl \
	    stable $D http://mirrordirector.raspbian.org/raspbian

cp $(which "qemu-arm-static") $P/usr/bin
chmod 0755 $P/usr/bin/qemu-arm-static
chroot $D /debootstrap/debootstrap --second-stage
rm -rf $P/debootstrap

tar -C $P -czvf $O .
chown $USER $O
rm -rf $P raspbian.public.key raspberrypi.gpg.key
