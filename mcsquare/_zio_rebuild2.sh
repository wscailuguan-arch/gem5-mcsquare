#!/bin/bash
set -x
cd /home/whx123456/gem5-latest/mcsquare || exit 1

mkdir -p /mnt/mcsq
mount -o loop,rw,offset=1048576 os/mcsquare-20.04.final.img /mnt/mcsq || exit 1
mount --bind /proc /mnt/mcsq/proc
mount --bind /sys /mnt/mcsq/sys
mount --bind /dev /mnt/mcsq/dev
mount --bind /dev/pts /mnt/mcsq/dev/pts

# Also disable AVX entirely (SSE-only) to avoid any residual 256-bit ymm ops
# that gem5 x86 O3 may not decode. Add -mno-avx after the already-present -mno-avx2.
grep -q -- '-mno-avx ' /mnt/mcsq/home/akkamath/zIO/Makefile || \
  sed -i 's/-mno-avx2/-mno-avx2 -mno-avx/' /mnt/mcsq/home/akkamath/zIO/Makefile
echo "=== zIO Makefile CFLAGS ==="
grep -n 'mno-avx' /mnt/mcsq/home/akkamath/zIO/Makefile

# Rebuild copy_interpose.so
chroot /mnt/mcsq /bin/bash -c 'cd /home/akkamath/zIO && make clean && make linux'

echo "=== verify no ymm remain ==="
echo -n "ymm count: "; objdump -d /mnt/mcsq/home/akkamath/zIO/copy_interpose.so | grep -c ymm
echo -n "vbroadcast count: "; objdump -d /mnt/mcsq/home/akkamath/zIO/copy_interpose.so | grep -c vbroadcast
ls -la /mnt/mcsq/home/akkamath/zIO/copy_interpose.so

sync
umount /mnt/mcsq/dev/pts
umount /mnt/mcsq/dev
umount /mnt/mcsq/sys
umount /mnt/mcsq/proc
umount /mnt/mcsq
echo "=== DONE ==="
