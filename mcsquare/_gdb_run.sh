#!/bin/bash
# Run gem5.debug under gdb (Atomic FF path) to catch the sortInsts SIGSEGV.
cd /home/whx123456/gem5-latest/mcsquare
mkdir -p results/micro/gdb
sudo gdb --batch -x _gdb_cmds.txt --args \
  ../build/X86/gem5.debug --debug-flags=PseudoInst -d results/micro/gdb ./fs.py \
  --fast-forward=1000000000000000000 --mem-size=3GB --cpu-type=O3CPU \
  --l1i-hwp-type=StridePrefetcher --l1d-hwp-type=StridePrefetcher --l2-hwp-type=StridePrefetcher \
  --command-line="earlyprintk=ttyS0 console=ttyS0 lpj=7999923 root=/dev/hda1 numa=on init=/root/gem5_init.sh" \
  --ctt-size=2048 --ctt-frac=0.5 --ctt-lat=787ps --cpu-clock=4GHz --mem-type=DDR4_2400_8x8 \
  --bpq-size=8 --wb-reads=3 --kernel=./os/vmlinux-5.7 --disk-image=./os/mcsquare-20.04.final.img \
  -n 8 --caches --l2cache --ctt-free-size=4 --mem-channels=2 \
  > /home/whx123456/_gdbout.txt 2>&1
echo "GDB_WRAPPER_EXIT=$?" >> /home/whx123456/_gdbout.txt
