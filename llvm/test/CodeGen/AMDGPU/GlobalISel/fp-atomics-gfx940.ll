; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=amdgcn -mcpu=gfx940 -global-isel -verify-machineinstrs | FileCheck %s -check-prefix=GFX940

declare float @llvm.amdgcn.flat.atomic.fadd.f32.p0.f32(ptr %ptr, float %data)
declare <2 x half> @llvm.amdgcn.flat.atomic.fadd.v2f16.p0.v2f16(ptr %ptr, <2 x half> %data)

define amdgpu_kernel void @flat_atomic_fadd_f32_noret(ptr %ptr, float %data) {
; GFX940-LABEL: flat_atomic_fadd_f32_noret:
; GFX940:       ; %bb.0:
; GFX940-NEXT:    s_load_dwordx2 s[0:1], s[2:3], 0x24
; GFX940-NEXT:    s_load_dword s4, s[2:3], 0x2c
; GFX940-NEXT:    s_waitcnt lgkmcnt(0)
; GFX940-NEXT:    v_mov_b64_e32 v[0:1], s[0:1]
; GFX940-NEXT:    v_mov_b32_e32 v2, s4
; GFX940-NEXT:    flat_atomic_add_f32 v[0:1], v2
; GFX940-NEXT:    s_endpgm
  %ret = call float @llvm.amdgcn.flat.atomic.fadd.f32.p0.f32(ptr %ptr, float %data)
  ret void
}

define amdgpu_kernel void @flat_atomic_fadd_f32_noret_pat(ptr %ptr) {
; GFX940-LABEL: flat_atomic_fadd_f32_noret_pat:
; GFX940:       ; %bb.0:
; GFX940-NEXT:    s_load_dwordx2 s[0:1], s[2:3], 0x24
; GFX940-NEXT:    v_mov_b32_e32 v2, 4.0
; GFX940-NEXT:    s_waitcnt lgkmcnt(0)
; GFX940-NEXT:    v_mov_b64_e32 v[0:1], s[0:1]
; GFX940-NEXT:    buffer_wbl2 sc0 sc1
; GFX940-NEXT:    flat_atomic_add_f32 v[0:1], v2 sc1
; GFX940-NEXT:    s_waitcnt vmcnt(0) lgkmcnt(0)
; GFX940-NEXT:    buffer_inv sc0 sc1
; GFX940-NEXT:    s_endpgm
  %ret = atomicrmw fadd ptr %ptr, float 4.0 seq_cst, !amdgpu.no.remote.memory !0
  ret void
}

define amdgpu_kernel void @flat_atomic_fadd_f32_noret_pat_ieee(ptr %ptr) #0 {
; GFX940-LABEL: flat_atomic_fadd_f32_noret_pat_ieee:
; GFX940:       ; %bb.0:
; GFX940-NEXT:    s_load_dwordx2 s[0:1], s[2:3], 0x24
; GFX940-NEXT:    v_mov_b32_e32 v2, 4.0
; GFX940-NEXT:    s_waitcnt lgkmcnt(0)
; GFX940-NEXT:    v_mov_b64_e32 v[0:1], s[0:1]
; GFX940-NEXT:    buffer_wbl2 sc0 sc1
; GFX940-NEXT:    flat_atomic_add_f32 v[0:1], v2 sc1
; GFX940-NEXT:    s_waitcnt vmcnt(0) lgkmcnt(0)
; GFX940-NEXT:    buffer_inv sc0 sc1
; GFX940-NEXT:    s_endpgm
  %ret = atomicrmw fadd ptr %ptr, float 4.0 seq_cst, !amdgpu.no.remote.memory !0
  ret void
}

define float @flat_atomic_fadd_f32_rtn(ptr %ptr, float %data) {
; GFX940-LABEL: flat_atomic_fadd_f32_rtn:
; GFX940:       ; %bb.0:
; GFX940-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX940-NEXT:    flat_atomic_add_f32 v0, v[0:1], v2 sc0
; GFX940-NEXT:    s_waitcnt vmcnt(0) lgkmcnt(0)
; GFX940-NEXT:    s_setpc_b64 s[30:31]
  %ret = call float @llvm.amdgcn.flat.atomic.fadd.f32.p0.f32(ptr %ptr, float %data)
  ret float %ret
}

