// RUN: %cheri128_purecap_cc1 -O0 -o - -emit-llvm %s -verify | FileCheck %s
// RUN: %cheri128_purecap_cc1 -DBUILTIN -O0 -o - -emit-llvm %s -verify | FileCheck %s

// If we are using -Werror this warning should not fail the build, only if it is explicitly added:
// RUN: %cheri128_purecap_cc1 -O0 -o /dev/null -emit-llvm %s -Werror 2> /dev/null
// RUN: not %cheri128_purecap_cc1 -O0 -o /dev/null -emit-llvm %s -Werror=cheri-misaligned 2>/dev/null

#ifdef BUILTIN
#define memcpy __builtin_memcpy
#define memmove __builtin_memmove
#else
void * memcpy(void *, const void *, unsigned long);
void * memmove(void *, const void *, unsigned long);
#endif

typedef __uintcap_t a;
void *b;

__uintcap_t get_cap(void);

void test_dst_unliagned_src_cap_memcpy(void* align1, short* align2, int* align4, long* align8, void** align_cap) {
  // CHECK-LABEL @test_dst_unliagned_src_cap_memcpy(
  a local_cap = get_cap();

  memcpy(align1, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{memcpy operation with capability argument 'a' (aka '__uintcap_t') and underaligned destination (aligned to 1 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 1 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB:#[0-9]+]]

  memcpy(align2, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{memcpy operation with capability argument 'a' (aka '__uintcap_t') and underaligned destination (aligned to 2 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 2 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]
  memcpy(align4, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{memcpy operation with capability argument 'a' (aka '__uintcap_t') and underaligned destination (aligned to 4 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 4 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]
  memcpy(align8, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{memcpy operation with capability argument 'a' (aka '__uintcap_t') and underaligned destination (aligned to 8 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 8 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]
  memcpy(align_cap, &local_cap, sizeof(local_cap)); // this is fine!
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 16 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
}

struct without_cap {
  char a;
  int b;
};

struct with_cap {
  struct without_cap a;
  void* cap;
};

void test_no_warn_for_non_caps(short* align2, int not_a_cap, __uintcap_t cap,
                               struct with_cap* struct_with_cap, struct without_cap* struct_without_cap) {
  // CHECK-LABEL @test_no_warn_for_non_caps(

  memcpy(align2, &not_a_cap, sizeof(not_a_cap));  // no warning
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 2 %{{.+}}, i8 addrspace(200)* align 4 %{{.+}}, i64 4, i1 false)

  memcpy(align2, struct_without_cap, sizeof(*struct_without_cap)); // no warning
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 2 %{{.+}}, i8 addrspace(200)* align 4 %{{.+}}, i64 8, i1 false)

  memcpy(align2, &cap, sizeof(cap));
  // expected-warning@-1{{memcpy operation with capability argument '__uintcap_t' and underaligned destination (aligned to 2 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 2 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]

  memcpy(align2, struct_with_cap, sizeof(*struct_with_cap));
  // expected-warning@-1{{memcpy operation with capability argument 'struct with_cap' and underaligned destination (aligned to 2 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 2 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 32, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]
}


void test_dst_unliagned_src_cap_memmove(void* align1, short* align2, int* align4, long* align8, void** align_cap) {
  // CHECK-LABEL @test_dst_unliagned_src_cap_memcpy(
  a local_cap = get_cap();

  memmove(align1, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{memmove operation with capability argument 'a' (aka '__uintcap_t') and underaligned destination (aligned to 1 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memmove.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 1 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]

  memmove(align2, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{memmove operation with capability argument 'a' (aka '__uintcap_t') and underaligned destination (aligned to 2 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memmove.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 2 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]

  memmove(align4, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{memmove operation with capability argument 'a' (aka '__uintcap_t') and underaligned destination (aligned to 4 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memmove.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 4 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]

  memmove(align8, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{memmove operation with capability argument 'a' (aka '__uintcap_t') and underaligned destination (aligned to 8 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memmove.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 8 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]

  memmove(align_cap, &local_cap, sizeof(local_cap)); // this is fine!
  // CHECK: call void @llvm.memmove.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 16 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
}

#define memcpy_chk(x,y,z) __builtin___memcpy_chk(x,y,z, __builtin_object_size(x,0))
#define memcpy_chk_inbounds(x,y,z) __builtin___memcpy_chk(x,y,z, z)
#define memmove_chk(x,y,z) __builtin___memmove_chk(x,y,z, __builtin_object_size(x,0))
#define memmove_chk_inbounds(x,y,z) __builtin___memmove_chk(x,y,z, z)

void test_memcpy_chk(void* align1, long* align8, void** align_cap) {
  // CHECK-LABEL @test_memcpy_chk(
  a local_cap = get_cap();
  memcpy_chk(align1, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{__memcpy_chk operation with capability argument 'a' (aka '__uintcap_t') and underaligned destination (aligned to 1 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call i8 addrspace(200)* @__memcpy_chk(
  memcpy_chk(align8, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{__memcpy_chk operation with capability argument 'a' (aka '__uintcap_t') and underaligned destination (aligned to 8 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call i8 addrspace(200)* @__memcpy_chk(

  memcpy_chk(align_cap, &local_cap, sizeof(local_cap)); // no warning
  // CHECK: call i8 addrspace(200)* @__memcpy_chk(

  // these are always turned into a memcpy:
  memcpy_chk_inbounds(align1, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{memcpy operation with capability argument 'a' (aka '__uintcap_t') and underaligned destination (aligned to 1 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 1 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]
  memcpy_chk_inbounds(align8, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{memcpy operation with capability argument 'a' (aka '__uintcap_t') and underaligned destination (aligned to 8 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 8 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]
  memcpy_chk_inbounds(align_cap, &local_cap, sizeof(local_cap));
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 16 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
}

void test_memmove_chk(void* align1, long* align8, void** align_cap) {
  // CHECK-LABEL @test_memmove_chk(
  a local_cap = get_cap();
  memmove_chk(align1, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{__memmove_chk operation with capability argument 'a' (aka '__uintcap_t') and underaligned destination (aligned to 1 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call i8 addrspace(200)* @__memmove_chk(
  memmove_chk(align8, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{__memmove_chk operation with capability argument 'a' (aka '__uintcap_t') and underaligned destination (aligned to 8 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call i8 addrspace(200)* @__memmove_chk(
  memmove_chk(align_cap, &local_cap, sizeof(local_cap)); // no warning
  // CHECK: call i8 addrspace(200)* @__memmove_chk(


  // these are always turned into a memmove:
  memmove_chk_inbounds(align1, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{memmove operation with capability argument 'a' (aka '__uintcap_t') and underaligned destination (aligned to 1 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memmove.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 1 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]

  memmove_chk_inbounds(align8, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{memmove operation with capability argument 'a' (aka '__uintcap_t') and underaligned destination (aligned to 8 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memmove.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 8 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]

  memmove_chk_inbounds(align_cap, &local_cap, sizeof(local_cap)); // no warning
  // CHECK: call void @llvm.memmove.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 16 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
}

void test_builtin_assume_aligned_fix(long *align8, char *align1, char *align1_again) {
  __uintcap_t local_cap = get_cap();

  memcpy(align8, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{memcpy operation with capability argument '__uintcap_t' and underaligned destination (aligned to 8 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 8 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]

  memmove(align8, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{memmove operation with capability argument '__uintcap_t' and underaligned destination (aligned to 8 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memmove.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 8 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]

  // should not warn if we add __builtin_assume_aligned or cast to __intcap_t
  memcpy(__builtin_assume_aligned(align8, sizeof(void *)), &local_cap, sizeof(local_cap));
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 16 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  memcpy((__intcap_t *)align8, &local_cap, sizeof(local_cap));
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 16 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  memmove(__builtin_assume_aligned(align8, sizeof(void *)), &local_cap, sizeof(local_cap));
  // CHECK: call void @llvm.memmove.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 16 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  memmove((__intcap_t *)align8, &local_cap, sizeof(local_cap));
  // CHECK: call void @llvm.memmove.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 16 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)

  // Check that we inferred align 8 in the warning here:
  memcpy(__builtin_assume_aligned(align8, sizeof(long)), &local_cap, sizeof(local_cap));
  // expected-warning@-1{{memcpy operation with capability argument '__uintcap_t' and underaligned destination (aligned to 8 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 8 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]

  // TODO: would be nice if it worked with an intermediate variable
  void *align4 = __builtin_assume_aligned(align1, 4);
  memcpy(align4, &local_cap, sizeof(local_cap));
  // expected-warning@-1{{memcpy operation with capability argument '__uintcap_t' and underaligned destination (aligned to 1 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 1 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]

  void *align32 = __builtin_assume_aligned(align1_again, 32);
  memcpy(align32, &local_cap, sizeof(local_cap)); // this is fine
  // expected-warning@-1{{memcpy operation with capability argument '__uintcap_t' and underaligned destination (aligned to 1 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 1 %{{.+}}, i8 addrspace(200)* align 16 %{{.+}}, i64 16, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]
}


extern __uintcap_t foo_array[10][2];
void test_no_crash_with_array(void) {
  char buffer[1234];
  memcpy(buffer, foo_array, sizeof(foo_array));
  // expected-warning@-1{{memcpy operation with capability argument '__uintcap_t' and underaligned destination (aligned to 1 bytes) may be inefficient or result in CHERI tags bits being stripped}}
  // expected-note@-2{{use __builtin_assume_aligned() or cast to __intcap_t*}}
  // CHECK: call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)*
  // CHECK-SAME: align 1 %{{.+}}, i8 addrspace(200)* align 16 {{.+}}, i64 320, i1 false)
  // CHECK-SAME: [[NOBUILTIN_ATTRIB]]
}

// CHECK: attributes [[NOBUILTIN_ATTRIB]] = { nobuiltin }
