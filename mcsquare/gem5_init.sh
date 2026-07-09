#!/bin/bash
# Minimal PID-1 init for gem5 KVM-without-PMU (2026-07-07).
# Bypasses systemd entirely (kernel boots straight into this) so none of
# systemd's time-dependent finalization units (getty/login/update-utmp) run
# under the broken KVM-no-PMU clock. Does the bare mounts, immediately switches
# to O3 via `m5 exit`, then runs the pre-compiled multi-test binaries on O3.
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

echo "INIT: gem5_init.sh started as PID $$"
mount -t proc     none /proc      2>/dev/null
mount -t sysfs    none /sys       2>/dev/null
mount -t devtmpfs none /dev       2>/dev/null
mount -o remount,rw /             2>/dev/null
echo "INIT: mounts done -> m5 exit (switch to O3)"

cd /home/akkamath/gem5-zIO/mcsquare
/sbin/m5 exit

echo "INIT: resumed on O3 -> running pre-compiled tests"
sizes="64 256 1024 4096 16384 65536 262144 1048576 4194304"
ZIO_BIN=/home/akkamath/zIO/copy_interpose.so
for i in $sizes; do
    echo "Test: size $i"
    ./test_all_$i
    LD_PRELOAD=$ZIO_BIN ./test_memcpy_$i
done

echo "INIT: all tests done -> m5 exit (end sim)"
/sbin/m5 exit
# Safety net: never let PID 1 return (would kernel-panic). Loop if m5 exit no-ops.
while true; do /sbin/m5 exit; sleep 1; done
