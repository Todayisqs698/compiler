; ============================================================
; float.ll —— float.sy 的等价 LLVM IR（Q2，成员A）
; ------------------------------------------------------------
; 对应 SysY 源程序：src/sysy/float.sy
;
; 编译运行（x86）：
;   clang float.ll ../../lib/libsysy_x86.a -o float
;   ./float              # 期望输出 4 个 %a 格式浮点值
;
; 覆盖指令：
;   alloca / store / load / fadd / fsub / fmul / fdiv / call / ret
; ============================================================

target triple = "x86_64-pc-linux-gnu"

; ---------- SysY 运行时库函数声明 ----------
declare void @putfloat(float)
declare void @putch(i32)

; ============================================================
; int main() {
;     float f1 = 3.14;  float f2 = 2.0;
;     float fsum = f1 + f2;   fdiff = f1 - f2;
;     float fmul = f1 * f2;   fdiv  = f1 / f2;
;     putfloat(...); putch(10); ...
; }
; ============================================================
define i32 @main() {
entry:
  ; --- 局部 float 变量（栈上分配，4 字节对齐） ---
  %f1    = alloca float, align 4
  %f2    = alloca float, align 4
  %fsum  = alloca float, align 4
  %fdiff = alloca float, align 4
  %fmul  = alloca float, align 4
  %fdiv  = alloca float, align 4

  ; float f1 = 3.14;   float f2 = 2.0;
  store float 0x40091EB860000000, ptr %f1, align 4   ; 3.14f 的 IEEE754 位模式
  store float 2.000000e+00, ptr %f2, align 4         ; 2.0f

  ; fsum = f1 + f2  (fadd)
  %a0 = load float, ptr %f1, align 4
  %b0 = load float, ptr %f2, align 4
  %s0 = fadd float %a0, %b0
  store float %s0, ptr %fsum, align 4

  ; fdiff = f1 - f2  (fsub)
  %a1 = load float, ptr %f1, align 4
  %b1 = load float, ptr %f2, align 4
  %d0 = fsub float %a1, %b1
  store float %d0, ptr %fdiff, align 4

  ; fmul = f1 * f2  (fmul)
  %a2 = load float, ptr %f1, align 4
  %b2 = load float, ptr %f2, align 4
  %m0 = fmul float %a2, %b2
  store float %m0, ptr %fmul, align 4

  ; fdiv = f1 / f2  (fdiv)
  %a3 = load float, ptr %f1, align 4
  %b3 = load float, ptr %f2, align 4
  %d1 = fdiv float %a3, %b3
  store float %d1, ptr %fdiv, align 4

  ; putfloat(fsum); putch(10);
  %v0 = load float, ptr %fsum, align 4
  call void @putfloat(float %v0)
  call void @putch(i32 10)

  ; putfloat(fdiff); putch(10);
  %v1 = load float, ptr %fdiff, align 4
  call void @putfloat(float %v1)
  call void @putch(i32 10)

  ; putfloat(fmul); putch(10);
  %v2 = load float, ptr %fmul, align 4
  call void @putfloat(float %v2)
  call void @putch(i32 10)

  ; putfloat(fdiv); putch(10);
  %v3 = load float, ptr %fdiv, align 4
  call void @putfloat(float %v3)
  call void @putch(i32 10)

  ret i32 0
}
