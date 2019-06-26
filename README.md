Build and install binfmt-support and qemu-user-static.
This allows running arm binaries via qemu transparently.

On debian:

```
sudo apt-get install debootstrap e2fsprogs dosfstools qemu-user-static
```

On arch:

```
sudo pacman -Sy debootstrap e2fsprogs dosfstools
git clone https://aur.archlinux.org/binfmt-support.git && cd binfmt-support && makepkg -si
git clone https://aur.archlinux.org/qemu-arm-static.git && cd qemu-arm-static && makepkg -si
git clone https://aur.archlinux.org/multipath-tools.git && cd multipath-tools && makepkg -si
```

Enable ARM binfmt:

```
update-binfmts --enable arm
```

Run bootstrap.sh to create initial debootstrapped image:

```
sudo ./bootstrap.sh
sudo chown $USER bootstrap.tar.gz trusted.gpg trusted.gpg~
```

Create docker image (finishes bootstrap and installs required software):

```
docker build -t rpi .
```

Export rootfs from the docker container:

```
docker create --name=rpi rpi /bin/bash
docker export rpi > rootfs.tar
docker rm rpi
```

Prepare proper image:

```
sudo ./mkimg.sh rootfs.tar rpi.img
sudo chown $USER rootfs.tar rpi.img
```

Flash the image:

```
sudo dd bs=4M if=rpi.img of=/dev/mmcblk0 conv=fsync
```

Remove docker leftovers:

```
docker system prune -a
```

On the host, to use Go stuff:

```
sudo /root/postinst.sh
dice-seed | tee /tmp/seed
```
