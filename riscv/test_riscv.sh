#!/usr/bin/env bash
# RISC-V 汇编对拍脚本：手写 .S 链接运行时库，用 qemu-riscv64 运行验证
# 用法：在 WSL 里执行  bash riscv/test_riscv.sh
set -euo pipefail

project_root=$(cd "$(dirname "$0")/.." && pwd)
build_dir="$project_root/build/riscv"
objdump_dir="$build_dir/objdump"
mkdir -p "$build_dir" "$objdump_dir"

cc=${RISCV_CC:-riscv64-unknown-elf-gcc}
ar=${RISCV_AR:-riscv64-unknown-elf-ar}
objdump=${RISCV_OBJDUMP:-riscv64-unknown-elf-objdump}
nm=${RISCV_NM:-riscv64-unknown-elf-nm}
qemu=${QEMU_RISCV64:-qemu-riscv64}

common_flags=(-march=rv64gc -mabi=lp64d)
link_flags=(-L"$build_dir" -lsysy_riscv -static -mcmodel=medany -Wl,--no-relax,-Ttext=0x90000000)

echo "=== RISC-V 工具链 ==="
"$cc" --version | head -n 1
"$qemu" --version | head -n 1

echo
echo "=== 从源码编译 RISC-V 运行时库 libsysy_riscv.a ==="
"$cc" -c "$project_root/lib/sylib.c" -o "$build_dir/sylib_riscv.o" -w
"$ar" rcs "$build_dir/libsysy_riscv.a" "$build_dir/sylib_riscv.o"

for name in core float recursive; do
    echo "[BUILD] $name.S"
    "$cc" "${common_flags[@]}" -c "$project_root/riscv/$name.S" -o "$build_dir/$name.o" -w
    "$cc" "${common_flags[@]}" "$build_dir/$name.o" -o "$build_dir/$name" "${link_flags[@]}"
    "$objdump" -d "$build_dir/$name" > "$objdump_dir/$name.txt"
    "$nm" -n "$build_dir/$name" > "$objdump_dir/${name}_symbols.txt"
done

normalize_output() {
    sed '/^TOTAL:/d' | tr -d '\r'
}

pass=0
fail=0

check() {
    local name=$1
    local input=$2
    local expected=$3
    local actual

    set +e
    if [[ -n "$input" ]]; then
        actual=$(printf '%s\n' "$input" | "$qemu" "$build_dir/$name" 2>&1 | normalize_output)
    else
        actual=$("$qemu" "$build_dir/$name" 2>&1 | normalize_output)
    fi
    set -e

    if [[ "$actual" == "$expected" ]]; then
        printf '[PASS] %-10s input=%-4s output=%q\n' "$name" "${input:-none}" "$actual"
        pass=$((pass + 1))
    else
        printf '[FAIL] %-10s input=%-4s\n' "$name" "${input:-none}"
        printf '       expected=%q\n' "$expected"
        printf '       actual  =%q\n' "$actual"
        fail=$((fail + 1))
    fi
}

echo
echo "=== 功能对拍 ==="
check core 0 $'0\n0'
check core 5 $'5\n27'
check core 10 $'10\n49'
check core -1 ''
check core 11 ''
check float '' $'0x1.48f5c4p+2\n0x1.23d70cp+0\n0x1.91eb86p+2\n0x1.91eb86p+0'
check recursive 0 '1'
check recursive 1 '1'
check recursive 5 '120'
check recursive 10 '3628800'

echo
echo "=== 结果：通过 $pass，失败 $fail ==="
if (( fail != 0 )); then
    exit 1
fi
