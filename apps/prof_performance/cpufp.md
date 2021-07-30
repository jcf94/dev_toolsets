# CPUFP

Build:

```bash
git clone https://github.com/pigirons/cpufp.git

cd cpufp

./build.sh
```

Run:

```bash
./cpufp 8
```

Res:

> In a Intel(R) Xeon(R) Platinum 8163 CPU @ 2.50GHz

```bash
Thread(s): 8
avx512f fp32 perf: 584.1821 gflops.
avx512f fp64 perf: 292.0338 gflops.
fma fp32 perf: 343.1058 gflops.
fma fp64 perf: 171.5942 gflops.
avx fp32 perf: 171.5411 gflops.
avx fp64 perf: 85.6948 gflops.
sse fp32 perf: 85.7863 gflops.
sse fp64 perf: 42.8947 gflops.
```
