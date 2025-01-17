// RUN: triton-shared-opt --triton-to-structured --remove-dead-values --canonicalize %s | FileCheck %s

module {
  tt.func public @wrap_stacked_masked_loop_01234567(%arg0: !tt.ptr<f32>, %arg1: !tt.ptr<f32>, %arg2: i32, %arg3: i32, %arg4: i32, %arg5: i32, %arg6: i32, %arg7: i32) {
    %cst = arith.constant dense<-9.900000e+01> : tensor<4x4xf32>
    %c1_i32 = arith.constant 1 : i32
    %c0_i32 = arith.constant 0 : i32
    %c2_i32 = arith.constant 2 : i32
    %cst_0 = arith.constant dense<3> : tensor<1x4xi32>
    %cst_1 = arith.constant dense<3> : tensor<4xi32>
    %cst_2 = arith.constant dense<2> : tensor<4xi32>
    %c4_i32 = arith.constant 4 : i32
    %0 = tt.make_range {end = 4 : i32, start = 0 : i32} : tensor<4xi32>
    %1 = arith.addi %0, %cst_2 : tensor<4xi32>
    %2 = tt.splat %arg2 : (i32) -> tensor<4xi32>
    %3 = arith.remsi %1, %2 : tensor<4xi32>
    %4 = arith.addi %0, %cst_1 : tensor<4xi32>
    %5 = tt.expand_dims %3 {axis = 1 : i32} : (tensor<4xi32>) -> tensor<4x1xi32>
    %6 = tt.splat %arg4 : (i32) -> tensor<4x1xi32>
    %7 = arith.muli %5, %6 : tensor<4x1xi32>
    %8 = tt.expand_dims %4 {axis = 0 : i32} : (tensor<4xi32>) -> tensor<1x4xi32>
    %9 = tt.splat %arg5 : (i32) -> tensor<1x4xi32>
    %10 = arith.muli %8, %9 : tensor<1x4xi32>
    %11 = tt.broadcast %7 : (tensor<4x1xi32>) -> tensor<4x4xi32>
    %12 = tt.broadcast %10 : (tensor<1x4xi32>) -> tensor<4x4xi32>
    %13 = arith.addi %11, %12 : tensor<4x4xi32>
    %14 = tt.splat %arg0 : (!tt.ptr<f32>) -> tensor<4x4x!tt.ptr<f32>>
    %15 = tt.addptr %14, %13 : tensor<4x4x!tt.ptr<f32>>, tensor<4x4xi32>
    %16 = tt.expand_dims %0 {axis = 1 : i32} : (tensor<4xi32>) -> tensor<4x1xi32>
    %17 = tt.splat %arg6 : (i32) -> tensor<4x1xi32>
    %18 = arith.muli %17, %16 : tensor<4x1xi32>
    %19 = tt.splat %arg1 : (!tt.ptr<f32>) -> tensor<4x1x!tt.ptr<f32>>
    %20 = tt.addptr %19, %18 : tensor<4x1x!tt.ptr<f32>>, tensor<4x1xi32>
    %21 = tt.expand_dims %0 {axis = 0 : i32} : (tensor<4xi32>) -> tensor<1x4xi32>
    %22 = tt.splat %arg7 : (i32) -> tensor<1x4xi32>
    %23 = arith.muli %22, %21 : tensor<1x4xi32>
    %24 = tt.broadcast %20 : (tensor<4x1x!tt.ptr<f32>>) -> tensor<4x4x!tt.ptr<f32>>
    %25 = tt.broadcast %23 : (tensor<1x4xi32>) -> tensor<4x4xi32>
    %26 = tt.addptr %24, %25 : tensor<4x4x!tt.ptr<f32>>, tensor<4x4xi32>
    %27 = arith.cmpi slt, %21, %cst_0 : tensor<1x4xi32>
    %28 = tt.broadcast %27 : (tensor<1x4xi1>) -> tensor<4x4xi1>
    %29 = arith.muli %arg5, %c4_i32 : i32
    %30 = tt.splat %29 : (i32) -> tensor<4x4xi32>
    %31:2 = scf.for %arg8 = %c0_i32 to %c2_i32 step %c1_i32 iter_args(%arg9 = %15, %arg10 = %26) -> (tensor<4x4x!tt.ptr<f32>>, tensor<4x4x!tt.ptr<f32>>)  : i32 {
      %32 = tt.load %arg9, %28, %cst {cache = 1 : i32, evict = 1 : i32, isVolatile = false} : tensor<4x4xf32>
      tt.store %arg10, %32 {cache = 1 : i32, evict = 1 : i32} : tensor<4x4xf32>
      %33 = tt.addptr %arg9, %30 : tensor<4x4x!tt.ptr<f32>>, tensor<4x4xi32>
      %34 = tt.addptr %arg10, %30 : tensor<4x4x!tt.ptr<f32>>, tensor<4x4xi32>
      scf.yield %33, %34 : tensor<4x4x!tt.ptr<f32>>, tensor<4x4x!tt.ptr<f32>>
    }
    tt.return
  }
}

