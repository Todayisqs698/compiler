    /* core.sy：函数、数组、循环、分支和整数运算 */
    .option nopic
    .text
    .align 2

    /* int relu(int n)，参数和返回值都使用 a0 */
    .globl relu
    .type relu, @function
relu:
    /* call_count++ */
    lla     t0, call_count
    lw      t1, 0(t0)
    addiw   t1, t1, 1
    sw      t1, 0(t0)

    /* n <= 0 时返回 0，否则返回 n */
    bge     zero, a0, .Lrelu_zero
    sext.w  a0, a0
    ret
.Lrelu_zero:
    li      a0, 0
    ret
    .size relu, .-relu

    .align 2
    .globl main
    .type main, @function
main:
    /* 96 字节栈帧：低 44 字节放 arr[11]，高地址保存寄存器 */
    addi    sp, sp, -96
    sd      ra, 88(sp)
    sd      s0, 80(sp)
    sd      s1, 72(sp)
    sd      s2, 64(sp)
    sd      s3, 56(sp)
    sd      s4, 48(sp)

    /* n = getint()，s0 保存 n */
    call    getint
    sext.w  s0, a0

    /* n 不在 [0, 10] 时直接返回 1 */
    blt     s0, zero, .Lmain_invalid
    li      t0, 10
    blt     t0, s0, .Lmain_invalid

    /* result = (n != 0) ? relu(n) : 0 */
    beq     s0, zero, .Lresult_zero
    mv      a0, s0
    call    relu
    sext.w  s1, a0
    j       .Lafter_result
.Lresult_zero:
    li      s1, 0
.Lafter_result:
    /* 输出 result 和换行 */
    mv      a0, s1
    call    putint
    li      a0, 10
    call    putch

    /* i = 0，sum = 0 */
    li      s2, 0
    li      s3, 0

.Lwhile_cond:
    /* while (i <= n)，i == 8 时 break */
    blt     s0, s2, .Lwhile_end
    li      t0, 8
    beq     s2, t0, .Lwhile_end

    /* arr[i] = relu(i)，int 数组下标要乘 4 */
    mv      a0, s2
    call    relu
    sext.w  s4, a0
    slli    t0, s2, 2
    add     t1, sp, t0
    sw      s4, 0(t1)

    /* sum = sum + arr[i] * 2 - i / 3 % 5 */
    li      t2, 2
    mulw    t3, s4, t2
    addw    s3, s3, t3
    li      t2, 3
    divw    t3, s2, t2
    li      t2, 5
    remw    t3, t3, t2
    subw    s3, s3, t3

    /* i++ */
    addiw   s2, s2, 1
    j       .Lwhile_cond

.Lwhile_end:
    /* 输出 sum，正常返回 0 */
    mv      a0, s3
    call    putint
    li      a0, 10
    call    putch
    li      a0, 0
    j       .Lmain_exit

.Lmain_invalid:
    li      a0, 1

.Lmain_exit:
    /* 恢复寄存器和栈帧 */
    mv      s4, a0
    ld      ra, 88(sp)
    ld      s0, 80(sp)
    ld      s1, 72(sp)
    ld      s2, 64(sp)
    ld      s3, 56(sp)
    mv      a0, s4
    ld      s4, 48(sp)
    addi    sp, sp, 96

    /* Linux exit，a0 是退出码 */
    li      a7, 93
    ecall
    .size main, .-main

    /* 全局变量 int call_count = 0 */
    .section .sbss,"aw",@nobits
    .align 2
    .globl call_count
    .type call_count, @object
    .size call_count, 4
call_count:
    .zero 4
