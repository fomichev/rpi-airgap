FROM scratch
ADD bootstrap.tar.gz /

COPY --chown=root:root etc/ /etc/
COPY --chown=root:root boot/ /boot/

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

# install raspi-config
RUN apt-get install -y --allow-unauthenticated raspi-config

# install usbmoun
RUN apt-get install -y -o Dpkg::Options::="--force-confdef" usbmount

# compiler & libs
RUN apt-get install -y libboost-all-dev libssl1.0-dev libpcre3-dev automake autoconf

WORKDIR /root

# electrum
RUN apt-get install -y electrum

# yubikey

RUN apt-get install -y yubikey-personalization
RUN curl -LO https://raw.githubusercontent.com/a-dma/yubitouch/master/yubitouch.sh
RUN chmod +x ./yubitouch.sh

# fat fsck

RUN apt-get install -y dosfstools

RUN apt-get clean
