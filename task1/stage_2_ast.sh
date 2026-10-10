#!/bin/bash
# 语法分析：生成干净的 AST（成员A）
# 用法：在 WSL 里执行  bash stage_2_ast.sh
cd "$(dirname "$0")"

# main_analysis.cpp 已不含任何 #include，AST 本身就很干净，
# 直接完整导出即可保留树形层级；只过滤 clang 的诊断信息行作为保险。
clang -Xclang -ast-dump -fsyntax-only main_analysis.cpp 2>&1 \
  | grep -vE "error:|warning:|\^|note:|errors generated|generated\." \
  > stage_2_ast.txt

echo "已生成 stage_2_ast.txt（$(wc -l < stage_2_ast.txt) 行）"
