FROM scratch
ADD bootstrap.tar.gz /

COPY --chown=root:root boot/ /boot/

COPY --chown=root:root etc/ /etc/
RUN chmod -R 0755 /etc/default

COPY --chown=root:root bin/ /bin/
RUN chmod 0755 /bin/gpg-*

# apt-get does setuid(apt) and fails to verify signature otherwise
ADD trusted.gpg /etc/apt/trusted.gpg
RUN chown _apt /etc/apt/trusted.gpg
RUN chmod -R 0755 /etc/apt

RUN update-ca-certificates

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

# create pi user
RUN apt-get install sudo
RUN groupadd -r pi
RUN useradd -r -g pi pi
RUN usermod -a -G sudo,staff,kmem,plugdev pi
RUN passwd -d pi
RUN mkdir /home/pi
RUN chown pi /home/pi
RUN chsh -s /bin/bash pi

COPY --chown=pi:pi home/pi/ /home/pi/

RUN apt-get install -y git
RUN git clone --depth 1 https://github.com/raspberrypi/firmware.git
RUN cp -R firmware/boot /
RUN cp -R firmware/hardfp/opt /
RUN cp -R firmware/modules /lib
RUN rm -rf firmware

# create usbmount mount points
RUN mkdir -p /media/usb0 /media/usb1 /media/usb2 /media/usb3 \
             /media/usb4 /media/usb5 /media/usb6 /media/usb7
RUN chown -R pi /media

WORKDIR /root

# install better console fonts
RUN apt-get install -y kbd

# install raspi-config
RUN apt-get install -y --allow-unauthenticated raspi-config

# install usbmoun
RUN apt-get install -y -o Dpkg::Options::="--force-confdef" usbmount

# compiler & libs
RUN apt-get install -y libboost-all-dev libssl1.0-dev libpcre3-dev automake autoconf

# electrum
RUN apt-get install -y electrum

# yubikey
RUN apt-get install -y yubikey-personalization
RUN curl -LO https://raw.githubusercontent.com/a-dma/yubitouch/master/yubitouch.sh
RUN chmod +x ./yubitouch.sh
RUN mv ./yubitouch.sh /bin/yubitouch.sh

# fat fsck
RUN apt-get install -y dosfstools

# go
RUN curl -LO https://dl.google.com/go/go1.12.6.linux-armv6l.tar.gz
RUN tar -C /usr/local -xzf go*.linux-armv6l.tar.gz
ENV PATH="${PATH}:/usr/local/go/bin"

# dice-seed (download only, compilation doesn't work in qemu)
RUN go get -v -d github.com/fomichev/dice-seed

# post install script
COPY --chown=root:root postinst.sh /

RUN apt-get clean
