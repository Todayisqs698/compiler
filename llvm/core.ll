; ============================================================
; core.ll —— core.sy 的等价 LLVM IR（Q2，成员A）
; ------------------------------------------------------------
; 对应 SysY 源程序：src/sysy/core.sy
; 使用 OpaquePointers（LLVM 15+ 的 ptr 类型）
;
; 编译运行（x86）：
;   clang core.ll ../../lib/libsysy_x86.a -o core
;   echo 5 | ./core      # 期望输出 5 和 27（末尾另有一行 TOTAL 计时信息）
;
; 覆盖指令：
;   alloca / store / load / add / sub / mul / sdiv / srem
;   icmp / br / call / ret / getelementptr
; ============================================================

target triple = "x86_64-pc-linux-gnu"

; ---------- 全局变量 ----------
@MAX_N = constant i32 10, align 4
@call_count = global i32 0, align 4

; ---------- SysY 运行时库函数声明 ----------
declare i32 @getint()
declare void @putint(i32)
declare void @putch(i32)

; ============================================================
; int relu(int n) {
;     call_count = call_count + 1;      // 全局变量
;     if (n <= 0) return 0;             // 条件分支
;     return n;
; }
; ============================================================
define i32 @relu(i32 %n) {
entry:
  ; call_count = call_count + 1
  %c0 = load i32, ptr @call_count, align 4
  %c1 = add i32 %c0, 1
  store i32 %c1, ptr @call_count, align 4

  ; if (n <= 0)
  %cmp = icmp sle i32 %n, 0
  br i1 %cmp, label %if.then, label %if.else

if.then:                          ; return 0
  ret i32 0

if.else:                          ; return n
  ret i32 %n
}

; ============================================================
; int main() { ... }
; ============================================================
define i32 @main() {
entry:
  ; --- 局部变量（栈上分配） ---
  %n      = alloca i32, align 4
  %result = alloca i32, align 4
  %i      = alloca i32, align 4
  %sum    = alloca i32, align 4
  %arr    = alloca [11 x i32], align 16   ; int arr[11]

  ; n = getint()
  %v0 = call i32 @getint()
  store i32 %v0, ptr %n, align 4

  ; if (n < 0 || n > MAX_N) return 1;
  %v1 = load i32, ptr %n, align 4
  %cmp1 = icmp slt i32 %v1, 0          ; n < 0
  br i1 %cmp1, label %ret1, label %chk2

chk2:                             ; n > MAX_N（10）
  %v2 = load i32, ptr %n, align 4
  %cmp2 = icmp sgt i32 %v2, 10
  br i1 %cmp2, label %ret1, label %chk3

ret1:                             ; return 1（边界错误）
  ret i32 1

chk3:                             ; if (n >= 0 && !(n == 0))
  %v3 = load i32, ptr %n, align 4
  %cmp3 = icmp sge i32 %v3, 0          ; n >= 0
  br i1 %cmp3, label %chk4, label %result0

chk4:                             ; !(n == 0)
  %v4 = load i32, ptr %n, align 4
  %cmp4 = icmp eq i32 %v4, 0
  br i1 %cmp4, label %result0, label %callrelu

callrelu:                         ; result = relu(n)
  %v5 = load i32, ptr %n, align 4
  %rv = call i32 @relu(i32 %v5)
  store i32 %rv, ptr %result, align 4
  br label %afterif

result0:                          ; result = 0
  store i32 0, ptr %result, align 4
  br label %afterif

afterif:
  ; putint(result); putch(10);
  %r1 = load i32, ptr %result, align 4
  call void @putint(i32 %r1)
  call void @putch(i32 10)

  ; sum = 0; i = 0;
  store i32 0, ptr %sum, align 4
  store i32 0, ptr %i, align 4
  br label %while.cond

while.cond:                       ; while (i <= n)
  %iv = load i32, ptr %i, align 4
  %nv = load i32, ptr %n, align 4
  %cmpw = icmp sle i32 %iv, %nv
  br i1 %cmpw, label %while.body, label %while.end

while.body:
  ; if (i == 8) break;
  %ib = load i32, ptr %i, align 4
  %cmpb = icmp eq i32 %ib, 8
  br i1 %cmpb, label %while.end, label %while.cont

while.cont:
  ; arr[i] = relu(i)
  %ic = load i32, ptr %i, align 4
  %rv2 = call i32 @relu(i32 %ic)
  %idx0 = sext i32 %ic to i64          ; 下标 i32 -> i64
  %p0 = getelementptr inbounds [11 x i32], ptr %arr, i64 0, i64 %idx0
  store i32 %rv2, ptr %p0, align 4

  ; sum = sum + arr[i] * 2 - i / 3 % 5
  %s0 = load i32, ptr %sum, align 4
  %id1 = load i32, ptr %i, align 4
  %idx1 = sext i32 %id1 to i64
  %p1 = getelementptr inbounds [11 x i32], ptr %arr, i64 0, i64 %idx1
  %av = load i32, ptr %p1, align 4     ; arr[i]
  %m0 = mul i32 %av, 2                 ; arr[i] * 2
  %s1 = add i32 %s0, %m0               ; sum + arr[i]*2
  %id2 = load i32, ptr %i, align 4
  %d0 = sdiv i32 %id2, 3               ; i / 3
  %r0 = srem i32 %d0, 5                ; (i/3) % 5
  %s2 = sub i32 %s1, %r0               ; sum + arr[i]*2 - i/3%5
  store i32 %s2, ptr %sum, align 4

  ; i = i + 1
  %id3 = load i32, ptr %i, align 4
  %id4 = add i32 %id3, 1
  store i32 %id4, ptr %i, align 4
  br label %while.cond

while.end:
  ; putint(sum); putch(10);
  %s3 = load i32, ptr %sum, align 4
  call void @putint(i32 %s3)
  call void @putch(i32 10)

  ret i32 0
}
