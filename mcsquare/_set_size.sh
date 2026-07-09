#!/bin/bash
set -x
cd /home/whx123456/gem5-latest/mcsquare || exit 1
mkdir -p /mnt/mcsq
mount -o loop,rw,offset=1048576 os/mcsquare-20.04.final.img /mnt/mcsq || exit 1
sed -i 's/^sizes=.*/sizes="64 256 1024 4096 16384 65536 262144 1048576 4194304"/' /mnt/mcsq/root/gem5_init.sh
grep -n '^sizes' /mnt/mcsq/root/gem5_init.sh
sync
umount /mnt/mcsq
echo DONE
