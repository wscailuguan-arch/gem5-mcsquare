#!/bin/bash
# multi-test via custom PID-1 init (bypass systemd), Atomic FF -> O3, using gem5.debug.
# fs.py L387 (force X86KvmCPU) is commented -> setCPUClass under --fast-forward gives
# (AtomicSimpleCPU FF, O3CPU future). Atomic = single event queue = stats dump runs on
# the main thread (holds GIL) -> pybind11 PyGILState_Check assert passes (KVM would put
# dump on a GIL-less worker thread and abort in gem5.debug). Slow boot but valid stats.
cd /home/whx123456/gem5-latest/mcsquare
mkdir -p results/micro/multi-test-atomic-debug
sudo ../build/X86/gem5.debug --debug-flags=PseudoInst -d results/micro/multi-test-atomic-debug ./fs.py --fast-forward=1000000000000000000 --mem-size=3GB --cpu-type=O3CPU --l1i-hwp-type=StridePrefetcher --l1d-hwp-type=StridePrefetcher --l2-hwp-type=StridePrefetcher --command-line="earlyprintk=ttyS0 console=ttyS0 lpj=7999923 root=/dev/hda1 numa=on init=/root/gem5_init.sh" --ctt-size=2048 --ctt-frac=0.5 --ctt-lat=787ps --cpu-clock=4GHz --mem-type=DDR4_2400_8x8 --bpq-size=8 --wb-reads=3 --kernel=./os/vmlinux-5.7 --disk-image=./os/mcsquare-20.04.final.img -n 8 --caches --l2cache --ctt-free-size=4 --mem-channels=2 > results/micro/multi-test-atomic-debug/fullout.txt 2> results/micro/multi-test-atomic-debug/err.txt
echo "GEM5_EXIT=$?" >> results/micro/multi-test-atomic-debug/fullout.txt
