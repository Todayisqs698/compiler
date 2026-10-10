    /* float.sy：单精度浮点四则运算 */
    .option nopic
    .text
    .align 2
    .globl main
    .type main, @function
main:
    /* 栈中依次保存四个结果，24(sp) 保存 ra */
    addi    sp, sp, -32
    sd      ra, 24(sp)

    /* 读取常量 f1 = 3.14，f2 = 2.0 */
    lla     t0, .LC_f1
    flw     ft0, 0(t0)
    lla     t0, .LC_f2
    flw     ft1, 0(t0)

    /* 计算 fsum、fdiff、fmul、fdiv */
    fadd.s  ft2, ft0, ft1
    fsub.s  ft3, ft0, ft1
    fmul.s  ft4, ft0, ft1
    fdiv.s  ft5, ft0, ft1
    fsw     ft2, 0(sp)
    fsw     ft3, 4(sp)
    fsw     ft4, 8(sp)
    fsw     ft5, 12(sp)

    /* putfloat 的参数放在 fa0，每个结果输出后换行 */
    flw     fa0, 0(sp)
    call    putfloat
    li      a0, 10
    call    putch

    flw     fa0, 4(sp)
    call    putfloat
    li      a0, 10
    call    putch

    flw     fa0, 8(sp)
    call    putfloat
    li      a0, 10
    call    putch

    flw     fa0, 12(sp)
    call    putfloat
    li      a0, 10
    call    putch

    /* 恢复栈帧并正常退出 */
    ld      ra, 24(sp)
    addi    sp, sp, 32
    li      a0, 0
    li      a7, 93
    ecall
    .size main, .-main

    /* IEEE 754 单精度常量 */
    .section .rodata
    .align 2
.LC_f1:
    .word   0x4048f5c3              /* 3.14f */
.LC_f2:
    .word   0x40000000              /* 2.0f */
