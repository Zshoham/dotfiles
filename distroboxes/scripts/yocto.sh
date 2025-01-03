#!/bin/sh

pacman -Syyu --noconfirm cpio diffstat chrpath rpcsvc-proto

wget -O /opt/yocto.sh https://downloads.yoctoproject.org/releases/yocto/yocto-4.3.4/buildtools/x86_64-buildtools-extended-nativesdk-standalone-4.3.4.sh 
