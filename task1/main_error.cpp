/* 语义分析演示：故意植入类型错误、未声明变量、函数重定义冲突 */
#define PI 3.14159

int g_count = 0;

int fib(int n) {
    int a = 0, b = 1, t;
    for (int i = 1; i < n; i++) {
        t = b;
        b = a + b;
        a = t;
    }
    return b;
}

/* 错误1：函数重定义，返回类型冲突 */
float fib(int n);

int main() {
    int n;
    int arr[10];

    /* 错误2：未声明的变量 */
    y = 5;

    /* 错误3：字符串字面量赋给 int（类型不兼容） */
    n = "hello";

    /* 错误4：数组越界只是警告，但这里制造类型错误：float 赋给 int 数组 */
    arr[0] = 3.14;

    /* 错误5：条件表达式类型错误（int 与指针比较） */
    if (n == "abc") {
        return 1;
    }

    return 0;
}
