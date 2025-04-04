; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature
; RUN: opt < %s -passes=tailcallelim -verify-dom-info -S | FileCheck %s

; the test was generated from the following C++ source:
;
; #include <stdio.h>
; typedef struct A { long long x[10] = {0}; } A;
; A global;
; void dostuff(A a, A b, int i) {
;  if (i==10) return;
;  a.x[5]++;
;  printf("%lld %lld\n", a.x[5], b.x[5]); dostuff(b, a, i+1);
; }
; __attribute((optnone)) int main() { dostuff(global, global, 0); }
;
; This test checks that values for two ByValue operands are copied
; into temporarily variables first and then the temporaily
; variables are copied into original function arguments location.

%struct.A = type { [10 x i64] }

@global = dso_local local_unnamed_addr global %struct.A zeroinitializer, align 8
@.str = private unnamed_addr constant [11 x i8] c"%lld %lld\0A\00", align 1

; Function Attrs: noinline nounwind uwtable
define dso_local void @_Z7dostuff1AS_i(ptr nocapture byval(%struct.A) align 8 %a, ptr nocapture readonly byval(%struct.A) align 8 %b, i32 %i) local_unnamed_addr #0 {
; CHECK-LABEL: define {{[^@]+}}@_Z7dostuff1AS_i
; CHECK-SAME: (ptr byval([[STRUCT_A:%.*]]) align 8 captures(none) [[A:%.*]], ptr byval([[STRUCT_A]]) align 8 captures(none) [[B:%.*]], i32 [[I:%.*]]) local_unnamed_addr #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[AGG_TMP52:%.*]] = alloca [[STRUCT_A]], align 8
; CHECK-NEXT:    [[AGG_TMP1:%.*]] = alloca [[STRUCT_A]], align 8
; CHECK-NEXT:    [[AGG_TMP:%.*]] = alloca [[STRUCT_A]], align 8
; CHECK-NEXT:    [[AGG_TMP5:%.*]] = alloca [[STRUCT_A]], align 8
; CHECK-NEXT:    br label [[TAILRECURSE:%.*]]
; CHECK:       tailrecurse:
; CHECK-NEXT:    [[I_TR:%.*]] = phi i32 [ [[I]], [[ENTRY:%.*]] ], [ [[ADD:%.*]], [[IF_END:%.*]] ]
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[I_TR]], 10
; CHECK-NEXT:    br i1 [[CMP]], label [[RETURN:%.*]], label [[IF_END]]
; CHECK:       if.end:
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [[STRUCT_A]], ptr [[A]], i64 0, i32 0, i64 5
; CHECK-NEXT:    [[TMP0:%.*]] = load i64, ptr [[ARRAYIDX]], align 8
; CHECK-NEXT:    [[INC:%.*]] = add nsw i64 [[TMP0]], 1
; CHECK-NEXT:    store i64 [[INC]], ptr [[ARRAYIDX]], align 8
; CHECK-NEXT:    [[ARRAYIDX4:%.*]] = getelementptr inbounds [[STRUCT_A]], ptr [[B]], i64 0, i32 0, i64 5
; CHECK-NEXT:    [[TMP1:%.*]] = load i64, ptr [[ARRAYIDX4]], align 8
; CHECK-NEXT:    [[CALL:%.*]] = tail call i32 (ptr, ...) @printf(ptr nonnull dereferenceable(1) @.str, i64 [[INC]], i64 [[TMP1]])
; CHECK-NEXT:    call void @llvm.lifetime.start.p0(i64 80, ptr nonnull [[AGG_TMP]])
; CHECK-NEXT:    call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 8 dereferenceable(80) [[AGG_TMP]], ptr nonnull align 8 dereferenceable(80) [[B]], i64 80, i1 false)
; CHECK-NEXT:    call void @llvm.lifetime.start.p0(i64 80, ptr nonnull [[AGG_TMP5]])
; CHECK-NEXT:    call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 8 dereferenceable(80) [[AGG_TMP5]], ptr nonnull align 8 dereferenceable(80) [[A]], i64 80, i1 false)
; CHECK-NEXT:    [[ADD]] = add nsw i32 [[I_TR]], 1
; CHECK-NEXT:    call void @llvm.memcpy.p0.p0.i64(ptr align 8 [[AGG_TMP1]], ptr align 8 [[AGG_TMP]], i64 80, i1 false)
; CHECK-NEXT:    call void @llvm.memcpy.p0.p0.i64(ptr align 8 [[AGG_TMP52]], ptr align 8 [[AGG_TMP5]], i64 80, i1 false)
; CHECK-NEXT:    call void @llvm.memcpy.p0.p0.i64(ptr align 8 [[A]], ptr align 8 [[AGG_TMP1]], i64 80, i1 false)
; CHECK-NEXT:    call void @llvm.memcpy.p0.p0.i64(ptr align 8 [[B]], ptr align 8 [[AGG_TMP52]], i64 80, i1 false)
; CHECK-NEXT:    call void @llvm.lifetime.end.p0(i64 80, ptr nonnull [[AGG_TMP]])
; CHECK-NEXT:    call void @llvm.lifetime.end.p0(i64 80, ptr nonnull [[AGG_TMP5]])
; CHECK-NEXT:    br label [[TAILRECURSE]]
; CHECK:       return:
; CHECK-NEXT:    ret void
;
entry:
  %agg.tmp = alloca %struct.A, align 8
  %agg.tmp5 = alloca %struct.A, align 8
  %cmp = icmp eq i32 %i, 10
  br i1 %cmp, label %return, label %if.end

