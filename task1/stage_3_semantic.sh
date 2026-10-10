#!/bin/bash
# 语义分析阶段演示（成员A）
# 用法：在 WSL 里执行  bash stage_3_semantic.sh
cd "$(dirname "$0")"

OUT=stage_3_semantic.txt
{
echo "===== 语义分析（semantic analysis）====="
echo ""
echo "【1】干净版本：clang -fsyntax-only main.cpp（完整版，含 iostream，无错误）"
clang -fsyntax-only main.cpp 2>&1
rc1=$?
echo "（main.cpp 退出码 ${rc1}，0 表示通过语义/类型检查）"
echo ""
echo "【2】错误版本：clang -fsyntax-only main_error.cpp（故意植入 5 类错误）"
echo "观察点：符号表检查（未声明变量）、类型检查（不兼容赋值/比较）、函数重定义检查"
echo "------------------------------------------------------------"
clang -fsyntax-only main_error.cpp 2>&1
rc2=$?
echo "------------------------------------------------------------"
echo "（main_error.cpp 退出码 ${rc2}，非 0 表示语义检查发现错误）"
} > "$OUT" 2>&1

echo "已生成 $OUT"
