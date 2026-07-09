ZIO=/home/akkamath/zIO
ZIO_BIN=${ZIO}/copy_interpose_manual.so

pushd ${ZIO};
# gem5's x86 O3 decoder implements no AVX/AVX2. zIO builds with -march=native, and
# under KVM the guest sees the host CPU, so gcc emits vpbroadcastq/ymm and the
# detailed CPU aborts on an invalid opcode. Force the build down to SSE.
# (-mno-avx2 alone still leaves 256-bit AVX-FP ymm uses; -mno-avx clears them.)
sed -i 's/-mno-avx512f/-mno-avx512f -mno-avx2 -mno-avx/' Makefile
make
ls
popd

cd /fleetbench/bazel-bin/fleetbench;

m5 exit

m5 resetstats
LD_PRELOAD=${ZIO_BIN} ./proto/proto_benchmark --benchmark_min_time=0.25s --benchmark_max_time=0.25s
m5 dumpstats

m5 exit