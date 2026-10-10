// 官方 HFusion 输入：向量加法（对应官方 VecAdd）
// 用 linalg.elemwise_binary（HFusion 继承自 linalg）+ add
// 转换 pass：--convert-hfusion-to-hivm
module attributes {hacc.target = #hacc.target<"Ascend310B4">} {
  func.func @vecadd(%A: memref<16xf16>, %B: memref<16xf16>, %C: memref<16xf16>)
      attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>} {
    linalg.elemwise_binary {fun = #linalg.binary_fn<add>}
      ins(%A, %B : memref<16xf16>, memref<16xf16>)
      outs(%C : memref<16xf16>)
    return
  }
}
