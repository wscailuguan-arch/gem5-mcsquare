#!/bin/bash
set -x
cd /home/whx123456/gem5-latest/mcsquare || exit 1

mkdir -p /mnt/mcsq
mount -o loop,rw,offset=1048576 os/mcsquare-20.04.final.img /mnt/mcsq || exit 1
mount --bind /proc /mnt/mcsq/proc
mount --bind /sys /mnt/mcsq/sys
mount --bind /dev /mnt/mcsq/dev
mount --bind /dev/pts /mnt/mcsq/dev/pts

echo "=== zIO Makefile CFLAGS before ==="
grep -n 'march=native' /mnt/mcsq/home/akkamath/zIO/Makefile

# 1. Disable AVX2 in zIO Makefile (append -mno-avx2 next to existing -mno-avx512f)
sed -i 's/-mno-avx512f/-mno-avx512f -mno-avx2/' /mnt/mcsq/home/akkamath/zIO/Makefile
echo "=== zIO Makefile CFLAGS after ==="
grep -n 'mno-avx' /mnt/mcsq/home/akkamath/zIO/Makefile

# 2. Rebuild copy_interpose.so inside guest (chroot)
chroot /mnt/mcsq /bin/bash -c 'cd /home/akkamath/zIO && make clean && make linux'
echo "=== new copy_interpose.so ==="
ls -la /mnt/mcsq/home/akkamath/zIO/copy_interpose.so

# 3. Inspect + set gem5_init.sh sizes to only 64 for quick verify
echo "=== gem5_init.sh full ==="
cat /mnt/mcsq/root/gem5_init.sh
echo "=== sizes before ==="
grep -n 'sizes' /mnt/mcsq/root/gem5_init.sh
sed -i 's/^sizes=.*/sizes="64"/' /mnt/mcsq/root/gem5_init.sh
echo "=== sizes after ==="
grep -n 'sizes' /mnt/mcsq/root/gem5_init.sh

# 4. Unmount
sync
umount /mnt/mcsq/dev/pts
umount /mnt/mcsq/dev
umount /mnt/mcsq/sys
umount /mnt/mcsq/proc
umount /mnt/mcsq
echo "=== DONE ==="
