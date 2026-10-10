/* 用于词法/语法分析的干净版本（不含 #include，避免 iostream 污染输出）
 * 与 main.cpp 逻辑一致；输入输出用函数声明替代，不引入任何头文件 */
#define PI 3.14159          /* 宏定义 */
#define mian main           /* 宏替换 */

int getint();               /* 输入函数声明 */
void putint(int n);         /* 输出函数声明 */

int g_count = 0;            /* 全局变量 */

/* 计算斐波那契第 n 项 */
int fib(int n) {
    int a = 0, b = 1, t;
    for (int i = 1; i < n; i++) {
        t = b;
        b = a + b;
        a = t;
    }
    return b;
}

int mian() {
    int n;
    n = getint();           /* 函数调用 */
    g_count = n;            /* 使用全局变量 */
    putint(fib(n));         /* 嵌套函数调用 */
    return 0;
}
