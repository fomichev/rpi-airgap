#!/bin/bash

set -e
set -x

I=$PWD/bootstrap.tar.gz
O=$PWD/rootfs.tar

c=$(buildah from scratch)
echo "Created container $c"

trap "buildah rm $c" EXIT

buildah add $c $I
buildah add $c overlay/etc /etc
buildah add $c overlay/boot /boot
buildah add $c overlay/home /home
buildah add $c overlay/usr /usr
buildah add $c overlay/stage2.sh
buildah add $c trusted.gpg

echo "Extracted base image, starting stage two..."
buildah run --net=host --volume $PWD/overlay:/overlay:ro $c /stage2.sh

m=$(buildah mount $c)
echo "Mounted container $m at $c, extracting base image..."
tar -C $m -cf $O .
buildah umount $c