// CHECK:         tt.func public @wrap_stacked_masked_loop_01234567([[PARAM_0_:%.+]]: !tt.ptr<f32, 1>, [[PARAM_1_:%.+]]: !tt.ptr<f32, 1>, [[PARAM_2_:%.+]]: i32, [[PARAM_3_:%.+]]: i32, [[PARAM_4_:%.+]]: i32, [[PARAM_5_:%.+]]: i32, [[PARAM_6_:%.+]]: i32, [[PARAM_7_:%.+]]: i32) {
// CHECK-DAG:       [[CST_minus_9_dot_900000_:%.+]] = arith.constant -9.900000e+01 : f32
// CHECK-DAG:       [[CST_0_:%.+]] = arith.constant 0 : index
// CHECK-DAG:       [[CST_3_:%.+]] = arith.constant 3 : index
// CHECK-DAG:       [[CST_2_:%.+]] = arith.constant 2 : index
// CHECK-DAG:       [[CST_1_:%.+]] = arith.constant 1 : i32
// CHECK-DAG:       [[CST_0_1_:%.+]] = arith.constant 0 : i32
// CHECK-DAG:       [[CST_2_1_:%.+]] = arith.constant 2 : i32
// CHECK-DAG:       [[CST_4_:%.+]] = arith.constant 4 : i32
// CHECK-DAG:       [[VAR_0_:%.+]] = arith.index_cast [[PARAM_2_]] : i32 to index
// CHECK-DAG:       [[VAR_1_:%.+]] = arith.index_cast [[PARAM_4_]] : i32 to index
// CHECK-NOT: separator of consecutive DAGs
// CHECK-DAG:       [[VAR_2_:%.+]] = arith.muli [[VAR_1_]], [[CST_2_]] : index
// CHECK-DAG:       [[VAR_3_:%.+]] = arith.muli [[VAR_0_]], [[VAR_1_]] : index
// CHECK-DAG:       [[VAR_4_:%.+]] = arith.index_cast [[PARAM_5_]] : i32 to index
// CHECK-NOT: separator of consecutive DAGs
// CHECK-DAG:       [[VAR_5_:%.+]] = arith.muli [[VAR_4_]], [[CST_3_]] : index
// CHECK-DAG:       [[VAR_6_:%.+]] = arith.index_cast [[PARAM_6_]] : i32 to index
// CHECK-DAG:       [[VAR_7_:%.+]] = arith.index_cast [[PARAM_7_]] : i32 to index
// CHECK-DAG:       [[VAR_8_:%.+]] = arith.muli [[PARAM_5_]], [[CST_4_]] : i32
// CHECK-NOT: separator of consecutive DAGs
// CHECK-DAG:       [[VAR_9_:%.+]] = arith.index_cast [[VAR_8_]] : i32 to index
// CHECK-DAG:       [[VAR_10_:%.+]] = arith.index_cast [[VAR_8_]] : i32 to index
// CHECK-DAG:       [[VAR_11_:%.+]]:2 = scf.for [[VAR_arg8_:%.+]] = [[CST_0_1_]] to [[CST_2_1_]] step [[CST_1_]] iter_args([[VAR_arg9_:%.+]] = [[VAR_2_]], [[VAR_arg10_:%.+]] = [[CST_0_]]) -> (index, index)  : i32 {
// CHECK-DAG:         [[VAR_12_:%.+]] = tts.make_tptr [[PARAM_1_]] to sizes: [4, 4], strides: {{.}}[[VAR_6_]], [[VAR_7_]]{{.}}, offsets: {{.}}[[PARAM_1_]]0, [[CST_0_]]{{.}}, parent_sizes: [0, 0] : <f32, 1> to tensor<4x4x!tt.ptr<f32, 1>>
// CHECK-DAG:         [[VAR_13_:%.+]] = tts.make_tptr [[PARAM_0_]] to sizes: [4, 4], strides: {{.}}[[VAR_1_]], [[VAR_4_]]{{.}}, offsets: {{.}}[[VAR_arg9_]], [[VAR_5_]]{{.}}, parent_sizes: {{.}}[[VAR_3_]], 0] : <f32, 1> to tensor<4x4x!tt.ptr<f32, 1>>
// CHECK:             [[VAR_14_:%.+]] = "tts.load"([[VAR_13_]], [[CST_minus_9_dot_900000_]]) <{operandSegmentSizes = array<i32: 1, 0, 1>, static_dims = array<i64: 4, 3>}> : (tensor<4x4x!tt.ptr<f32, 1>>, f32) -> tensor<4x4xf32>
// CHECK:             "tts.store"([[VAR_12_]], [[VAR_14_]]) <{static_dims = array<i64>}> : (tensor<4x4x!tt.ptr<f32, 1>>, tensor<4x4xf32>) -> ()
// CHECK-DAG:         [[VAR_15_:%.+]] = arith.addi [[VAR_arg9_]], [[VAR_10_]] : index
// CHECK-DAG:         [[VAR_16_:%.+]] = arith.addi [[VAR_arg10_]], [[VAR_9_]] : index
// CHECK:             scf.yield [[VAR_15_]], [[VAR_16_]] : index, index
// CHECK:           }
// CHECK:           tt.return
// CHECK:         }
