; ============================================================
; recursive.ll —— recursive.sy 的等价 LLVM IR（Q2，成员A，可选）
; ------------------------------------------------------------
; 对应 SysY 源程序：src/sysy/recursive.sy
;
; 编译运行（x86）：
;   clang recursive.ll ../../lib/libsysy_x86.a -o recursive
;   echo 5 | ./recursive   # 期望输出 120
;
; 覆盖指令：
;   icmp / br / sub / mul / call（递归调用自身）/ ret
; ============================================================

target triple = "x86_64-pc-linux-gnu"

; ---------- SysY 运行时库函数声明 ----------
declare i32 @getint()
declare void @putint(i32)
declare void @putch(i32)

; ============================================================
; int factorial(int n) {
;     if (n <= 1) return 1;
;     return n * factorial(n - 1);    // 递归调用自身
; }
; ============================================================
define i32 @factorial(i32 %n) {
entry:
  %cmp = icmp sle i32 %n, 1          ; n <= 1
  br i1 %cmp, label %base, label %recur

base:                             ; 递归出口：return 1
  ret i32 1

recur:                            ; 递归：n * factorial(n-1)
  %n1 = sub i32 %n, 1              ; n - 1
  %r0 = call i32 @factorial(i32 %n1)   ; factorial(n-1)
  %r1 = mul i32 %n, %r0            ; n * factorial(n-1)
  ret i32 %r1
}

; ============================================================
; int main() {
;     int n = getint();
;     putint(factorial(n)); putch(10);
; }
; ============================================================
define i32 @main() {
entry:
  %n = alloca i32, align 4

  ; n = getint()
  %v0 = call i32 @getint()
  store i32 %v0, ptr %n, align 4

  ; putint(factorial(n)); putch(10);
  %n1 = load i32, ptr %n, align 4
  %r0 = call i32 @factorial(i32 %n1)
  call void @putint(i32 %r0)
  call void @putch(i32 10)

  ret i32 0
}
