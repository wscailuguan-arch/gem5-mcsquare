#!/bin/bash
D=results/micro/multi-test-init-debug-n1
echo '=== GEM5_EXIT ==='
grep GEM5_EXIT $D/fullout.txt
echo '=== num dump sections ==='
grep -c 'Begin Simulation Statistics' $D/stats.txt
echo '=== nonzero mcsquare stats (any dump) ==='
awk '/mcsquare/ && ($2+0) != 0 {print NR": "$1" = "$2}' $D/stats.txt
echo '=== per-dump sizeElided for mem_ctrls0 (with dump index) ==='
awk '
/Begin Simulation Statistics/ {d++}
/mem_ctrls0.mcsquare.sizeElided/ {print "dump "d": sizeElided="$2}
/mem_ctrls0.mcsquare.maxEntries/ {print "dump "d": maxEntries="$2}
' $D/stats.txt
