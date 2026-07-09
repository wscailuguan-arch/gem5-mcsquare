#!/bin/bash
D=results/micro/multi-test-init-debug-n1
echo '=== GEM5_EXIT ==='
grep GEM5_EXIT $D/fullout.txt
echo '=== elide=1 packets at memctrl (with tick) ==='
grep 'elide=1' $D/err.txt | grep memctrl
echo '=== elide pseudo-inst + dumpstats ticks (fullout) ==='
grep -e 'memcpy_elide(' -e dumpstats $D/fullout.txt | head -3
echo '=== per-dump sizeElided/maxEntries mem_ctrls0 ==='
awk '
/Begin Simulation Statistics/ {d++}
/mem_ctrls0.mcsquare.sizeElided/ {print "dump "d": sizeElided="$2}
/mem_ctrls0.mcsquare.maxEntries/ {print "dump "d": maxEntries="$2}
' $D/stats.txt
