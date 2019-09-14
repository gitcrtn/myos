#!/usr/bin/env bash

# install dependencies
apt-get update
apt-get install -y build-essential bc cpio mkisofs wget

# prepare workdir
mkdir -p /work/iso9660
cd /work

# prepare isolinux
mkdir iso9660/isolinux
wget https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.xz
tar xf syslinux-6.03.tar.xz
cp syslinux-6.03/bios/core/isolinux.bin iso9660/isolinux/
cp syslinux-6.03/bios/com32/elflink/ldlinux/ldlinux.c32 iso9660/isolinux/
cp /pwd/isolinux.cfg iso9660/isolinux/

# build kernel
mkdir iso9660/boot
wget https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.9.6.tar.xz
tar xf linux-4.9.6.tar.xz
cd linux-4.9.6/
make defconfig
make bzImage
cp arch/x86/boot/bzImage ../iso9660/boot/
cd ..

# build busybox
wget https://busybox.net/downloads/busybox-1.26.2.tar.bz2
tar xf busybox-1.26.2.tar.bz2
cd busybox-1.26.2/
make defconfig
sed -i -e 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
make
make install
cp -r _install ../initrd
cd ..

# prepare initrd
mkdir initrd/proc
mkdir initrd/sys
mkdir -p initrd/etc/init.d
cp /pwd/rcS initrd/etc/init.d/
chmod a+x initrd/etc/init.d/rcS
cd initrd/
find . | cpio --create --format=newc --owner=root:root | gzip > ../iso9660/boot/initrd.gz
cd ..

# build iso
cd iso9660/
mkisofs -o /pwd/myos.iso -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table .
