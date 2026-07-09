#!/bin/bash
D=results/micro/multi-test-init-debug-n1
echo '=== device tail ==='
tail -6 "$D/system.pc.com_1.device"
echo '=== num dumps so far ==='
grep -c 'Begin Simulation Statistics' "$D/stats.txt"
echo '=== dump 1 (elide) sizeElided + maxEntries ==='
awk '
/Begin Simulation Statistics/ {d++}
d==1 && /mcsquare.sizeElided/ {print}
d==1 && /mcsquare.maxEntries/ {print}
d>=2 {exit}
' "$D/stats.txt"
