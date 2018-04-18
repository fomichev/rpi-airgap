FROM scratch
ADD bootstrap.tar.gz /

COPY --chown=root:root etc/ /etc/
COPY --chown=root:root boot/ /boot/

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

RUN apt-get install -y git
RUN git clone --depth 1 https://github.com/raspberrypi/firmware.git
RUN cp -R firmware/boot /
RUN cp -R firmware/hardfp/opt /
RUN cp -R firmware/modules /lib
RUN rm -rf firmware

# install raspi-config
RUN apt-get install -y raspi-config

# install usbmoun
RUN apt-get install -y -o Dpkg::Options::="--force-confdef" usbmount

# compiler & libs
RUN apt-get install -y libboost-all-dev libssl1.0-dev libpcre3-dev automake autoconf

WORKDIR /root

# veracrypt
RUN apt-get install -y libfuse-dev makeself
RUN curl -LO https://launchpad.net/veracrypt/trunk/1.21/+download/veracrypt-1.21-raspbian-setup.tar.bz2
RUN curl -LO https://launchpad.net/veracrypt/trunk/1.21/+download/veracrypt-1.21-raspbian-setup.tar.bz2.sig
RUN curl -LO https://www.idrix.fr/VeraCrypt/VeraCrypt_PGP_public_key.asc
RUN gpg --import VeraCrypt_PGP_public_key.asc
RUN gpg --verify veracrypt-1.21-raspbian-setup.tar.bz2.sig veracrypt-1.21-raspbian-setup.tar.bz2
RUN tar xf veracrypt-1.21-raspbian-setup.tar.bz2
RUN rm veracrypt-1.21-raspbian-setup.tar.bz2
RUN mv veracrypt-1.21-setup-console-armv7 /usr/local/bin

# electrum
RUN apt-get install -y electrum

# electrum-ltc
RUN apt-get install -y python-pip python-dev
RUN wget https://github.com/pooler/electrum-ltc/archive/3.1.2.1.tar.gz
RUN pip2 install ./3.1.2.1.tar.gz

# vanitygen-plus
RUN git clone https://github.com/exploitagency/vanitygen-plus.git
RUN cd vanitygen-plus && make && mv vanitygen /usr/local/bin

# etherium vanitygen
RUN curl -LO https://github.com/Limeth/ethaddrgen/releases/download/v1.0.7/ethaddrgen-v1.0.7-armv7-unknown-linux-gnueabihf.tar.gz
RUN tar xf ethaddrgen-v1.0.7-armv7-unknown-linux-gnueabihf.tar.gz
RUN mv ethaddrgen /usr/local/bin

# etherium-cpp
RUN curl -LO https://github.com/doublethinkco/cpp-ethereum-cross/releases/download/untagged-ba02a914c014fee4bd81/crosseth-armhf-apt.tgz
RUN tar xf crosseth-armhf-apt.tgz
RUN mv eth /usr/local/bin

# qrencode
RUN apt-get install -y qrencode libqrencode-dev

# simple text paper wallet
RUN git clone https://github.com/fomichev/paperwallet.txt.git && cd paperwallet.txt && make && mv pwt /usr/local/bin

RUN apt-get clean
