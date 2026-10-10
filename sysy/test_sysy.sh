#!/bin/bash
# SysY 程序逻辑验证脚本（x86，运行时库从 lib/sylib.c 源码编译）
# 用法：在 WSL 里执行  bash sysy/test_sysy.sh
set -euo pipefail
cd "$(dirname "$0")/.."   # 进入项目根目录
mkdir -p build/sysy

# 只含函数声明的精简头（避免 sylib.h 里的全局变量定义造成重复定义）
cat > build/sysy/sylib_decl.h << 'EOF'
int   getint();
int   getch();
int   getarray(int a[]);
float getfloat();
int   getfarray(float a[]);
void  putint(int a);
void  putch(int a);
void  putarray(int n, int a[]);
void  putfloat(float a);
void  putfarray(int n, float a[]);
EOF

echo "=== 编译运行时库 lib/sylib.c ==="
gcc -c lib/sylib.c -o build/sysy/sylib.o

echo "=== 编译 SysY 源程序（gcc -x c + 链接运行时库）==="
for name in core float recursive; do
    gcc -x c -include build/sysy/sylib_decl.h -c sysy/$name.sy -o build/sysy/$name.o
    gcc build/sysy/$name.o build/sysy/sylib.o -o build/sysy/$name
done
echo "编译全部成功"
echo ""
echo "注意：每行末尾可能附带运行时库 'TOTAL: ...' 计时输出（非程序逻辑输出）"

echo ""
echo "=== 程序一 core.sy ==="
printf "输入 0  -> "; echo 0  | build/sysy/core
printf "输入 5  -> "; echo 5  | build/sysy/core
printf "输入 10 -> "; echo 10 | build/sysy/core
printf "输入 -1 -> "; echo -1 | build/sysy/core; echo "  (上方无数字=正确)"
printf "输入 11 -> "; echo 11 | build/sysy/core; echo "  (上方无数字=正确)"

echo ""
echo "=== 程序二 float.sy（无输入）==="
build/sysy/float

echo ""
echo "=== 程序三(可选) recursive.sy ==="
printf "输入 5 -> "; echo 5 | build/sysy/recursive
