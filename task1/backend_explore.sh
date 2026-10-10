#!/usr/bin/env bash
# 任务一后端（成员B）：代码生成 / 汇编 / 链接 / 反汇编 / 符号表 / 性能 / 自动向量化与并行化
# 用法：在装有 g++/clang++ 的环境里执行  bash task1/backend_explore.sh
set -euo pipefail

script_dir=$(cd "$(dirname "$0")" && pwd)
artifact_dir="$script_dir/build/backend"
log_dir="$artifact_dir/logs"
mkdir -p "$artifact_dir" "$log_dir"

summary_log="$log_dir/backend-summary.log"
exec > >(tee "$summary_log") 2>&1

echo "=== 实验环境 ==="
date '+%Y-%m-%d %H:%M:%S %Z'
uname -a
printf 'gcc target: '; g++ -dumpmachine
g++ --version | head -n 1
clang++ --version | head -n 1
objdump --version | head -n 1

echo
echo "=== O0/O1/O2/O3 代码生成、汇编和链接 ==="
for level in 0 1 2 3; do
    echo "[BUILD] -O$level"
    g++ -O"$level" -S "$script_dir/main.cpp" -o "$artifact_dir/main_O$level.s"
    g++ -O"$level" -c "$script_dir/main.cpp" -o "$artifact_dir/main_O$level.o"
    g++ -O"$level" "$script_dir/main.cpp" -o "$artifact_dir/main_O$level"
    objdump -d -C "$artifact_dir/main_O$level.o" > "$log_dir/main_O${level}_object_disassembly.txt"
    objdump -d -C "$artifact_dir/main_O$level" > "$log_dir/main_O${level}_executable_disassembly.txt"
    nm -C "$artifact_dir/main_O$level.o" > "$log_dir/main_O${level}_object_symbols.txt"
    nm -C "$artifact_dir/main_O$level" > "$log_dir/main_O${level}_executable_symbols.txt"
done

echo
echo "=== 文件与段大小 ==="
printf '%-8s %12s %12s %12s %12s %12s\n' 'Level' 'ASM(bytes)' 'OBJ(bytes)' 'ELF(bytes)' 'text' 'bss'
for level in 0 1 2 3; do
    asm_size=$(stat -c '%s' "$artifact_dir/main_O$level.s")
    obj_size=$(stat -c '%s' "$artifact_dir/main_O$level.o")
    exe_size=$(stat -c '%s' "$artifact_dir/main_O$level")
    read -r text_size _ _ bss_size _ < <(size "$artifact_dir/main_O$level" | tail -n 1)
    printf 'O%-7s %12s %12s %12s %12s %12s\n' "$level" "$asm_size" "$obj_size" "$exe_size" "$text_size" "$bss_size"
done

echo
echo "=== 汇编行数与 fib 函数指令数 ==="
printf '%-8s %12s %16s\n' 'Level' 'ASM lines' 'fib instructions'
for level in 0 1 2 3; do
    asm_lines=$(wc -l < "$artifact_dir/main_O$level.s")
    fib_instructions=$(sed -n '/<fib(int)>:/,/^$/p' "$log_dir/main_O${level}_object_disassembly.txt" | grep -Ec '^[[:space:]]+[0-9a-f]+:' || true)
    printf 'O%-7s %12s %16s\n' "$level" "$asm_lines" "$fib_instructions"
done

echo
echo "=== 运行结果一致性（输入 10） ==="
reference='please input n: fib(10) = 55'
for level in 0 1 2 3; do
    actual=$(printf '10\n' | "$artifact_dir/main_O$level")
    if [[ "$actual" != "$reference" ]]; then
        printf '[FAIL] O%s output=%q\n' "$level" "$actual"
        exit 1
    fi
    printf '[PASS] O%s %s\n' "$level" "$actual"
done

echo
echo "=== 汇编器、重定位和链接器证据（O0） ==="
file "$artifact_dir/main_O0.s" "$artifact_dir/main_O0.o" "$artifact_dir/main_O0"
readelf -h "$artifact_dir/main_O0.o" | tee "$log_dir/main_O0_object_elf_header.txt"
readelf -h "$artifact_dir/main_O0" | tee "$log_dir/main_O0_executable_elf_header.txt"
objdump -r "$artifact_dir/main_O0.o" | tee "$log_dir/main_O0_relocations.txt"

echo
echo "=== 性能对比 ==="
for level in 0 1 2 3; do
    g++ -O"$level" "$script_dir/bench.cpp" -o "$artifact_dir/bench_O$level"
done

for case in '1000 20000' '100000 200' '1000000 20'; do
    printf '%s\n' "-- n/trials: $case"
    for level in 0 1 2 3; do
        printf 'O%s: ' "$level"
        printf '%s\n' "$case" | "$artifact_dir/bench_O$level"
    done
done | tee "$log_dir/performance.log"

echo
echo "=== 自动向量化与并行化探索 ==="
g++ -O3 -fopt-info-vec-optimized="$log_dir/vectorization.log" \
    "$script_dir/parallel_demo.cpp" -o "$artifact_dir/parallel_vectorized"
g++ -O3 -fopenmp -ftree-parallelize-loops=4 \
    -fopt-info-optimized="$log_dir/parallelization.log" \
    "$script_dir/parallel_demo.cpp" -o "$artifact_dir/parallel_auto"
objdump -d -C "$artifact_dir/parallel_vectorized" > "$log_dir/parallel_vectorized_disassembly.txt"
objdump -d -C "$artifact_dir/parallel_auto" > "$log_dir/parallel_auto_disassembly.txt"
nm -C "$artifact_dir/parallel_auto" > "$log_dir/parallel_auto_symbols.txt"
"$artifact_dir/parallel_vectorized"
"$artifact_dir/parallel_auto"
echo '-- vectorization report --'
cat "$log_dir/vectorization.log"
echo '-- parallelization report excerpt --'
sed -n '1,80p' "$log_dir/parallelization.log"
echo '-- GOMP symbols --'
grep 'GOMP_' "$log_dir/parallel_auto_symbols.txt" || echo 'no GOMP symbol emitted'

echo
echo "=== 后端实验完成 ==="
