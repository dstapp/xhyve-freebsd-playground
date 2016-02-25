#!/bin/bash

command -v brew >/dev/null || { echo "Homebrew must be installed. Aborting." && exit 1; }

USERBOOT="/Library/Caches/Homebrew/xhyve--git/test/userboot.so"
BOOTVOLUME="FreeBSD-10.2-RELEASE-amd64-bootonly.iso"
IMG="fbsd.img"
KERNELENV=""

if [ -f $BOOTVOLUME ]
then
	echo "FreeBSD image does already exist, skipping download"
else
	echo "Downloading FreeBSD install image..."
	curl -O http://ftp.freebsd.org/pub/FreeBSD/releases/ISO-IMAGES/10.2/$BOOTVOLUME
fi

command -v xhyve >/dev/null 2>&1 || echo "Installing xhyve..." && brew install xhyve --HEAD

if [ ! -f $IMG ]
then
	echo "Creating FreeBSD disk image..."
	mkfile 5g $IMG

	echo "Running xhyve to install FreeBSD. You'll be asked for your user password to create the networking device. Please install FreeBSD and shut down the machine afterwards. Press any key to continue..."
	read

	clear

	sudo xhyve -A -m 2G -c 2 -s 0:0,hostbridge -s 31,lpc -l com1,stdio -s 2:0,virtio-net -s 3:0,ahci-cd,$BOOTVOLUME -s 4:0,virtio-blk,$IMG -U deaddead-dead-dead-dead-deaddeaddead -f fbsd,$USERBOOT,$BOOTVOLUME,"$KERNELENV"	
fi

BOOTVOLUME=$IMG

echo "Starting FreeBSD in xhyve... Shut down the machine to exit. Have fun!"
read

clear

sudo xhyve -A -m 2G -c 2 -s 0:0,hostbridge -s 31,lpc -l com1,stdio -s 2:0,virtio-net -s 3:0,ahci-cd,$BOOTVOLUME -s 4:0,virtio-blk,$IMG -U deaddead-dead-dead-dead-deaddeaddead -f fbsd,$USERBOOT,$BOOTVOLUME,"$KERNELENV"