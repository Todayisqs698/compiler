// 向量相加：对应 AscendNPU IR 官方 VecAdd 示例（16 个 f32 元素）
// 这是「高层方言」linalg.generic，只表达"逐元素加法"的语义，不涉及任何硬件细节。
// 注意与官方 add.mlir 的区别：官方用的是 hivm 方言（Tile 级 load/vadd/store + gm/ub 地址空间），
// 本演示用社区 linalg 方言（HFusion 正是基于 linalg 扩展而来），展示同一套 MLIR 降低机制。
func.func @add(%A: memref<16xf32>, %B: memref<16xf32>, %C: memref<16xf32>) {
  linalg.generic {
    indexing_maps = [affine_map<(i) -> (i)>, affine_map<(i) -> (i)>, affine_map<(i) -> (i)>],
    iterator_types = ["parallel"]
  } ins(%A, %B : memref<16xf32>, memref<16xf32>) outs(%C : memref<16xf32>) {
  ^bb0(%a: f32, %b: f32, %c: f32):
    %sum = arith.addf %a, %b : f32
    linalg.yield %sum : f32
  }
  return
}
