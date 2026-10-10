module attributes {hacc.target = #hacc.target<"Ascend310B4">} {
  func.func @vecadd(%arg0: memref<16xf16>, %arg1: memref<16xf16>, %arg2: memref<16xf16>) attributes {hacc.entry, hacc.function_kind = #hacc.function_kind<DEVICE>} {
    hivm.hir.vadd ins(%arg0, %arg1 : memref<16xf16>, memref<16xf16>) outs(%arg2 : memref<16xf16>)
    return
  }
}

