Build and install binfmt-support and qemu-user-static.
This allows running arm binaries via qemu transparently.

On debian:

```
sudo apt-get install debootstrap e2fsprogs dosfstools qemu-user-static
```

On arch:

```
sudo pacman -Sy debootstrap e2fsprogs dosfstools
git clone https://aur.archlinux.org/qemu-arm-static.git && cd qemu-arm-static && makepkg -si

# kpartx
git clone https://aur.archlinux.org/multipath-tools.git && cd multipath-tools && makepkg -si
```

Enable ARM binfmt:

```
echo ":arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-arm-static:" | sudo tee /etc/binfmt.d/qemu-arm.conf

sudo systemctl restart systemd-binfmt
```

Run bootstrap.sh to create initial debootstrapped image:

```
sudo ./bootstrap.sh
sudo chown $USER bootstrap.tar.gz trusted.gpg
```

Create docker image (finishes bootstrap and installs required software):

```
sudo systemctl start docker.service
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
sudo systemctl stop docker.service
```

On the host, to use Go stuff:

```
sudo /postinst.sh
dice-seed | tee /tmp/seed
```
