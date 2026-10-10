// vector 方言：向量加法（对应 vecadd.mlir 的「向量化版本」）
// 博客核心观点：vector dialect 在 linalg/affine 之后、LLVM 之前，
// 负责数据并行（SIMD）抽象；它既可降到 LLVM 的 SIMD 指令，也可"反向量化"回 SCF 标量循环。
func.func @add(%A: memref<16xf32>, %B: memref<16xf32>, %C: memref<16xf32>) {
  %c0 = arith.constant 0 : index
  %f0 = arith.constant 0.0 : f32
  // 从内存读 16 个 f32 到 vector<16xf32>（一条 SIMD 装载语义）
  %va = vector.transfer_read %A[%c0], %f0 : memref<16xf32>, vector<16xf32>
  %vb = vector.transfer_read %B[%c0], %f0 : memref<16xf32>, vector<16xf32>
  // 整条向量一次相加（数据并行）
  %vc = arith.addf %va, %vb : vector<16xf32>
  // 一条 SIMD 写回语义
  vector.transfer_write %vc, %C[%c0] : vector<16xf32>, memref<16xf32>
  return
}
