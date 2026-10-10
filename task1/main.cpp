#include <iostream>          /* 测试：文件包含处理 */
#define PI 3.14159          /* 测试：宏定义替换 */
#define mian main           /* 测试：宏替换（预处理后 mian 变成 main） */

using namespace std;

int g_count = 0;            /* 测试：全局变量 */

/* 计算斐波那契第 n 项（迭代实现） */
int fib(int n) {
    int a = 0, b = 1, t;
    /* 多行注释：
       循环递推计算 fib(n) */
    for (int i = 1; i < n; i++) {
        t = b;
        b = a + b;
        a = t;
    }
    return b;
}

int mian() {
    int n;
    cout << "please input n: ";
    cin >> n;               // 单行注释：读取输入
    g_count = n;            // 使用全局变量
    cout << "fib(" << n << ") = " << fib(n) << endl;  // 调用函数并输出
    return 0;
}
