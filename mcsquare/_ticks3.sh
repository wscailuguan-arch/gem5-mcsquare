#!/bin/bash
D=results/micro/multi-test-init-debug-n1
echo '=== GEM5_EXIT ==='
grep -a GEM5_EXIT $D/fullout.txt
echo '=== increment tick (from MCSQ_INC) ==='
grep -a MCSQ_INC $D/err.txt | head -2
echo '=== reset_stats + dumpstats + elide ticks (program order) ==='
grep -a -e 'reset_stats' -e 'dumpstats' -e 'memcpy_elide(' $D/fullout.txt | head -8
