ZIO=/home/akkamath/zIO
ZIO_BIN=${ZIO}/copy_interpose.so

pushd ${ZIO};
# gem5's x86 O3 decoder implements no AVX/AVX2. zIO builds with -march=native, and
# under KVM the guest sees the host CPU, so gcc emits vpbroadcastq/ymm and the
# detailed CPU aborts on an invalid opcode. Force the build down to SSE.
# (-mno-avx2 alone still leaves 256-bit AVX-FP ymm uses; -mno-avx clears them.)
sed -i 's/-mno-avx512f/-mno-avx512f -mno-avx2 -mno-avx/' Makefile
make
ls
popd

REDIS=/home/akkamath/zIO/benchmarks/redis
pushd ${REDIS}
make MALLOC=libc
mkdir pmem
ls
popd

echo "Done compilation"
m5 exit

cd ${REDIS}/src
LD_PRELOAD=${ZIO_BIN} ./redis-server ../redis_ext4.conf &
sleep 1
echo "Redis running"
m5 resetstats
./redis-benchmark -p 7379 -d 65536 -t set -c 16 -n 500
m5 dumpstats
echo "Redis done"
pkill redis-server
sleep 1
m5 exit