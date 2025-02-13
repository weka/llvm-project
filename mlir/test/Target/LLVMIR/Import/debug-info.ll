; RUN: mlir-translate -import-llvm -mlir-print-debuginfo -split-input-file %s | FileCheck %s

; CHECK: #[[$UNKNOWN_LOC:.+]] = loc(unknown)

; CHECK-LABEL: @module_loc(
define i32 @module_loc(i32 %0) {
entry:
  br label %next
end:
  ; CHECK: ^{{.*}}(%{{.+}}: i32 loc(unknown)):
  %1 = phi i32 [ %2, %next ]
  ret i32 %1
next:
  ; CHECK: = llvm.mul %{{.+}}, %{{.+}} : i32 loc(#[[$UNKNOWN_LOC]])
  %2 = mul i32 %0, %0
  br label %end
}

; // -----

; CHECK-LABEL: @instruction_loc
define i32 @instruction_loc(i32 %arg1) {
  ; CHECK: llvm.add {{.*}} loc(#[[FILE_LOC:.*]])
  %1 = add i32 %arg1, %arg1, !dbg !5

  ; CHECK: llvm.mul {{.*}} loc(#[[CALLSITE_LOC:.*]])
  %2 = mul i32 %1, %1, !dbg !7

  ret i32 %2
}

; CHECK-DAG: #[[RAW_FILE_LOC:.+]] = loc("debug-info.ll":1:2)
; CHECK-DAG: #[[SP:.+]] =  #llvm.di_subprogram<compileUnit = #{{.*}}, scope = #{{.*}}, name = "instruction_loc"
; CHECK-DAG: #[[CALLEE:.+]] =  #llvm.di_subprogram<compileUnit = #{{.*}}, scope = #{{.*}}, name = "callee"
; CHECK-DAG: #[[FILE_LOC]] = loc(fused<#[[SP]]>[#[[RAW_FILE_LOC]]])
; CHECK-DAG: #[[CALLEE_LOC:.+]] = loc("debug-info.ll":7:4)
; CHECK-DAG: #[[RAW_CALLER_LOC:.+]] = loc("debug-info.ll":2:2)
; CHECK-DAG: #[[CALLER_LOC:.+]] = loc(fused<#[[SP]]>[#[[RAW_CALLER_LOC]]])
; CHECK-DAG: #[[RAW_CALLSITE_LOC:.+]] = loc(callsite(#[[CALLEE_LOC]] at #[[CALLER_LOC]]))
; CHECK-DAG: #[[CALLSITE_LOC]] = loc(fused<#[[CALLEE]]>[#[[RAW_CALLSITE_LOC]]])

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!3 = distinct !DISubprogram(name: "instruction_loc", scope: !2, file: !2, spFlags: DISPFlagDefinition, unit: !1)
!4 = distinct !DISubprogram(name: "callee", scope: !2, file: !2, spFlags: DISPFlagDefinition, unit: !1)
!5 = !DILocation(line: 1, column: 2, scope: !3)
!6 = !DILocation(line: 2, column: 2, scope: !3)
!7 = !DILocation(line: 7, column: 4, scope: !4, inlinedAt: !6)

; // -----

; CHECK-LABEL: @lexical_block
define i32 @lexical_block(i32 %arg1) {
  ; CHECK: llvm.add {{.*}} loc(#[[LOC0:.*]])
  %1 = add i32 %arg1, %arg1, !dbg !6

  ; CHECK: llvm.mul {{.*}} loc(#[[LOC1:.*]])
  %2 = mul i32 %arg1, %arg1, !dbg !7

  ret i32 %2
}
; CHECK: #[[FILE:.+]] = #llvm.di_file<"debug-info.ll" in "/">
; CHECK: #[[SP:.+]] = #llvm.di_subprogram<compileUnit =
; CHECK: #[[LB0:.+]] = #llvm.di_lexical_block<scope = #[[SP]]>
; CHECK: #[[LB1:.+]] = #llvm.di_lexical_block<scope = #[[SP]], file = #[[FILE]], line = 2, column = 2>
; CHECK: #[[LOC0]] = loc(fused<#[[LB0]]>[{{.*}}])
; CHECK: #[[LOC1]] = loc(fused<#[[LB1]]>[{{.*}}])

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!3 = distinct !DISubprogram(name: "lexical_block", scope: !2, file: !2, spFlags: DISPFlagDefinition, unit: !1)
!4 = !DILexicalBlock(scope: !3)
!5 = !DILexicalBlock(scope: !3, file: !2, line: 2, column: 2)
!6 = !DILocation(line: 1, column: 2, scope: !4)
!7 = !DILocation(line: 2, column: 2, scope: !5)

; // -----

; CHECK-LABEL: @lexical_block_file
define i32 @lexical_block_file(i32 %arg1) {
  ; CHECK: llvm.add {{.*}} loc(#[[LOC0:.*]])
  %1 = add i32 %arg1, %arg1, !dbg !6

  ; CHECK: llvm.mul {{.*}} loc(#[[LOC1:.*]])
  %2 = mul i32 %arg1, %arg1, !dbg !7

  ret i32 %2
}
; CHECK: #[[FILE:.+]] = #llvm.di_file<"debug-info.ll" in "/">
; CHECK: #[[SP:.+]] = #llvm.di_subprogram<compileUnit =
; CHECK: #[[LB0:.+]] = #llvm.di_lexical_block_file<scope = #[[SP]], discriminator = 0>
; CHECK: #[[LB1:.+]] = #llvm.di_lexical_block_file<scope = #[[SP]], file = #[[FILE]], discriminator = 0>
; CHECK: #[[LOC0]] = loc(fused<#[[LB0]]>[
; CHECK: #[[LOC1]] = loc(fused<#[[LB1]]>[

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!3 = distinct !DISubprogram(name: "lexical_block_file", scope: !2, file: !2, spFlags: DISPFlagDefinition, unit: !1)
!4 = !DILexicalBlockFile(scope: !3, discriminator: 0)
!5 = !DILexicalBlockFile(scope: !3, file: !2, discriminator: 0)
!6 = !DILocation(line: 1, column: 2, scope: !4)
!7 = !DILocation(line: 2, column: 2, scope: !5)

; // -----

; CHECK-DAG: #[[NULL:.+]] = #llvm.di_null_type
; CHECK-DAG: #[[INT1:.+]] = #llvm.di_basic_type<tag = DW_TAG_base_type, name = "int1">
; CHECK-DAG: #[[INT2:.+]] = #llvm.di_basic_type<tag = DW_TAG_base_type, name = "int2", sizeInBits = 32, encoding = DW_ATE_signed>
; CHECK-DAG: #llvm.di_subroutine_type<types = #[[NULL]], #[[INT1]], #[[INT2]]>

define void @basic_type() !dbg !3 {
  ret void
}

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!3 = distinct !DISubprogram(name: "basic_type", scope: !2, file: !2, spFlags: DISPFlagDefinition, unit: !1, type: !4)
!4 = !DISubroutineType(types: !5)
!5 = !{null, !6, !7}
!6 = !DIBasicType(name: "int1")
!7 = !DIBasicType(name: "int2", encoding: DW_ATE_signed, size: 32)

; // -----

; CHECK: #[[INT:.+]] = #llvm.di_basic_type<tag = DW_TAG_base_type, name = "int">
; CHECK: #[[PTR1:.+]] = #llvm.di_derived_type<tag = DW_TAG_pointer_type, baseType = #[[INT]]>
; CHECK: #[[PTR2:.+]] = #llvm.di_derived_type<tag = DW_TAG_pointer_type, name = "mypointer", baseType = #[[INT]], sizeInBits = 64, alignInBits = 32, offsetInBits = 4>
; CHECK: #llvm.di_subroutine_type<types = #[[PTR1]], #[[PTR2]]>

define void @derived_type() !dbg !3 {
  ret void
}

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!3 = distinct !DISubprogram(name: "derived_type", scope: !2, file: !2, spFlags: DISPFlagDefinition, unit: !1, type: !4)
!4 = !DISubroutineType(types: !5)
!5 = !{!7, !8}
!6 = !DIBasicType(name: "int")
!7 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !6)
!8 = !DIDerivedType(name: "mypointer", tag: DW_TAG_pointer_type, baseType: !6, size: 64, align: 32, offset: 4)

; // -----

; CHECK-DAG: #[[INT:.+]] = #llvm.di_basic_type<tag = DW_TAG_base_type, name = "int">
; CHECK-DAG: #[[FILE:.+]] = #llvm.di_file<"debug-info.ll" in "/">
; CHECK-DAG: #[[COMP1:.+]] = #llvm.di_composite_type<tag = DW_TAG_array_type, name = "array1", line = 10, sizeInBits = 128, alignInBits = 32>
; CHECK-DAG: #[[COMP2:.+]] = #llvm.di_composite_type<{{.*}}, file = #[[FILE]], scope = #[[FILE]], baseType = #[[INT]]>
; CHECK-DAG: #[[COMP3:.+]] = #llvm.di_composite_type<{{.*}}, flags = Vector, elements = #llvm.di_subrange<count = 4 : i64>>
; CHECK-DAG: #[[COMP4:.+]] = #llvm.di_composite_type<{{.*}}, flags = Vector, elements = #llvm.di_subrange<lowerBound = 0 : i64, upperBound = 4 : i64, stride = 1 : i64>>
; CHECK-DAG: #llvm.di_subroutine_type<types = #[[COMP1]], #[[COMP2]], #[[COMP3]], #[[COMP4]]>

define void @composite_type() !dbg !3 {
  ret void
}

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!3 = distinct !DISubprogram(name: "composite_type", scope: !2, file: !2, spFlags: DISPFlagDefinition, unit: !1, type: !4)
!4 = !DISubroutineType(types: !5)
!5 = !{!7, !8, !9, !10}
!6 = !DIBasicType(name: "int")
!7 = !DICompositeType(tag: DW_TAG_array_type, name: "array1", line: 10, size: 128, align: 32)
!8 = !DICompositeType(tag: DW_TAG_array_type, name: "array2", file: !2, scope: !2, baseType: !6)
!9 = !DICompositeType(tag: DW_TAG_array_type, name: "array3", flags: DIFlagVector, elements: !13)
!10 = !DICompositeType(tag: DW_TAG_array_type, name: "array4", flags: DIFlagVector, elements: !14)
!11 = !DISubrange(count: 4)
!12 = !DISubrange(lowerBound: 0, upperBound: 4, stride: 1)
!13 = !{!11}
!14 = !{!12}

; // -----

; CHECK-DAG: #[[FILE:.+]] = #llvm.di_file<"debug-info.ll" in "/">
; CHECK-DAG: #[[CU:.+]] = #llvm.di_compile_unit<sourceLanguage = DW_LANG_C, file = #[[FILE]], isOptimized = false, emissionKind = None>
; Verify an empty subroutine types list is supported.
; CHECK-DAG: #[[SP_TYPE:.+]] = #llvm.di_subroutine_type<callingConvention = DW_CC_normal>
; CHECK-DAG: #[[SP:.+]] = #llvm.di_subprogram<compileUnit = #[[CU]], scope = #[[FILE]], name = "subprogram", linkageName = "subprogram", file = #[[FILE]], line = 42, scopeLine = 42, subprogramFlags = Definition, type = #[[SP_TYPE]]>

define void @subprogram() !dbg !3 {
  ret void
}

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!3 = distinct !DISubprogram(name: "subprogram", linkageName: "subprogram", scope: !2, file: !2, line: 42, scopeLine: 42, spFlags: DISPFlagDefinition, unit: !1, type: !4)
!4 = !DISubroutineType(cc: DW_CC_normal, types: !5)
!5 = !{}
!6 = !DIBasicType(name: "int")

; // -----

; CHECK-LABEL: @func_loc
define void @func_loc() !dbg !3 {
  ret void
}
; CHECK: #[[SP:.+]] =  #llvm.di_subprogram<compileUnit = #{{.*}}, scope = #{{.*}}, name = "func_loc", file = #{{.*}}, subprogramFlags = Definition>
; CHECK: loc(fused<#[[SP]]>[

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!3 = distinct !DISubprogram(name: "func_loc", scope: !2, file: !2, spFlags: DISPFlagDefinition, unit: !1)

; // -----

; Verify the module location is set to the source filename.
; CHECK: loc("debug-info.ll":0:0)
source_filename = "debug-info.ll"

; // -----

; NOTE: The debug intrinsics are reordered as a side-effect of the dominance-
;       preserving measures needed to import LLVM IR.

; CHECK: #[[FILE:.+]] = #llvm.di_file<
; CHECK: #[[$SP:.+]] = #llvm.di_subprogram<
; CHECK: #[[$LABEL:.+]] = #llvm.di_label<scope = #[[$SP]], name = "label", file = #[[FILE]], line = 42>
; CHECK: #[[$VAR1:.+]] = #llvm.di_local_variable<scope = #[[$SP]], name = "arg">
; CHECK: #[[$VAR0:.+]] = #llvm.di_local_variable<scope = #[[$SP]], name = "arg", file = #[[FILE]], line = 1, arg = 1, alignInBits = 32, type = #{{.*}}>

; CHECK-LABEL: @intrinsic
; CHECK-SAME:  %[[ARG0:[a-zA-Z0-9]+]]
; CHECK-SAME:  %[[ARG1:[a-zA-Z0-9]+]]
define void @intrinsic(i64 %0, ptr %1) {
  ; CHECK: llvm.intr.dbg.declare #[[$VAR1]] = %[[ARG1]] : !llvm.ptr loc(#[[LOC1:.+]])
  ; CHECK: llvm.intr.dbg.value #[[$VAR0]] = %[[ARG0]] : i64 loc(#[[LOC0:.+]])
  call void @llvm.dbg.value(metadata i64 %0, metadata !5, metadata !DIExpression()), !dbg !7
  call void @llvm.dbg.declare(metadata ptr %1, metadata !6, metadata !DIExpression()), !dbg !9
  ; CHECK: llvm.intr.dbg.label #[[$LABEL]] loc(#[[LOC1:.+]])
  call void @llvm.dbg.label(metadata !10), !dbg !9
  ret void
}

; CHECK: #[[LOC1]] = loc(fused<#[[$SP]]>[{{.*}}])
; CHECK: #[[LOC0]] = loc(fused<#[[$SP]]>[{{.*}}])

declare void @llvm.dbg.value(metadata, metadata, metadata)
declare void @llvm.dbg.declare(metadata, metadata, metadata)
declare void @llvm.dbg.label(metadata)

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!3 = distinct !DISubprogram(name: "intrinsic", scope: !2, file: !2, spFlags: DISPFlagDefinition, unit: !1)
!4 = !DIBasicType(name: "int")
!5 = !DILocalVariable(scope: !3, name: "arg", file: !2, line: 1, arg: 1, align: 32, type: !4);
!6 = !DILocalVariable(scope: !3, name: "arg")
!7 = !DILocation(line: 1, column: 2, scope: !3)
!8 = !DILocation(line: 2, column: 2, scope: !3)
!9 = !DILocation(line: 3, column: 2, scope: !3)
!10 = !DILabel(scope: !3, name: "label", file: !2, line: 42)

; // -----

; CHECK-LABEL: @class_method
define void @class_method() {
  ; CHECK: llvm.return loc(#[[LOC:.+]])
  ret void, !dbg !9
}

; Verify the elements parameter is dropped due to the cyclic dependencies.
; CHECK: #[[COMP:.+]] = #llvm.di_composite_type<tag = DW_TAG_class_type, name = "class_name", file = #{{.*}}, line = 42, flags = "TypePassByReference|NonTrivial">
; CHECK: #[[COMP_PTR:.+]] = #llvm.di_derived_type<tag = DW_TAG_pointer_type, baseType = #[[COMP]], sizeInBits = 64>
; CHECK: #[[SP_TYPE:.+]] = #llvm.di_subroutine_type<types = #{{.*}}, #[[COMP_PTR]]>
; CHECK: #[[SP:.+]] = #llvm.di_subprogram<compileUnit = #{{.*}}, scope = #[[COMP]], name = "class_method", file = #{{.*}}, subprogramFlags = Definition, type = #[[SP_TYPE]]>
; CHECK: #[[LOC]] = loc(fused<#[[SP]]>

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!3 = !DICompositeType(tag: DW_TAG_class_type, name: "class_name", file: !2, line: 42, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !4)
!4 = !{!5}
!5 = distinct !DISubprogram(name: "class_method", scope: !3, file: !2, type: !6, spFlags: DISPFlagDefinition, unit: !1)
!6 = !DISubroutineType(types: !7)
!7 = !{null, !8}
!8 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3, size: 64, flags: DIFlagArtificial | DIFlagObjectPointer)
!9 = !DILocation(line: 1, column: 2, scope: !5)

; // -----

; Verify the elements parameter is dropped due to the cyclic dependencies.
; CHECK: #[[$COMP:.+]] = #llvm.di_composite_type<tag = DW_TAG_class_type, name = "class_field", file = #{{.*}}, line = 42, flags = "TypePassByReference|NonTrivial">
; CHECK: #[[$COMP_PTR:.+]] = #llvm.di_derived_type<tag = DW_TAG_pointer_type, baseType = #[[$COMP]]>
; CHECK: #[[$VAR0:.+]] = #llvm.di_local_variable<scope = #{{.*}}, name = "class_field", file = #{{.*}}, type = #[[$COMP_PTR]]>

; CHECK-LABEL: @class_field
; CHECK-SAME:  %[[ARG0:[a-zA-Z0-9]+]]
define void @class_field(ptr %arg1) {
  ; CHECK: llvm.intr.dbg.value #[[$VAR0]] = %[[ARG0]] : !llvm.ptr
  call void @llvm.dbg.value(metadata ptr %arg1, metadata !7, metadata !DIExpression()), !dbg !9
  ret void
}

declare void @llvm.dbg.value(metadata, metadata, metadata)

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!3 = !DICompositeType(tag: DW_TAG_class_type, name: "class_field", file: !2, line: 42, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !4)
!4 = !{!6}
!5 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3, flags: DIFlagArtificial | DIFlagObjectPointer)
!6 = !DIDerivedType(tag: DW_TAG_member, name: "call_field", file: !2, baseType: !5)
!7 = !DILocalVariable(scope: !8, name: "class_field", file: !2, type: !5);
!8 = distinct !DISubprogram(name: "class_field", scope: !2, file: !2, spFlags: DISPFlagDefinition, unit: !1)
!9 = !DILocation(line: 1, column: 2, scope: !8)

; // -----

; CHECK-DAG: #[[NULL:.+]] = #llvm.di_null_type
; CHECK-DAG: #llvm.di_subroutine_type<types = #[[NULL]], #[[NULL]]>

declare !dbg !3 void @variadic_func()

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!3 = !DISubprogram(name: "variadic_func", scope: !2, file: !2, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, type: !4)
!4 = !DISubroutineType(types: !5)
!5 = !{null, null}

; // -----

define void @dbg_use_before_def(ptr %arg) {
  call void @llvm.dbg.value(metadata ptr %dbg_arg, metadata !7, metadata !DIExpression()), !dbg !9
  %dbg_arg = getelementptr double, ptr %arg, i64 16
  ret void
}

declare void @llvm.dbg.value(metadata, metadata, metadata)

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!3 = !DICompositeType(tag: DW_TAG_class_type, name: "class_field", file: !2, line: 42, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !4)
!4 = !{!6}
!5 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3, flags: DIFlagArtificial | DIFlagObjectPointer)
!6 = !DIDerivedType(tag: DW_TAG_member, name: "call_field", file: !2, baseType: !5)
!7 = !DILocalVariable(scope: !8, name: "var", file: !2, type: !5);
!8 = distinct !DISubprogram(name: "dbg_use_before_def", scope: !2, file: !2, spFlags: DISPFlagDefinition, unit: !1)
!9 = !DILocation(line: 1, column: 2, scope: !8)

; // -----

; This test checks that broken dominance doesn't break the metadata import.

; CHECK-LABEL: @dbg_broken_dominance
define void @dbg_broken_dominance(ptr %arg, i1 %cond) {
  br i1 %cond, label %b1, label %b2
b1:
  br label %b3
b2:
  %dbg_arg = getelementptr double, ptr %arg, i64 16
  ; CHECK: llvm.getelementptr
  ; CHECK-NEXT: llvm.intr.dbg.value
  br label %b3
b3:
  call void @llvm.dbg.value(metadata ptr %dbg_arg, metadata !7, metadata !DIExpression()), !dbg !9
  ret void
}

declare void @llvm.dbg.value(metadata, metadata, metadata)

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!3 = !DICompositeType(tag: DW_TAG_class_type, name: "class_field", file: !2, line: 42, flags: DIFlagTypePassByReference | DIFlagNonTrivial, elements: !4)
!4 = !{!6}
!5 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !3, flags: DIFlagArtificial | DIFlagObjectPointer)
!6 = !DIDerivedType(tag: DW_TAG_member, name: "call_field", file: !2, baseType: !5)
!7 = !DILocalVariable(scope: !8, name: "var", file: !2, type: !5);
!8 = distinct !DISubprogram(name: "dbg_use_before_def", scope: !2, file: !2, spFlags: DISPFlagDefinition, unit: !1)
!9 = !DILocation(line: 1, column: 2, scope: !8)

; // -----

; CHECK-DAG: #[[NAMESPACE:.+]] = #llvm.di_namespace<name = "std", exportSymbols = false>
; CHECK-DAG: #[[SUBPROGRAM:.+]] =  #llvm.di_subprogram<compileUnit = #{{.*}}, scope = #[[NAMESPACE]], name = "namespace"

define void @namespace(ptr %arg) {
  call void @llvm.dbg.value(metadata ptr %arg, metadata !7, metadata !DIExpression()), !dbg !9
  ret void
}

declare void @llvm.dbg.value(metadata, metadata, metadata)

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!7 = !DILocalVariable(scope: !8, name: "var")
!8 = distinct !DISubprogram(name: "namespace", scope: !10, file: !2, unit: !1);
!9 = !DILocation(line: 1, column: 2, scope: !8)
!10 = !DINamespace(name: "std", scope: null)

; // -----

; CHECK-DAG: #[[SUBPROGRAM:.+]] =  #llvm.di_subprogram<compileUnit = #{{.*}}, scope = #{{.*}}, name = "noname_variable"
; CHECK-DAG: #[[LOCAL_VARIABLE:.+]] =  #llvm.di_local_variable<scope = #[[SUBPROGRAM]]>

define void @noname_variable(ptr %arg) {
  call void @llvm.dbg.value(metadata ptr %arg, metadata !7, metadata !DIExpression()), !dbg !9
  ret void
}

declare void @llvm.dbg.value(metadata, metadata, metadata)

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!7 = !DILocalVariable(scope: !8)
!8 = distinct !DISubprogram(name: "noname_variable", scope: !2, file: !2, unit: !1);
!9 = !DILocation(line: 1, column: 2, scope: !8)

; // -----

; CHECK: #[[SUBPROGRAM:.*]] = #llvm.di_subprogram<compileUnit = #{{.*}}, scope = #{{.*}}, file = #{{.*}}, subprogramFlags = Definition>
; CHECK: #[[FUNC_LOC:.*]] = loc(fused<#[[SUBPROGRAM]]>[{{.*}}])
define void @noname_subprogram(ptr %arg) !dbg !8 {
  ret void
}

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!8 = distinct !DISubprogram(scope: !2, file: !2, spFlags: DISPFlagDefinition, unit: !1);

; // -----

; CHECK:      #[[MODULE:.+]] = #llvm.di_module<
; CHECK-SAME: file = #{{.*}}, scope = #{{.*}}, name = "module", 
; CHECK-SAME: configMacros = "bar", includePath = "/",
; CHECK-SAME: apinotes = "/", line = 42, isDecl = true
; CHECK-SAME: >
; CHECK: #[[SUBPROGRAM:.+]] = #llvm.di_subprogram<compileUnit = #{{.*}}, scope = #[[MODULE]], name = "func_in_module"

define void @func_in_module(ptr %arg) !dbg !8 {
  ret void
}

!llvm.dbg.cu = !{!1}
!llvm.module.flags = !{!0}
!0 = !{i32 2, !"Debug Info Version", i32 3}
!1 = distinct !DICompileUnit(language: DW_LANG_C, file: !2)
!2 = !DIFile(filename: "debug-info.ll", directory: "/")
!8 = distinct !DISubprogram(name: "func_in_module", scope: !10, file: !2, unit: !1);
!10 = !DIModule(scope: !2, name: "module", configMacros: "bar", includePath: "/", apinotes: "/", file: !2, line: 42, isDecl: true)
