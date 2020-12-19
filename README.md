Build and install binfmt-support and qemu-user-static.
This allows running arm binaries via qemu transparently.

On debian:

```
sudo apt-get install debootstrap e2fsprogs dosfstools qemu-user-static
```

On arch:

```
sudo pacman -Sy debootstrap e2fsprogs dosfstools
yay qemu-user-static-bin

# kpartx
git clone https://aur.archlinux.org/multipath-tools.git && cd multipath-tools && makepkg -si
```

Enable ARM binfmt:

```
echo ":arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-arm-static:" | sudo tee /etc/binfmt.d/qemu-arm.conf

sudo systemctl restart systemd-binfmt
```

Run bootstrap.sh to create initial debootstrapped image (`bootstrap.tar.gz`):

```
sudo ./bootstrap.sh
sudo chown $USER bootstrap.tar.gz trusted.gpg
```

Run buildah to prepare the image and install everything:

```
sudo ./buildah.sh
sudo chown $USER rootfs.tar
```

The command above will output `rootfs.tar`, now convert it to an image:

```
sudo ./mkimg.sh rootfs.tar rpi.img
sudo chown $USER rootfs.tar rpi.img
```

Flash the image:

```
sudo dd bs=32M if=rpi.img of=/dev/mmcblk0 status=progress
sync
```