if.end:                                           ; preds = %entry
  %arrayidx = getelementptr inbounds %struct.A, ptr %a, i64 0, i32 0, i64 5
  %0 = load i64, ptr %arrayidx, align 8
  %inc = add nsw i64 %0, 1
  store i64 %inc, ptr %arrayidx, align 8
  %arrayidx4 = getelementptr inbounds %struct.A, ptr %b, i64 0, i32 0, i64 5
  %1 = load i64, ptr %arrayidx4, align 8
  %call = call i32 (ptr, ...) @printf(ptr nonnull dereferenceable(1) @.str
, i64 %inc, i64 %1)
  call void @llvm.lifetime.start.p0(i64 80, ptr nonnull %agg.tmp)
  call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 8 dereferenceable(80) %agg.tmp, ptr nonnull align 8 dereferenceable(80) %b, i64 80, i1 false)
  call void @llvm.lifetime.start.p0(i64 80, ptr nonnull %agg.tmp5)
  call void @llvm.memcpy.p0.p0.i64(ptr nonnull align 8 dereferenceable(80) %agg.tmp5, ptr nonnull align 8 dereferenceable(80) %a, i64 80, i1 false)
  %add = add nsw i32 %i, 1
  call void @_Z7dostuff1AS_i(ptr nonnull byval(%struct.A) align 8 %agg.tmp, ptr nonnull byval(%struct.A) align 8 %agg.tmp5, i32 %add)
  call void @llvm.lifetime.end.p0(i64 80, ptr nonnull %agg.tmp)
  call void @llvm.lifetime.end.p0(i64 80, ptr nonnull %agg.tmp5)
  br label %return

return:                                           ; preds = %entry, %if.end
  ret void
}

; Function Attrs: nofree nounwind
declare dso_local noundef i32 @printf(ptr nocapture noundef readonly, ...) local_unnamed_addr #1

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0.p0.i64(ptr noalias nocapture writeonly, ptr noalias nocapture readonly, i64, i1 immarg) #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #2

; Function Attrs: noinline norecurse nounwind optnone uwtable
define dso_local i32 @main() local_unnamed_addr #3 {
; CHECK-LABEL: define {{[^@]+}}@main() local_unnamed_addr {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[AGG_TMP:%.*]] = alloca [[STRUCT_A:%.*]], align 8
; CHECK-NEXT:    [[AGG_TMP1:%.*]] = alloca [[STRUCT_A]], align 8
; CHECK-NEXT:    call void @llvm.memcpy.p0.p0.i64(ptr align 8 [[AGG_TMP]], ptr align 8 @global, i64 80, i1 false)
; CHECK-NEXT:    call void @llvm.memcpy.p0.p0.i64(ptr align 8 [[AGG_TMP1]], ptr align 8 @global, i64 80, i1 false)
; CHECK-NEXT:    tail call void @_Z7dostuff1AS_i(ptr byval([[STRUCT_A]]) align 8 [[AGG_TMP]], ptr byval([[STRUCT_A]]) align 8 [[AGG_TMP1]], i32 0)
; CHECK-NEXT:    ret i32 0
;
entry:
  %agg.tmp = alloca %struct.A, align 8
  %agg.tmp1 = alloca %struct.A, align 8
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.tmp, ptr align 8 @global, i64 80, i1 false)
  call void @llvm.memcpy.p0.p0.i64(ptr align 8 %agg.tmp1, ptr align 8 @global, i64 80, i1 false)
  call void @_Z7dostuff1AS_i(ptr byval(%struct.A) align 8 %agg.tmp, ptr byval(%struct.A) align 8 %agg.tmp1, i32 0)
  ret i32 0
}

attributes #0 = { uwtable }
attributes #1 = { uwtable }
attributes #2 = { argmemonly nounwind willreturn }
