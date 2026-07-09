cd /home/akkamath/gem5-zIO/mcsquare

# Pre-compiled variant (2026-07-06): test binaries + libm5 + zIO copy_interpose.so
# were built ahead of time into the disk image via a Fedora-host chroot, because
# gem5-KVM on this WSL2 box has no hardware PMU and hangs when compiling in-guest.
# This script therefore SKIPS all compilation and jumps straight to the ROI:
#   boot (FF cpu) -> first `m5 exit` switches to O3 -> run pre-built binaries -> `m5 exit`.
# Original (compile+run) script: multi-test-run.sh

sizes=(64 256 1024 4096 16384 65536 262144 1048576 4194304)
ZIO_BIN=/home/akkamath/zIO/copy_interpose.so

# NOTE (2026-07-07): removed the pre-switch `sleep 2`. Under KVM-without-PMU the
# guest clock is broken, so any time-dependent op (sleep) BEFORE the O3 switch
# stalls. Jump straight to `m5 exit` right after boot -> switch to O3 -> the
# workload below runs on O3's correct clock.
m5 exit

# Begin tests
for i in ${sizes[@]}; do
    echo "Test: size $i"
    ./test_all_$i
    LD_PRELOAD=${ZIO_BIN} ./test_memcpy_$i
done

# All done!
m5 exit
