#!/bin/bash
# 对拍脚本：手写 LLVM IR 与 SysY 源程序输出 diff 对比
# 用法：在 WSL 里执行  bash llvm/test_llvm.sh
set -euo pipefail
cd "$(dirname "$0")/.."   # 进入项目根目录
mkdir -p build/llvm

# 只含函数声明的精简头（编译 .sy 时用）
cat > build/llvm/sylib_decl.h << 'EOF'
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
gcc -c lib/sylib.c -o build/llvm/sylib.o

echo "=== 编译：SysY 源程序（gcc） vs 手写 LLVM IR（clang）==="
for name in core float recursive; do
    gcc -x c -include build/llvm/sylib_decl.h -c sysy/$name.sy -o build/llvm/${name}_sy.o
    gcc build/llvm/${name}_sy.o build/llvm/sylib.o -o build/llvm/${name}_sy
    clang llvm/$name.ll build/llvm/sylib.o -o build/llvm/${name}_ll
done
echo "编译完成"

pass=0; fail=0
check() {
  local name="$1"; local sy="$2"; local ll="$3"; local input="$4"
  local out_sy out_ll
  out_sy=$(printf '%s' "$input" | "$sy" 2>/dev/null)
  out_ll=$(printf '%s' "$input" | "$ll" 2>/dev/null)
  if [ "$out_sy" = "$out_ll" ]; then
    printf "  [PASS] %-28s 输入=[%s]\n" "$name" "$input"
    pass=$((pass+1))
  else
    printf "  [FAIL] %-28s 输入=[%s]\n" "$name" "$input"
    printf "    SysY : %s\n" "$(echo "$out_sy" | tr '\n' '|')"
    printf "    IR   : %s\n" "$(echo "$out_ll" | tr '\n' '|')"
    fail=$((fail+1))
  fi
}

echo ""
echo "=== 对拍：core ==="
for x in 0 1 5 8 9 10 12 13 -1; do
  check "core" build/llvm/core_sy build/llvm/core_ll "$x"
done

echo ""
echo "=== 对拍：float（无输入）==="
check "float" build/llvm/float_sy build/llvm/float_ll ""

echo ""
echo "=== 对拍：recursive ==="
for x in 0 1 5 10; do
  check "recursive" build/llvm/rec_sy build/llvm/rec_ll "$x"
done

echo ""
echo "=== 结果：通过 $pass 项，失败 $fail 项 ==="
[ "$fail" -eq 0 ] && echo "✅ 全部对拍通过" || echo "❌ 存在不一致，请检查"
