#!/bin/bash

set -e
set -x

# WTF? Export and rewrite the orignial trusted.gpg, otherwise:
# The key(s) in the keyring /etc/apt/trusted.gpg are ignored as the
# file has an unsupported filetype.
gpg --no-default-keyring --keyring /trusted.gpg --export > /etc/apt/trusted.gpg

ln -s /usr/local/bin/addhwrng /bin/addhwrng
chown -R root:root /boot
chown -R root:root /etc
chown -R root:root /usr/local/bin

chmod -R 0755 /etc/default
chmod -R 0755 /usr/local

# apt-get does setuid(apt) and fails to verify signature otherwise
chown _apt /etc/apt/trusted.gpg
chmod -R 0755 /etc/apt

update-ca-certificates

export DEBIAN_FRONTEND=noninteractive

apt-get update

# create pi user
apt-get install sudo
groupadd -r pi
useradd -r -g pi pi
usermod -a -G sudo,staff,kmem,plugdev pi
passwd -d pi
chown -R pi:pi /home/pi
chsh -s /bin/bash pi
ln -sf /media/.gnupg /home/pi/.gnupg

apt-get install -y git
git clone --depth 1 https://github.com/raspberrypi/firmware.git
cp -R firmware/boot /
cp -R firmware/hardfp/opt /
cp -R firmware/modules /lib
rm -rf firmware

chown -R pi /media

cd /root

# install better console fonts
apt-get install -y kbd

# install raspi-config
apt-get install -y raspi-config

# compiler & libs
apt-get install -y libboost-all-dev libssl1.0-dev libpcre3-dev automake autoconf

# electrum
apt-get install -y electrum

# fat fsck
apt-get install -y dosfstools

# qrencode
apt-get install -y qrencode

# gpg smartcard
apt-get install -y pcscd scdaemon

# mkfs.ext4
apt-get install -y e2fsprogs

# rsync
apt-get install -y rsync

# go
apt-get install -y wget
wget https://golang.org/dl/go1.15.6.linux-armv6l.tar.gz
tar -C /usr/local -xzf go*.linux-armv6l.tar.gz
PATH="${PATH}:/usr/local/go/bin"

# dice-seed
go get -v -d github.com/fomichev/dice-seed
/usr/local/go/bin/go build github.com/fomichev/dice-seed
mv dice-seed /usr/local/bin

# cleanup
apt-get clean
rm /trusted.gpg /stage2.sh
