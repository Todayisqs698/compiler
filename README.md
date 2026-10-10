# 编译系统原理 · 预备实验（Lab0）

《了解你的编译器、LLVM IR 编程、汇编编程》源代码。

## 目录结构

```
lab0/
├── task1/                  # 任务一：了解你的编译器（前端 + 后端）
│   ├── main.cpp            #   主源程序（贯穿预处理器→编译器六阶段→汇编器→链接器）
│   ├── main_analysis.cpp   #   词法/语法分析的干净版本
│   ├── main_error.cpp      #   语义分析演示（故意植入 5 类错误）
│   ├── bench.cpp           #   性能基准测试
│   ├── parallel_demo.cpp   #   自动向量化/并行化示例（SAXPY）
│   ├── run_opt.sh          #   O0~O3 优化对比
│   ├── backend_explore.sh  #   后端全流程（汇编/链接/反汇编/符号表/性能）
│   ├── stage_2_ast.sh      #   语法分析（AST）
│   └── stage_3_semantic.sh #   语义分析
│
├── sysy/                   # 任务二/三共用 SysY 源程序
│   ├── core.sy             #   程序一：relu + 全运算 + 数组 + 循环 + break
│   ├── float.sy            #   程序二：浮点四则
│   ├── recursive.sy        #   程序三：递归
│   └── test_sysy.sh        #   SysY 源程序逻辑验证
│
├── llvm/                   # 任务二：手写 LLVM IR（成员A）
│   ├── core.ll / float.ll / recursive.ll
│   └── test_llvm.sh        #   .sy vs .ll 对拍
│
├── riscv/                  # 任务三：手写 RISC-V 汇编（成员B）
│   ├── core.S / float.S / recursive.S
│   └── test_riscv.sh       #   qemu-riscv64 对拍
│
├── mlir/                   # 进阶：MLIR（成员A主笔）
│   ├── hfusion_vecadd.mlir          #   HFusion 输入
│   ├── hfusion_vecadd_lowered.mlir  #   HFusion→HIVM 转换结果
│   ├── official_add.mlir            #   官方 VecAdd 示例
│   └── vecadd.mlir / vecadd_vector.mlir   # 标准 MLIR 标量/向量路径
│
└── lib/                    # SysY 运行时库源码（官方）
    ├── sylib.c
    └── sylib.h
```

## 环境要求

| 工具 | 说明 |
| --- | --- |
| gcc / g++ | 编译 SysY 源程序、性能对比 |
| clang / clang++ | 编译手写 LLVM IR、生成参考 IR |
| riscv64-unknown-elf-gcc / objdump / nm | RISC-V 交叉编译（需含 newlib） |
| qemu-riscv64 | 运行 RISC-V 程序 |

> 本项目在 WSL Ubuntu 中验证通过（gcc 15.2.0 / clang 21.1.8 / riscv64-unknown-elf-gcc 15.1.0 / qemu-riscv64 10.2.1）。

## 运行方式

```bash
# 任务一：了解编译器（优化对比 / 后端全流程）
bash task1/run_opt.sh
bash task1/backend_explore.sh

# 任务二：SysY 源程序逻辑验证 + 手写 LLVM IR 对拍
bash sysy/test_sysy.sh
bash llvm/test_llvm.sh

# 任务三：手写 RISC-V 汇编对拍
bash riscv/test_riscv.sh
```

## 关键注意事项

1. **运行时库 `putfloat` 采用 `%a`（十六进制浮点）格式**，输出形如 `0x1.48f5c4p+2`。
2. **程序正常退出会额外输出一行 `TOTAL: ...`**（运行时库计时析构函数），对拍脚本已忽略该行。
3. **RISC-V 汇编结尾不用 `ret`**（会卡在 `after_main` 析构），改用 `li a0,0; li a7,93; ecall`。
4. 构建产物统一输出到 `build/`，已被 `.gitignore` 忽略。

## 分工

| 任务 | 成员A | 成员B |
| --- | --- | --- |
| 任务一：了解编译器 | 预处理/词法/语法/语义/IR 生成 + 优化对 IR 的影响 | 汇编/链接/执行 + 优化对汇编与性能的影响 + 自动并行化 |
| 任务二：LLVM IR | `core.ll` / `float.ll` / `recursive.ll` | — |
| 任务三：RISC-V 汇编 | — | `core.S` / `float.S` / `recursive.S` |
| 进阶：MLIR | 主笔 | 辅助 |
