Build and install binfmt-support and qemu-user-static.
This allows running arm binaries via qemu transparently.

On arch:
$ sudo pacman -Sy debootstrap e2fsprogs dosfstools
$ git clone https://aur.archlinux.org/binfmt-support.git && cd binfmt-support && makepkg -si
$ git clone https://aur.archlinux.org/qemu-arm-static.git && cd qemu-arm-static && makepkg -si
$ git clone https://aur.archlinux.org/multipath-tools.git && cd multipath-tools && makepkg -si
$ update-binfmts --enable qemu-arm

Run bootstrap.sh to create initial debootstrapped image:
$ sudo ./bootstrap.sh

Create docker image (finishes bootstrap and installs required software):
$ docker build -t rpi .

Export rootfs from the docker container:
$ docker create --name=rpi rpi /bin/bash
$ docker export rpi > rootfs.tar

Prepare proper image:
$ sudo ./mkimg.sh rootfs.tar rpi.img

Flash the image:
dd bs=4M if=rpi.img of=/dev/sdX conv=fsync
