/* 优化性能基准测试：斐波那契计算，跑 trials 次取平均时间
 * 用法：./bench <n> <trials>   （n=斐波那契项数，trials=重复次数） */
#include <stdio.h>
#include <time.h>

int main() {
    int n, trials, a, b, i, t;
    scanf("%d %d", &n, &trials);
    clock_t start, end;
    double total = 0.0;
    volatile int sink = 0;      /* 防止编译器把循环优化掉 */
    int sum = 0;

    for (int tr = 0; tr < trials; tr++) {
        start = clock();
        a = 0; b = 1; i = 1;
        while (i < n) {
            t = b;
            b = a + b;
            a = t;
            i = i + 1;
        }
        sum += b;
        end = clock();
        total += (double)(end - start) / CLOCKS_PER_SEC;
    }
    sink = sum;
    printf("n=%d trials=%d avg_time=%f s sum=%d\n", n, trials, total / trials, sum);
    return 0;
}
