#!/bin/bash
# 优化等级对比：O0~O3 的程序大小、段大小、汇编、LLVM IR、运行性能
# 用法：在 WSL 里执行  bash task1/run_opt.sh
cd "$(dirname "$0")"
mkdir -p build

echo "========== ① 各优化等级程序大小对比 =========="
for O in 0 1 2 3; do
    g++ -O$O main.cpp -o build/main_O$O
    g++ -O$O -S main.cpp -o build/main_O$O.s
    clang++ -O$O -S -emit-llvm main.cpp -o build/main_O$O.ll
done

echo "--- 可执行文件大小 ---"
ls -l build/main_O0 build/main_O1 build/main_O2 build/main_O3 | awk '{print $9, $5" bytes"}'

echo ""
echo "--- 各段大小 (size 命令: text/data/bss) ---"
for O in 0 1 2 3; do
    echo -n "O$O: "
    size build/main_O$O | tail -1
done

echo ""
echo "--- 汇编 .s 文件大小 ---"
ls -l build/main_O0.s build/main_O1.s build/main_O2.s build/main_O3.s | awk '{print $9, $5" bytes"}'

echo ""
echo "--- LLVM IR .ll 文件大小 ---"
ls -l build/main_O0.ll build/main_O1.ll build/main_O2.ll build/main_O3.ll | awk '{print $9, $5" bytes"}'

echo ""
echo "========== ② 各优化等级运行性能对比 =========="
for O in 0 1 2 3; do
    g++ -O$O bench.cpp -o build/bench_O$O
done

echo "--- 小规模 n=1000, trials=100000 ---"
for O in 0 1 2 3; do
    echo -n "O$O: "
    echo "1000 100000" | ./build/bench_O$O
done

echo ""
echo "--- 中规模 n=100000, trials=10000 ---"
for O in 0 1 2 3; do
    echo -n "O$O: "
    echo "100000 10000" | ./build/bench_O$O
done

echo ""
echo "--- 大规模 n=10000000, trials=100 ---"
for O in 0 1 2 3; do
    echo -n "O$O: "
    echo "10000000 100" | ./build/bench_O$O
done
