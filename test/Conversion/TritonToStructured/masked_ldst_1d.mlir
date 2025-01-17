// RUN: triton-shared-opt --triton-to-structured --remove-dead-values --canonicalize %s | FileCheck %s

module {
  tt.func @kernel(
  %arg0 : !tt.ptr<bf16>,
  %arg1 : !tt.ptr<bf16>,
  %arg2 : i32
  )
  {
    %0 = tt.splat %arg0 : (!tt.ptr<bf16>) -> tensor<128x!tt.ptr<bf16>>
    %1 = tt.splat %arg1 : (!tt.ptr<bf16>) -> tensor<128x!tt.ptr<bf16>>
    %2 = tt.make_range {end = 128 : i32, start = 0 : i32} : tensor<128xi32>
    %ldptr = tt.addptr %0, %2 : tensor<128x!tt.ptr<bf16>>, tensor<128xi32>
    %stptr = tt.addptr %1, %2 : tensor<128x!tt.ptr<bf16>>, tensor<128xi32>
    %nans = arith.constant dense<0xFF80> : tensor<128xbf16>
    %5 = tt.splat %arg2 : (i32) -> tensor<128xi32>
    %mask = arith.cmpi slt, %2, %5 : tensor<128xi32>
    %buff = tt.load %ldptr, %mask, %nans {cache = 1 : i32, evict = 1 : i32, isVolatile = false} : tensor<128xbf16>
    tt.store %stptr, %buff, %mask : tensor<128xbf16>
    tt.return
  }
}

// CHECK:         tt.func @kernel([[PARAM_0_:%.+]]: !tt.ptr<bf16, 1>, [[PARAM_1_:%.+]]: !tt.ptr<bf16, 1>, [[PARAM_2_:%.+]]: i32) {
// CHECK-DAG:       [[CST_0_:%.+]] = arith.constant 0xFF80 : bf16
// CHECK-DAG:       [[CST_128_:%.+]] = arith.constant 128 : index
// CHECK-DAG:       [[VAR_0_:%.+]] = tts.make_tptr [[PARAM_0_]] to sizes: [128], strides: [1], offsets: [0], parent_sizes: [0] : <bf16, 1> to tensor<128x!tt.ptr<bf16, 1>>
// CHECK-DAG:       [[VAR_1_:%.+]] = tts.make_tptr [[PARAM_1_]] to sizes: [128], strides: [1], offsets: [0], parent_sizes: [0] : <bf16, 1> to tensor<128x!tt.ptr<bf16, 1>>
// CHECK-DAG:       [[VAR_2_:%.+]] = arith.index_cast [[PARAM_2_]] : i32 to index
// CHECK:           [[VAR_3_:%.+]] = arith.minsi [[VAR_2_]], [[CST_128_]] : index
// CHECK-DAG:       [[VAR_4_:%.+]] = "tts.load"([[VAR_0_]], [[VAR_3_]], [[CST_0_]]) <{operandSegmentSizes = array<i32: 1, 1, 1>, static_dims = array<i64: -9223372036854775808>}> : (tensor<128x!tt.ptr<bf16, 1>>, index, bf16) -> tensor<128xbf16>
// CHECK-DAG:       [[VAR_5_:%.+]] = arith.index_cast [[PARAM_2_]] : i32 to index
// CHECK:           [[VAR_6_:%.+]] = arith.minsi [[VAR_5_]], [[CST_128_]] : index
// CHECK:           "tts.store"([[VAR_1_]], [[VAR_4_]], [[VAR_6_]]) <{static_dims = array<i64: -9223372036854775808>}> : (tensor<128x!tt.ptr<bf16, 1>>, tensor<128xbf16>, index) -> ()
// CHECK:           tt.return
// CHECK:         }