define float @flat_atomic_fadd_f32_rtn_pat(ptr %ptr, float %data) {
; GFX940-LABEL: flat_atomic_fadd_f32_rtn_pat:
; GFX940:       ; %bb.0:
; GFX940-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX940-NEXT:    v_mov_b32_e32 v2, 4.0
; GFX940-NEXT:    buffer_wbl2 sc0 sc1
; GFX940-NEXT:    flat_atomic_add_f32 v0, v[0:1], v2 sc0 sc1
; GFX940-NEXT:    s_waitcnt vmcnt(0) lgkmcnt(0)
; GFX940-NEXT:    buffer_inv sc0 sc1
; GFX940-NEXT:    s_setpc_b64 s[30:31]
  %ret = atomicrmw fadd ptr %ptr, float 4.0 seq_cst, !amdgpu.no.remote.memory !0
  ret float %ret
}

define amdgpu_kernel void @flat_atomic_fadd_v2f16_noret(ptr %ptr, <2 x half> %data) {
; GFX940-LABEL: flat_atomic_fadd_v2f16_noret:
; GFX940:       ; %bb.0:
; GFX940-NEXT:    s_load_dwordx2 s[0:1], s[2:3], 0x24
; GFX940-NEXT:    s_load_dword s4, s[2:3], 0x2c
; GFX940-NEXT:    s_waitcnt lgkmcnt(0)
; GFX940-NEXT:    v_mov_b64_e32 v[0:1], s[0:1]
; GFX940-NEXT:    v_mov_b32_e32 v2, s4
; GFX940-NEXT:    flat_atomic_pk_add_f16 v[0:1], v2
; GFX940-NEXT:    s_endpgm
  %ret = call <2 x half> @llvm.amdgcn.flat.atomic.fadd.v2f16.p0.v2f16(ptr %ptr, <2 x half> %data)
  ret void
}

define <2 x half> @flat_atomic_fadd_v2f16_rtn(ptr %ptr, <2 x half> %data) {
; GFX940-LABEL: flat_atomic_fadd_v2f16_rtn:
; GFX940:       ; %bb.0:
; GFX940-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX940-NEXT:    flat_atomic_pk_add_f16 v0, v[0:1], v2 sc0
; GFX940-NEXT:    s_waitcnt vmcnt(0) lgkmcnt(0)
; GFX940-NEXT:    s_setpc_b64 s[30:31]
  %ret = call <2 x half> @llvm.amdgcn.flat.atomic.fadd.v2f16.p0.v2f16(ptr %ptr, <2 x half> %data)
  ret <2 x half> %ret
}

define <2 x half> @local_atomic_fadd_ret_v2f16_offset(ptr addrspace(3) %ptr, <2 x half> %val) {
; GFX940-LABEL: local_atomic_fadd_ret_v2f16_offset:
; GFX940:       ; %bb.0:
; GFX940-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX940-NEXT:    ds_pk_add_rtn_f16 v0, v0, v1 offset:65532
; GFX940-NEXT:    s_waitcnt lgkmcnt(0)
; GFX940-NEXT:    s_setpc_b64 s[30:31]
  %gep = getelementptr <2 x half>, ptr addrspace(3) %ptr, i32 16383
  %result = atomicrmw fadd ptr addrspace(3) %gep, <2 x half> %val seq_cst
  ret <2 x half> %result
}

define void @local_atomic_fadd_noret_v2f16_offset(ptr addrspace(3) %ptr, <2 x half> %val) {
; GFX940-LABEL: local_atomic_fadd_noret_v2f16_offset:
; GFX940:       ; %bb.0:
; GFX940-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX940-NEXT:    ds_pk_add_f16 v0, v1 offset:65532
; GFX940-NEXT:    s_waitcnt lgkmcnt(0)
; GFX940-NEXT:    s_setpc_b64 s[30:31]
  %gep = getelementptr <2 x half>, ptr addrspace(3) %ptr, i32 16383
  %unused = atomicrmw fadd ptr addrspace(3) %gep, <2 x half> %val seq_cst
  ret void
}

