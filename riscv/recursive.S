    /* recursive.sy：递归计算阶乘 */
    .option nopic
    .text
    .align 2

    /* int factorial(int n)，参数和返回值都使用 a0 */
    .globl factorial
    .type factorial, @function
factorial:
    /* 每层递归保存 ra 和当前 n */
    addi    sp, sp, -32
    sd      ra, 24(sp)
    sd      s0, 16(sp)
    sext.w  s0, a0

    /* n <= 1 时返回 1 */
    li      t0, 1
    bge     t0, s0, .Lfactorial_base

    /* return n * factorial(n - 1) */
    addiw   a0, s0, -1
    call    factorial
    mulw    a0, s0, a0
    j       .Lfactorial_return

.Lfactorial_base:
    li      a0, 1

.Lfactorial_return:
    /* 回到上一层递归 */
    ld      ra, 24(sp)
    ld      s0, 16(sp)
    addi    sp, sp, 32
    ret
    .size factorial, .-factorial

    .align 2
    .globl main
    .type main, @function
main:
    /* main 需要保存自己的返回地址 */
    addi    sp, sp, -16
    sd      ra, 8(sp)

    /* 读入 n，计算并输出 factorial(n) */
    call    getint
    call    factorial
    call    putint
    li      a0, 10
    call    putch

    /* 恢复栈帧并正常退出 */
    ld      ra, 8(sp)
    addi    sp, sp, 16
    li      a0, 0
    li      a7, 93
    ecall
    .size main, .-main
