#include <cstddef>
#include <cstdio>
#include <vector>

static void saxpy(const float *x, const float *y, float *out, float a, std::size_t n) {
    for (std::size_t i = 0; i < n; ++i) {
        out[i] = a * x[i] + y[i];
    }
}

int main() {
    constexpr std::size_t n = 1U << 20;
    std::vector<float> x(n, 1.5F);
    std::vector<float> y(n, 2.0F);
    std::vector<float> out(n, 0.0F);
    saxpy(x.data(), y.data(), out.data(), 2.0F, n);
    std::printf("out[0]=%.1f out[n-1]=%.1f\n", out.front(), out.back());
    return 0;
}