define <2 x half> @global_atomic_fadd_ret_v2f16_agent_offset(ptr addrspace(1) %ptr, <2 x half> %val) {
; GFX940-LABEL: global_atomic_fadd_ret_v2f16_agent_offset:
; GFX940:       ; %bb.0:
; GFX940-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX940-NEXT:    buffer_wbl2 sc1
; GFX940-NEXT:    global_atomic_pk_add_f16 v0, v[0:1], v2, off offset:1024 sc0
; GFX940-NEXT:    s_waitcnt vmcnt(0)
; GFX940-NEXT:    buffer_inv sc1
; GFX940-NEXT:    s_setpc_b64 s[30:31]
  %gep = getelementptr <2 x half>, ptr addrspace(1) %ptr, i32 256
  %result = atomicrmw fadd ptr addrspace(1) %gep, <2 x half> %val syncscope("agent") seq_cst
  ret <2 x half> %result
}

define void @global_atomic_fadd_noret_v2f16_agent_offset(ptr addrspace(1) %ptr, <2 x half> %val) {
; GFX940-LABEL: global_atomic_fadd_noret_v2f16_agent_offset:
; GFX940:       ; %bb.0:
; GFX940-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX940-NEXT:    buffer_wbl2 sc1
; GFX940-NEXT:    global_atomic_pk_add_f16 v[0:1], v2, off offset:1024
; GFX940-NEXT:    s_waitcnt vmcnt(0)
; GFX940-NEXT:    buffer_inv sc1
; GFX940-NEXT:    s_setpc_b64 s[30:31]
  %gep = getelementptr <2 x half>, ptr addrspace(1) %ptr, i32 256
  %unused = atomicrmw fadd ptr addrspace(1) %gep, <2 x half> %val syncscope("agent") seq_cst
  ret void
}

define <2 x half> @flat_atomic_fadd_ret_v2f16_agent_offset(ptr %ptr, <2 x half> %val) {
; GFX940-LABEL: flat_atomic_fadd_ret_v2f16_agent_offset:
; GFX940:       ; %bb.0:
; GFX940-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX940-NEXT:    buffer_wbl2 sc1
; GFX940-NEXT:    flat_atomic_pk_add_f16 v0, v[0:1], v2 offset:1024 sc0
; GFX940-NEXT:    s_waitcnt vmcnt(0) lgkmcnt(0)
; GFX940-NEXT:    buffer_inv sc1
; GFX940-NEXT:    s_setpc_b64 s[30:31]
  %gep = getelementptr <2 x half>, ptr %ptr, i32 256
  %result = atomicrmw fadd ptr %gep, <2 x half> %val syncscope("agent") seq_cst
  ret <2 x half> %result
}

define void @flat_atomic_fadd_noret_v2f16_agent_offset(ptr %ptr, <2 x half> %val) {
; GFX940-LABEL: flat_atomic_fadd_noret_v2f16_agent_offset:
; GFX940:       ; %bb.0:
; GFX940-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX940-NEXT:    buffer_wbl2 sc1
; GFX940-NEXT:    flat_atomic_pk_add_f16 v[0:1], v2 offset:1024
; GFX940-NEXT:    s_waitcnt vmcnt(0) lgkmcnt(0)
; GFX940-NEXT:    buffer_inv sc1
; GFX940-NEXT:    s_setpc_b64 s[30:31]
  %gep = getelementptr <2 x half>, ptr %ptr, i32 256
  %unused = atomicrmw fadd ptr %gep, <2 x half> %val syncscope("agent") seq_cst
  ret void
}

attributes #0 = { "denormal-fp-math-f32"="ieee,ieee" }

!0 = !{}
