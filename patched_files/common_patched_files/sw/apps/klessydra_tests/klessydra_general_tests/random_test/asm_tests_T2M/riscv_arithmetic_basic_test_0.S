.include "user_define.h"
.globl _start
.section .text
.option norvc;
_start:           
                  .include "user_init.s"
                  csrr x5, 0xf14
                  li x6, 0
                  beq x5, x6, 0f

0: la x10, h0_start
jalr x0, x10, 0
h0_start:
                  li x17, 0x40001100
                  csrw 0x301, x17
kernel_sp:        
                  la x15, kernel_stack_end

trap_vec_init:    
                  la x17, mtvec_handler
                  ori x17, x17, 0
                  csrw 0x305, x17 # MTVEC

mepc_setup:       
                  la x17, init
                  csrw 0x341, x17

custom_csr_setup: 
                  nop

init_machine_mode:
                  li x17, 0x1800
                  csrw 0x300, x17 # MSTATUS
                  mret
init:             
                  li x0, 0xf5b58eca
                  li x1, 0xf6d1b93a
                  li x2, 0xf9159e5f
                  li x3, 0x4
                  li x4, 0x0
                  li x5, 0x2
                  li x6, 0xf13f093f
                  li x7, 0x80000000
                  li x8, 0x6
                  li x9, 0x0
                  li x10, 0x0
                  li x11, 0x91184c9b
                  li x12, 0x80000000
                  li x13, 0x0
                  li x14, 0xfc2a8ada
                  li x16, 0x80000000
                  li x17, 0x0
                  li x18, 0xf15dba39
                  li x19, 0x80000000
                  li x20, 0xc
                  li x21, 0xfc6f1e5b
                  li x22, 0x80000000
                  li x23, 0xb358cfe1
                  li x24, 0x0
                  li x25, 0x80000000
                  li x26, 0x0
                  li x28, 0x2dfa8ee0
                  li x29, 0xf273cc8f
                  li x30, 0x389711e7
                  li x31, 0xf854891a
                  la x27, user_stack_end
main:             li         a1, 0x0 #start riscv_int_numeric_corner_stream_39
                  li         t2, 0x0
                  li         s7, 0xffffffff
                  li         t1, 0x80000000
                  li         s8, 0xffffffff
                  li         s5, 0x0
                  li         a6, 0x0
                  li         a4, 0x80000000
                  li         s9, 0x0
                  li         s6, 0x80000000
                  auipc      s9, 925829
                  mulhsu     s6, a1, s5
                  remu       s8, s5, a4
                  divu       t2, a4, a6
                  divu       t2, a4, a6
                  remu       s8, s5, a4
                  lui        a6, 496523
                  remu       s8, s5, a4
                  auipc      s9, 925829
                  mulh       t1, s6, a4
                  lui        a6, 496523
                  mul        s5, s7, s5
                  div        t1, t2, s8
                  nop
                  add        a6, a4, s5
                  sub        t2, s6, t1
                  remu       s8, s5, a4
                  add        a6, a4, s5
                  rem        s5, s6, t2
                  auipc      s9, 925829
                  remu       s8, s5, a4 #end riscv_int_numeric_corner_stream_39
                  li         s10, 0xffffffff #start riscv_int_numeric_corner_stream_4
                  li         t5, 0xc3952e00
                  li         s0, 0xffffffff
                  li         s3, 0xb1920382
                  li         a6, 0x80000000
                  li         a7, 0x0
                  li         s7, 0x80000000
                  li         tp, 0xffffffff
                  li         a3, 0xa4dbb478
                  li         t4, 0xff61b13d
                  auipc      t5, 925829
                  lui        a7, 496523
                  nop
                  divu       s0, a6, a7
                  lui        a7, 496523
                  add        a7, a6, s3
                  add        a7, a6, s3
                  remu       t4, s3, a6
                  add        a7, a6, s3
                  mulhu      t5, t5, a3
                  sub        s0, s7, tp
                  remu       t4, s3, a6
                  auipc      t5, 925829
                  mulhsu     s7, a3, s3
                  add        a7, a6, s3
                  remu       t4, s3, a6
                  mulh       tp, s7, a6
                  div        tp, s0, t4
                  mulhsu     s7, a3, s3
                  mulh       tp, s7, a6
                  sub        s0, s7, tp
                  nop
                  auipc      t5, 925829 #end riscv_int_numeric_corner_stream_4
                  li         s8, 0x0 #start riscv_int_numeric_corner_stream_7
                  li         t6, 0x80000000
                  li         s0, 0xffffffff
                  li         a3, 0x939aa700
                  li         sp, 0xffffffff
                  li         s10, 0xe726e40c
                  li         s5, 0x0
                  li         a1, 0x0
                  li         a7, 0x80000000
                  li         ra, 0x0
                  div        ra, sp, s10
                  mul        a7, s8, a7
                  div        ra, sp, s10
                  mulhsu     s5, s0, a7
                  divu       sp, a1, a3
                  addi       sp, sp, 677
                  div        ra, sp, s10
                  remu       s10, a7, a1
                  mulh       ra, s5, a1
                  sub        sp, s5, ra
                  auipc      t6, 925829
                  remu       s10, a7, a1
                  sub        sp, s5, ra
                  nop
                  mulh       ra, s5, a1 #end riscv_int_numeric_corner_stream_7
                  li         t1, 0x949df400 #start riscv_int_numeric_corner_stream_17
                  li         a4, 0x0
                  li         s6, 0xffffffff
                  li         sp, 0xa435ec3a
                  li         s7, 0xca670019
                  li         t5, 0x0
                  li         a3, 0x80000000
                  li         s3, 0x80000000
                  li         gp, 0x0
                  li         t4, 0x80000000
                  divu       gp, a3, a4
                  mulhsu     s6, t1, s3
                  rem        s3, s6, gp
                  div        sp, gp, t4
                  rem        s3, s6, gp
                  lui        a4, 496523
                  mulh       sp, s6, a3
                  mulhu      t5, t5, t1
                  auipc      t5, 925829
                  div        sp, gp, t4
                  mul        s3, s7, s3
                  sub        gp, s6, sp
                  mulhsu     s6, t1, s3
                  mulhsu     s6, t1, s3
                  sub        gp, s6, sp
                  mulhu      t5, t5, t1
                  divu       gp, a3, a4
                  divu       gp, a3, a4
                  mulh       sp, s6, a3
                  nop
                  mulhsu     s6, t1, s3
                  div        sp, gp, t4
                  mul        s3, s7, s3
                  remu       t4, s3, a3
                  sub        gp, s6, sp
                  auipc      t5, 925829
                  mulh       sp, s6, a3 #end riscv_int_numeric_corner_stream_17
                  li         s1, 0x80000000 #start riscv_int_numeric_corner_stream_38
                  li         tp, 0x300132c9
                  li         s8, 0x80000000
                  li         t2, 0x0
                  li         a6, 0x80000000
                  li         s9, 0xffffffff
                  li         gp, 0xc8e27e21
                  li         t6, 0x0
                  li         s4, 0x0
                  li         ra, 0x80000000
                  add        s1, t2, a6
                  remu       s9, a6, t2
                  nop
                  remu       s9, a6, t2
                  divu       gp, t2, s1
                  addi       gp, gp, 677
                  mul        a6, s8, a6
                  mulh       ra, s4, t2
                  divu       gp, t2, s1
                  div        ra, gp, s9
                  mulhsu     s4, tp, a6
                  nop
                  mulhu      t6, t6, tp
                  mulhu      t6, t6, tp
                  mul        a6, s8, a6 #end riscv_int_numeric_corner_stream_38
                  li         t4, 0x1b00cc5 #start riscv_int_numeric_corner_stream_22
                  li         s10, 0x0
                  li         sp, 0xffffffff
                  li         s9, 0x0
                  li         tp, 0x0
                  li         a6, 0x80000000
                  li         a7, 0x0
                  li         s0, 0x150c02dd
                  li         t1, 0x80000000
                  li         t2, 0xffffffff
                  mul        a6, s9, a6
                  auipc      t4, 925829
                  add        s0, t2, a6
                  div        sp, tp, s10
                  nop
                  mul        a6, s9, a6
                  mulh       sp, a7, t2
                  sub        tp, a7, sp
                  lui        s0, 496523
                  nop
                  add        s0, t2, a6
                  mulhsu     a7, t1, a6
                  mulhsu     a7, t1, a6
                  mulhsu     a7, t1, a6
                  auipc      t4, 925829
                  divu       tp, t2, s0
                  auipc      t4, 925829 #end riscv_int_numeric_corner_stream_22
                  li         s4, 0x0 #start riscv_int_numeric_corner_stream_30
                  li         a6, 0x80000000
                  li         a7, 0x0
                  li         s1, 0x5e4f9189
                  li         tp, 0x6574f6c1
                  li         t2, 0xffffffff
                  li         ra, 0x0
                  li         s3, 0xffffffff
                  li         s5, 0x80000000
                  li         t1, 0x80000000
                  add        s1, t2, a6
                  auipc      s5, 925829
                  add        s1, t2, a6
                  add        s1, t2, a6
                  mulhu      s5, s5, t1
                  auipc      s5, 925829
                  remu       s4, a6, t2
                  rem        a6, a7, tp
                  divu       tp, t2, s1
                  mulhu      s5, s5, t1
                  nop
                  div        ra, tp, s4
                  add        s1, t2, a6
                  rem        a6, a7, tp
                  addi       tp, tp, 677 #end riscv_int_numeric_corner_stream_30
                  li         s8, 0xffffffff #start riscv_int_numeric_corner_stream_15
                  li         a6, 0x0
                  li         t5, 0x0
                  li         t1, 0x9557bab2
                  li         a1, 0x0
                  li         s1, 0x80000000
                  li         a4, 0x0
                  li         s5, 0xffffffff
                  li         s6, 0x80000000
                  li         t2, 0xffffffff
                  nop
                  rem        a6, s5, t2
                  nop
                  mulhsu     s5, s1, a6
                  rem        a6, s5, t2
                  divu       t2, a1, a4
                  remu       s8, a6, a1
                  sub        t2, s5, t1
                  div        t1, t2, s8
                  addi       t2, t2, 677
                  add        a4, a1, a6
                  auipc      t5, 925829
                  divu       t2, a1, a4
                  div        t1, t2, s8
                  lui        a4, 496523
                  lui        a4, 496523 #end riscv_int_numeric_corner_stream_15
                  li         t4, 0x18d8a536 #start riscv_int_numeric_corner_stream_16
                  li         s5, 0x1e797432
                  li         gp, 0x0
                  li         s7, 0xe749fe4d
                  li         a6, 0xffffffff
                  li         s3, 0x80000000
                  li         s9, 0x0
                  li         a4, 0x80000000
                  li         t5, 0x0
                  li         s1, 0xb898afe3
                  mulh       gp, s7, a6
                  mul        s5, s9, s5
                  addi       s1, s1, 677
                  sub        s1, s7, gp
                  mulhu      t5, t5, a4
                  divu       s1, a6, s3
                  mul        s5, s9, s5
                  add        s3, a6, s5
                  mulh       gp, s7, a6
                  div        gp, s1, t4
                  addi       s1, s1, 677
                  mulhu      t5, t5, a4
                  mulhsu     s7, a4, s5
                  mul        s5, s9, s5
                  mulh       gp, s7, a6
                  add        s3, a6, s5
                  remu       t4, s5, a6 #end riscv_int_numeric_corner_stream_16
                  li         s6, 0xffffffff #start riscv_int_numeric_corner_stream_25
                  li         s5, 0x0
                  li         s9, 0xffffffff
                  li         t5, 0xddd58842
                  li         s10, 0xffffffff
                  li         t4, 0xffffffff
                  li         t2, 0x80000000
                  li         t3, 0x2c930cb3
                  li         s2, 0x0
                  li         s0, 0x0
                  lui        s6, 496523
                  mulhu      t5, t5, s2
                  div        t2, s0, t4
                  addi       s0, s0, 677
                  lui        s6, 496523
                  mulhsu     s10, s2, s9
                  mul        s9, t3, s9
                  nop
                  remu       t4, s9, s5
                  remu       t4, s9, s5
                  mulh       t2, s10, s5
                  sub        s0, s10, t2
                  divu       s0, s5, s6
                  mul        s9, t3, s9
                  rem        s9, s10, s0
                  nop
                  nop
                  mul        s9, t3, s9
                  mulhu      t5, t5, s2
                  add        s6, s5, s9
                  mul        s9, t3, s9
                  mulh       t2, s10, s5
                  auipc      t5, 925829
                  mulh       t2, s10, s5
                  addi       s0, s0, 677
                  remu       t4, s9, s5
                  add        s6, s5, s9
                  add        s6, s5, s9
                  mulhu      t5, t5, s2 #end riscv_int_numeric_corner_stream_25
                  li         s7, 0x80000000 #start riscv_int_numeric_corner_stream_13
                  li         a4, 0x0
                  li         s3, 0x80000000
                  li         t0, 0x80000000
                  li         t5, 0xffffffff
                  li         a6, 0x80000000
                  li         s10, 0x0
                  li         s2, 0xffffffff
                  li         a3, 0xd3d245fa
                  li         t2, 0x2a800afa
                  auipc      t5, 925829
                  add        a6, a4, s2
                  mul        s2, s7, s2
                  addi       t2, t2, 677
                  lui        a6, 496523
                  remu       s10, s2, a4
                  remu       s10, s2, a4
                  addi       t2, t2, 677
                  div        t0, t2, s10
                  mulh       t0, s3, a4
                  mulhsu     s3, a3, s2
                  addi       t2, t2, 677
                  divu       t2, a4, a6
                  mulhu      t5, t5, a3
                  mulh       t0, s3, a4
                  auipc      t5, 925829
                  mulh       t0, s3, a4
                  nop #end riscv_int_numeric_corner_stream_13
                  li         s6, 0xaaf4d2a0 #start riscv_int_numeric_corner_stream_10
                  li         tp, 0x0
                  li         s10, 0x0
                  li         t6, 0x41f492e4
                  li         t4, 0xffffffff
                  li         t5, 0xffffffff
                  li         s8, 0xffffffff
                  li         s1, 0xffffffff
                  li         a2, 0xffffffff
                  li         t3, 0x72c0d11f
                  nop
                  mulh       tp, t3, s6
                  mulhsu     t3, a2, s10
                  mul        s10, t4, s10
                  addi       s1, s1, 677
                  rem        s10, t3, s1
                  add        s8, s6, s10
                  mulhsu     t3, a2, s10
                  sub        s1, t3, tp
                  lui        s8, 496523
                  divu       s1, s6, s8
                  nop
                  mulhu      t6, t6, a2
                  auipc      t6, 925829
                  remu       t5, s10, s6
                  div        tp, s1, t5
                  mul        s10, t4, s10
                  mulhsu     t3, a2, s10
                  divu       s1, s6, s8
                  mul        s10, t4, s10
                  mul        s10, t4, s10
                  auipc      t6, 925829
                  rem        s10, t3, s1
                  lui        s8, 496523
                  nop
                  mulh       tp, t3, s6
                  sub        s1, t3, tp
                  mul        s10, t4, s10 #end riscv_int_numeric_corner_stream_10
                  li         t2, 0xb5285a40 #start riscv_int_numeric_corner_stream_28
                  li         s2, 0x0
                  li         t1, 0x80000000
                  li         s8, 0xffffffff
                  li         t5, 0x80000000
                  li         s3, 0xffffffff
                  li         ra, 0xffffffff
                  li         t3, 0x8da3f5e0
                  li         s0, 0x165e1325
                  li         a1, 0x80000000
                  auipc      t5, 925829
                  addi       t1, t1, 677
                  add        a1, s0, s2
                  mulh       ra, s3, s0
                  lui        a1, 496523
                  mulhu      t5, t5, t2
                  mulhu      t5, t5, t2
                  mulh       ra, s3, s0
                  divu       t1, s0, a1
                  mulh       ra, s3, s0
                  mul        s2, s8, s2
                  mulh       ra, s3, s0
                  div        ra, t1, t3
                  nop
                  mul        s2, s8, s2
                  mul        s2, s8, s2
                  mulh       ra, s3, s0
                  divu       t1, s0, a1
                  mul        s2, s8, s2
                  remu       t3, s2, s0
                  lui        a1, 496523
                  remu       t3, s2, s0 #end riscv_int_numeric_corner_stream_28
                  li         t3, 0xffffffff #start riscv_int_numeric_corner_stream_26
                  li         ra, 0xffffffff
                  li         gp, 0x0
                  li         s10, 0x0
                  li         s4, 0xffffffff
                  li         a6, 0x80000000
                  li         s5, 0xa476fa3a
                  li         t6, 0x80000000
                  li         s2, 0x1bdc47f7
                  li         a1, 0xc444c825
                  nop
                  sub        gp, s5, ra
                  auipc      t6, 925829
                  mulh       ra, s5, a6
                  nop
                  rem        s4, s5, gp
                  auipc      t6, 925829
                  nop
                  mulh       ra, s5, a6
                  add        s2, a6, s4
                  rem        s4, s5, gp
                  divu       gp, a6, s2
                  auipc      t6, 925829
                  divu       gp, a6, s2
                  rem        s4, s5, gp
                  addi       gp, gp, 677
                  mulh       ra, s5, a6
                  divu       gp, a6, s2
                  auipc      t6, 925829
                  rem        s4, s5, gp
                  sub        gp, s5, ra
                  auipc      t6, 925829
                  div        ra, gp, t3
                  remu       t3, s4, a6 #end riscv_int_numeric_corner_stream_26
                  li         a4, 0xffffffff #start riscv_int_numeric_corner_stream_21
                  li         a3, 0x0
                  li         t1, 0x58228cea
                  li         a7, 0xffffffff
                  li         ra, 0x0
                  li         t4, 0xffffffff
                  li         gp, 0x0
                  li         a6, 0xffffffff
                  li         a1, 0xffffffff
                  li         s10, 0x80000000
                  div        ra, gp, s10
                  remu       s10, a4, a1
                  rem        a4, a6, gp
                  mulh       ra, a6, a1
                  rem        a4, a6, gp
                  rem        a4, a6, gp
                  mul        a4, a7, a4
                  divu       gp, a1, a3
                  sub        gp, a6, ra
                  auipc      t4, 925829
                  sub        gp, a6, ra
                  mul        a4, a7, a4
                  mul        a4, a7, a4
                  divu       gp, a1, a3
                  rem        a4, a6, gp
                  div        ra, gp, s10
                  divu       gp, a1, a3
                  mulhu      t4, t4, t1
                  rem        a4, a6, gp #end riscv_int_numeric_corner_stream_21
                  li         t3, 0xffffffff #start riscv_int_numeric_corner_stream_34
                  li         a1, 0x80000000
                  li         a2, 0x48c421d6
                  li         a3, 0xaaa29ae6
                  li         s6, 0x5744a9a5
                  li         t6, 0xd06bc581
                  li         t0, 0x502d12be
                  li         tp, 0x0
                  li         s8, 0xffffffff
                  li         s0, 0x80000000
                  lui        a2, 496523
                  lui        a2, 496523
                  sub        t0, s6, tp
                  mulhsu     s6, s0, a3
                  mulhsu     s6, s0, a3
                  divu       t0, a1, a2
                  mulh       tp, s6, a1
                  remu       t3, a3, a1
                  rem        a3, s6, t0
                  sub        t0, s6, tp
                  rem        a3, s6, t0
                  div        tp, t0, t3
                  nop
                  add        a2, a1, a3
                  lui        a2, 496523
                  addi       t0, t0, 677
                  auipc      t6, 925829
                  mulh       tp, s6, a1
                  nop
                  mul        a3, s8, a3
                  mulh       tp, s6, a1
                  rem        a3, s6, t0
                  mulhu      t6, t6, s0
                  remu       t3, a3, a1
                  nop
                  mulhsu     s6, s0, a3 #end riscv_int_numeric_corner_stream_34
                  li         s3, 0xcfa8ea6 #start riscv_int_numeric_corner_stream_20
                  li         ra, 0x0
                  li         a1, 0xbaaf2f3
                  li         s7, 0x80000000
                  li         s5, 0x80000000
                  li         a3, 0xffffffff
                  li         t1, 0x80000000
                  li         s0, 0xffffffff
                  li         t0, 0x0
                  li         t4, 0x80000000
                  mulhsu     s3, t1, a3
                  divu       t0, s0, a1
                  divu       t0, s0, a1
                  remu       s7, a3, s0
                  auipc      t4, 925829
                  div        ra, t0, s7
                  nop
                  mulh       ra, s3, s0
                  mulhsu     s3, t1, a3
                  addi       t0, t0, 677
                  mulh       ra, s3, s0
                  div        ra, t0, s7
                  sub        t0, s3, ra
                  mulhu      t4, t4, t1
                  mulh       ra, s3, s0
                  remu       s7, a3, s0
                  mul        a3, s5, a3
                  addi       t0, t0, 677
                  div        ra, t0, s7
                  nop #end riscv_int_numeric_corner_stream_20
                  li         a4, 0x80000000 #start riscv_int_numeric_corner_stream_27
                  li         t2, 0x0
                  li         s9, 0x80000000
                  li         tp, 0xffffffff
                  li         t3, 0x80000000
                  li         a2, 0x0
                  li         t6, 0xffffffff
                  li         t1, 0x0
                  li         t5, 0x80000000
                  li         a1, 0xffffffff
                  mulh       tp, s9, a1
                  remu       t5, a4, a1
                  divu       t1, a1, a2
                  lui        a2, 496523
                  mulh       tp, s9, a1
                  divu       t1, a1, a2
                  sub        t1, s9, tp
                  lui        a2, 496523
                  remu       t5, a4, a1
                  rem        a4, s9, t1
                  add        a2, a1, a4
                  divu       t1, a1, a2
                  div        tp, t1, t5
                  divu       t1, a1, a2
                  lui        a2, 496523
                  divu       t1, a1, a2
                  lui        a2, 496523
                  remu       t5, a4, a1
                  nop
                  mulh       tp, s9, a1
                  mulhu      t6, t6, t2
                  lui        a2, 496523
                  lui        a2, 496523
                  divu       t1, a1, a2
                  rem        a4, s9, t1
                  mulhsu     s9, t2, a4
                  lui        a2, 496523
                  addi       t1, t1, 677
                  mulh       tp, s9, a1 #end riscv_int_numeric_corner_stream_27
                  li         t6, 0x0 #start riscv_int_numeric_corner_stream_2
                  li         s5, 0xffffffff
                  li         t4, 0x0
                  li         t2, 0x0
                  li         sp, 0x0
                  li         a3, 0x80000000
                  li         a1, 0xaf9beb1d
                  li         s8, 0x0
                  li         s3, 0x98985ea6
                  li         t3, 0x0
                  lui        s3, 496523
                  mul        s5, t3, s5
                  rem        s5, s8, t2
                  divu       t2, a3, s3
                  mulhsu     s8, a1, s5
                  rem        s5, s8, t2
                  addi       t2, t2, 677
                  addi       t2, t2, 677
                  add        s3, a3, s5
                  nop
                  nop
                  lui        s3, 496523
                  rem        s5, s8, t2
                  rem        s5, s8, t2
                  div        sp, t2, t4
                  remu       t4, s5, a3
                  remu       t4, s5, a3
                  div        sp, t2, t4
                  rem        s5, s8, t2
                  mulhsu     s8, a1, s5
                  mulhsu     s8, a1, s5
                  nop
                  mulhsu     s8, a1, s5
                  mulhsu     s8, a1, s5
                  sub        t2, s8, sp
                  rem        s5, s8, t2
                  addi       t2, t2, 677
                  mulh       sp, s8, a3 #end riscv_int_numeric_corner_stream_2
                  li         sp, 0xffffffff #start riscv_int_numeric_corner_stream_11
                  li         t6, 0x0
                  li         t3, 0xffffffff
                  li         s9, 0x0
                  li         s0, 0x5385e0d7
                  li         s4, 0x0
                  li         a6, 0xe33e7841
                  li         t5, 0x9f70a34c
                  li         t1, 0x80000000
                  li         s2, 0x0
                  nop
                  sub        t1, s9, sp
                  mul        s4, t3, s4
                  mul        s4, t3, s4
                  auipc      t6, 925829
                  auipc      t6, 925829
                  mulh       sp, s9, a6
                  mulhsu     s9, s0, s4
                  addi       t1, t1, 677
                  addi       t1, t1, 677
                  mulhsu     s9, s0, s4
                  mulh       sp, s9, a6
                  mul        s4, t3, s4
                  rem        s4, s9, t1
                  div        sp, t1, t5
                  rem        s4, s9, t1
                  add        s2, a6, s4
                  div        sp, t1, t5
                  auipc      t6, 925829
                  div        sp, t1, t5
                  addi       t1, t1, 677
                  mul        s4, t3, s4
                  remu       t5, s4, a6
                  mulhu      t6, t6, s0
                  addi       t1, t1, 677
                  mul        s4, t3, s4 #end riscv_int_numeric_corner_stream_11
                  li         s8, 0x0 #start riscv_int_numeric_corner_stream_18
                  li         ra, 0x7e57c468
                  li         s4, 0x0
                  li         s9, 0x47bde5e
                  li         s3, 0x80000000
                  li         a4, 0xabacc305
                  li         t6, 0x3a3ae096
                  li         a1, 0x0
                  li         a2, 0xffffffff
                  li         s5, 0x1cc8357c
                  mulhu      t6, t6, a2
                  mulh       ra, s5, a4
                  lui        s3, 496523
                  lui        s3, 496523
                  remu       s9, s4, a4
                  mul        s4, s8, s4
                  sub        a1, s5, ra
                  rem        s4, s5, a1
                  mulhu      t6, t6, a2
                  remu       s9, s4, a4
                  mulhu      t6, t6, a2
                  remu       s9, s4, a4
                  mulhu      t6, t6, a2
                  mulh       ra, s5, a4
                  remu       s9, s4, a4 #end riscv_int_numeric_corner_stream_18
                  li         s5, 0x0 #start riscv_int_numeric_corner_stream_35
                  li         s8, 0xa9132828
                  li         sp, 0xffffffff
                  li         s10, 0x11771777
                  li         t5, 0xd664df54
                  li         a1, 0x0
                  li         t4, 0x0
                  li         t6, 0xffffffff
                  li         s3, 0x80000000
                  li         a3, 0x0
                  mulhsu     s10, a3, s8
                  nop
                  mulh       sp, s10, s3
                  auipc      t6, 925829
                  divu       a1, s3, s5
                  mulhsu     s10, a3, s8
                  mul        s8, t4, s8
                  remu       t5, s8, s3
                  lui        s5, 496523
                  addi       a1, a1, 677
                  lui        s5, 496523
                  divu       a1, s3, s5
                  divu       a1, s3, s5
                  sub        a1, s10, sp
                  mul        s8, t4, s8
                  mulhsu     s10, a3, s8 #end riscv_int_numeric_corner_stream_35
                  srai       s8, t0, 25
                  lui        s6, 496523
                  divu       s3, gp, a2
                  srli       t6, t5, 10
                  sra        t1, t1, a0
                  mulh       s2, t1, a3
                  sub        ra, t1, s11
                  slt        a1, a1, zero
                  sub        ra, t1, s11
                  srai       s8, t0, 25
                  srli       t6, t5, 10
                  remu       s0, t0, gp
                  sltiu      a2, a0, -848
                  nop
                  srli       t6, t5, 10
                  mulhu      s1, s9, a1
                  nop
                  divu       s3, gp, a2
                  div        zero, a7, s0
                  sra        t1, t1, a0
                  nop
                  ori        t1, ra, -664
                  sub        ra, t1, s11
                  slt        a1, a1, zero
                  or         a7, a0, zero
                  slli       tp, t1, 9
                  xor        a4, a2, s0
                  div        zero, a7, s0
                  divu       s3, gp, a2
                  nop
                  auipc      a4, 925829
                  sll        s10, sp, a0
                  div        zero, a7, s0
                  sub        ra, t1, s11
                  mulhsu     s8, sp, s5
                  auipc      a4, 925829
                  sub        ra, t1, s11
                  slti       s10, s8, -890
                  sltiu      a2, a0, -848
                  addi       s3, a2, 677
                  rem        a6, s6, a7
                  slli       tp, t1, 9
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  lui        s6, 496523
                  mulhu      s1, s9, a1
                  and        sp, s3, s5
                  slli       tp, t1, 9
                  sltiu      a2, a0, -848
                  srl        zero, t1, a4
                  sltu       t3, t1, tp
                  slti       s10, s8, -890
                  sltiu      a2, a0, -848
                  or         a7, a0, zero
                  slli       tp, t1, 9
                  andi       gp, s9, -46
                  xor        a4, a2, s0
                  xori       s3, s8, -101
                  div        zero, a7, s0
                  srai       s8, t0, 25
                  mulhu      s1, s9, a1
                  sra        t1, t1, a0
                  mulh       s2, t1, a3
                  srli       t6, t5, 10
                  remu       s0, t0, gp
                  or         a7, a0, zero
                  xori       s3, s8, -101
                  add        tp, gp, s11
                  mul        a6, t2, s5
                  or         a7, a0, zero
                  srai       s8, t0, 25
                  divu       s3, gp, a2
                  remu       s0, t0, gp
                  srli       t6, t5, 10
                  slli       tp, t1, 9
                  andi       gp, s9, -46
                  srai       s8, t0, 25
                  and        sp, s3, s5
                  slli       tp, t1, 9
                  rem        a6, s6, a7
                  sltu       t3, t1, tp
                  slt        a1, a1, zero
                  srli       t6, t5, 10
                  xori       s3, s8, -101
                  andi       gp, s9, -46
                  xori       s3, s8, -101
                  divu       s3, gp, a2
                  srl        zero, t1, a4
                  sra        t1, t1, a0
                  srli       t6, t5, 10
                  sra        t1, t1, a0
                  sll        s10, sp, a0
                  mulh       s2, t1, a3
                  divu       s3, gp, a2
                  sra        t1, t1, a0
                  xori       s3, s8, -101
                  sltu       t3, t1, tp
                  andi       gp, s9, -46
                  and        sp, s3, s5
                  sub        ra, t1, s11
                  rem        a6, s6, a7
                  xori       s3, s8, -101
                  xor        a4, a2, s0
                  lui        s6, 496523
                  slt        a1, a1, zero
                  and        sp, s3, s5
                  nop
                  sltu       t3, t1, tp
                  mul        a6, t2, s5
                  sltiu      a2, a0, -848
                  srli       t6, t5, 10
                  srai       s8, t0, 25
                  slli       tp, t1, 9
                  remu       s0, t0, gp
                  divu       s3, gp, a2
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  sra        t1, t1, a0
                  rem        a6, s6, a7
                  or         a7, a0, zero
                  sra        t1, t1, a0
                  mul        a6, t2, s5
                  slli       tp, t1, 9
                  sub        ra, t1, s11
                  sra        t1, t1, a0
                  or         a7, a0, zero
                  rem        a6, s6, a7
                  and        sp, s3, s5
                  and        sp, s3, s5
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  srli       t6, t5, 10
                  mulhu      s1, s9, a1
                  remu       s0, t0, gp
                  slt        a1, a1, zero
                  nop
                  sra        t1, t1, a0
                  srl        zero, t1, a4
                  auipc      a4, 925829
                  add        tp, gp, s11
                  or         a7, a0, zero
                  rem        a6, s6, a7
                  add        tp, gp, s11
                  rem        a6, s6, a7
                  slti       s10, s8, -890
                  and        sp, s3, s5
                  xori       s3, s8, -101
                  ori        t1, ra, -664
                  slli       tp, t1, 9
                  mulhu      s1, s9, a1
                  and        sp, s3, s5
                  sub        ra, t1, s11
                  divu       s3, gp, a2
                  auipc      a4, 925829
                  ori        t1, ra, -664
                  addi       s3, a2, 677
                  andi       gp, s9, -46
                  sltiu      a2, a0, -848
                  divu       s3, gp, a2
                  li         s1, 0xffffffff #start riscv_int_numeric_corner_stream_3
                  li         gp, 0x0
                  li         s0, 0x0
                  li         t6, 0x80000000
                  li         s3, 0xffffffff
                  li         s6, 0xffffffff
                  li         a4, 0x80000000
                  li         t5, 0xffffffff
                  li         t4, 0xffffffff
                  li         a2, 0x0
                  sub        s0, s6, gp
                  mulhu      t6, t6, s1
                  auipc      t6, 925829
                  mul        s3, t4, s3
                  add        a4, a2, s3
                  sub        s0, s6, gp
                  auipc      t6, 925829
                  sub        s0, s6, gp
                  addi       s0, s0, 677
                  mulh       gp, s6, a2
                  add        a4, a2, s3
                  sub        s0, s6, gp
                  div        gp, s0, t5
                  rem        s3, s6, s0
                  addi       s0, s0, 677
                  add        a4, a2, s3
                  nop
                  mulhu      t6, t6, s1
                  add        a4, a2, s3
                  nop
                  sub        s0, s6, gp
                  mul        s3, t4, s3
                  mulhu      t6, t6, s1
                  addi       s0, s0, 677
                  mul        s3, t4, s3
                  addi       s0, s0, 677
                  mul        s3, t4, s3 #end riscv_int_numeric_corner_stream_3
                  mulhu      s1, s9, a1
                  div        zero, a7, s0
                  mul        a6, t2, s5
                  sra        t1, t1, a0
                  srl        zero, t1, a4
                  nop
                  srai       s8, t0, 25
                  nop
                  mulhu      s1, s9, a1
                  xori       s3, s8, -101
                  mul        a6, t2, s5
                  sub        ra, t1, s11
                  divu       s3, gp, a2
                  mulh       s2, t1, a3
                  xor        a4, a2, s0
                  slti       s10, s8, -890
                  srl        zero, t1, a4
                  rem        a6, s6, a7
                  sltu       t3, t1, tp
                  srli       t6, t5, 10
                  mulh       s2, t1, a3
                  slli       tp, t1, 9
                  addi       s3, a2, 677
                  ori        t1, ra, -664
                  slli       tp, t1, 9
                  xori       s3, s8, -101
                  mulhu      s1, s9, a1
                  srl        zero, t1, a4
                  sub        ra, t1, s11
                  lui        s6, 496523
                  ori        t1, ra, -664
                  srl        zero, t1, a4
                  xori       s3, s8, -101
                  mulh       s2, t1, a3
                  mulh       s2, t1, a3
                  mul        a6, t2, s5
                  ori        t1, ra, -664
                  slli       tp, t1, 9
                  addi       s3, a2, 677
                  slti       s10, s8, -890
                  div        zero, a7, s0
                  sll        s10, sp, a0
                  andi       gp, s9, -46
                  slt        a1, a1, zero
                  srl        zero, t1, a4
                  remu       s0, t0, gp
                  auipc      a4, 925829
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  auipc      a4, 925829
                  xor        a4, a2, s0
                  slti       s10, s8, -890
                  slli       tp, t1, 9
                  addi       s3, a2, 677
                  slti       s10, s8, -890
                  divu       s3, gp, a2
                  auipc      a4, 925829
                  sra        t1, t1, a0
                  remu       s0, t0, gp
                  slli       tp, t1, 9
                  div        zero, a7, s0
                  div        zero, a7, s0
                  sltiu      a2, a0, -848
                  sltiu      a2, a0, -848
                  srli       t6, t5, 10
                  sll        s10, sp, a0
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  add        tp, gp, s11
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  auipc      a4, 925829
                  sra        t1, t1, a0
                  xor        a4, a2, s0
                  slti       s10, s8, -890
                  sll        s10, sp, a0
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  mul        a6, t2, s5
                  sub        ra, t1, s11
                  sltiu      a2, a0, -848
                  mulhu      s1, s9, a1
                  srli       t6, t5, 10
                  nop
                  divu       s3, gp, a2
                  mulhu      s1, s9, a1
                  rem        a6, s6, a7
                  lui        s6, 496523
                  xori       s3, s8, -101
                  add        tp, gp, s11
                  ori        t1, ra, -664
                  addi       s3, a2, 677
                  and        sp, s3, s5
                  sltiu      a2, a0, -848
                  divu       s3, gp, a2
                  slt        a1, a1, zero
                  mulhu      s1, s9, a1
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  sra        t1, t1, a0
                  mulh       s2, t1, a3
                  mul        a6, t2, s5
                  sub        ra, t1, s11
                  sll        s10, sp, a0
                  ori        t1, ra, -664
                  mul        a6, t2, s5
                  or         a7, a0, zero
                  mulhu      s1, s9, a1
                  xor        a4, a2, s0
                  remu       s0, t0, gp
                  srl        zero, t1, a4
                  slli       tp, t1, 9
                  sra        t1, t1, a0
                  rem        a6, s6, a7
                  lui        s6, 496523
                  sltu       t3, t1, tp
                  or         a7, a0, zero
                  slli       tp, t1, 9
                  slt        a1, a1, zero
                  and        sp, s3, s5
                  xori       s3, s8, -101
                  rem        a6, s6, a7
                  xor        a4, a2, s0
                  mulhu      s1, s9, a1
                  srai       s8, t0, 25
                  ori        t1, ra, -664
                  slti       s10, s8, -890
                  and        sp, s3, s5
                  mul        a6, t2, s5
                  andi       gp, s9, -46
                  slt        a1, a1, zero
                  lui        s6, 496523
                  slli       tp, t1, 9
                  lui        s6, 496523
                  srai       s8, t0, 25
                  addi       s3, a2, 677
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  xori       s3, s8, -101
                  sltiu      a2, a0, -848
                  divu       s3, gp, a2
                  xor        a4, a2, s0
                  slli       tp, t1, 9
                  ori        t1, ra, -664
                  addi       s3, a2, 677
                  div        zero, a7, s0
                  addi       s3, a2, 677
                  rem        a6, s6, a7
                  sll        s10, sp, a0
                  auipc      a4, 925829
                  nop
                  add        tp, gp, s11
                  sltiu      a2, a0, -848
                  div        zero, a7, s0
                  srl        zero, t1, a4
                  srai       s8, t0, 25
                  lui        s6, 496523
                  sra        t1, t1, a0
                  slt        a1, a1, zero
                  div        zero, a7, s0
                  rem        a6, s6, a7
                  slt        a1, a1, zero
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  srli       t6, t5, 10
                  sltiu      a2, a0, -848
                  rem        a6, s6, a7
                  and        sp, s3, s5
                  addi       s3, a2, 677
                  xori       s3, s8, -101
                  slli       tp, t1, 9
                  lui        s6, 496523
                  xori       s3, s8, -101
                  xori       s3, s8, -101
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  auipc      a4, 925829
                  mul        a6, t2, s5
                  mulhsu     s8, sp, s5
                  srl        zero, t1, a4
                  rem        a6, s6, a7
                  or         a7, a0, zero
                  sub        ra, t1, s11
                  add        tp, gp, s11
                  slt        a1, a1, zero
                  mul        a6, t2, s5
                  srl        zero, t1, a4
                  srli       t6, t5, 10
                  sll        s10, sp, a0
                  add        tp, gp, s11
                  mul        a6, t2, s5
                  lui        s6, 496523
                  sra        t1, t1, a0
                  mulhu      s1, s9, a1
                  srai       s8, t0, 25
                  and        sp, s3, s5
                  div        zero, a7, s0
                  rem        a6, s6, a7
                  sltu       t3, t1, tp
                  slti       s10, s8, -890
                  lui        s6, 496523
                  nop
                  srai       s8, t0, 25
                  and        sp, s3, s5
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  srli       t6, t5, 10
                  andi       gp, s9, -46
                  slti       s10, s8, -890
                  sub        ra, t1, s11
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  slti       s10, s8, -890
                  sltu       t3, t1, tp
                  slli       tp, t1, 9
                  slti       s10, s8, -890
                  rem        a6, s6, a7
                  mul        a6, t2, s5
                  slti       s10, s8, -890
                  mul        a6, t2, s5
                  and        sp, s3, s5
                  xori       s3, s8, -101
                  sra        t1, t1, a0
                  srai       s8, t0, 25
                  mul        a6, t2, s5
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  slli       tp, t1, 9
                  or         a7, a0, zero
                  mulhu      s1, s9, a1
                  ori        t1, ra, -664
                  sub        ra, t1, s11
                  sub        ra, t1, s11
                  divu       s3, gp, a2
                  sltiu      a2, a0, -848
                  sub        ra, t1, s11
                  rem        a6, s6, a7
                  sltiu      a2, a0, -848
                  sltu       t3, t1, tp
                  sub        ra, t1, s11
                  xor        a4, a2, s0
                  mulhu      s1, s9, a1
                  xori       s3, s8, -101
                  nop
                  and        sp, s3, s5
                  divu       s3, gp, a2
                  sltu       t3, t1, tp
                  or         a7, a0, zero
                  slti       s10, s8, -890
                  slli       tp, t1, 9
                  and        sp, s3, s5
                  lui        s6, 496523
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  auipc      a4, 925829
                  nop
                  nop
                  nop
                  or         a7, a0, zero
                  div        zero, a7, s0
                  srai       s8, t0, 25
                  mul        a6, t2, s5
                  divu       s3, gp, a2
                  lui        s6, 496523
                  mulhu      s1, s9, a1
                  divu       s3, gp, a2
                  add        tp, gp, s11
                  or         a7, a0, zero
                  sltu       t3, t1, tp
                  slti       s10, s8, -890
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  nop
                  srli       t6, t5, 10
                  srl        zero, t1, a4
                  auipc      a4, 925829
                  xori       s3, s8, -101
                  sub        ra, t1, s11
                  sltiu      a2, a0, -848
                  srl        zero, t1, a4
                  mul        a6, t2, s5
                  auipc      a4, 925829
                  xor        a4, a2, s0
                  addi       s3, a2, 677
                  mulh       s2, t1, a3
                  srli       t6, t5, 10
                  mulhu      s1, s9, a1
                  and        sp, s3, s5
                  divu       s3, gp, a2
                  sub        ra, t1, s11
                  sltiu      a2, a0, -848
                  sub        ra, t1, s11
                  or         a7, a0, zero
                  sltu       t3, t1, tp
                  mulhu      s1, s9, a1
                  addi       s3, a2, 677
                  mulhsu     s8, sp, s5
                  or         a7, a0, zero
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  lui        s6, 496523
                  srai       s8, t0, 25
                  remu       s0, t0, gp
                  rem        a6, s6, a7
                  srli       t6, t5, 10
                  andi       gp, s9, -46
                  auipc      a4, 925829
                  and        sp, s3, s5
                  sra        t1, t1, a0
                  or         a7, a0, zero
                  slti       s10, s8, -890
                  sltu       t3, t1, tp
                  slli       tp, t1, 9
                  auipc      a4, 925829
                  nop
                  sub        ra, t1, s11
                  or         a7, a0, zero
                  xor        a4, a2, s0
                  ori        t1, ra, -664
                  nop
                  mul        a6, t2, s5
                  sltiu      a2, a0, -848
                  div        zero, a7, s0
                  remu       s0, t0, gp
                  srai       s8, t0, 25
                  divu       s3, gp, a2
                  mul        a6, t2, s5
                  or         a7, a0, zero
                  srai       s8, t0, 25
                  add        tp, gp, s11
                  addi       s3, a2, 677
                  srai       s8, t0, 25
                  rem        a6, s6, a7
                  sltu       t3, t1, tp
                  sra        t1, t1, a0
                  slt        a1, a1, zero
                  sll        s10, sp, a0
                  ori        t1, ra, -664
                  sltu       t3, t1, tp
                  xori       s3, s8, -101
                  auipc      a4, 925829
                  remu       s0, t0, gp
                  slt        a1, a1, zero
                  ori        t1, ra, -664
                  div        zero, a7, s0
                  ori        t1, ra, -664
                  or         a7, a0, zero
                  mulhu      s1, s9, a1
                  slli       tp, t1, 9
                  addi       s3, a2, 677
                  andi       gp, s9, -46
                  mul        a6, t2, s5
                  nop
                  mulhsu     s8, sp, s5
                  mulhu      s1, s9, a1
                  sra        t1, t1, a0
                  mul        a6, t2, s5
                  srli       t6, t5, 10
                  srai       s8, t0, 25
                  sll        s10, sp, a0
                  andi       gp, s9, -46
                  lui        s6, 496523
                  andi       gp, s9, -46
                  mulhsu     s8, sp, s5
                  srl        zero, t1, a4
                  add        tp, gp, s11
                  srli       t6, t5, 10
                  srl        zero, t1, a4
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  slt        a1, a1, zero
                  slt        a1, a1, zero
                  mul        a6, t2, s5
                  xori       s3, s8, -101
                  sub        ra, t1, s11
                  lui        s6, 496523
                  or         a7, a0, zero
                  remu       s0, t0, gp
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  slli       tp, t1, 9
                  andi       gp, s9, -46
                  slti       s10, s8, -890
                  ori        t1, ra, -664
                  nop
                  or         a7, a0, zero
                  xor        a4, a2, s0
                  sltu       t3, t1, tp
                  mulhsu     s8, sp, s5
                  mul        a6, t2, s5
                  sll        s10, sp, a0
                  div        zero, a7, s0
                  mul        a6, t2, s5
                  sltu       t3, t1, tp
                  sltu       t3, t1, tp
                  srli       t6, t5, 10
                  nop
                  slt        a1, a1, zero
                  div        zero, a7, s0
                  auipc      a4, 925829
                  and        sp, s3, s5
                  nop
                  slli       tp, t1, 9
                  srli       t6, t5, 10
                  xori       s3, s8, -101
                  addi       s3, a2, 677
                  sltu       t3, t1, tp
                  or         a7, a0, zero
                  addi       s3, a2, 677
                  auipc      a4, 925829
                  ori        t1, ra, -664
                  addi       s3, a2, 677
                  remu       s0, t0, gp
                  div        zero, a7, s0
                  mulhu      s1, s9, a1
                  sra        t1, t1, a0
                  add        tp, gp, s11
                  nop
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  mulhsu     s8, sp, s5
                  mulhu      s1, s9, a1
                  and        sp, s3, s5
                  xor        a4, a2, s0
                  sll        s10, sp, a0
                  sub        ra, t1, s11
                  sll        s10, sp, a0
                  xori       s3, s8, -101
                  remu       s0, t0, gp
                  srl        zero, t1, a4
                  mul        a6, t2, s5
                  slti       s10, s8, -890
                  srl        zero, t1, a4
                  sra        t1, t1, a0
                  sll        s10, sp, a0
                  sltu       t3, t1, tp
                  nop
                  sll        s10, sp, a0
                  or         a7, a0, zero
                  slti       s10, s8, -890
                  nop
                  ori        t1, ra, -664
                  srai       s8, t0, 25
                  mul        a6, t2, s5
                  add        tp, gp, s11
                  sub        ra, t1, s11
                  slt        a1, a1, zero
                  sub        ra, t1, s11
                  ori        t1, ra, -664
                  and        sp, s3, s5
                  sltiu      a2, a0, -848
                  mulhu      s1, s9, a1
                  divu       s3, gp, a2
                  andi       gp, s9, -46
                  or         a7, a0, zero
                  srl        zero, t1, a4
                  slti       s10, s8, -890
                  lui        s6, 496523
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  divu       s3, gp, a2
                  slt        a1, a1, zero
                  rem        a6, s6, a7
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  lui        s6, 496523
                  addi       s3, a2, 677
                  srai       s8, t0, 25
                  sra        t1, t1, a0
                  remu       s0, t0, gp
                  sltu       t3, t1, tp
                  mul        a6, t2, s5
                  sltiu      a2, a0, -848
                  divu       s3, gp, a2
                  add        tp, gp, s11
                  mul        a6, t2, s5
                  rem        a6, s6, a7
                  rem        a6, s6, a7
                  mulh       s2, t1, a3
                  sra        t1, t1, a0
                  addi       s3, a2, 677
                  divu       s3, gp, a2
                  srli       t6, t5, 10
                  ori        t1, ra, -664
                  remu       s0, t0, gp
                  nop
                  xori       s3, s8, -101
                  mulh       s2, t1, a3
                  xor        a4, a2, s0
                  mul        a6, t2, s5
                  srai       s8, t0, 25
                  sra        t1, t1, a0
                  rem        a6, s6, a7
                  div        zero, a7, s0
                  lui        s6, 496523
                  ori        t1, ra, -664
                  xor        a4, a2, s0
                  remu       s0, t0, gp
                  srl        zero, t1, a4
                  add        tp, gp, s11
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  slti       s10, s8, -890
                  sltiu      a2, a0, -848
                  srai       s8, t0, 25
                  add        tp, gp, s11
                  srl        zero, t1, a4
                  sll        s10, sp, a0
                  li         t6, 0x0 #start riscv_int_numeric_corner_stream_24
                  li         t4, 0xffffffff
                  li         sp, 0x0
                  li         a1, 0x6a7131e1
                  li         s5, 0xffffffff
                  li         a3, 0xeeaaa766
                  li         s6, 0x0
                  li         s7, 0x80000000
                  li         t1, 0x80000000
                  li         s8, 0xcaf2d243
                  lui        s5, 496523
                  auipc      t6, 925829
                  addi       t1, t1, 677
                  sub        t1, s7, sp
                  div        sp, t1, t4
                  auipc      t6, 925829
                  div        sp, t1, t4
                  mulhu      t6, t6, a1
                  divu       t1, a3, s5
                  mulhsu     s7, a1, s6
                  mulh       sp, s7, a3
                  lui        s5, 496523
                  mulh       sp, s7, a3
                  lui        s5, 496523
                  mulhu      t6, t6, a1
                  nop
                  lui        s5, 496523
                  mulhsu     s7, a1, s6
                  add        s5, a3, s6
                  div        sp, t1, t4
                  rem        s6, s7, t1
                  mul        s6, s8, s6
                  sub        t1, s7, sp
                  addi       t1, t1, 677
                  add        s5, a3, s6
                  sub        t1, s7, sp
                  mulhu      t6, t6, a1
                  mul        s6, s8, s6
                  mulhu      t6, t6, a1 #end riscv_int_numeric_corner_stream_24
                  divu       s3, gp, a2
                  srli       t6, t5, 10
                  slli       tp, t1, 9
                  srli       t6, t5, 10
                  add        tp, gp, s11
                  divu       s3, gp, a2
                  auipc      a4, 925829
                  sra        t1, t1, a0
                  remu       s0, t0, gp
                  xori       s3, s8, -101
                  addi       s3, a2, 677
                  ori        t1, ra, -664
                  mul        a6, t2, s5
                  andi       gp, s9, -46
                  lui        s6, 496523
                  srai       s8, t0, 25
                  or         a7, a0, zero
                  xori       s3, s8, -101
                  auipc      a4, 925829
                  addi       s3, a2, 677
                  sll        s10, sp, a0
                  sra        t1, t1, a0
                  mulhu      s1, s9, a1
                  srl        zero, t1, a4
                  sub        ra, t1, s11
                  sltu       t3, t1, tp
                  srli       t6, t5, 10
                  srai       s8, t0, 25
                  remu       s0, t0, gp
                  slti       s10, s8, -890
                  sltu       t3, t1, tp
                  mulhu      s1, s9, a1
                  or         a7, a0, zero
                  slli       tp, t1, 9
                  divu       s3, gp, a2
                  nop
                  sltiu      a2, a0, -848
                  slt        a1, a1, zero
                  mul        a6, t2, s5
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  divu       s3, gp, a2
                  div        zero, a7, s0
                  and        sp, s3, s5
                  div        zero, a7, s0
                  sltu       t3, t1, tp
                  divu       s3, gp, a2
                  mulh       s2, t1, a3
                  andi       gp, s9, -46
                  slti       s10, s8, -890
                  divu       s3, gp, a2
                  rem        a6, s6, a7
                  xor        a4, a2, s0
                  div        zero, a7, s0
                  sltiu      a2, a0, -848
                  auipc      a4, 925829
                  rem        a6, s6, a7
                  sltu       t3, t1, tp
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  slt        a1, a1, zero
                  mul        a6, t2, s5
                  slt        a1, a1, zero
                  and        sp, s3, s5
                  add        tp, gp, s11
                  sltiu      a2, a0, -848
                  addi       s3, a2, 677
                  srai       s8, t0, 25
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  or         a7, a0, zero
                  addi       s3, a2, 677
                  mulhsu     s8, sp, s5
                  xori       s3, s8, -101
                  mul        a6, t2, s5
                  mulhu      s1, s9, a1
                  sra        t1, t1, a0
                  srl        zero, t1, a4
                  mulhsu     s8, sp, s5
                  sltiu      a2, a0, -848
                  rem        a6, s6, a7
                  sltiu      a2, a0, -848
                  addi       s3, a2, 677
                  div        zero, a7, s0
                  auipc      a4, 925829
                  slli       tp, t1, 9
                  sra        t1, t1, a0
                  nop
                  mul        a6, t2, s5
                  andi       gp, s9, -46
                  sra        t1, t1, a0
                  auipc      a4, 925829
                  lui        s6, 496523
                  xor        a4, a2, s0
                  srl        zero, t1, a4
                  slt        a1, a1, zero
                  xori       s3, s8, -101
                  mul        a6, t2, s5
                  mulhsu     s8, sp, s5
                  sll        s10, sp, a0
                  addi       s3, a2, 677
                  remu       s0, t0, gp
                  srl        zero, t1, a4
                  rem        a6, s6, a7
                  sra        t1, t1, a0
                  sltiu      a2, a0, -848
                  sltu       t3, t1, tp
                  sltu       t3, t1, tp
                  auipc      a4, 925829
                  sltiu      a2, a0, -848
                  nop
                  mulhsu     s8, sp, s5
                  sub        ra, t1, s11
                  rem        a6, s6, a7
                  andi       gp, s9, -46
                  mulh       s2, t1, a3
                  srai       s8, t0, 25
                  mulhsu     s8, sp, s5
                  slli       tp, t1, 9
                  divu       s3, gp, a2
                  srl        zero, t1, a4
                  auipc      a4, 925829
                  mulhsu     s8, sp, s5
                  slti       s10, s8, -890
                  xori       s3, s8, -101
                  sub        ra, t1, s11
                  mulhsu     s8, sp, s5
                  and        sp, s3, s5
                  nop
                  srai       s8, t0, 25
                  addi       s3, a2, 677
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  srai       s8, t0, 25
                  or         a7, a0, zero
                  add        tp, gp, s11
                  xori       s3, s8, -101
                  auipc      a4, 925829
                  sub        ra, t1, s11
                  lui        s6, 496523
                  xor        a4, a2, s0
                  mul        a6, t2, s5
                  auipc      a4, 925829
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  mul        a6, t2, s5
                  sltu       t3, t1, tp
                  andi       gp, s9, -46
                  auipc      a4, 925829
                  add        tp, gp, s11
                  sub        ra, t1, s11
                  mulhsu     s8, sp, s5
                  srli       t6, t5, 10
                  mulhsu     s8, sp, s5
                  mulh       s2, t1, a3
                  ori        t1, ra, -664
                  auipc      a4, 925829
                  srli       t6, t5, 10
                  mulh       s2, t1, a3
                  mul        a6, t2, s5
                  add        tp, gp, s11
                  slli       tp, t1, 9
                  divu       s3, gp, a2
                  rem        a6, s6, a7
                  sltu       t3, t1, tp
                  lui        s6, 496523
                  sltu       t3, t1, tp
                  auipc      a4, 925829
                  sll        s10, sp, a0
                  lui        s6, 496523
                  and        sp, s3, s5
                  rem        a6, s6, a7
                  srl        zero, t1, a4
                  and        sp, s3, s5
                  ori        t1, ra, -664
                  and        sp, s3, s5
                  sltu       t3, t1, tp
                  ori        t1, ra, -664
                  slli       tp, t1, 9
                  nop
                  sltiu      a2, a0, -848
                  mulhu      s1, s9, a1
                  sll        s10, sp, a0
                  add        tp, gp, s11
                  remu       s0, t0, gp
                  xori       s3, s8, -101
                  and        sp, s3, s5
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  srai       s8, t0, 25
                  sll        s10, sp, a0
                  or         a7, a0, zero
                  slti       s10, s8, -890
                  and        sp, s3, s5
                  mulhsu     s8, sp, s5
                  remu       s0, t0, gp
                  sub        ra, t1, s11
                  divu       s3, gp, a2
                  nop
                  ori        t1, ra, -664
                  sra        t1, t1, a0
                  lui        s6, 496523
                  slt        a1, a1, zero
                  mulhu      s1, s9, a1
                  and        sp, s3, s5
                  add        tp, gp, s11
                  addi       s3, a2, 677
                  addi       s3, a2, 677
                  sub        ra, t1, s11
                  sltu       t3, t1, tp
                  sll        s10, sp, a0
                  nop
                  slli       tp, t1, 9
                  mul        a6, t2, s5
                  xor        a4, a2, s0
                  lui        s6, 496523
                  and        sp, s3, s5
                  slt        a1, a1, zero
                  and        sp, s3, s5
                  slti       s10, s8, -890
                  div        zero, a7, s0
                  sltiu      a2, a0, -848
                  divu       s3, gp, a2
                  auipc      a4, 925829
                  sltu       t3, t1, tp
                  mulh       s2, t1, a3
                  srai       s8, t0, 25
                  slti       s10, s8, -890
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  sll        s10, sp, a0
                  lui        s6, 496523
                  rem        a6, s6, a7
                  xori       s3, s8, -101
                  remu       s0, t0, gp
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  addi       s3, a2, 677
                  add        tp, gp, s11
                  mulh       s2, t1, a3
                  slt        a1, a1, zero
                  sra        t1, t1, a0
                  remu       s0, t0, gp
                  sra        t1, t1, a0
                  remu       s0, t0, gp
                  slt        a1, a1, zero
                  mulhsu     s8, sp, s5
                  add        tp, gp, s11
                  rem        a6, s6, a7
                  or         a7, a0, zero
                  lui        s6, 496523
                  sub        ra, t1, s11
                  xor        a4, a2, s0
                  mulhu      s1, s9, a1
                  rem        a6, s6, a7
                  mulh       s2, t1, a3
                  auipc      a4, 925829
                  mul        a6, t2, s5
                  remu       s0, t0, gp
                  div        zero, a7, s0
                  or         a7, a0, zero
                  nop
                  sll        s10, sp, a0
                  add        tp, gp, s11
                  div        zero, a7, s0
                  andi       gp, s9, -46
                  sltu       t3, t1, tp
                  slt        a1, a1, zero
                  add        tp, gp, s11
                  mulh       s2, t1, a3
                  mulhu      s1, s9, a1
                  mul        a6, t2, s5
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  slli       tp, t1, 9
                  srli       t6, t5, 10
                  nop
                  srl        zero, t1, a4
                  nop
                  rem        a6, s6, a7
                  remu       s0, t0, gp
                  and        sp, s3, s5
                  mulhu      s1, s9, a1
                  mulh       s2, t1, a3
                  srai       s8, t0, 25
                  srl        zero, t1, a4
                  sra        t1, t1, a0
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  ori        t1, ra, -664
                  div        zero, a7, s0
                  or         a7, a0, zero
                  sll        s10, sp, a0
                  auipc      a4, 925829
                  andi       gp, s9, -46
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  mulhsu     s8, sp, s5
                  slli       tp, t1, 9
                  add        tp, gp, s11
                  sub        ra, t1, s11
                  rem        a6, s6, a7
                  sub        ra, t1, s11
                  remu       s0, t0, gp
                  auipc      a4, 925829
                  mul        a6, t2, s5
                  rem        a6, s6, a7
                  div        zero, a7, s0
                  slt        a1, a1, zero
                  sll        s10, sp, a0
                  sltu       t3, t1, tp
                  addi       s3, a2, 677
                  srli       t6, t5, 10
                  div        zero, a7, s0
                  div        zero, a7, s0
                  remu       s0, t0, gp
                  lui        s6, 496523
                  or         a7, a0, zero
                  auipc      a4, 925829
                  sltiu      a2, a0, -848
                  lui        s6, 496523
                  sltu       t3, t1, tp
                  rem        a6, s6, a7
                  mulhsu     s8, sp, s5
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  mulhu      s1, s9, a1
                  slt        a1, a1, zero
                  mul        a6, t2, s5
                  srai       s8, t0, 25
                  lui        s6, 496523
                  lui        s6, 496523
                  remu       s0, t0, gp
                  slli       tp, t1, 9
                  div        zero, a7, s0
                  slt        a1, a1, zero
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  mul        a6, t2, s5
                  or         a7, a0, zero
                  div        zero, a7, s0
                  slli       tp, t1, 9
                  sub        ra, t1, s11
                  srli       t6, t5, 10
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  xor        a4, a2, s0
                  sltu       t3, t1, tp
                  remu       s0, t0, gp
                  andi       gp, s9, -46
                  sltiu      a2, a0, -848
                  nop
                  srl        zero, t1, a4
                  xori       s3, s8, -101
                  auipc      a4, 925829
                  slti       s10, s8, -890
                  xor        a4, a2, s0
                  sra        t1, t1, a0
                  xori       s3, s8, -101
                  slli       tp, t1, 9
                  mulh       s2, t1, a3
                  sub        ra, t1, s11
                  mulh       s2, t1, a3
                  mulh       s2, t1, a3
                  mulhsu     s8, sp, s5
                  slti       s10, s8, -890
                  xori       s3, s8, -101
                  divu       s3, gp, a2
                  sra        t1, t1, a0
                  ori        t1, ra, -664
                  lui        s6, 496523
                  slt        a1, a1, zero
                  andi       gp, s9, -46
                  mulhsu     s8, sp, s5
                  mulh       s2, t1, a3
                  divu       s3, gp, a2
                  remu       s0, t0, gp
                  ori        t1, ra, -664
                  srl        zero, t1, a4
                  xori       s3, s8, -101
                  divu       s3, gp, a2
                  addi       s3, a2, 677
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  mulh       s2, t1, a3
                  divu       s3, gp, a2
                  slt        a1, a1, zero
                  div        zero, a7, s0
                  auipc      a4, 925829
                  sltiu      a2, a0, -848
                  xori       s3, s8, -101
                  xori       s3, s8, -101
                  sub        ra, t1, s11
                  add        tp, gp, s11
                  slli       tp, t1, 9
                  sltu       t3, t1, tp
                  add        tp, gp, s11
                  ori        t1, ra, -664
                  slt        a1, a1, zero
                  sra        t1, t1, a0
                  divu       s3, gp, a2
                  xor        a4, a2, s0
                  sra        t1, t1, a0
                  remu       s0, t0, gp
                  slti       s10, s8, -890
                  div        zero, a7, s0
                  srai       s8, t0, 25
                  add        tp, gp, s11
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  mulhsu     s8, sp, s5
                  auipc      a4, 925829
                  nop
                  ori        t1, ra, -664
                  remu       s0, t0, gp
                  sltu       t3, t1, tp
                  slli       tp, t1, 9
                  remu       s0, t0, gp
                  and        sp, s3, s5
                  ori        t1, ra, -664
                  srl        zero, t1, a4
                  rem        a6, s6, a7
                  auipc      a4, 925829
                  slt        a1, a1, zero
                  lui        s6, 496523
                  add        tp, gp, s11
                  srli       t6, t5, 10
                  sub        ra, t1, s11
                  mulh       s2, t1, a3
                  sra        t1, t1, a0
                  mulh       s2, t1, a3
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  rem        a6, s6, a7
                  remu       s0, t0, gp
                  auipc      a4, 925829
                  auipc      a4, 925829
                  lui        s6, 496523
                  add        tp, gp, s11
                  ori        t1, ra, -664
                  or         a7, a0, zero
                  add        tp, gp, s11
                  andi       gp, s9, -46
                  mulhsu     s8, sp, s5
                  mulhsu     s8, sp, s5
                  sll        s10, sp, a0
                  sll        s10, sp, a0
                  sll        s10, sp, a0
                  slt        a1, a1, zero
                  mulhsu     s8, sp, s5
                  andi       gp, s9, -46
                  and        sp, s3, s5
                  auipc      a4, 925829
                  or         a7, a0, zero
                  mulhu      s1, s9, a1
                  slt        a1, a1, zero
                  nop
                  sll        s10, sp, a0
                  mul        a6, t2, s5
                  remu       s0, t0, gp
                  mul        a6, t2, s5
                  sltiu      a2, a0, -848
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  xor        a4, a2, s0
                  srli       t6, t5, 10
                  sltu       t3, t1, tp
                  mulhsu     s8, sp, s5
                  divu       s3, gp, a2
                  slt        a1, a1, zero
                  xori       s3, s8, -101
                  nop
                  srli       t6, t5, 10
                  srl        zero, t1, a4
                  srai       s8, t0, 25
                  auipc      a4, 925829
                  lui        s6, 496523
                  slli       tp, t1, 9
                  srl        zero, t1, a4
                  andi       gp, s9, -46
                  srl        zero, t1, a4
                  sub        ra, t1, s11
                  ori        t1, ra, -664
                  divu       s3, gp, a2
                  xor        a4, a2, s0
                  sra        t1, t1, a0
                  slti       s10, s8, -890
                  nop
                  mulhu      s1, s9, a1
                  slli       tp, t1, 9
                  rem        a6, s6, a7
                  nop
                  ori        t1, ra, -664
                  andi       gp, s9, -46
                  srl        zero, t1, a4
                  slti       s10, s8, -890
                  sra        t1, t1, a0
                  sll        s10, sp, a0
                  sll        s10, sp, a0
                  mul        a6, t2, s5
                  sra        t1, t1, a0
                  sltu       t3, t1, tp
                  xori       s3, s8, -101
                  slti       s10, s8, -890
                  mul        a6, t2, s5
                  lui        s6, 496523
                  rem        a6, s6, a7
                  div        zero, a7, s0
                  remu       s0, t0, gp
                  auipc      a4, 925829
                  div        zero, a7, s0
                  auipc      a4, 925829
                  sltiu      a2, a0, -848
                  div        zero, a7, s0
                  nop
                  lui        s6, 496523
                  mulhu      s1, s9, a1
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  remu       s0, t0, gp
                  rem        a6, s6, a7
                  andi       gp, s9, -46
                  sltiu      a2, a0, -848
                  mulh       s2, t1, a3
                  lui        s6, 496523
                  slt        a1, a1, zero
                  xor        a4, a2, s0
                  ori        t1, ra, -664
                  addi       s3, a2, 677
                  sltu       t3, t1, tp
                  add        tp, gp, s11
                  li         a1, 0x80000000 #start riscv_int_numeric_corner_stream_23
                  li         s7, 0x80000000
                  li         s0, 0x5504c9f6
                  li         sp, 0xfdc086d1
                  li         s5, 0x2c03db1
                  li         t1, 0x966e5f5
                  li         gp, 0x0
                  li         s6, 0x7b4d14e7
                  li         s8, 0xffffffff
                  li         t5, 0x80000000
                  sub        gp, s6, sp
                  mul        s5, s7, s5
                  auipc      t5, 925829
                  sub        gp, s6, sp
                  remu       s8, s5, s0
                  mulh       sp, s6, s0
                  sub        gp, s6, sp
                  sub        gp, s6, sp
                  remu       s8, s5, s0
                  divu       gp, s0, a1
                  lui        a1, 496523
                  nop
                  rem        s5, s6, gp
                  mulhsu     s6, t1, s5
                  add        a1, s0, s5
                  addi       gp, gp, 677
                  addi       gp, gp, 677
                  mulhu      t5, t5, t1
                  sub        gp, s6, sp
                  mulhu      t5, t5, t1
                  add        a1, s0, s5
                  addi       gp, gp, 677
                  div        sp, gp, s8
                  divu       gp, s0, a1
                  div        sp, gp, s8
                  sub        gp, s6, sp
                  div        sp, gp, s8
                  lui        a1, 496523
                  mulh       sp, s6, s0 #end riscv_int_numeric_corner_stream_23
                  remu       s0, t0, gp
                  sub        ra, t1, s11
                  srai       s8, t0, 25
                  div        zero, a7, s0
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  add        tp, gp, s11
                  srai       s8, t0, 25
                  slli       tp, t1, 9
                  addi       s3, a2, 677
                  addi       s3, a2, 677
                  slli       tp, t1, 9
                  ori        t1, ra, -664
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  srl        zero, t1, a4
                  slti       s10, s8, -890
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  xor        a4, a2, s0
                  ori        t1, ra, -664
                  srl        zero, t1, a4
                  mulhu      s1, s9, a1
                  xori       s3, s8, -101
                  sltiu      a2, a0, -848
                  rem        a6, s6, a7
                  sll        s10, sp, a0
                  div        zero, a7, s0
                  srl        zero, t1, a4
                  srai       s8, t0, 25
                  xori       s3, s8, -101
                  mulh       s2, t1, a3
                  xori       s3, s8, -101
                  sltiu      a2, a0, -848
                  add        tp, gp, s11
                  mulhsu     s8, sp, s5
                  nop
                  sra        t1, t1, a0
                  or         a7, a0, zero
                  rem        a6, s6, a7
                  div        zero, a7, s0
                  divu       s3, gp, a2
                  sltiu      a2, a0, -848
                  mulhsu     s8, sp, s5
                  addi       s3, a2, 677
                  slti       s10, s8, -890
                  sll        s10, sp, a0
                  lui        s6, 496523
                  mulh       s2, t1, a3
                  andi       gp, s9, -46
                  mulh       s2, t1, a3
                  mulhsu     s8, sp, s5
                  mul        a6, t2, s5
                  mul        a6, t2, s5
                  andi       gp, s9, -46
                  div        zero, a7, s0
                  rem        a6, s6, a7
                  add        tp, gp, s11
                  sub        ra, t1, s11
                  or         a7, a0, zero
                  nop
                  srai       s8, t0, 25
                  sra        t1, t1, a0
                  slt        a1, a1, zero
                  srai       s8, t0, 25
                  and        sp, s3, s5
                  div        zero, a7, s0
                  srai       s8, t0, 25
                  slt        a1, a1, zero
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  and        sp, s3, s5
                  sub        ra, t1, s11
                  mulhsu     s8, sp, s5
                  rem        a6, s6, a7
                  div        zero, a7, s0
                  and        sp, s3, s5
                  srli       t6, t5, 10
                  addi       s3, a2, 677
                  slli       tp, t1, 9
                  and        sp, s3, s5
                  sltiu      a2, a0, -848
                  slt        a1, a1, zero
                  sra        t1, t1, a0
                  sll        s10, sp, a0
                  remu       s0, t0, gp
                  srli       t6, t5, 10
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  mulhsu     s8, sp, s5
                  mulhu      s1, s9, a1
                  remu       s0, t0, gp
                  sub        ra, t1, s11
                  slt        a1, a1, zero
                  mulh       s2, t1, a3
                  xori       s3, s8, -101
                  xori       s3, s8, -101
                  sra        t1, t1, a0
                  remu       s0, t0, gp
                  and        sp, s3, s5
                  remu       s0, t0, gp
                  or         a7, a0, zero
                  mulh       s2, t1, a3
                  mulh       s2, t1, a3
                  ori        t1, ra, -664
                  slti       s10, s8, -890
                  mulhu      s1, s9, a1
                  sra        t1, t1, a0
                  div        zero, a7, s0
                  andi       gp, s9, -46
                  srai       s8, t0, 25
                  ori        t1, ra, -664
                  sll        s10, sp, a0
                  ori        t1, ra, -664
                  sltu       t3, t1, tp
                  auipc      a4, 925829
                  lui        s6, 496523
                  xori       s3, s8, -101
                  sub        ra, t1, s11
                  slti       s10, s8, -890
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  divu       s3, gp, a2
                  and        sp, s3, s5
                  nop
                  auipc      a4, 925829
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  srli       t6, t5, 10
                  slt        a1, a1, zero
                  andi       gp, s9, -46
                  remu       s0, t0, gp
                  srai       s8, t0, 25
                  sra        t1, t1, a0
                  mulh       s2, t1, a3
                  mul        a6, t2, s5
                  nop
                  slli       tp, t1, 9
                  sll        s10, sp, a0
                  rem        a6, s6, a7
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  srli       t6, t5, 10
                  sra        t1, t1, a0
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  slti       s10, s8, -890
                  sra        t1, t1, a0
                  div        zero, a7, s0
                  xori       s3, s8, -101
                  and        sp, s3, s5
                  slt        a1, a1, zero
                  divu       s3, gp, a2
                  nop
                  mulh       s2, t1, a3
                  slt        a1, a1, zero
                  mulh       s2, t1, a3
                  sra        t1, t1, a0
                  or         a7, a0, zero
                  mulhu      s1, s9, a1
                  sltiu      a2, a0, -848
                  srl        zero, t1, a4
                  div        zero, a7, s0
                  lui        s6, 496523
                  slti       s10, s8, -890
                  sltu       t3, t1, tp
                  mulh       s2, t1, a3
                  xor        a4, a2, s0
                  divu       s3, gp, a2
                  slli       tp, t1, 9
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  add        tp, gp, s11
                  sll        s10, sp, a0
                  srl        zero, t1, a4
                  lui        s6, 496523
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  and        sp, s3, s5
                  sltu       t3, t1, tp
                  srai       s8, t0, 25
                  slli       tp, t1, 9
                  divu       s3, gp, a2
                  sll        s10, sp, a0
                  srli       t6, t5, 10
                  slti       s10, s8, -890
                  rem        a6, s6, a7
                  or         a7, a0, zero
                  add        tp, gp, s11
                  slli       tp, t1, 9
                  mulhu      s1, s9, a1
                  sltu       t3, t1, tp
                  addi       s3, a2, 677
                  divu       s3, gp, a2
                  sll        s10, sp, a0
                  sll        s10, sp, a0
                  addi       s3, a2, 677
                  slt        a1, a1, zero
                  xori       s3, s8, -101
                  sra        t1, t1, a0
                  mulhu      s1, s9, a1
                  nop
                  sll        s10, sp, a0
                  slt        a1, a1, zero
                  slli       tp, t1, 9
                  ori        t1, ra, -664
                  sub        ra, t1, s11
                  or         a7, a0, zero
                  srl        zero, t1, a4
                  or         a7, a0, zero
                  auipc      a4, 925829
                  andi       gp, s9, -46
                  srai       s8, t0, 25
                  sll        s10, sp, a0
                  ori        t1, ra, -664
                  addi       s3, a2, 677
                  slt        a1, a1, zero
                  xori       s3, s8, -101
                  srli       t6, t5, 10
                  slti       s10, s8, -890
                  divu       s3, gp, a2
                  div        zero, a7, s0
                  xor        a4, a2, s0
                  sll        s10, sp, a0
                  slli       tp, t1, 9
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  srai       s8, t0, 25
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  addi       s3, a2, 677
                  remu       s0, t0, gp
                  slti       s10, s8, -890
                  ori        t1, ra, -664
                  add        tp, gp, s11
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  and        sp, s3, s5
                  auipc      a4, 925829
                  srli       t6, t5, 10
                  xor        a4, a2, s0
                  nop
                  div        zero, a7, s0
                  and        sp, s3, s5
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  divu       s3, gp, a2
                  or         a7, a0, zero
                  sll        s10, sp, a0
                  sll        s10, sp, a0
                  srli       t6, t5, 10
                  and        sp, s3, s5
                  sltu       t3, t1, tp
                  sub        ra, t1, s11
                  xori       s3, s8, -101
                  mulhu      s1, s9, a1
                  andi       gp, s9, -46
                  xor        a4, a2, s0
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  slli       tp, t1, 9
                  ori        t1, ra, -664
                  divu       s3, gp, a2
                  xori       s3, s8, -101
                  sltu       t3, t1, tp
                  div        zero, a7, s0
                  sub        ra, t1, s11
                  sra        t1, t1, a0
                  lui        s6, 496523
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  srai       s8, t0, 25
                  remu       s0, t0, gp
                  lui        s6, 496523
                  nop
                  nop
                  srli       t6, t5, 10
                  addi       s3, a2, 677
                  sub        ra, t1, s11
                  or         a7, a0, zero
                  mulhsu     s8, sp, s5
                  xori       s3, s8, -101
                  andi       gp, s9, -46
                  mulhsu     s8, sp, s5
                  sub        ra, t1, s11
                  slt        a1, a1, zero
                  auipc      a4, 925829
                  div        zero, a7, s0
                  sll        s10, sp, a0
                  xori       s3, s8, -101
                  srli       t6, t5, 10
                  remu       s0, t0, gp
                  srai       s8, t0, 25
                  xori       s3, s8, -101
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  mulhsu     s8, sp, s5
                  xor        a4, a2, s0
                  srai       s8, t0, 25
                  lui        s6, 496523
                  mul        a6, t2, s5
                  sra        t1, t1, a0
                  addi       s3, a2, 677
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  rem        a6, s6, a7
                  ori        t1, ra, -664
                  sll        s10, sp, a0
                  div        zero, a7, s0
                  or         a7, a0, zero
                  lui        s6, 496523
                  mulhsu     s8, sp, s5
                  srli       t6, t5, 10
                  or         a7, a0, zero
                  mulhu      s1, s9, a1
                  srai       s8, t0, 25
                  slt        a1, a1, zero
                  addi       s3, a2, 677
                  and        sp, s3, s5
                  mulhsu     s8, sp, s5
                  nop
                  auipc      a4, 925829
                  slli       tp, t1, 9
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  mul        a6, t2, s5
                  srl        zero, t1, a4
                  andi       gp, s9, -46
                  ori        t1, ra, -664
                  mulhu      s1, s9, a1
                  xor        a4, a2, s0
                  srl        zero, t1, a4
                  nop
                  and        sp, s3, s5
                  lui        s6, 496523
                  slt        a1, a1, zero
                  or         a7, a0, zero
                  remu       s0, t0, gp
                  sltu       t3, t1, tp
                  mulh       s2, t1, a3
                  rem        a6, s6, a7
                  sub        ra, t1, s11
                  srli       t6, t5, 10
                  andi       gp, s9, -46
                  srl        zero, t1, a4
                  sub        ra, t1, s11
                  ori        t1, ra, -664
                  sll        s10, sp, a0
                  or         a7, a0, zero
                  sub        ra, t1, s11
                  srai       s8, t0, 25
                  div        zero, a7, s0
                  li         a3, 0xffffffff #start riscv_int_numeric_corner_stream_5
                  li         s4, 0x0
                  li         a6, 0x4d5e9562
                  li         a2, 0x0
                  li         s10, 0xedd788a9
                  li         t4, 0x71a2a48c
                  li         a7, 0xffffffff
                  li         gp, 0x80000000
                  li         t1, 0xffffffff
                  li         s1, 0x285b9feb
                  addi       t1, t1, 677
                  add        a3, a2, a6
                  remu       s10, a6, a2
                  div        gp, t1, s10
                  div        gp, t1, s10
                  mulh       gp, a7, a2
                  rem        a6, a7, t1
                  mul        a6, s4, a6
                  remu       s10, a6, a2
                  nop
                  remu       s10, a6, a2
                  lui        a3, 496523
                  divu       t1, a2, a3
                  nop
                  rem        a6, a7, t1
                  sub        t1, a7, gp
                  nop
                  div        gp, t1, s10 #end riscv_int_numeric_corner_stream_5
                  xor        a4, a2, s0
                  div        zero, a7, s0
                  addi       s3, a2, 677
                  xori       s3, s8, -101
                  mulhu      s1, s9, a1
                  or         a7, a0, zero
                  rem        a6, s6, a7
                  xor        a4, a2, s0
                  srl        zero, t1, a4
                  and        sp, s3, s5
                  auipc      a4, 925829
                  add        tp, gp, s11
                  add        tp, gp, s11
                  addi       s3, a2, 677
                  lui        s6, 496523
                  remu       s0, t0, gp
                  slt        a1, a1, zero
                  lui        s6, 496523
                  nop
                  xor        a4, a2, s0
                  div        zero, a7, s0
                  ori        t1, ra, -664
                  add        tp, gp, s11
                  ori        t1, ra, -664
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  sra        t1, t1, a0
                  ori        t1, ra, -664
                  sub        ra, t1, s11
                  lui        s6, 496523
                  mulh       s2, t1, a3
                  sll        s10, sp, a0
                  rem        a6, s6, a7
                  srl        zero, t1, a4
                  srai       s8, t0, 25
                  and        sp, s3, s5
                  sll        s10, sp, a0
                  sltu       t3, t1, tp
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  remu       s0, t0, gp
                  xori       s3, s8, -101
                  sltu       t3, t1, tp
                  or         a7, a0, zero
                  mulh       s2, t1, a3
                  mulh       s2, t1, a3
                  slli       tp, t1, 9
                  mulhsu     s8, sp, s5
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  remu       s0, t0, gp
                  slli       tp, t1, 9
                  slt        a1, a1, zero
                  sub        ra, t1, s11
                  sll        s10, sp, a0
                  remu       s0, t0, gp
                  mulhu      s1, s9, a1
                  srai       s8, t0, 25
                  srli       t6, t5, 10
                  sltiu      a2, a0, -848
                  lui        s6, 496523
                  mulhu      s1, s9, a1
                  div        zero, a7, s0
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  mulhu      s1, s9, a1
                  sltu       t3, t1, tp
                  mul        a6, t2, s5
                  mulhu      s1, s9, a1
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  xori       s3, s8, -101
                  slli       tp, t1, 9
                  sltu       t3, t1, tp
                  xori       s3, s8, -101
                  sltiu      a2, a0, -848
                  sltiu      a2, a0, -848
                  divu       s3, gp, a2
                  mulhu      s1, s9, a1
                  andi       gp, s9, -46
                  lui        s6, 496523
                  mulhu      s1, s9, a1
                  rem        a6, s6, a7
                  mulh       s2, t1, a3
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  remu       s0, t0, gp
                  andi       gp, s9, -46
                  divu       s3, gp, a2
                  sub        ra, t1, s11
                  ori        t1, ra, -664
                  mulhsu     s8, sp, s5
                  remu       s0, t0, gp
                  srl        zero, t1, a4
                  mulh       s2, t1, a3
                  xor        a4, a2, s0
                  sltiu      a2, a0, -848
                  nop
                  srl        zero, t1, a4
                  sub        ra, t1, s11
                  addi       s3, a2, 677
                  sltiu      a2, a0, -848
                  ori        t1, ra, -664
                  srai       s8, t0, 25
                  srli       t6, t5, 10
                  auipc      a4, 925829
                  xori       s3, s8, -101
                  sll        s10, sp, a0
                  and        sp, s3, s5
                  slti       s10, s8, -890
                  and        sp, s3, s5
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  remu       s0, t0, gp
                  sra        t1, t1, a0
                  xori       s3, s8, -101
                  mulhu      s1, s9, a1
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  xor        a4, a2, s0
                  or         a7, a0, zero
                  mulhu      s1, s9, a1
                  addi       s3, a2, 677
                  sub        ra, t1, s11
                  divu       s3, gp, a2
                  xor        a4, a2, s0
                  divu       s3, gp, a2
                  add        tp, gp, s11
                  auipc      a4, 925829
                  remu       s0, t0, gp
                  xori       s3, s8, -101
                  sub        ra, t1, s11
                  divu       s3, gp, a2
                  add        tp, gp, s11
                  ori        t1, ra, -664
                  slt        a1, a1, zero
                  srl        zero, t1, a4
                  sltu       t3, t1, tp
                  ori        t1, ra, -664
                  div        zero, a7, s0
                  add        tp, gp, s11
                  sra        t1, t1, a0
                  add        tp, gp, s11
                  divu       s3, gp, a2
                  xor        a4, a2, s0
                  add        tp, gp, s11
                  sltiu      a2, a0, -848
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  mulhsu     s8, sp, s5
                  rem        a6, s6, a7
                  add        tp, gp, s11
                  nop
                  remu       s0, t0, gp
                  or         a7, a0, zero
                  srai       s8, t0, 25
                  srl        zero, t1, a4
                  srai       s8, t0, 25
                  sub        ra, t1, s11
                  andi       gp, s9, -46
                  srli       t6, t5, 10
                  sub        ra, t1, s11
                  mulh       s2, t1, a3
                  mulhsu     s8, sp, s5
                  mulhu      s1, s9, a1
                  mulh       s2, t1, a3
                  sll        s10, sp, a0
                  addi       s3, a2, 677
                  sll        s10, sp, a0
                  srl        zero, t1, a4
                  nop
                  sub        ra, t1, s11
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  slt        a1, a1, zero
                  div        zero, a7, s0
                  srl        zero, t1, a4
                  xori       s3, s8, -101
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  mulhu      s1, s9, a1
                  mul        a6, t2, s5
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  ori        t1, ra, -664
                  mulhsu     s8, sp, s5
                  mulhsu     s8, sp, s5
                  sll        s10, sp, a0
                  lui        s6, 496523
                  addi       s3, a2, 677
                  mulhsu     s8, sp, s5
                  mulh       s2, t1, a3
                  rem        a6, s6, a7
                  sra        t1, t1, a0
                  slti       s10, s8, -890
                  nop
                  remu       s0, t0, gp
                  auipc      a4, 925829
                  sra        t1, t1, a0
                  mulh       s2, t1, a3
                  slli       tp, t1, 9
                  xori       s3, s8, -101
                  addi       s3, a2, 677
                  srai       s8, t0, 25
                  sub        ra, t1, s11
                  sra        t1, t1, a0
                  addi       s3, a2, 677
                  sltu       t3, t1, tp
                  srl        zero, t1, a4
                  srl        zero, t1, a4
                  sltiu      a2, a0, -848
                  or         a7, a0, zero
                  slli       tp, t1, 9
                  mul        a6, t2, s5
                  div        zero, a7, s0
                  mul        a6, t2, s5
                  sltiu      a2, a0, -848
                  sltiu      a2, a0, -848
                  remu       s0, t0, gp
                  srl        zero, t1, a4
                  addi       s3, a2, 677
                  srl        zero, t1, a4
                  remu       s0, t0, gp
                  slti       s10, s8, -890
                  sra        t1, t1, a0
                  mulhsu     s8, sp, s5
                  srli       t6, t5, 10
                  and        sp, s3, s5
                  srli       t6, t5, 10
                  slt        a1, a1, zero
                  mulhsu     s8, sp, s5
                  remu       s0, t0, gp
                  mul        a6, t2, s5
                  ori        t1, ra, -664
                  remu       s0, t0, gp
                  xor        a4, a2, s0
                  mulh       s2, t1, a3
                  slti       s10, s8, -890
                  rem        a6, s6, a7
                  slti       s10, s8, -890
                  mul        a6, t2, s5
                  ori        t1, ra, -664
                  xori       s3, s8, -101
                  mulhsu     s8, sp, s5
                  srli       t6, t5, 10
                  slti       s10, s8, -890
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  srli       t6, t5, 10
                  slt        a1, a1, zero
                  rem        a6, s6, a7
                  sra        t1, t1, a0
                  nop
                  srli       t6, t5, 10
                  sub        ra, t1, s11
                  and        sp, s3, s5
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  slli       tp, t1, 9
                  divu       s3, gp, a2
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  remu       s0, t0, gp
                  sltu       t3, t1, tp
                  xor        a4, a2, s0
                  slt        a1, a1, zero
                  div        zero, a7, s0
                  and        sp, s3, s5
                  mulh       s2, t1, a3
                  sra        t1, t1, a0
                  xor        a4, a2, s0
                  srai       s8, t0, 25
                  nop
                  andi       gp, s9, -46
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  xor        a4, a2, s0
                  slti       s10, s8, -890
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  mul        a6, t2, s5
                  andi       gp, s9, -46
                  xor        a4, a2, s0
                  divu       s3, gp, a2
                  ori        t1, ra, -664
                  or         a7, a0, zero
                  srai       s8, t0, 25
                  slt        a1, a1, zero
                  xori       s3, s8, -101
                  andi       gp, s9, -46
                  mulh       s2, t1, a3
                  mulh       s2, t1, a3
                  and        sp, s3, s5
                  or         a7, a0, zero
                  addi       s3, a2, 677
                  slt        a1, a1, zero
                  auipc      a4, 925829
                  slti       s10, s8, -890
                  mul        a6, t2, s5
                  mulhsu     s8, sp, s5
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  divu       s3, gp, a2
                  ori        t1, ra, -664
                  addi       s3, a2, 677
                  sltiu      a2, a0, -848
                  lui        s6, 496523
                  srai       s8, t0, 25
                  rem        a6, s6, a7
                  rem        a6, s6, a7
                  slli       tp, t1, 9
                  xor        a4, a2, s0
                  mulhsu     s8, sp, s5
                  sub        ra, t1, s11
                  srai       s8, t0, 25
                  div        zero, a7, s0
                  sll        s10, sp, a0
                  slli       tp, t1, 9
                  srai       s8, t0, 25
                  srai       s8, t0, 25
                  divu       s3, gp, a2
                  mulhu      s1, s9, a1
                  and        sp, s3, s5
                  slli       tp, t1, 9
                  nop
                  remu       s0, t0, gp
                  xor        a4, a2, s0
                  srl        zero, t1, a4
                  mulhsu     s8, sp, s5
                  rem        a6, s6, a7
                  slt        a1, a1, zero
                  sub        ra, t1, s11
                  sll        s10, sp, a0
                  mul        a6, t2, s5
                  div        zero, a7, s0
                  addi       s3, a2, 677
                  srl        zero, t1, a4
                  lui        s6, 496523
                  mulh       s2, t1, a3
                  or         a7, a0, zero
                  sll        s10, sp, a0
                  sll        s10, sp, a0
                  xor        a4, a2, s0
                  mulh       s2, t1, a3
                  mulhu      s1, s9, a1
                  divu       s3, gp, a2
                  sra        t1, t1, a0
                  nop
                  mulhu      s1, s9, a1
                  sra        t1, t1, a0
                  add        tp, gp, s11
                  and        sp, s3, s5
                  srai       s8, t0, 25
                  div        zero, a7, s0
                  auipc      a4, 925829
                  sub        ra, t1, s11
                  srl        zero, t1, a4
                  and        sp, s3, s5
                  addi       s3, a2, 677
                  remu       s0, t0, gp
                  or         a7, a0, zero
                  or         a7, a0, zero
                  mulh       s2, t1, a3
                  sltiu      a2, a0, -848
                  divu       s3, gp, a2
                  lui        s6, 496523
                  remu       s0, t0, gp
                  mulhu      s1, s9, a1
                  mulh       s2, t1, a3
                  srli       t6, t5, 10
                  xor        a4, a2, s0
                  ori        t1, ra, -664
                  rem        a6, s6, a7
                  lui        s6, 496523
                  ori        t1, ra, -664
                  ori        t1, ra, -664
                  divu       s3, gp, a2
                  sub        ra, t1, s11
                  xor        a4, a2, s0
                  sltiu      a2, a0, -848
                  sra        t1, t1, a0
                  mulhsu     s8, sp, s5
                  mulhsu     s8, sp, s5
                  xori       s3, s8, -101
                  slt        a1, a1, zero
                  sltiu      a2, a0, -848
                  divu       s3, gp, a2
                  xori       s3, s8, -101
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  rem        a6, s6, a7
                  lui        s6, 496523
                  mulh       s2, t1, a3
                  mul        a6, t2, s5
                  add        tp, gp, s11
                  div        zero, a7, s0
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  and        sp, s3, s5
                  ori        t1, ra, -664
                  slt        a1, a1, zero
                  xori       s3, s8, -101
                  andi       gp, s9, -46
                  mulh       s2, t1, a3
                  andi       gp, s9, -46
                  slli       tp, t1, 9
                  addi       s3, a2, 677
                  add        tp, gp, s11
                  srai       s8, t0, 25
                  srl        zero, t1, a4
                  andi       gp, s9, -46
                  xori       s3, s8, -101
                  sub        ra, t1, s11
                  slli       tp, t1, 9
                  slti       s10, s8, -890
                  add        tp, gp, s11
                  rem        a6, s6, a7
                  srli       t6, t5, 10
                  xor        a4, a2, s0
                  slli       tp, t1, 9
                  rem        a6, s6, a7
                  srai       s8, t0, 25
                  srli       t6, t5, 10
                  slli       tp, t1, 9
                  addi       s3, a2, 677
                  and        sp, s3, s5
                  auipc      a4, 925829
                  ori        t1, ra, -664
                  srli       t6, t5, 10
                  lui        s6, 496523
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  srl        zero, t1, a4
                  add        tp, gp, s11
                  andi       gp, s9, -46
                  sra        t1, t1, a0
                  sub        ra, t1, s11
                  xori       s3, s8, -101
                  xor        a4, a2, s0
                  xor        a4, a2, s0
                  li         t5, 0x80000000 #start riscv_int_numeric_corner_stream_33
                  li         a1, 0x80000000
                  li         s6, 0xffffffff
                  li         s7, 0x0
                  li         gp, 0x0
                  li         s10, 0x80000000
                  li         a2, 0x96ce93e9
                  li         a7, 0x9bc39dfc
                  li         t4, 0x0
                  li         t2, 0x0
                  mul        s6, s10, s6
                  auipc      t5, 925829
                  div        gp, t2, t4
                  mulhsu     s7, a1, s6
                  remu       t4, s6, a2
                  mulhu      t5, t5, a1
                  mulh       gp, s7, a2
                  mulhu      t5, t5, a1
                  mulh       gp, s7, a2
                  remu       t4, s6, a2
                  mulh       gp, s7, a2
                  addi       t2, t2, 677
                  divu       t2, a2, a7
                  divu       t2, a2, a7
                  sub        t2, s7, gp
                  mulhu      t5, t5, a1
                  rem        s6, s7, t2
                  mulhsu     s7, a1, s6
                  nop
                  remu       t4, s6, a2
                  remu       t4, s6, a2
                  mulhu      t5, t5, a1
                  add        a7, a2, s6
                  addi       t2, t2, 677
                  rem        s6, s7, t2
                  lui        a7, 496523
                  mulhsu     s7, a1, s6
                  add        a7, a2, s6
                  remu       t4, s6, a2 #end riscv_int_numeric_corner_stream_33
                  sltiu      a2, a0, -848
                  sltu       t3, t1, tp
                  xori       s3, s8, -101
                  and        sp, s3, s5
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  sll        s10, sp, a0
                  ori        t1, ra, -664
                  andi       gp, s9, -46
                  slti       s10, s8, -890
                  rem        a6, s6, a7
                  mul        a6, t2, s5
                  mulh       s2, t1, a3
                  mulhsu     s8, sp, s5
                  mul        a6, t2, s5
                  mulhsu     s8, sp, s5
                  or         a7, a0, zero
                  and        sp, s3, s5
                  xori       s3, s8, -101
                  and        sp, s3, s5
                  sll        s10, sp, a0
                  srl        zero, t1, a4
                  mul        a6, t2, s5
                  slti       s10, s8, -890
                  div        zero, a7, s0
                  ori        t1, ra, -664
                  xor        a4, a2, s0
                  xori       s3, s8, -101
                  addi       s3, a2, 677
                  rem        a6, s6, a7
                  sltiu      a2, a0, -848
                  sltiu      a2, a0, -848
                  auipc      a4, 925829
                  sll        s10, sp, a0
                  andi       gp, s9, -46
                  slli       tp, t1, 9
                  or         a7, a0, zero
                  xor        a4, a2, s0
                  xor        a4, a2, s0
                  mulh       s2, t1, a3
                  addi       s3, a2, 677
                  lui        s6, 496523
                  rem        a6, s6, a7
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  srl        zero, t1, a4
                  rem        a6, s6, a7
                  sltiu      a2, a0, -848
                  sra        t1, t1, a0
                  addi       s3, a2, 677
                  mulh       s2, t1, a3
                  auipc      a4, 925829
                  addi       s3, a2, 677
                  remu       s0, t0, gp
                  slli       tp, t1, 9
                  sltu       t3, t1, tp
                  srai       s8, t0, 25
                  srl        zero, t1, a4
                  remu       s0, t0, gp
                  slt        a1, a1, zero
                  mulh       s2, t1, a3
                  nop
                  lui        s6, 496523
                  lui        s6, 496523
                  rem        a6, s6, a7
                  ori        t1, ra, -664
                  slti       s10, s8, -890
                  nop
                  sra        t1, t1, a0
                  rem        a6, s6, a7
                  andi       gp, s9, -46
                  lui        s6, 496523
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  ori        t1, ra, -664
                  and        sp, s3, s5
                  lui        s6, 496523
                  rem        a6, s6, a7
                  mulhsu     s8, sp, s5
                  div        zero, a7, s0
                  add        tp, gp, s11
                  andi       gp, s9, -46
                  remu       s0, t0, gp
                  remu       s0, t0, gp
                  rem        a6, s6, a7
                  addi       s3, a2, 677
                  addi       s3, a2, 677
                  mul        a6, t2, s5
                  sll        s10, sp, a0
                  addi       s3, a2, 677
                  srl        zero, t1, a4
                  sltu       t3, t1, tp
                  xor        a4, a2, s0
                  sltu       t3, t1, tp
                  and        sp, s3, s5
                  xor        a4, a2, s0
                  remu       s0, t0, gp
                  srl        zero, t1, a4
                  addi       s3, a2, 677
                  and        sp, s3, s5
                  slti       s10, s8, -890
                  add        tp, gp, s11
                  rem        a6, s6, a7
                  add        tp, gp, s11
                  or         a7, a0, zero
                  xor        a4, a2, s0
                  remu       s0, t0, gp
                  sltu       t3, t1, tp
                  sra        t1, t1, a0
                  nop
                  mul        a6, t2, s5
                  nop
                  lui        s6, 496523
                  div        zero, a7, s0
                  lui        s6, 496523
                  srli       t6, t5, 10
                  sltu       t3, t1, tp
                  add        tp, gp, s11
                  slti       s10, s8, -890
                  ori        t1, ra, -664
                  auipc      a4, 925829
                  sltiu      a2, a0, -848
                  slli       tp, t1, 9
                  andi       gp, s9, -46
                  xori       s3, s8, -101
                  mulhsu     s8, sp, s5
                  mulhsu     s8, sp, s5
                  andi       gp, s9, -46
                  div        zero, a7, s0
                  divu       s3, gp, a2
                  srai       s8, t0, 25
                  addi       s3, a2, 677
                  andi       gp, s9, -46
                  mul        a6, t2, s5
                  andi       gp, s9, -46
                  mulhsu     s8, sp, s5
                  lui        s6, 496523
                  mul        a6, t2, s5
                  xor        a4, a2, s0
                  mulhsu     s8, sp, s5
                  srli       t6, t5, 10
                  mulhu      s1, s9, a1
                  lui        s6, 496523
                  srai       s8, t0, 25
                  remu       s0, t0, gp
                  mulh       s2, t1, a3
                  rem        a6, s6, a7
                  sub        ra, t1, s11
                  auipc      a4, 925829
                  rem        a6, s6, a7
                  divu       s3, gp, a2
                  sltu       t3, t1, tp
                  sltiu      a2, a0, -848
                  ori        t1, ra, -664
                  mulh       s2, t1, a3
                  mulhu      s1, s9, a1
                  sra        t1, t1, a0
                  slt        a1, a1, zero
                  srli       t6, t5, 10
                  mul        a6, t2, s5
                  sll        s10, sp, a0
                  sll        s10, sp, a0
                  sub        ra, t1, s11
                  remu       s0, t0, gp
                  srai       s8, t0, 25
                  mul        a6, t2, s5
                  xori       s3, s8, -101
                  andi       gp, s9, -46
                  mulh       s2, t1, a3
                  mulh       s2, t1, a3
                  nop
                  mul        a6, t2, s5
                  addi       s3, a2, 677
                  slt        a1, a1, zero
                  sltu       t3, t1, tp
                  divu       s3, gp, a2
                  slt        a1, a1, zero
                  sltiu      a2, a0, -848
                  rem        a6, s6, a7
                  andi       gp, s9, -46
                  mulh       s2, t1, a3
                  and        sp, s3, s5
                  sll        s10, sp, a0
                  or         a7, a0, zero
                  ori        t1, ra, -664
                  sll        s10, sp, a0
                  slt        a1, a1, zero
                  remu       s0, t0, gp
                  nop
                  srai       s8, t0, 25
                  li         t2, 0xffffffff #start riscv_int_numeric_corner_stream_19
                  li         gp, 0x0
                  li         a6, 0xffffffff
                  li         s0, 0xffffffff
                  li         a3, 0x80000000
                  li         s5, 0x80000000
                  li         ra, 0x0
                  li         a7, 0x0
                  li         s7, 0x0
                  li         s1, 0xffffffff
                  auipc      s7, 925829
                  mul        a3, a7, a3
                  sub        gp, a6, ra
                  sub        gp, a6, ra
                  mulhsu     a6, t2, a3
                  mulhsu     a6, t2, a3
                  remu       s5, a3, s0
                  divu       gp, s0, s1
                  mulhsu     a6, t2, a3
                  mul        a3, a7, a3
                  rem        a3, a6, gp
                  mulh       ra, a6, s0
                  add        s1, s0, a3
                  sub        gp, a6, ra
                  divu       gp, s0, s1
                  add        s1, s0, a3
                  mulhsu     a6, t2, a3
                  auipc      s7, 925829
                  mulhu      s7, s7, t2
                  rem        a3, a6, gp
                  mulhu      s7, s7, t2
                  addi       gp, gp, 677
                  divu       gp, s0, s1
                  addi       gp, gp, 677
                  nop
                  mulhsu     a6, t2, a3
                  auipc      s7, 925829
                  lui        s1, 496523
                  nop #end riscv_int_numeric_corner_stream_19
                  lui        s6, 496523
                  xori       s3, s8, -101
                  or         a7, a0, zero
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  mulh       s2, t1, a3
                  auipc      a4, 925829
                  nop
                  lui        s6, 496523
                  lui        s6, 496523
                  srli       t6, t5, 10
                  rem        a6, s6, a7
                  srl        zero, t1, a4
                  srli       t6, t5, 10
                  and        sp, s3, s5
                  addi       s3, a2, 677
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  slti       s10, s8, -890
                  srli       t6, t5, 10
                  slli       tp, t1, 9
                  srli       t6, t5, 10
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  ori        t1, ra, -664
                  mul        a6, t2, s5
                  rem        a6, s6, a7
                  mulhu      s1, s9, a1
                  andi       gp, s9, -46
                  sra        t1, t1, a0
                  ori        t1, ra, -664
                  srl        zero, t1, a4
                  srl        zero, t1, a4
                  sra        t1, t1, a0
                  mulh       s2, t1, a3
                  srai       s8, t0, 25
                  li         s5, 0x80000000 #start riscv_int_numeric_corner_stream_14
                  li         s2, 0xffffffff
                  li         t6, 0xffffffff
                  li         a1, 0x0
                  li         s0, 0x80000000
                  li         s7, 0xffffffff
                  li         a3, 0x80000000
                  li         tp, 0x7180a117
                  li         t3, 0xe3e84a10
                  li         t0, 0x0
                  lui        a3, 496523
                  divu       t0, a1, a3
                  mulhsu     s5, s0, s2
                  rem        s2, s5, t0
                  sub        t0, s5, tp
                  div        tp, t0, t3
                  auipc      t6, 925829
                  nop
                  auipc      t6, 925829
                  divu       t0, a1, a3
                  nop
                  lui        a3, 496523
                  add        a3, a1, s2
                  mulhu      t6, t6, s0
                  nop
                  nop
                  lui        a3, 496523
                  addi       t0, t0, 677
                  addi       t0, t0, 677
                  mul        s2, s7, s2
                  div        tp, t0, t3
                  auipc      t6, 925829
                  add        a3, a1, s2
                  sub        t0, s5, tp
                  rem        s2, s5, t0
                  mulhsu     s5, s0, s2 #end riscv_int_numeric_corner_stream_14
                  sltu       t3, t1, tp
                  sltiu      a2, a0, -848
                  or         a7, a0, zero
                  sra        t1, t1, a0
                  mul        a6, t2, s5
                  auipc      a4, 925829
                  addi       s3, a2, 677
                  sltu       t3, t1, tp
                  slt        a1, a1, zero
                  mulhsu     s8, sp, s5
                  sltiu      a2, a0, -848
                  divu       s3, gp, a2
                  andi       gp, s9, -46
                  slti       s10, s8, -890
                  add        tp, gp, s11
                  slli       tp, t1, 9
                  sub        ra, t1, s11
                  sltu       t3, t1, tp
                  sltiu      a2, a0, -848
                  mulhu      s1, s9, a1
                  or         a7, a0, zero
                  slt        a1, a1, zero
                  ori        t1, ra, -664
                  xor        a4, a2, s0
                  mulhsu     s8, sp, s5
                  sltiu      a2, a0, -848
                  add        tp, gp, s11
                  auipc      a4, 925829
                  lui        s6, 496523
                  srli       t6, t5, 10
                  sltu       t3, t1, tp
                  xori       s3, s8, -101
                  sub        ra, t1, s11
                  auipc      a4, 925829
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  divu       s3, gp, a2
                  nop
                  divu       s3, gp, a2
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  srl        zero, t1, a4
                  divu       s3, gp, a2
                  xori       s3, s8, -101
                  and        sp, s3, s5
                  nop
                  sll        s10, sp, a0
                  xor        a4, a2, s0
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  divu       s3, gp, a2
                  mulhsu     s8, sp, s5
                  mul        a6, t2, s5
                  sll        s10, sp, a0
                  slt        a1, a1, zero
                  add        tp, gp, s11
                  srl        zero, t1, a4
                  and        sp, s3, s5
                  sub        ra, t1, s11
                  slt        a1, a1, zero
                  add        tp, gp, s11
                  addi       s3, a2, 677
                  mul        a6, t2, s5
                  xori       s3, s8, -101
                  add        tp, gp, s11
                  srl        zero, t1, a4
                  mulhu      s1, s9, a1
                  xor        a4, a2, s0
                  srl        zero, t1, a4
                  and        sp, s3, s5
                  mul        a6, t2, s5
                  ori        t1, ra, -664
                  sub        ra, t1, s11
                  slt        a1, a1, zero
                  slti       s10, s8, -890
                  sltu       t3, t1, tp
                  lui        s6, 496523
                  mul        a6, t2, s5
                  nop
                  sltu       t3, t1, tp
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  nop
                  slti       s10, s8, -890
                  add        tp, gp, s11
                  or         a7, a0, zero
                  remu       s0, t0, gp
                  divu       s3, gp, a2
                  and        sp, s3, s5
                  mulhu      s1, s9, a1
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  lui        s6, 496523
                  and        sp, s3, s5
                  rem        a6, s6, a7
                  addi       s3, a2, 677
                  ori        t1, ra, -664
                  nop
                  andi       gp, s9, -46
                  xor        a4, a2, s0
                  sra        t1, t1, a0
                  sll        s10, sp, a0
                  rem        a6, s6, a7
                  sub        ra, t1, s11
                  slt        a1, a1, zero
                  slt        a1, a1, zero
                  xor        a4, a2, s0
                  slt        a1, a1, zero
                  nop
                  divu       s3, gp, a2
                  add        tp, gp, s11
                  mul        a6, t2, s5
                  remu       s0, t0, gp
                  and        sp, s3, s5
                  sub        ra, t1, s11
                  lui        s6, 496523
                  divu       s3, gp, a2
                  xori       s3, s8, -101
                  lui        s6, 496523
                  sltu       t3, t1, tp
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  remu       s0, t0, gp
                  addi       s3, a2, 677
                  slt        a1, a1, zero
                  srl        zero, t1, a4
                  rem        a6, s6, a7
                  mulhu      s1, s9, a1
                  slti       s10, s8, -890
                  xori       s3, s8, -101
                  remu       s0, t0, gp
                  div        zero, a7, s0
                  slti       s10, s8, -890
                  remu       s0, t0, gp
                  nop
                  sltu       t3, t1, tp
                  sltu       t3, t1, tp
                  srai       s8, t0, 25
                  lui        s6, 496523
                  or         a7, a0, zero
                  srli       t6, t5, 10
                  divu       s3, gp, a2
                  auipc      a4, 925829
                  slt        a1, a1, zero
                  andi       gp, s9, -46
                  slti       s10, s8, -890
                  or         a7, a0, zero
                  sltu       t3, t1, tp
                  srl        zero, t1, a4
                  mul        a6, t2, s5
                  div        zero, a7, s0
                  addi       s3, a2, 677
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  divu       s3, gp, a2
                  srai       s8, t0, 25
                  lui        s6, 496523
                  divu       s3, gp, a2
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  sltiu      a2, a0, -848
                  mulhu      s1, s9, a1
                  divu       s3, gp, a2
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  sltiu      a2, a0, -848
                  srli       t6, t5, 10
                  ori        t1, ra, -664
                  divu       s3, gp, a2
                  mulh       s2, t1, a3
                  auipc      a4, 925829
                  remu       s0, t0, gp
                  mulhsu     s8, sp, s5
                  rem        a6, s6, a7
                  or         a7, a0, zero
                  rem        a6, s6, a7
                  add        tp, gp, s11
                  auipc      a4, 925829
                  sub        ra, t1, s11
                  remu       s0, t0, gp
                  slt        a1, a1, zero
                  or         a7, a0, zero
                  addi       s3, a2, 677
                  ori        t1, ra, -664
                  sll        s10, sp, a0
                  mulhsu     s8, sp, s5
                  nop
                  divu       s3, gp, a2
                  slti       s10, s8, -890
                  mul        a6, t2, s5
                  sltu       t3, t1, tp
                  lui        s6, 496523
                  or         a7, a0, zero
                  and        sp, s3, s5
                  nop
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  sll        s10, sp, a0
                  sltu       t3, t1, tp
                  slt        a1, a1, zero
                  add        tp, gp, s11
                  lui        s6, 496523
                  slt        a1, a1, zero
                  auipc      a4, 925829
                  divu       s3, gp, a2
                  sltiu      a2, a0, -848
                  slti       s10, s8, -890
                  lui        s6, 496523
                  divu       s3, gp, a2
                  sltu       t3, t1, tp
                  sub        ra, t1, s11
                  mulh       s2, t1, a3
                  mulhsu     s8, sp, s5
                  sltu       t3, t1, tp
                  and        sp, s3, s5
                  auipc      a4, 925829
                  mulhu      s1, s9, a1
                  mulh       s2, t1, a3
                  rem        a6, s6, a7
                  auipc      a4, 925829
                  addi       s3, a2, 677
                  addi       s3, a2, 677
                  slt        a1, a1, zero
                  mulhsu     s8, sp, s5
                  remu       s0, t0, gp
                  slti       s10, s8, -890
                  mul        a6, t2, s5
                  nop
                  slt        a1, a1, zero
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  mulh       s2, t1, a3
                  or         a7, a0, zero
                  ori        t1, ra, -664
                  slt        a1, a1, zero
                  add        tp, gp, s11
                  sra        t1, t1, a0
                  slt        a1, a1, zero
                  auipc      a4, 925829
                  slt        a1, a1, zero
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  nop
                  sub        ra, t1, s11
                  srli       t6, t5, 10
                  sll        s10, sp, a0
                  lui        s6, 496523
                  remu       s0, t0, gp
                  sltu       t3, t1, tp
                  srai       s8, t0, 25
                  divu       s3, gp, a2
                  remu       s0, t0, gp
                  mulh       s2, t1, a3
                  addi       s3, a2, 677
                  sub        ra, t1, s11
                  rem        a6, s6, a7
                  srli       t6, t5, 10
                  nop
                  xor        a4, a2, s0
                  sll        s10, sp, a0
                  ori        t1, ra, -664
                  sub        ra, t1, s11
                  or         a7, a0, zero
                  mul        a6, t2, s5
                  sltu       t3, t1, tp
                  sub        ra, t1, s11
                  xori       s3, s8, -101
                  ori        t1, ra, -664
                  andi       gp, s9, -46
                  divu       s3, gp, a2
                  auipc      a4, 925829
                  mulhu      s1, s9, a1
                  mulhsu     s8, sp, s5
                  auipc      a4, 925829
                  and        sp, s3, s5
                  auipc      a4, 925829
                  srli       t6, t5, 10
                  div        zero, a7, s0
                  addi       s3, a2, 677
                  add        tp, gp, s11
                  andi       gp, s9, -46
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  srli       t6, t5, 10
                  sltiu      a2, a0, -848
                  mulhu      s1, s9, a1
                  div        zero, a7, s0
                  mulhsu     s8, sp, s5
                  andi       gp, s9, -46
                  srl        zero, t1, a4
                  xori       s3, s8, -101
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  sltu       t3, t1, tp
                  add        tp, gp, s11
                  sub        ra, t1, s11
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  mul        a6, t2, s5
                  sltu       t3, t1, tp
                  nop
                  slt        a1, a1, zero
                  sltu       t3, t1, tp
                  div        zero, a7, s0
                  auipc      a4, 925829
                  mulh       s2, t1, a3
                  xor        a4, a2, s0
                  ori        t1, ra, -664
                  add        tp, gp, s11
                  srli       t6, t5, 10
                  mul        a6, t2, s5
                  xori       s3, s8, -101
                  xor        a4, a2, s0
                  sltu       t3, t1, tp
                  add        tp, gp, s11
                  srl        zero, t1, a4
                  remu       s0, t0, gp
                  or         a7, a0, zero
                  xori       s3, s8, -101
                  sltiu      a2, a0, -848
                  and        sp, s3, s5
                  remu       s0, t0, gp
                  xor        a4, a2, s0
                  andi       gp, s9, -46
                  srai       s8, t0, 25
                  srai       s8, t0, 25
                  srli       t6, t5, 10
                  lui        s6, 496523
                  div        zero, a7, s0
                  mul        a6, t2, s5
                  and        sp, s3, s5
                  div        zero, a7, s0
                  divu       s3, gp, a2
                  lui        s6, 496523
                  ori        t1, ra, -664
                  srl        zero, t1, a4
                  auipc      a4, 925829
                  andi       gp, s9, -46
                  srai       s8, t0, 25
                  div        zero, a7, s0
                  div        zero, a7, s0
                  addi       s3, a2, 677
                  lui        s6, 496523
                  slti       s10, s8, -890
                  andi       gp, s9, -46
                  slt        a1, a1, zero
                  xori       s3, s8, -101
                  mulhsu     s8, sp, s5
                  and        sp, s3, s5
                  mulhsu     s8, sp, s5
                  sra        t1, t1, a0
                  mulhu      s1, s9, a1
                  ori        t1, ra, -664
                  mulhsu     s8, sp, s5
                  andi       gp, s9, -46
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  xor        a4, a2, s0
                  sra        t1, t1, a0
                  mulhsu     s8, sp, s5
                  mulhu      s1, s9, a1
                  divu       s3, gp, a2
                  srai       s8, t0, 25
                  slti       s10, s8, -890
                  rem        a6, s6, a7
                  srli       t6, t5, 10
                  srl        zero, t1, a4
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  sll        s10, sp, a0
                  xor        a4, a2, s0
                  addi       s3, a2, 677
                  xori       s3, s8, -101
                  srli       t6, t5, 10
                  or         a7, a0, zero
                  srl        zero, t1, a4
                  rem        a6, s6, a7
                  div        zero, a7, s0
                  remu       s0, t0, gp
                  rem        a6, s6, a7
                  sra        t1, t1, a0
                  addi       s3, a2, 677
                  srli       t6, t5, 10
                  rem        a6, s6, a7
                  lui        s6, 496523
                  nop
                  auipc      a4, 925829
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  add        tp, gp, s11
                  mulh       s2, t1, a3
                  slli       tp, t1, 9
                  lui        s6, 496523
                  rem        a6, s6, a7
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  auipc      a4, 925829
                  lui        s6, 496523
                  nop
                  ori        t1, ra, -664
                  auipc      a4, 925829
                  sltiu      a2, a0, -848
                  mul        a6, t2, s5
                  xor        a4, a2, s0
                  mulhu      s1, s9, a1
                  div        zero, a7, s0
                  andi       gp, s9, -46
                  mul        a6, t2, s5
                  srli       t6, t5, 10
                  mul        a6, t2, s5
                  srl        zero, t1, a4
                  mulh       s2, t1, a3
                  sltu       t3, t1, tp
                  xor        a4, a2, s0
                  mulh       s2, t1, a3
                  mul        a6, t2, s5
                  mulhsu     s8, sp, s5
                  sltu       t3, t1, tp
                  srli       t6, t5, 10
                  mulhu      s1, s9, a1
                  sltiu      a2, a0, -848
                  slli       tp, t1, 9
                  add        tp, gp, s11
                  sll        s10, sp, a0
                  mulhsu     s8, sp, s5
                  addi       s3, a2, 677
                  andi       gp, s9, -46
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  div        zero, a7, s0
                  srli       t6, t5, 10
                  remu       s0, t0, gp
                  div        zero, a7, s0
                  or         a7, a0, zero
                  and        sp, s3, s5
                  divu       s3, gp, a2
                  andi       gp, s9, -46
                  and        sp, s3, s5
                  slt        a1, a1, zero
                  slti       s10, s8, -890
                  srl        zero, t1, a4
                  mulhsu     s8, sp, s5
                  addi       s3, a2, 677
                  srl        zero, t1, a4
                  mulhu      s1, s9, a1
                  andi       gp, s9, -46
                  auipc      a4, 925829
                  mulh       s2, t1, a3
                  mul        a6, t2, s5
                  or         a7, a0, zero
                  slt        a1, a1, zero
                  andi       gp, s9, -46
                  andi       gp, s9, -46
                  add        tp, gp, s11
                  auipc      a4, 925829
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  nop
                  andi       gp, s9, -46
                  slti       s10, s8, -890
                  sltu       t3, t1, tp
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  sltiu      a2, a0, -848
                  xori       s3, s8, -101
                  lui        s6, 496523
                  xor        a4, a2, s0
                  add        tp, gp, s11
                  ori        t1, ra, -664
                  mulhsu     s8, sp, s5
                  sra        t1, t1, a0
                  sltu       t3, t1, tp
                  mulhu      s1, s9, a1
                  ori        t1, ra, -664
                  rem        a6, s6, a7
                  sltu       t3, t1, tp
                  slli       tp, t1, 9
                  srai       s8, t0, 25
                  div        zero, a7, s0
                  add        tp, gp, s11
                  ori        t1, ra, -664
                  srl        zero, t1, a4
                  sra        t1, t1, a0
                  srl        zero, t1, a4
                  or         a7, a0, zero
                  lui        s6, 496523
                  auipc      a4, 925829
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  mulhu      s1, s9, a1
                  lui        s6, 496523
                  rem        a6, s6, a7
                  addi       s3, a2, 677
                  srl        zero, t1, a4
                  auipc      a4, 925829
                  add        tp, gp, s11
                  slli       tp, t1, 9
                  mul        a6, t2, s5
                  srli       t6, t5, 10
                  mulhu      s1, s9, a1
                  sltu       t3, t1, tp
                  addi       s3, a2, 677
                  auipc      a4, 925829
                  ori        t1, ra, -664
                  sra        t1, t1, a0
                  sltu       t3, t1, tp
                  nop
                  nop
                  divu       s3, gp, a2
                  sltiu      a2, a0, -848
                  auipc      a4, 925829
                  divu       s3, gp, a2
                  xor        a4, a2, s0
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  xor        a4, a2, s0
                  mulhu      s1, s9, a1
                  mulhu      s1, s9, a1
                  slli       tp, t1, 9
                  srl        zero, t1, a4
                  mulhu      s1, s9, a1
                  or         a7, a0, zero
                  nop
                  mulhsu     s8, sp, s5
                  sltu       t3, t1, tp
                  ori        t1, ra, -664
                  srai       s8, t0, 25
                  srai       s8, t0, 25
                  divu       s3, gp, a2
                  auipc      a4, 925829
                  sltiu      a2, a0, -848
                  srl        zero, t1, a4
                  mulh       s2, t1, a3
                  xor        a4, a2, s0
                  srli       t6, t5, 10
                  slti       s10, s8, -890
                  add        tp, gp, s11
                  mul        a6, t2, s5
                  div        zero, a7, s0
                  and        sp, s3, s5
                  slli       tp, t1, 9
                  mulh       s2, t1, a3
                  mul        a6, t2, s5
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  sra        t1, t1, a0
                  sll        s10, sp, a0
                  and        sp, s3, s5
                  mul        a6, t2, s5
                  srl        zero, t1, a4
                  slli       tp, t1, 9
                  remu       s0, t0, gp
                  remu       s0, t0, gp
                  srl        zero, t1, a4
                  lui        s6, 496523
                  xor        a4, a2, s0
                  slli       tp, t1, 9
                  sub        ra, t1, s11
                  srai       s8, t0, 25
                  andi       gp, s9, -46
                  slti       s10, s8, -890
                  sra        t1, t1, a0
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  sub        ra, t1, s11
                  mulhu      s1, s9, a1
                  divu       s3, gp, a2
                  sltiu      a2, a0, -848
                  slt        a1, a1, zero
                  slti       s10, s8, -890
                  mulhsu     s8, sp, s5
                  xor        a4, a2, s0
                  sub        ra, t1, s11
                  xori       s3, s8, -101
                  srli       t6, t5, 10
                  xori       s3, s8, -101
                  mul        a6, t2, s5
                  andi       gp, s9, -46
                  add        tp, gp, s11
                  nop
                  slli       tp, t1, 9
                  rem        a6, s6, a7
                  slti       s10, s8, -890
                  xori       s3, s8, -101
                  addi       s3, a2, 677
                  addi       s3, a2, 677
                  mul        a6, t2, s5
                  srl        zero, t1, a4
                  rem        a6, s6, a7
                  remu       s0, t0, gp
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  ori        t1, ra, -664
                  add        tp, gp, s11
                  mulhsu     s8, sp, s5
                  div        zero, a7, s0
                  mulhu      s1, s9, a1
                  mulh       s2, t1, a3
                  div        zero, a7, s0
                  sra        t1, t1, a0
                  sltu       t3, t1, tp
                  slli       tp, t1, 9
                  srai       s8, t0, 25
                  addi       s3, a2, 677
                  sub        ra, t1, s11
                  rem        a6, s6, a7
                  sub        ra, t1, s11
                  sra        t1, t1, a0
                  or         a7, a0, zero
                  nop
                  div        zero, a7, s0
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  addi       s3, a2, 677
                  sltu       t3, t1, tp
                  srl        zero, t1, a4
                  and        sp, s3, s5
                  sltu       t3, t1, tp
                  lui        s6, 496523
                  xor        a4, a2, s0
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  or         a7, a0, zero
                  addi       s3, a2, 677
                  ori        t1, ra, -664
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  xor        a4, a2, s0
                  sub        ra, t1, s11
                  auipc      a4, 925829
                  sltiu      a2, a0, -848
                  mulh       s2, t1, a3
                  slti       s10, s8, -890
                  andi       gp, s9, -46
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  nop
                  andi       gp, s9, -46
                  auipc      a4, 925829
                  auipc      a4, 925829
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  xori       s3, s8, -101
                  mul        a6, t2, s5
                  srai       s8, t0, 25
                  auipc      a4, 925829
                  srl        zero, t1, a4
                  slti       s10, s8, -890
                  andi       gp, s9, -46
                  div        zero, a7, s0
                  addi       s3, a2, 677
                  addi       s3, a2, 677
                  sltiu      a2, a0, -848
                  and        sp, s3, s5
                  div        zero, a7, s0
                  rem        a6, s6, a7
                  divu       s3, gp, a2
                  sll        s10, sp, a0
                  srli       t6, t5, 10
                  sub        ra, t1, s11
                  and        sp, s3, s5
                  lui        s6, 496523
                  sra        t1, t1, a0
                  srai       s8, t0, 25
                  slt        a1, a1, zero
                  mulhsu     s8, sp, s5
                  div        zero, a7, s0
                  remu       s0, t0, gp
                  auipc      a4, 925829
                  slli       tp, t1, 9
                  and        sp, s3, s5
                  lui        s6, 496523
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  and        sp, s3, s5
                  slt        a1, a1, zero
                  sra        t1, t1, a0
                  xori       s3, s8, -101
                  slti       s10, s8, -890
                  slt        a1, a1, zero
                  sltu       t3, t1, tp
                  remu       s0, t0, gp
                  div        zero, a7, s0
                  addi       s3, a2, 677
                  slti       s10, s8, -890
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  sltiu      a2, a0, -848
                  srl        zero, t1, a4
                  srai       s8, t0, 25
                  addi       s3, a2, 677
                  addi       s3, a2, 677
                  srli       t6, t5, 10
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  slt        a1, a1, zero
                  xori       s3, s8, -101
                  xor        a4, a2, s0
                  sra        t1, t1, a0
                  ori        t1, ra, -664
                  srai       s8, t0, 25
                  and        sp, s3, s5
                  auipc      a4, 925829
                  sub        ra, t1, s11
                  slt        a1, a1, zero
                  addi       s3, a2, 677
                  srli       t6, t5, 10
                  rem        a6, s6, a7
                  addi       s3, a2, 677
                  andi       gp, s9, -46
                  rem        a6, s6, a7
                  xor        a4, a2, s0
                  sltiu      a2, a0, -848
                  xor        a4, a2, s0
                  slt        a1, a1, zero
                  rem        a6, s6, a7
                  divu       s3, gp, a2
                  andi       gp, s9, -46
                  xori       s3, s8, -101
                  and        sp, s3, s5
                  auipc      a4, 925829
                  divu       s3, gp, a2
                  sra        t1, t1, a0
                  lui        s6, 496523
                  mulhu      s1, s9, a1
                  sltiu      a2, a0, -848
                  slti       s10, s8, -890
                  addi       s3, a2, 677
                  slti       s10, s8, -890
                  mul        a6, t2, s5
                  mul        a6, t2, s5
                  mulhsu     s8, sp, s5
                  xori       s3, s8, -101
                  slt        a1, a1, zero
                  mulh       s2, t1, a3
                  div        zero, a7, s0
                  andi       gp, s9, -46
                  add        tp, gp, s11
                  lui        s6, 496523
                  xori       s3, s8, -101
                  lui        s6, 496523
                  addi       s3, a2, 677
                  add        tp, gp, s11
                  or         a7, a0, zero
                  sltiu      a2, a0, -848
                  mulhsu     s8, sp, s5
                  nop
                  slti       s10, s8, -890
                  mul        a6, t2, s5
                  sltu       t3, t1, tp
                  mulhsu     s8, sp, s5
                  auipc      a4, 925829
                  mulh       s2, t1, a3
                  sra        t1, t1, a0
                  sltu       t3, t1, tp
                  sub        ra, t1, s11
                  sltu       t3, t1, tp
                  mulh       s2, t1, a3
                  addi       s3, a2, 677
                  lui        s6, 496523
                  srl        zero, t1, a4
                  xori       s3, s8, -101
                  lui        s6, 496523
                  lui        s6, 496523
                  mulhsu     s8, sp, s5
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  remu       s0, t0, gp
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  srai       s8, t0, 25
                  rem        a6, s6, a7
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  and        sp, s3, s5
                  xori       s3, s8, -101
                  slti       s10, s8, -890
                  mulhsu     s8, sp, s5
                  slli       tp, t1, 9
                  mulhu      s1, s9, a1
                  mulhsu     s8, sp, s5
                  li         t0, 0x80000000 #start riscv_int_numeric_corner_stream_8
                  li         sp, 0x0
                  li         s1, 0xffffffff
                  li         s0, 0x18ddd8f1
                  li         a3, 0x0
                  li         a7, 0xc41bed06
                  li         s7, 0x54e4d5db
                  li         t2, 0xffffffff
                  li         t6, 0x80000000
                  li         s5, 0xd13bc4c0
                  sub        t0, a7, sp
                  remu       s7, a3, s0
                  auipc      t6, 925829
                  add        s1, s0, a3
                  divu       t0, s0, s1
                  mulhsu     a7, t2, a3
                  remu       s7, a3, s0
                  auipc      t6, 925829
                  add        s1, s0, a3
                  rem        a3, a7, t0
                  mul        a3, s5, a3
                  sub        t0, a7, sp
                  remu       s7, a3, s0
                  mulhu      t6, t6, t2
                  mul        a3, s5, a3
                  add        s1, s0, a3
                  rem        a3, a7, t0
                  addi       t0, t0, 677 #end riscv_int_numeric_corner_stream_8
                  addi       s3, a2, 677
                  sub        ra, t1, s11
                  mulhu      s1, s9, a1
                  div        zero, a7, s0
                  slli       tp, t1, 9
                  mulh       s2, t1, a3
                  mul        a6, t2, s5
                  sltu       t3, t1, tp
                  divu       s3, gp, a2
                  andi       gp, s9, -46
                  sub        ra, t1, s11
                  mul        a6, t2, s5
                  or         a7, a0, zero
                  sll        s10, sp, a0
                  remu       s0, t0, gp
                  rem        a6, s6, a7
                  xori       s3, s8, -101
                  mulhu      s1, s9, a1
                  sll        s10, sp, a0
                  srai       s8, t0, 25
                  nop
                  slti       s10, s8, -890
                  slt        a1, a1, zero
                  sub        ra, t1, s11
                  slt        a1, a1, zero
                  srli       t6, t5, 10
                  addi       s3, a2, 677
                  sub        ra, t1, s11
                  sltu       t3, t1, tp
                  and        sp, s3, s5
                  slt        a1, a1, zero
                  nop
                  ori        t1, ra, -664
                  sub        ra, t1, s11
                  div        zero, a7, s0
                  remu       s0, t0, gp
                  sltu       t3, t1, tp
                  or         a7, a0, zero
                  mul        a6, t2, s5
                  sub        ra, t1, s11
                  sltu       t3, t1, tp
                  xori       s3, s8, -101
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  srai       s8, t0, 25
                  and        sp, s3, s5
                  srli       t6, t5, 10
                  auipc      a4, 925829
                  mul        a6, t2, s5
                  rem        a6, s6, a7
                  remu       s0, t0, gp
                  add        tp, gp, s11
                  nop
                  or         a7, a0, zero
                  sra        t1, t1, a0
                  slli       tp, t1, 9
                  divu       s3, gp, a2
                  div        zero, a7, s0
                  or         a7, a0, zero
                  sra        t1, t1, a0
                  srl        zero, t1, a4
                  div        zero, a7, s0
                  slli       tp, t1, 9
                  remu       s0, t0, gp
                  mul        a6, t2, s5
                  sltu       t3, t1, tp
                  slt        a1, a1, zero
                  mulhu      s1, s9, a1
                  mulh       s2, t1, a3
                  rem        a6, s6, a7
                  mulhsu     s8, sp, s5
                  mulh       s2, t1, a3
                  sll        s10, sp, a0
                  addi       s3, a2, 677
                  mulhsu     s8, sp, s5
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  or         a7, a0, zero
                  sltu       t3, t1, tp
                  srli       t6, t5, 10
                  slt        a1, a1, zero
                  slti       s10, s8, -890
                  xor        a4, a2, s0
                  srli       t6, t5, 10
                  addi       s3, a2, 677
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  rem        a6, s6, a7
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  ori        t1, ra, -664
                  div        zero, a7, s0
                  xori       s3, s8, -101
                  slli       tp, t1, 9
                  div        zero, a7, s0
                  sltiu      a2, a0, -848
                  or         a7, a0, zero
                  sra        t1, t1, a0
                  sltu       t3, t1, tp
                  nop
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  mulh       s2, t1, a3
                  srai       s8, t0, 25
                  nop
                  mulhsu     s8, sp, s5
                  mulhu      s1, s9, a1
                  andi       gp, s9, -46
                  or         a7, a0, zero
                  nop
                  addi       s3, a2, 677
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  slti       s10, s8, -890
                  mulhsu     s8, sp, s5
                  mulhu      s1, s9, a1
                  slli       tp, t1, 9
                  slti       s10, s8, -890
                  sub        ra, t1, s11
                  slti       s10, s8, -890
                  sra        t1, t1, a0
                  rem        a6, s6, a7
                  lui        s6, 496523
                  divu       s3, gp, a2
                  add        tp, gp, s11
                  div        zero, a7, s0
                  auipc      a4, 925829
                  sra        t1, t1, a0
                  mulh       s2, t1, a3
                  div        zero, a7, s0
                  mulhu      s1, s9, a1
                  or         a7, a0, zero
                  slli       tp, t1, 9
                  sub        ra, t1, s11
                  add        tp, gp, s11
                  rem        a6, s6, a7
                  sub        ra, t1, s11
                  srai       s8, t0, 25
                  divu       s3, gp, a2
                  sra        t1, t1, a0
                  xor        a4, a2, s0
                  or         a7, a0, zero
                  sll        s10, sp, a0
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  slli       tp, t1, 9
                  sra        t1, t1, a0
                  ori        t1, ra, -664
                  add        tp, gp, s11
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  sra        t1, t1, a0
                  mulhu      s1, s9, a1
                  or         a7, a0, zero
                  slt        a1, a1, zero
                  slt        a1, a1, zero
                  divu       s3, gp, a2
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  and        sp, s3, s5
                  andi       gp, s9, -46
                  sltu       t3, t1, tp
                  div        zero, a7, s0
                  sll        s10, sp, a0
                  sra        t1, t1, a0
                  mul        a6, t2, s5
                  sra        t1, t1, a0
                  mulh       s2, t1, a3
                  ori        t1, ra, -664
                  sll        s10, sp, a0
                  srai       s8, t0, 25
                  srai       s8, t0, 25
                  sltiu      a2, a0, -848
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  andi       gp, s9, -46
                  div        zero, a7, s0
                  andi       gp, s9, -46
                  and        sp, s3, s5
                  div        zero, a7, s0
                  sub        ra, t1, s11
                  slli       tp, t1, 9
                  add        tp, gp, s11
                  mul        a6, t2, s5
                  addi       s3, a2, 677
                  mulhsu     s8, sp, s5
                  rem        a6, s6, a7
                  remu       s0, t0, gp
                  sltiu      a2, a0, -848
                  lui        s6, 496523
                  or         a7, a0, zero
                  mul        a6, t2, s5
                  xori       s3, s8, -101
                  sll        s10, sp, a0
                  sub        ra, t1, s11
                  xori       s3, s8, -101
                  add        tp, gp, s11
                  div        zero, a7, s0
                  nop
                  nop
                  sub        ra, t1, s11
                  sll        s10, sp, a0
                  xor        a4, a2, s0
                  sltiu      a2, a0, -848
                  xori       s3, s8, -101
                  andi       gp, s9, -46
                  lui        s6, 496523
                  nop
                  or         a7, a0, zero
                  rem        a6, s6, a7
                  mulh       s2, t1, a3
                  srli       t6, t5, 10
                  sltu       t3, t1, tp
                  divu       s3, gp, a2
                  srli       t6, t5, 10
                  auipc      a4, 925829
                  slt        a1, a1, zero
                  addi       s3, a2, 677
                  or         a7, a0, zero
                  srli       t6, t5, 10
                  mul        a6, t2, s5
                  sll        s10, sp, a0
                  mulh       s2, t1, a3
                  and        sp, s3, s5
                  divu       s3, gp, a2
                  mul        a6, t2, s5
                  andi       gp, s9, -46
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  remu       s0, t0, gp
                  addi       s3, a2, 677
                  lui        s6, 496523
                  nop
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  ori        t1, ra, -664
                  and        sp, s3, s5
                  srli       t6, t5, 10
                  slt        a1, a1, zero
                  sltu       t3, t1, tp
                  slti       s10, s8, -890
                  sltu       t3, t1, tp
                  slt        a1, a1, zero
                  srai       s8, t0, 25
                  mul        a6, t2, s5
                  div        zero, a7, s0
                  slt        a1, a1, zero
                  divu       s3, gp, a2
                  add        tp, gp, s11
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  div        zero, a7, s0
                  sll        s10, sp, a0
                  sra        t1, t1, a0
                  sltu       t3, t1, tp
                  srai       s8, t0, 25
                  auipc      a4, 925829
                  sra        t1, t1, a0
                  mul        a6, t2, s5
                  sltu       t3, t1, tp
                  sltiu      a2, a0, -848
                  auipc      a4, 925829
                  sll        s10, sp, a0
                  lui        s6, 496523
                  and        sp, s3, s5
                  addi       s3, a2, 677
                  ori        t1, ra, -664
                  div        zero, a7, s0
                  rem        a6, s6, a7
                  add        tp, gp, s11
                  rem        a6, s6, a7
                  slli       tp, t1, 9
                  and        sp, s3, s5
                  add        tp, gp, s11
                  srli       t6, t5, 10
                  sltiu      a2, a0, -848
                  slti       s10, s8, -890
                  srai       s8, t0, 25
                  srl        zero, t1, a4
                  slti       s10, s8, -890
                  slli       tp, t1, 9
                  srai       s8, t0, 25
                  srli       t6, t5, 10
                  mulh       s2, t1, a3
                  sltiu      a2, a0, -848
                  remu       s0, t0, gp
                  srai       s8, t0, 25
                  or         a7, a0, zero
                  mulhu      s1, s9, a1
                  sll        s10, sp, a0
                  rem        a6, s6, a7
                  srai       s8, t0, 25
                  ori        t1, ra, -664
                  remu       s0, t0, gp
                  ori        t1, ra, -664
                  sra        t1, t1, a0
                  sll        s10, sp, a0
                  remu       s0, t0, gp
                  sub        ra, t1, s11
                  ori        t1, ra, -664
                  auipc      a4, 925829
                  auipc      a4, 925829
                  div        zero, a7, s0
                  nop
                  and        sp, s3, s5
                  sll        s10, sp, a0
                  sltiu      a2, a0, -848
                  mul        a6, t2, s5
                  rem        a6, s6, a7
                  or         a7, a0, zero
                  rem        a6, s6, a7
                  srl        zero, t1, a4
                  xori       s3, s8, -101
                  sltiu      a2, a0, -848
                  andi       gp, s9, -46
                  remu       s0, t0, gp
                  auipc      a4, 925829
                  nop
                  xori       s3, s8, -101
                  lui        s6, 496523
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  ori        t1, ra, -664
                  nop
                  mulh       s2, t1, a3
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  srai       s8, t0, 25
                  or         a7, a0, zero
                  addi       s3, a2, 677
                  slli       tp, t1, 9
                  srli       t6, t5, 10
                  mul        a6, t2, s5
                  xori       s3, s8, -101
                  addi       s3, a2, 677
                  xori       s3, s8, -101
                  remu       s0, t0, gp
                  mulhsu     s8, sp, s5
                  div        zero, a7, s0
                  div        zero, a7, s0
                  and        sp, s3, s5
                  sltiu      a2, a0, -848
                  xor        a4, a2, s0
                  slti       s10, s8, -890
                  or         a7, a0, zero
                  mulhsu     s8, sp, s5
                  mulhu      s1, s9, a1
                  xori       s3, s8, -101
                  remu       s0, t0, gp
                  nop
                  srl        zero, t1, a4
                  add        tp, gp, s11
                  addi       s3, a2, 677
                  sub        ra, t1, s11
                  slti       s10, s8, -890
                  mulh       s2, t1, a3
                  slti       s10, s8, -890
                  rem        a6, s6, a7
                  nop
                  slt        a1, a1, zero
                  sub        ra, t1, s11
                  mulhu      s1, s9, a1
                  addi       s3, a2, 677
                  divu       s3, gp, a2
                  slti       s10, s8, -890
                  lui        s6, 496523
                  lui        s6, 496523
                  lui        s6, 496523
                  mulh       s2, t1, a3
                  xori       s3, s8, -101
                  and        sp, s3, s5
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  andi       gp, s9, -46
                  slt        a1, a1, zero
                  mulh       s2, t1, a3
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  sltu       t3, t1, tp
                  or         a7, a0, zero
                  slti       s10, s8, -890
                  mulh       s2, t1, a3
                  xor        a4, a2, s0
                  add        tp, gp, s11
                  xor        a4, a2, s0
                  addi       s3, a2, 677
                  div        zero, a7, s0
                  mulhsu     s8, sp, s5
                  or         a7, a0, zero
                  auipc      a4, 925829
                  andi       gp, s9, -46
                  remu       s0, t0, gp
                  andi       gp, s9, -46
                  and        sp, s3, s5
                  xori       s3, s8, -101
                  mul        a6, t2, s5
                  sltu       t3, t1, tp
                  add        tp, gp, s11
                  sltiu      a2, a0, -848
                  or         a7, a0, zero
                  srl        zero, t1, a4
                  mulh       s2, t1, a3
                  slti       s10, s8, -890
                  slt        a1, a1, zero
                  sub        ra, t1, s11
                  xori       s3, s8, -101
                  rem        a6, s6, a7
                  srai       s8, t0, 25
                  mulh       s2, t1, a3
                  andi       gp, s9, -46
                  ori        t1, ra, -664
                  srai       s8, t0, 25
                  ori        t1, ra, -664
                  auipc      a4, 925829
                  sll        s10, sp, a0
                  or         a7, a0, zero
                  mulhu      s1, s9, a1
                  slt        a1, a1, zero
                  xori       s3, s8, -101
                  auipc      a4, 925829
                  addi       s3, a2, 677
                  div        zero, a7, s0
                  srai       s8, t0, 25
                  mulhu      s1, s9, a1
                  lui        s6, 496523
                  mulhsu     s8, sp, s5
                  mulhsu     s8, sp, s5
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  sra        t1, t1, a0
                  addi       s3, a2, 677
                  slli       tp, t1, 9
                  and        sp, s3, s5
                  remu       s0, t0, gp
                  mulhu      s1, s9, a1
                  mulh       s2, t1, a3
                  ori        t1, ra, -664
                  divu       s3, gp, a2
                  xori       s3, s8, -101
                  div        zero, a7, s0
                  lui        s6, 496523
                  mulh       s2, t1, a3
                  srli       t6, t5, 10
                  andi       gp, s9, -46
                  mulh       s2, t1, a3
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  addi       s3, a2, 677
                  rem        a6, s6, a7
                  nop
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  mul        a6, t2, s5
                  srli       t6, t5, 10
                  or         a7, a0, zero
                  sltiu      a2, a0, -848
                  andi       gp, s9, -46
                  sltu       t3, t1, tp
                  or         a7, a0, zero
                  slt        a1, a1, zero
                  nop
                  andi       gp, s9, -46
                  and        sp, s3, s5
                  sltiu      a2, a0, -848
                  slli       tp, t1, 9
                  addi       s3, a2, 677
                  auipc      a4, 925829
                  xor        a4, a2, s0
                  mul        a6, t2, s5
                  sra        t1, t1, a0
                  or         a7, a0, zero
                  slt        a1, a1, zero
                  remu       s0, t0, gp
                  ori        t1, ra, -664
                  rem        a6, s6, a7
                  auipc      a4, 925829
                  remu       s0, t0, gp
                  mulhsu     s8, sp, s5
                  divu       s3, gp, a2
                  sub        ra, t1, s11
                  add        tp, gp, s11
                  sra        t1, t1, a0
                  mul        a6, t2, s5
                  xori       s3, s8, -101
                  mulhu      s1, s9, a1
                  mulhu      s1, s9, a1
                  srl        zero, t1, a4
                  rem        a6, s6, a7
                  and        sp, s3, s5
                  slti       s10, s8, -890
                  srl        zero, t1, a4
                  addi       s3, a2, 677
                  sra        t1, t1, a0
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  sub        ra, t1, s11
                  mulhu      s1, s9, a1
                  ori        t1, ra, -664
                  andi       gp, s9, -46
                  mulh       s2, t1, a3
                  sra        t1, t1, a0
                  slli       tp, t1, 9
                  and        sp, s3, s5
                  mulhu      s1, s9, a1
                  mulhsu     s8, sp, s5
                  or         a7, a0, zero
                  remu       s0, t0, gp
                  mulh       s2, t1, a3
                  mulh       s2, t1, a3
                  slt        a1, a1, zero
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  slli       tp, t1, 9
                  slti       s10, s8, -890
                  or         a7, a0, zero
                  sub        ra, t1, s11
                  ori        t1, ra, -664
                  auipc      a4, 925829
                  andi       gp, s9, -46
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  srai       s8, t0, 25
                  mulhu      s1, s9, a1
                  sub        ra, t1, s11
                  rem        a6, s6, a7
                  sll        s10, sp, a0
                  rem        a6, s6, a7
                  sltu       t3, t1, tp
                  addi       s3, a2, 677
                  srl        zero, t1, a4
                  add        tp, gp, s11
                  remu       s0, t0, gp
                  and        sp, s3, s5
                  slti       s10, s8, -890
                  srli       t6, t5, 10
                  and        sp, s3, s5
                  addi       s3, a2, 677
                  rem        a6, s6, a7
                  sltu       t3, t1, tp
                  sub        ra, t1, s11
                  sltiu      a2, a0, -848
                  auipc      a4, 925829
                  sra        t1, t1, a0
                  lui        s6, 496523
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  ori        t1, ra, -664
                  srai       s8, t0, 25
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  mul        a6, t2, s5
                  slti       s10, s8, -890
                  ori        t1, ra, -664
                  slli       tp, t1, 9
                  lui        s6, 496523
                  mulhsu     s8, sp, s5
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  xor        a4, a2, s0
                  and        sp, s3, s5
                  addi       s3, a2, 677
                  mulh       s2, t1, a3
                  xori       s3, s8, -101
                  auipc      a4, 925829
                  div        zero, a7, s0
                  sub        ra, t1, s11
                  slli       tp, t1, 9
                  nop
                  mulhu      s1, s9, a1
                  mulh       s2, t1, a3
                  divu       s3, gp, a2
                  mulh       s2, t1, a3
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  lui        s6, 496523
                  sra        t1, t1, a0
                  addi       s3, a2, 677
                  divu       s3, gp, a2
                  andi       gp, s9, -46
                  remu       s0, t0, gp
                  sltu       t3, t1, tp
                  slti       s10, s8, -890
                  sub        ra, t1, s11
                  and        sp, s3, s5
                  xori       s3, s8, -101
                  mulhsu     s8, sp, s5
                  srli       t6, t5, 10
                  remu       s0, t0, gp
                  mulhu      s1, s9, a1
                  auipc      a4, 925829
                  mulh       s2, t1, a3
                  srai       s8, t0, 25
                  sra        t1, t1, a0
                  slli       tp, t1, 9
                  xori       s3, s8, -101
                  lui        s6, 496523
                  sub        ra, t1, s11
                  srai       s8, t0, 25
                  sltiu      a2, a0, -848
                  slli       tp, t1, 9
                  sub        ra, t1, s11
                  slti       s10, s8, -890
                  addi       s3, a2, 677
                  mul        a6, t2, s5
                  or         a7, a0, zero
                  addi       s3, a2, 677
                  nop
                  sll        s10, sp, a0
                  lui        s6, 496523
                  xor        a4, a2, s0
                  slli       tp, t1, 9
                  nop
                  add        tp, gp, s11
                  auipc      a4, 925829
                  mul        a6, t2, s5
                  mul        a6, t2, s5
                  divu       s3, gp, a2
                  div        zero, a7, s0
                  xor        a4, a2, s0
                  srli       t6, t5, 10
                  div        zero, a7, s0
                  nop
                  divu       s3, gp, a2
                  or         a7, a0, zero
                  mulhu      s1, s9, a1
                  srl        zero, t1, a4
                  auipc      a4, 925829
                  srl        zero, t1, a4
                  slti       s10, s8, -890
                  ori        t1, ra, -664
                  mulh       s2, t1, a3
                  auipc      a4, 925829
                  add        tp, gp, s11
                  ori        t1, ra, -664
                  rem        a6, s6, a7
                  xor        a4, a2, s0
                  div        zero, a7, s0
                  rem        a6, s6, a7
                  auipc      a4, 925829
                  or         a7, a0, zero
                  add        tp, gp, s11
                  ori        t1, ra, -664
                  addi       s3, a2, 677
                  divu       s3, gp, a2
                  srai       s8, t0, 25
                  addi       s3, a2, 677
                  xori       s3, s8, -101
                  rem        a6, s6, a7
                  lui        s6, 496523
                  remu       s0, t0, gp
                  mulhu      s1, s9, a1
                  mulhsu     s8, sp, s5
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  xor        a4, a2, s0
                  sltiu      a2, a0, -848
                  srl        zero, t1, a4
                  mulhu      s1, s9, a1
                  nop
                  remu       s0, t0, gp
                  div        zero, a7, s0
                  sltiu      a2, a0, -848
                  rem        a6, s6, a7
                  lui        s6, 496523
                  sub        ra, t1, s11
                  addi       s3, a2, 677
                  add        tp, gp, s11
                  lui        s6, 496523
                  sll        s10, sp, a0
                  addi       s3, a2, 677
                  sltiu      a2, a0, -848
                  andi       gp, s9, -46
                  sra        t1, t1, a0
                  mulh       s2, t1, a3
                  rem        a6, s6, a7
                  srai       s8, t0, 25
                  mulhsu     s8, sp, s5
                  xori       s3, s8, -101
                  div        zero, a7, s0
                  lui        s6, 496523
                  auipc      a4, 925829
                  ori        t1, ra, -664
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  divu       s3, gp, a2
                  mulh       s2, t1, a3
                  slli       tp, t1, 9
                  andi       gp, s9, -46
                  srl        zero, t1, a4
                  mulhu      s1, s9, a1
                  xori       s3, s8, -101
                  mulhsu     s8, sp, s5
                  andi       gp, s9, -46
                  slti       s10, s8, -890
                  xori       s3, s8, -101
                  sra        t1, t1, a0
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  xor        a4, a2, s0
                  slt        a1, a1, zero
                  addi       s3, a2, 677
                  srli       t6, t5, 10
                  sltu       t3, t1, tp
                  slti       s10, s8, -890
                  rem        a6, s6, a7
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  mulh       s2, t1, a3
                  srai       s8, t0, 25
                  sltiu      a2, a0, -848
                  mulh       s2, t1, a3
                  sub        ra, t1, s11
                  ori        t1, ra, -664
                  slli       tp, t1, 9
                  xor        a4, a2, s0
                  sll        s10, sp, a0
                  mul        a6, t2, s5
                  ori        t1, ra, -664
                  mul        a6, t2, s5
                  xori       s3, s8, -101
                  sll        s10, sp, a0
                  auipc      a4, 925829
                  lui        s6, 496523
                  nop
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  sll        s10, sp, a0
                  srli       t6, t5, 10
                  slti       s10, s8, -890
                  sub        ra, t1, s11
                  mulhu      s1, s9, a1
                  rem        a6, s6, a7
                  div        zero, a7, s0
                  div        zero, a7, s0
                  srl        zero, t1, a4
                  nop
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  sltu       t3, t1, tp
                  div        zero, a7, s0
                  ori        t1, ra, -664
                  remu       s0, t0, gp
                  srai       s8, t0, 25
                  andi       gp, s9, -46
                  andi       gp, s9, -46
                  addi       s3, a2, 677
                  andi       gp, s9, -46
                  xor        a4, a2, s0
                  or         a7, a0, zero
                  srli       t6, t5, 10
                  slti       s10, s8, -890
                  srli       t6, t5, 10
                  sltu       t3, t1, tp
                  lui        s6, 496523
                  divu       s3, gp, a2
                  srl        zero, t1, a4
                  mulhu      s1, s9, a1
                  xor        a4, a2, s0
                  div        zero, a7, s0
                  sltiu      a2, a0, -848
                  xor        a4, a2, s0
                  ori        t1, ra, -664
                  divu       s3, gp, a2
                  nop
                  li         t0, 0x0 #start riscv_int_numeric_corner_stream_31
                  li         a7, 0x0
                  li         a3, 0xffffffff
                  li         t5, 0x0
                  li         s8, 0xffffffff
                  li         s9, 0x3f6e23bc
                  li         t2, 0x80000000
                  li         a2, 0xffffffff
                  li         a1, 0x2dd27b5
                  li         a4, 0xffffffff
                  lui        a3, 496523
                  sub        t2, a7, t0
                  rem        a4, a7, t2
                  divu       t2, a2, a3
                  mul        a4, s8, a4
                  mul        a4, s8, a4
                  mulhsu     a7, a1, a4
                  mulh       t0, a7, a2
                  mul        a4, s8, a4
                  divu       t2, a2, a3
                  sub        t2, a7, t0
                  mulhsu     a7, a1, a4
                  rem        a4, a7, t2
                  divu       t2, a2, a3
                  add        a3, a2, a4
                  remu       s9, a4, a2
                  rem        a4, a7, t2
                  nop
                  mulh       t0, a7, a2
                  auipc      t5, 925829
                  addi       t2, t2, 677
                  remu       s9, a4, a2
                  nop
                  mulhsu     a7, a1, a4
                  rem        a4, a7, t2 #end riscv_int_numeric_corner_stream_31
                  nop
                  sltiu      a2, a0, -848
                  add        tp, gp, s11
                  andi       gp, s9, -46
                  slt        a1, a1, zero
                  add        tp, gp, s11
                  sltu       t3, t1, tp
                  nop
                  slti       s10, s8, -890
                  slti       s10, s8, -890
                  mulhu      s1, s9, a1
                  sub        ra, t1, s11
                  slti       s10, s8, -890
                  nop
                  rem        a6, s6, a7
                  mulhu      s1, s9, a1
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  nop
                  rem        a6, s6, a7
                  mulh       s2, t1, a3
                  sll        s10, sp, a0
                  sltiu      a2, a0, -848
                  divu       s3, gp, a2
                  and        sp, s3, s5
                  remu       s0, t0, gp
                  slti       s10, s8, -890
                  slti       s10, s8, -890
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  remu       s0, t0, gp
                  nop
                  srai       s8, t0, 25
                  rem        a6, s6, a7
                  divu       s3, gp, a2
                  mulhu      s1, s9, a1
                  remu       s0, t0, gp
                  mulhsu     s8, sp, s5
                  addi       s3, a2, 677
                  addi       s3, a2, 677
                  lui        s6, 496523
                  sra        t1, t1, a0
                  sltu       t3, t1, tp
                  srai       s8, t0, 25
                  mul        a6, t2, s5
                  rem        a6, s6, a7
                  sub        ra, t1, s11
                  srl        zero, t1, a4
                  mul        a6, t2, s5
                  slli       tp, t1, 9
                  mulhsu     s8, sp, s5
                  divu       s3, gp, a2
                  slt        a1, a1, zero
                  and        sp, s3, s5
                  srli       t6, t5, 10
                  divu       s3, gp, a2
                  sll        s10, sp, a0
                  slli       tp, t1, 9
                  srai       s8, t0, 25
                  mulh       s2, t1, a3
                  auipc      a4, 925829
                  xori       s3, s8, -101
                  rem        a6, s6, a7
                  mulhsu     s8, sp, s5
                  addi       s3, a2, 677
                  srli       t6, t5, 10
                  add        tp, gp, s11
                  ori        t1, ra, -664
                  sltu       t3, t1, tp
                  sub        ra, t1, s11
                  mulhsu     s8, sp, s5
                  sll        s10, sp, a0
                  mulh       s2, t1, a3
                  or         a7, a0, zero
                  add        tp, gp, s11
                  xor        a4, a2, s0
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  mulhu      s1, s9, a1
                  auipc      a4, 925829
                  ori        t1, ra, -664
                  div        zero, a7, s0
                  xor        a4, a2, s0
                  remu       s0, t0, gp
                  sltiu      a2, a0, -848
                  slti       s10, s8, -890
                  divu       s3, gp, a2
                  srl        zero, t1, a4
                  sltiu      a2, a0, -848
                  srai       s8, t0, 25
                  srli       t6, t5, 10
                  sra        t1, t1, a0
                  add        tp, gp, s11
                  rem        a6, s6, a7
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  sub        ra, t1, s11
                  slti       s10, s8, -890
                  slli       tp, t1, 9
                  and        sp, s3, s5
                  divu       s3, gp, a2
                  mulh       s2, t1, a3
                  or         a7, a0, zero
                  sll        s10, sp, a0
                  sltiu      a2, a0, -848
                  sltu       t3, t1, tp
                  mul        a6, t2, s5
                  slt        a1, a1, zero
                  remu       s0, t0, gp
                  divu       s3, gp, a2
                  lui        s6, 496523
                  sra        t1, t1, a0
                  mulh       s2, t1, a3
                  srai       s8, t0, 25
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  srl        zero, t1, a4
                  lui        s6, 496523
                  mul        a6, t2, s5
                  sltiu      a2, a0, -848
                  slti       s10, s8, -890
                  mulhu      s1, s9, a1
                  add        tp, gp, s11
                  sltiu      a2, a0, -848
                  sll        s10, sp, a0
                  srli       t6, t5, 10
                  srai       s8, t0, 25
                  sra        t1, t1, a0
                  srli       t6, t5, 10
                  srai       s8, t0, 25
                  srli       t6, t5, 10
                  remu       s0, t0, gp
                  srli       t6, t5, 10
                  div        zero, a7, s0
                  sltu       t3, t1, tp
                  mulh       s2, t1, a3
                  sub        ra, t1, s11
                  xor        a4, a2, s0
                  sub        ra, t1, s11
                  div        zero, a7, s0
                  or         a7, a0, zero
                  sltu       t3, t1, tp
                  divu       s3, gp, a2
                  srli       t6, t5, 10
                  srai       s8, t0, 25
                  slli       tp, t1, 9
                  ori        t1, ra, -664
                  divu       s3, gp, a2
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  srli       t6, t5, 10
                  srl        zero, t1, a4
                  auipc      a4, 925829
                  sltiu      a2, a0, -848
                  lui        s6, 496523
                  sll        s10, sp, a0
                  or         a7, a0, zero
                  or         a7, a0, zero
                  nop
                  sltiu      a2, a0, -848
                  addi       s3, a2, 677
                  ori        t1, ra, -664
                  andi       gp, s9, -46
                  divu       s3, gp, a2
                  slti       s10, s8, -890
                  slt        a1, a1, zero
                  andi       gp, s9, -46
                  rem        a6, s6, a7
                  slli       tp, t1, 9
                  remu       s0, t0, gp
                  remu       s0, t0, gp
                  mul        a6, t2, s5
                  lui        s6, 496523
                  divu       s3, gp, a2
                  or         a7, a0, zero
                  xori       s3, s8, -101
                  mul        a6, t2, s5
                  sll        s10, sp, a0
                  auipc      a4, 925829
                  addi       s3, a2, 677
                  sub        ra, t1, s11
                  sltu       t3, t1, tp
                  mulhu      s1, s9, a1
                  sll        s10, sp, a0
                  sltiu      a2, a0, -848
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  mulhsu     s8, sp, s5
                  remu       s0, t0, gp
                  div        zero, a7, s0
                  slt        a1, a1, zero
                  slli       tp, t1, 9
                  ori        t1, ra, -664
                  andi       gp, s9, -46
                  slli       tp, t1, 9
                  slt        a1, a1, zero
                  mulhsu     s8, sp, s5
                  or         a7, a0, zero
                  sra        t1, t1, a0
                  add        tp, gp, s11
                  lui        s6, 496523
                  xori       s3, s8, -101
                  andi       gp, s9, -46
                  mulhsu     s8, sp, s5
                  srl        zero, t1, a4
                  add        tp, gp, s11
                  mul        a6, t2, s5
                  add        tp, gp, s11
                  sltu       t3, t1, tp
                  mulhsu     s8, sp, s5
                  remu       s0, t0, gp
                  xor        a4, a2, s0
                  slti       s10, s8, -890
                  mulhsu     s8, sp, s5
                  slli       tp, t1, 9
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  slli       tp, t1, 9
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  srl        zero, t1, a4
                  auipc      a4, 925829
                  remu       s0, t0, gp
                  srli       t6, t5, 10
                  slt        a1, a1, zero
                  addi       s3, a2, 677
                  sra        t1, t1, a0
                  sll        s10, sp, a0
                  mul        a6, t2, s5
                  srai       s8, t0, 25
                  sll        s10, sp, a0
                  sll        s10, sp, a0
                  xor        a4, a2, s0
                  srai       s8, t0, 25
                  ori        t1, ra, -664
                  ori        t1, ra, -664
                  sra        t1, t1, a0
                  rem        a6, s6, a7
                  divu       s3, gp, a2
                  mul        a6, t2, s5
                  xori       s3, s8, -101
                  auipc      a4, 925829
                  slti       s10, s8, -890
                  slli       tp, t1, 9
                  slti       s10, s8, -890
                  nop
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  or         a7, a0, zero
                  or         a7, a0, zero
                  srl        zero, t1, a4
                  xori       s3, s8, -101
                  mulh       s2, t1, a3
                  remu       s0, t0, gp
                  slli       tp, t1, 9
                  mul        a6, t2, s5
                  slt        a1, a1, zero
                  andi       gp, s9, -46
                  srai       s8, t0, 25
                  mulh       s2, t1, a3
                  addi       s3, a2, 677
                  sltu       t3, t1, tp
                  add        tp, gp, s11
                  mul        a6, t2, s5
                  xor        a4, a2, s0
                  andi       gp, s9, -46
                  sltiu      a2, a0, -848
                  sltu       t3, t1, tp
                  ori        t1, ra, -664
                  sll        s10, sp, a0
                  and        sp, s3, s5
                  sll        s10, sp, a0
                  srai       s8, t0, 25
                  sltu       t3, t1, tp
                  slt        a1, a1, zero
                  ori        t1, ra, -664
                  andi       gp, s9, -46
                  nop
                  srli       t6, t5, 10
                  mulh       s2, t1, a3
                  slt        a1, a1, zero
                  add        tp, gp, s11
                  or         a7, a0, zero
                  or         a7, a0, zero
                  sltiu      a2, a0, -848
                  or         a7, a0, zero
                  andi       gp, s9, -46
                  srli       t6, t5, 10
                  mul        a6, t2, s5
                  lui        s6, 496523
                  add        tp, gp, s11
                  lui        s6, 496523
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  mulhsu     s8, sp, s5
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  sltiu      a2, a0, -848
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  xori       s3, s8, -101
                  slti       s10, s8, -890
                  lui        s6, 496523
                  srl        zero, t1, a4
                  and        sp, s3, s5
                  add        tp, gp, s11
                  srai       s8, t0, 25
                  slli       tp, t1, 9
                  srli       t6, t5, 10
                  mul        a6, t2, s5
                  or         a7, a0, zero
                  mulh       s2, t1, a3
                  slti       s10, s8, -890
                  mulhu      s1, s9, a1
                  add        tp, gp, s11
                  sub        ra, t1, s11
                  sra        t1, t1, a0
                  slli       tp, t1, 9
                  xori       s3, s8, -101
                  sltu       t3, t1, tp
                  auipc      a4, 925829
                  add        tp, gp, s11
                  sltiu      a2, a0, -848
                  add        tp, gp, s11
                  sltu       t3, t1, tp
                  mulhu      s1, s9, a1
                  sltiu      a2, a0, -848
                  sub        ra, t1, s11
                  mulhsu     s8, sp, s5
                  mulhsu     s8, sp, s5
                  lui        s6, 496523
                  mulhu      s1, s9, a1
                  andi       gp, s9, -46
                  xor        a4, a2, s0
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  srli       t6, t5, 10
                  sub        ra, t1, s11
                  andi       gp, s9, -46
                  xori       s3, s8, -101
                  lui        s6, 496523
                  mulhsu     s8, sp, s5
                  or         a7, a0, zero
                  lui        s6, 496523
                  xor        a4, a2, s0
                  xori       s3, s8, -101
                  sra        t1, t1, a0
                  xor        a4, a2, s0
                  xor        a4, a2, s0
                  or         a7, a0, zero
                  sll        s10, sp, a0
                  andi       gp, s9, -46
                  srl        zero, t1, a4
                  sltu       t3, t1, tp
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  remu       s0, t0, gp
                  mulh       s2, t1, a3
                  mul        a6, t2, s5
                  or         a7, a0, zero
                  sll        s10, sp, a0
                  div        zero, a7, s0
                  mulhu      s1, s9, a1
                  auipc      a4, 925829
                  ori        t1, ra, -664
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  slt        a1, a1, zero
                  ori        t1, ra, -664
                  divu       s3, gp, a2
                  nop
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  auipc      a4, 925829
                  ori        t1, ra, -664
                  sll        s10, sp, a0
                  remu       s0, t0, gp
                  addi       s3, a2, 677
                  slti       s10, s8, -890
                  slli       tp, t1, 9
                  xori       s3, s8, -101
                  divu       s3, gp, a2
                  sub        ra, t1, s11
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  or         a7, a0, zero
                  add        tp, gp, s11
                  srai       s8, t0, 25
                  sltiu      a2, a0, -848
                  and        sp, s3, s5
                  slt        a1, a1, zero
                  slt        a1, a1, zero
                  divu       s3, gp, a2
                  mulh       s2, t1, a3
                  rem        a6, s6, a7
                  andi       gp, s9, -46
                  mulh       s2, t1, a3
                  mul        a6, t2, s5
                  divu       s3, gp, a2
                  sra        t1, t1, a0
                  sll        s10, sp, a0
                  mulhsu     s8, sp, s5
                  mul        a6, t2, s5
                  divu       s3, gp, a2
                  sra        t1, t1, a0
                  slli       tp, t1, 9
                  remu       s0, t0, gp
                  sltiu      a2, a0, -848
                  sub        ra, t1, s11
                  ori        t1, ra, -664
                  sub        ra, t1, s11
                  and        sp, s3, s5
                  rem        a6, s6, a7
                  ori        t1, ra, -664
                  mul        a6, t2, s5
                  slti       s10, s8, -890
                  and        sp, s3, s5
                  slti       s10, s8, -890
                  remu       s0, t0, gp
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  rem        a6, s6, a7
                  slli       tp, t1, 9
                  sltu       t3, t1, tp
                  divu       s3, gp, a2
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  slt        a1, a1, zero
                  ori        t1, ra, -664
                  div        zero, a7, s0
                  srli       t6, t5, 10
                  srl        zero, t1, a4
                  slt        a1, a1, zero
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  mul        a6, t2, s5
                  sltiu      a2, a0, -848
                  slti       s10, s8, -890
                  nop
                  auipc      a4, 925829
                  mulhu      s1, s9, a1
                  divu       s3, gp, a2
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  slti       s10, s8, -890
                  mul        a6, t2, s5
                  div        zero, a7, s0
                  auipc      a4, 925829
                  addi       s3, a2, 677
                  or         a7, a0, zero
                  sra        t1, t1, a0
                  mulhsu     s8, sp, s5
                  mulh       s2, t1, a3
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  divu       s3, gp, a2
                  mul        a6, t2, s5
                  and        sp, s3, s5
                  slli       tp, t1, 9
                  mulh       s2, t1, a3
                  andi       gp, s9, -46
                  slli       tp, t1, 9
                  li         t3, 0x80000000 #start riscv_int_numeric_corner_stream_9
                  li         t1, 0x0
                  li         a6, 0xffffffff
                  li         s3, 0x80000000
                  li         s6, 0x80000000
                  li         tp, 0xffffffff
                  li         t2, 0xffffffff
                  li         s9, 0x0
                  li         s4, 0x0
                  li         t6, 0x0
                  divu       t1, a6, s3
                  add        s3, a6, s4
                  mul        s4, s9, s4
                  lui        s3, 496523
                  nop
                  lui        s3, 496523
                  mul        s4, s9, s4
                  mulhsu     s6, t2, s4
                  addi       t1, t1, 677
                  addi       t1, t1, 677
                  nop
                  mulhu      t6, t6, t2
                  add        s3, a6, s4
                  nop
                  mul        s4, s9, s4
                  mulh       tp, s6, a6
                  div        tp, t1, t3
                  divu       t1, a6, s3
                  auipc      t6, 925829
                  div        tp, t1, t3
                  div        tp, t1, t3
                  divu       t1, a6, s3
                  mulh       tp, s6, a6
                  div        tp, t1, t3
                  nop
                  lui        s3, 496523
                  auipc      t6, 925829
                  remu       t3, s4, a6 #end riscv_int_numeric_corner_stream_9
                  slli       tp, t1, 9
                  slti       s10, s8, -890
                  addi       s3, a2, 677
                  slli       tp, t1, 9
                  ori        t1, ra, -664
                  mulh       s2, t1, a3
                  addi       s3, a2, 677
                  srli       t6, t5, 10
                  mul        a6, t2, s5
                  or         a7, a0, zero
                  sub        ra, t1, s11
                  divu       s3, gp, a2
                  srli       t6, t5, 10
                  lui        s6, 496523
                  sub        ra, t1, s11
                  sra        t1, t1, a0
                  slti       s10, s8, -890
                  and        sp, s3, s5
                  addi       s3, a2, 677
                  mul        a6, t2, s5
                  sltiu      a2, a0, -848
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  rem        a6, s6, a7
                  auipc      a4, 925829
                  slt        a1, a1, zero
                  nop
                  mulh       s2, t1, a3
                  srli       t6, t5, 10
                  mulhsu     s8, sp, s5
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  rem        a6, s6, a7
                  xori       s3, s8, -101
                  sub        ra, t1, s11
                  xori       s3, s8, -101
                  mulh       s2, t1, a3
                  xori       s3, s8, -101
                  addi       s3, a2, 677
                  auipc      a4, 925829
                  add        tp, gp, s11
                  div        zero, a7, s0
                  lui        s6, 496523
                  add        tp, gp, s11
                  srl        zero, t1, a4
                  mul        a6, t2, s5
                  auipc      a4, 925829
                  sltu       t3, t1, tp
                  and        sp, s3, s5
                  mul        a6, t2, s5
                  ori        t1, ra, -664
                  mul        a6, t2, s5
                  sll        s10, sp, a0
                  ori        t1, ra, -664
                  addi       s3, a2, 677
                  sltu       t3, t1, tp
                  slti       s10, s8, -890
                  add        tp, gp, s11
                  slt        a1, a1, zero
                  sra        t1, t1, a0
                  sll        s10, sp, a0
                  sltu       t3, t1, tp
                  divu       s3, gp, a2
                  mul        a6, t2, s5
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  slti       s10, s8, -890
                  mulhsu     s8, sp, s5
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  rem        a6, s6, a7
                  add        tp, gp, s11
                  srli       t6, t5, 10
                  andi       gp, s9, -46
                  remu       s0, t0, gp
                  sub        ra, t1, s11
                  sub        ra, t1, s11
                  remu       s0, t0, gp
                  andi       gp, s9, -46
                  srai       s8, t0, 25
                  div        zero, a7, s0
                  sll        s10, sp, a0
                  add        tp, gp, s11
                  auipc      a4, 925829
                  slti       s10, s8, -890
                  rem        a6, s6, a7
                  remu       s0, t0, gp
                  mul        a6, t2, s5
                  mulh       s2, t1, a3
                  lui        s6, 496523
                  srai       s8, t0, 25
                  mulhsu     s8, sp, s5
                  or         a7, a0, zero
                  addi       s3, a2, 677
                  add        tp, gp, s11
                  slt        a1, a1, zero
                  or         a7, a0, zero
                  andi       gp, s9, -46
                  sltiu      a2, a0, -848
                  sltiu      a2, a0, -848
                  lui        s6, 496523
                  srai       s8, t0, 25
                  mulhsu     s8, sp, s5
                  rem        a6, s6, a7
                  sra        t1, t1, a0
                  sltu       t3, t1, tp
                  sll        s10, sp, a0
                  lui        s6, 496523
                  xori       s3, s8, -101
                  ori        t1, ra, -664
                  ori        t1, ra, -664
                  remu       s0, t0, gp
                  mulhu      s1, s9, a1
                  div        zero, a7, s0
                  srli       t6, t5, 10
                  slt        a1, a1, zero
                  rem        a6, s6, a7
                  nop
                  rem        a6, s6, a7
                  sltu       t3, t1, tp
                  mulh       s2, t1, a3
                  slli       tp, t1, 9
                  add        tp, gp, s11
                  sra        t1, t1, a0
                  slt        a1, a1, zero
                  sll        s10, sp, a0
                  or         a7, a0, zero
                  slt        a1, a1, zero
                  ori        t1, ra, -664
                  slli       tp, t1, 9
                  divu       s3, gp, a2
                  and        sp, s3, s5
                  srl        zero, t1, a4
                  sra        t1, t1, a0
                  add        tp, gp, s11
                  and        sp, s3, s5
                  divu       s3, gp, a2
                  mulhu      s1, s9, a1
                  lui        s6, 496523
                  xori       s3, s8, -101
                  mul        a6, t2, s5
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  addi       s3, a2, 677
                  add        tp, gp, s11
                  sra        t1, t1, a0
                  mulh       s2, t1, a3
                  xor        a4, a2, s0
                  srai       s8, t0, 25
                  auipc      a4, 925829
                  div        zero, a7, s0
                  slti       s10, s8, -890
                  sltiu      a2, a0, -848
                  slt        a1, a1, zero
                  slli       tp, t1, 9
                  rem        a6, s6, a7
                  andi       gp, s9, -46
                  slti       s10, s8, -890
                  mulhsu     s8, sp, s5
                  lui        s6, 496523
                  rem        a6, s6, a7
                  sra        t1, t1, a0
                  divu       s3, gp, a2
                  slti       s10, s8, -890
                  slti       s10, s8, -890
                  sub        ra, t1, s11
                  andi       gp, s9, -46
                  slti       s10, s8, -890
                  andi       gp, s9, -46
                  add        tp, gp, s11
                  auipc      a4, 925829
                  sltu       t3, t1, tp
                  srl        zero, t1, a4
                  sub        ra, t1, s11
                  sltiu      a2, a0, -848
                  and        sp, s3, s5
                  mulh       s2, t1, a3
                  slli       tp, t1, 9
                  sltiu      a2, a0, -848
                  auipc      a4, 925829
                  xor        a4, a2, s0
                  sra        t1, t1, a0
                  slt        a1, a1, zero
                  slli       tp, t1, 9
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  srl        zero, t1, a4
                  slti       s10, s8, -890
                  nop
                  srl        zero, t1, a4
                  divu       s3, gp, a2
                  rem        a6, s6, a7
                  sltu       t3, t1, tp
                  sltu       t3, t1, tp
                  mulh       s2, t1, a3
                  ori        t1, ra, -664
                  andi       gp, s9, -46
                  slt        a1, a1, zero
                  div        zero, a7, s0
                  andi       gp, s9, -46
                  sub        ra, t1, s11
                  ori        t1, ra, -664
                  add        tp, gp, s11
                  xori       s3, s8, -101
                  sltiu      a2, a0, -848
                  add        tp, gp, s11
                  xori       s3, s8, -101
                  or         a7, a0, zero
                  ori        t1, ra, -664
                  slti       s10, s8, -890
                  mulh       s2, t1, a3
                  sltu       t3, t1, tp
                  and        sp, s3, s5
                  and        sp, s3, s5
                  andi       gp, s9, -46
                  or         a7, a0, zero
                  ori        t1, ra, -664
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  srai       s8, t0, 25
                  srli       t6, t5, 10
                  divu       s3, gp, a2
                  and        sp, s3, s5
                  sll        s10, sp, a0
                  xori       s3, s8, -101
                  sltu       t3, t1, tp
                  mulhu      s1, s9, a1
                  srli       t6, t5, 10
                  sltu       t3, t1, tp
                  andi       gp, s9, -46
                  mulh       s2, t1, a3
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  div        zero, a7, s0
                  auipc      a4, 925829
                  add        tp, gp, s11
                  sltu       t3, t1, tp
                  lui        s6, 496523
                  srl        zero, t1, a4
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  srai       s8, t0, 25
                  and        sp, s3, s5
                  remu       s0, t0, gp
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  divu       s3, gp, a2
                  srli       t6, t5, 10
                  xor        a4, a2, s0
                  xor        a4, a2, s0
                  lui        s6, 496523
                  mul        a6, t2, s5
                  mul        a6, t2, s5
                  andi       gp, s9, -46
                  xor        a4, a2, s0
                  div        zero, a7, s0
                  srli       t6, t5, 10
                  srl        zero, t1, a4
                  div        zero, a7, s0
                  remu       s0, t0, gp
                  remu       s0, t0, gp
                  mulh       s2, t1, a3
                  auipc      a4, 925829
                  slti       s10, s8, -890
                  ori        t1, ra, -664
                  mul        a6, t2, s5
                  lui        s6, 496523
                  slt        a1, a1, zero
                  xor        a4, a2, s0
                  srl        zero, t1, a4
                  rem        a6, s6, a7
                  divu       s3, gp, a2
                  lui        s6, 496523
                  divu       s3, gp, a2
                  lui        s6, 496523
                  lui        s6, 496523
                  srai       s8, t0, 25
                  sub        ra, t1, s11
                  sll        s10, sp, a0
                  nop
                  mulhu      s1, s9, a1
                  andi       gp, s9, -46
                  srli       t6, t5, 10
                  slt        a1, a1, zero
                  slli       tp, t1, 9
                  addi       s3, a2, 677
                  rem        a6, s6, a7
                  auipc      a4, 925829
                  srl        zero, t1, a4
                  divu       s3, gp, a2
                  xori       s3, s8, -101
                  div        zero, a7, s0
                  sra        t1, t1, a0
                  lui        s6, 496523
                  nop
                  nop
                  xori       s3, s8, -101
                  sub        ra, t1, s11
                  srl        zero, t1, a4
                  remu       s0, t0, gp
                  slt        a1, a1, zero
                  srai       s8, t0, 25
                  mulh       s2, t1, a3
                  or         a7, a0, zero
                  srl        zero, t1, a4
                  sll        s10, sp, a0
                  xor        a4, a2, s0
                  slli       tp, t1, 9
                  sra        t1, t1, a0
                  srli       t6, t5, 10
                  rem        a6, s6, a7
                  mulhu      s1, s9, a1
                  sltiu      a2, a0, -848
                  srli       t6, t5, 10
                  auipc      a4, 925829
                  sra        t1, t1, a0
                  remu       s0, t0, gp
                  auipc      a4, 925829
                  mulh       s2, t1, a3
                  sub        ra, t1, s11
                  slt        a1, a1, zero
                  sll        s10, sp, a0
                  nop
                  srli       t6, t5, 10
                  slti       s10, s8, -890
                  addi       s3, a2, 677
                  divu       s3, gp, a2
                  lui        s6, 496523
                  auipc      a4, 925829
                  ori        t1, ra, -664
                  lui        s6, 496523
                  sltiu      a2, a0, -848
                  srl        zero, t1, a4
                  srai       s8, t0, 25
                  addi       s3, a2, 677
                  or         a7, a0, zero
                  auipc      a4, 925829
                  srli       t6, t5, 10
                  auipc      a4, 925829
                  sltu       t3, t1, tp
                  slti       s10, s8, -890
                  sll        s10, sp, a0
                  slt        a1, a1, zero
                  mulhu      s1, s9, a1
                  slt        a1, a1, zero
                  sll        s10, sp, a0
                  lui        s6, 496523
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  auipc      a4, 925829
                  slti       s10, s8, -890
                  slli       tp, t1, 9
                  divu       s3, gp, a2
                  mulhsu     s8, sp, s5
                  or         a7, a0, zero
                  srl        zero, t1, a4
                  andi       gp, s9, -46
                  sltu       t3, t1, tp
                  rem        a6, s6, a7
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  auipc      a4, 925829
                  add        tp, gp, s11
                  auipc      a4, 925829
                  ori        t1, ra, -664
                  and        sp, s3, s5
                  xori       s3, s8, -101
                  nop
                  slt        a1, a1, zero
                  slli       tp, t1, 9
                  srl        zero, t1, a4
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  mulhsu     s8, sp, s5
                  mulh       s2, t1, a3
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  slti       s10, s8, -890
                  mulhu      s1, s9, a1
                  sll        s10, sp, a0
                  xori       s3, s8, -101
                  nop
                  ori        t1, ra, -664
                  srl        zero, t1, a4
                  slti       s10, s8, -890
                  xori       s3, s8, -101
                  slli       tp, t1, 9
                  auipc      a4, 925829
                  sltiu      a2, a0, -848
                  slti       s10, s8, -890
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  lui        s6, 496523
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  auipc      a4, 925829
                  divu       s3, gp, a2
                  ori        t1, ra, -664
                  mulhu      s1, s9, a1
                  lui        s6, 496523
                  nop
                  srl        zero, t1, a4
                  sltu       t3, t1, tp
                  slti       s10, s8, -890
                  nop
                  sra        t1, t1, a0
                  xori       s3, s8, -101
                  ori        t1, ra, -664
                  lui        s6, 496523
                  slti       s10, s8, -890
                  sltu       t3, t1, tp
                  xori       s3, s8, -101
                  nop
                  srl        zero, t1, a4
                  xori       s3, s8, -101
                  lui        s6, 496523
                  slli       tp, t1, 9
                  sra        t1, t1, a0
                  ori        t1, ra, -664
                  xor        a4, a2, s0
                  add        tp, gp, s11
                  div        zero, a7, s0
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  add        tp, gp, s11
                  srai       s8, t0, 25
                  nop
                  sltu       t3, t1, tp
                  slti       s10, s8, -890
                  lui        s6, 496523
                  sltu       t3, t1, tp
                  slt        a1, a1, zero
                  slli       tp, t1, 9
                  srli       t6, t5, 10
                  sra        t1, t1, a0
                  slti       s10, s8, -890
                  mul        a6, t2, s5
                  srli       t6, t5, 10
                  slt        a1, a1, zero
                  rem        a6, s6, a7
                  sltiu      a2, a0, -848
                  mulh       s2, t1, a3
                  sltiu      a2, a0, -848
                  divu       s3, gp, a2
                  or         a7, a0, zero
                  mulhsu     s8, sp, s5
                  srl        zero, t1, a4
                  sll        s10, sp, a0
                  addi       s3, a2, 677
                  andi       gp, s9, -46
                  or         a7, a0, zero
                  slt        a1, a1, zero
                  addi       s3, a2, 677
                  sltu       t3, t1, tp
                  sub        ra, t1, s11
                  nop
                  div        zero, a7, s0
                  xori       s3, s8, -101
                  auipc      a4, 925829
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  addi       s3, a2, 677
                  sra        t1, t1, a0
                  remu       s0, t0, gp
                  add        tp, gp, s11
                  sltiu      a2, a0, -848
                  sltiu      a2, a0, -848
                  mulhsu     s8, sp, s5
                  divu       s3, gp, a2
                  slt        a1, a1, zero
                  ori        t1, ra, -664
                  lui        s6, 496523
                  mul        a6, t2, s5
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  nop
                  divu       s3, gp, a2
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  srli       t6, t5, 10
                  and        sp, s3, s5
                  ori        t1, ra, -664
                  auipc      a4, 925829
                  mul        a6, t2, s5
                  mulhsu     s8, sp, s5
                  sltu       t3, t1, tp
                  mulhsu     s8, sp, s5
                  slli       tp, t1, 9
                  nop
                  sll        s10, sp, a0
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  sub        ra, t1, s11
                  slt        a1, a1, zero
                  or         a7, a0, zero
                  sll        s10, sp, a0
                  srai       s8, t0, 25
                  srl        zero, t1, a4
                  sra        t1, t1, a0
                  or         a7, a0, zero
                  ori        t1, ra, -664
                  nop
                  sub        ra, t1, s11
                  slti       s10, s8, -890
                  srli       t6, t5, 10
                  sub        ra, t1, s11
                  or         a7, a0, zero
                  auipc      a4, 925829
                  auipc      a4, 925829
                  xori       s3, s8, -101
                  auipc      a4, 925829
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  ori        t1, ra, -664
                  mulhu      s1, s9, a1
                  sra        t1, t1, a0
                  add        tp, gp, s11
                  nop
                  ori        t1, ra, -664
                  slt        a1, a1, zero
                  mulhu      s1, s9, a1
                  mulhu      s1, s9, a1
                  lui        s6, 496523
                  and        sp, s3, s5
                  remu       s0, t0, gp
                  mulhu      s1, s9, a1
                  and        sp, s3, s5
                  divu       s3, gp, a2
                  sltiu      a2, a0, -848
                  mulhsu     s8, sp, s5
                  mulhsu     s8, sp, s5
                  srli       t6, t5, 10
                  lui        s6, 496523
                  srli       t6, t5, 10
                  or         a7, a0, zero
                  and        sp, s3, s5
                  sll        s10, sp, a0
                  and        sp, s3, s5
                  srl        zero, t1, a4
                  nop
                  xor        a4, a2, s0
                  slti       s10, s8, -890
                  slli       tp, t1, 9
                  srai       s8, t0, 25
                  srli       t6, t5, 10
                  and        sp, s3, s5
                  auipc      a4, 925829
                  ori        t1, ra, -664
                  nop
                  add        tp, gp, s11
                  remu       s0, t0, gp
                  nop
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  sltu       t3, t1, tp
                  mulhsu     s8, sp, s5
                  remu       s0, t0, gp
                  div        zero, a7, s0
                  ori        t1, ra, -664
                  ori        t1, ra, -664
                  addi       s3, a2, 677
                  slli       tp, t1, 9
                  srl        zero, t1, a4
                  remu       s0, t0, gp
                  divu       s3, gp, a2
                  nop
                  or         a7, a0, zero
                  mulhsu     s8, sp, s5
                  divu       s3, gp, a2
                  or         a7, a0, zero
                  sra        t1, t1, a0
                  sltu       t3, t1, tp
                  mulhsu     s8, sp, s5
                  div        zero, a7, s0
                  sltu       t3, t1, tp
                  andi       gp, s9, -46
                  sub        ra, t1, s11
                  sra        t1, t1, a0
                  xori       s3, s8, -101
                  add        tp, gp, s11
                  or         a7, a0, zero
                  and        sp, s3, s5
                  mulhsu     s8, sp, s5
                  nop
                  sltu       t3, t1, tp
                  xor        a4, a2, s0
                  xori       s3, s8, -101
                  srli       t6, t5, 10
                  and        sp, s3, s5
                  slti       s10, s8, -890
                  div        zero, a7, s0
                  slti       s10, s8, -890
                  slli       tp, t1, 9
                  and        sp, s3, s5
                  addi       s3, a2, 677
                  add        tp, gp, s11
                  xori       s3, s8, -101
                  mul        a6, t2, s5
                  mulhu      s1, s9, a1
                  and        sp, s3, s5
                  sra        t1, t1, a0
                  srl        zero, t1, a4
                  srai       s8, t0, 25
                  nop
                  remu       s0, t0, gp
                  remu       s0, t0, gp
                  srl        zero, t1, a4
                  auipc      a4, 925829
                  mul        a6, t2, s5
                  rem        a6, s6, a7
                  add        tp, gp, s11
                  and        sp, s3, s5
                  sub        ra, t1, s11
                  sltiu      a2, a0, -848
                  sub        ra, t1, s11
                  mulhu      s1, s9, a1
                  slti       s10, s8, -890
                  add        tp, gp, s11
                  srli       t6, t5, 10
                  xori       s3, s8, -101
                  srai       s8, t0, 25
                  andi       gp, s9, -46
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  sub        ra, t1, s11
                  and        sp, s3, s5
                  sub        ra, t1, s11
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  lui        s6, 496523
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  mulh       s2, t1, a3
                  div        zero, a7, s0
                  or         a7, a0, zero
                  or         a7, a0, zero
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  srli       t6, t5, 10
                  slli       tp, t1, 9
                  rem        a6, s6, a7
                  divu       s3, gp, a2
                  xori       s3, s8, -101
                  sra        t1, t1, a0
                  srai       s8, t0, 25
                  sltu       t3, t1, tp
                  mulh       s2, t1, a3
                  sltiu      a2, a0, -848
                  slt        a1, a1, zero
                  srai       s8, t0, 25
                  mulhu      s1, s9, a1
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  slli       tp, t1, 9
                  remu       s0, t0, gp
                  addi       s3, a2, 677
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  remu       s0, t0, gp
                  slli       tp, t1, 9
                  mulh       s2, t1, a3
                  andi       gp, s9, -46
                  add        tp, gp, s11
                  mulhsu     s8, sp, s5
                  mulhsu     s8, sp, s5
                  sll        s10, sp, a0
                  or         a7, a0, zero
                  remu       s0, t0, gp
                  sltu       t3, t1, tp
                  xori       s3, s8, -101
                  slt        a1, a1, zero
                  div        zero, a7, s0
                  xori       s3, s8, -101
                  or         a7, a0, zero
                  div        zero, a7, s0
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  sll        s10, sp, a0
                  addi       s3, a2, 677
                  remu       s0, t0, gp
                  ori        t1, ra, -664
                  srl        zero, t1, a4
                  slti       s10, s8, -890
                  addi       s3, a2, 677
                  or         a7, a0, zero
                  lui        s6, 496523
                  div        zero, a7, s0
                  remu       s0, t0, gp
                  nop
                  xor        a4, a2, s0
                  sub        ra, t1, s11
                  rem        a6, s6, a7
                  nop
                  lui        s6, 496523
                  slt        a1, a1, zero
                  and        sp, s3, s5
                  auipc      a4, 925829
                  mul        a6, t2, s5
                  mulhsu     s8, sp, s5
                  srli       t6, t5, 10
                  auipc      a4, 925829
                  lui        s6, 496523
                  slt        a1, a1, zero
                  divu       s3, gp, a2
                  srli       t6, t5, 10
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  lui        s6, 496523
                  sub        ra, t1, s11
                  and        sp, s3, s5
                  slti       s10, s8, -890
                  xor        a4, a2, s0
                  sll        s10, sp, a0
                  mulhsu     s8, sp, s5
                  srai       s8, t0, 25
                  sltiu      a2, a0, -848
                  slt        a1, a1, zero
                  and        sp, s3, s5
                  remu       s0, t0, gp
                  or         a7, a0, zero
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  slti       s10, s8, -890
                  sub        ra, t1, s11
                  srl        zero, t1, a4
                  slli       tp, t1, 9
                  or         a7, a0, zero
                  srl        zero, t1, a4
                  nop
                  srai       s8, t0, 25
                  mulhsu     s8, sp, s5
                  sub        ra, t1, s11
                  addi       s3, a2, 677
                  xori       s3, s8, -101
                  xori       s3, s8, -101
                  slli       tp, t1, 9
                  mulh       s2, t1, a3
                  divu       s3, gp, a2
                  divu       s3, gp, a2
                  slli       tp, t1, 9
                  srli       t6, t5, 10
                  nop
                  auipc      a4, 925829
                  lui        s6, 496523
                  div        zero, a7, s0
                  srai       s8, t0, 25
                  srai       s8, t0, 25
                  auipc      a4, 925829
                  xor        a4, a2, s0
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  sltu       t3, t1, tp
                  slti       s10, s8, -890
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  remu       s0, t0, gp
                  srai       s8, t0, 25
                  slti       s10, s8, -890
                  mulh       s2, t1, a3
                  addi       s3, a2, 677
                  sll        s10, sp, a0
                  nop
                  addi       s3, a2, 677
                  xori       s3, s8, -101
                  divu       s3, gp, a2
                  srli       t6, t5, 10
                  nop
                  sub        ra, t1, s11
                  slli       tp, t1, 9
                  or         a7, a0, zero
                  remu       s0, t0, gp
                  mulhu      s1, s9, a1
                  add        tp, gp, s11
                  mulh       s2, t1, a3
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  div        zero, a7, s0
                  mul        a6, t2, s5
                  xori       s3, s8, -101
                  lui        s6, 496523
                  mulhsu     s8, sp, s5
                  sll        s10, sp, a0
                  nop
                  addi       s3, a2, 677
                  lui        s6, 496523
                  slli       tp, t1, 9
                  mul        a6, t2, s5
                  ori        t1, ra, -664
                  mulhu      s1, s9, a1
                  add        tp, gp, s11
                  li         t6, 0x1ef54ff6 #start riscv_int_numeric_corner_stream_6
                  li         s5, 0x80000000
                  li         a3, 0xffffffff
                  li         s6, 0x15abff1a
                  li         tp, 0xffffffff
                  li         a2, 0x0
                  li         t5, 0xffffffff
                  li         s8, 0x80000000
                  li         s4, 0x80000000
                  li         a1, 0x80000000
                  auipc      t6, 925829
                  add        s4, a3, s5
                  nop
                  nop
                  add        s4, a3, s5
                  remu       t5, s5, a3
                  lui        s4, 496523
                  mulh       tp, s6, a3
                  divu       a1, a3, s4
                  add        s4, a3, s5
                  add        s4, a3, s5
                  addi       a1, a1, 677
                  mul        s5, s8, s5
                  addi       a1, a1, 677
                  nop
                  mulh       tp, s6, a3
                  remu       t5, s5, a3
                  mulhsu     s6, a2, s5
                  lui        s4, 496523
                  lui        s4, 496523
                  addi       a1, a1, 677
                  mul        s5, s8, s5
                  mulhsu     s6, a2, s5
                  add        s4, a3, s5
                  lui        s4, 496523 #end riscv_int_numeric_corner_stream_6
                  xori       s3, s8, -101
                  nop
                  srai       s8, t0, 25
                  sub        ra, t1, s11
                  rem        a6, s6, a7
                  mulhu      s1, s9, a1
                  and        sp, s3, s5
                  and        sp, s3, s5
                  rem        a6, s6, a7
                  slli       tp, t1, 9
                  slti       s10, s8, -890
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  slt        a1, a1, zero
                  auipc      a4, 925829
                  xori       s3, s8, -101
                  auipc      a4, 925829
                  div        zero, a7, s0
                  mulhsu     s8, sp, s5
                  sra        t1, t1, a0
                  add        tp, gp, s11
                  xor        a4, a2, s0
                  remu       s0, t0, gp
                  ori        t1, ra, -664
                  and        sp, s3, s5
                  slt        a1, a1, zero
                  mul        a6, t2, s5
                  slt        a1, a1, zero
                  and        sp, s3, s5
                  andi       gp, s9, -46
                  nop
                  remu       s0, t0, gp
                  slli       tp, t1, 9
                  auipc      a4, 925829
                  srl        zero, t1, a4
                  add        tp, gp, s11
                  mulhsu     s8, sp, s5
                  and        sp, s3, s5
                  xori       s3, s8, -101
                  sltu       t3, t1, tp
                  sltiu      a2, a0, -848
                  xori       s3, s8, -101
                  lui        s6, 496523
                  sltu       t3, t1, tp
                  rem        a6, s6, a7
                  add        tp, gp, s11
                  nop
                  or         a7, a0, zero
                  auipc      a4, 925829
                  rem        a6, s6, a7
                  div        zero, a7, s0
                  srai       s8, t0, 25
                  mulhu      s1, s9, a1
                  sltiu      a2, a0, -848
                  slti       s10, s8, -890
                  mulhu      s1, s9, a1
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  divu       s3, gp, a2
                  auipc      a4, 925829
                  slli       tp, t1, 9
                  addi       s3, a2, 677
                  addi       s3, a2, 677
                  sltu       t3, t1, tp
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  addi       s3, a2, 677
                  sltu       t3, t1, tp
                  rem        a6, s6, a7
                  mulhu      s1, s9, a1
                  ori        t1, ra, -664
                  srl        zero, t1, a4
                  sltiu      a2, a0, -848
                  mulh       s2, t1, a3
                  lui        s6, 496523
                  srli       t6, t5, 10
                  andi       gp, s9, -46
                  lui        s6, 496523
                  slli       tp, t1, 9
                  sra        t1, t1, a0
                  mulhu      s1, s9, a1
                  srai       s8, t0, 25
                  sltu       t3, t1, tp
                  nop
                  mul        a6, t2, s5
                  andi       gp, s9, -46
                  mul        a6, t2, s5
                  slti       s10, s8, -890
                  mul        a6, t2, s5
                  div        zero, a7, s0
                  auipc      a4, 925829
                  slti       s10, s8, -890
                  rem        a6, s6, a7
                  srli       t6, t5, 10
                  srl        zero, t1, a4
                  remu       s0, t0, gp
                  nop
                  slt        a1, a1, zero
                  srai       s8, t0, 25
                  sra        t1, t1, a0
                  srli       t6, t5, 10
                  add        tp, gp, s11
                  srli       t6, t5, 10
                  div        zero, a7, s0
                  add        tp, gp, s11
                  srli       t6, t5, 10
                  andi       gp, s9, -46
                  divu       s3, gp, a2
                  rem        a6, s6, a7
                  xor        a4, a2, s0
                  andi       gp, s9, -46
                  sltiu      a2, a0, -848
                  srai       s8, t0, 25
                  ori        t1, ra, -664
                  mul        a6, t2, s5
                  slti       s10, s8, -890
                  srli       t6, t5, 10
                  sub        ra, t1, s11
                  srli       t6, t5, 10
                  lui        s6, 496523
                  sub        ra, t1, s11
                  xor        a4, a2, s0
                  sltu       t3, t1, tp
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  and        sp, s3, s5
                  mul        a6, t2, s5
                  divu       s3, gp, a2
                  sll        s10, sp, a0
                  srai       s8, t0, 25
                  lui        s6, 496523
                  sltiu      a2, a0, -848
                  auipc      a4, 925829
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  ori        t1, ra, -664
                  andi       gp, s9, -46
                  srai       s8, t0, 25
                  sltiu      a2, a0, -848
                  srl        zero, t1, a4
                  slli       tp, t1, 9
                  sub        ra, t1, s11
                  remu       s0, t0, gp
                  addi       s3, a2, 677
                  srl        zero, t1, a4
                  sll        s10, sp, a0
                  mulh       s2, t1, a3
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  sltu       t3, t1, tp
                  div        zero, a7, s0
                  mulhsu     s8, sp, s5
                  and        sp, s3, s5
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  sltu       t3, t1, tp
                  divu       s3, gp, a2
                  divu       s3, gp, a2
                  xori       s3, s8, -101
                  divu       s3, gp, a2
                  auipc      a4, 925829
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  mulhu      s1, s9, a1
                  slti       s10, s8, -890
                  lui        s6, 496523
                  mulhu      s1, s9, a1
                  or         a7, a0, zero
                  add        tp, gp, s11
                  div        zero, a7, s0
                  divu       s3, gp, a2
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  remu       s0, t0, gp
                  ori        t1, ra, -664
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  lui        s6, 496523
                  xori       s3, s8, -101
                  mulhu      s1, s9, a1
                  add        tp, gp, s11
                  or         a7, a0, zero
                  remu       s0, t0, gp
                  mul        a6, t2, s5
                  or         a7, a0, zero
                  andi       gp, s9, -46
                  or         a7, a0, zero
                  auipc      a4, 925829
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  mulh       s2, t1, a3
                  srli       t6, t5, 10
                  and        sp, s3, s5
                  sltiu      a2, a0, -848
                  div        zero, a7, s0
                  and        sp, s3, s5
                  xori       s3, s8, -101
                  addi       s3, a2, 677
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  sltu       t3, t1, tp
                  lui        s6, 496523
                  rem        a6, s6, a7
                  addi       s3, a2, 677
                  auipc      a4, 925829
                  addi       s3, a2, 677
                  mul        a6, t2, s5
                  sll        s10, sp, a0
                  sub        ra, t1, s11
                  xor        a4, a2, s0
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  slli       tp, t1, 9
                  div        zero, a7, s0
                  srli       t6, t5, 10
                  slt        a1, a1, zero
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  addi       s3, a2, 677
                  slti       s10, s8, -890
                  mulh       s2, t1, a3
                  or         a7, a0, zero
                  srai       s8, t0, 25
                  mulh       s2, t1, a3
                  ori        t1, ra, -664
                  mulh       s2, t1, a3
                  lui        s6, 496523
                  sltiu      a2, a0, -848
                  sltu       t3, t1, tp
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  mulhsu     s8, sp, s5
                  mul        a6, t2, s5
                  sra        t1, t1, a0
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  andi       gp, s9, -46
                  and        sp, s3, s5
                  remu       s0, t0, gp
                  ori        t1, ra, -664
                  mulhsu     s8, sp, s5
                  lui        s6, 496523
                  lui        s6, 496523
                  div        zero, a7, s0
                  div        zero, a7, s0
                  srli       t6, t5, 10
                  slli       tp, t1, 9
                  mulh       s2, t1, a3
                  nop
                  divu       s3, gp, a2
                  mulhu      s1, s9, a1
                  srai       s8, t0, 25
                  nop
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  mul        a6, t2, s5
                  and        sp, s3, s5
                  rem        a6, s6, a7
                  sltiu      a2, a0, -848
                  remu       s0, t0, gp
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  sltu       t3, t1, tp
                  srli       t6, t5, 10
                  mul        a6, t2, s5
                  auipc      a4, 925829
                  slti       s10, s8, -890
                  lui        s6, 496523
                  sltu       t3, t1, tp
                  mulhu      s1, s9, a1
                  nop
                  lui        s6, 496523
                  srl        zero, t1, a4
                  remu       s0, t0, gp
                  sltiu      a2, a0, -848
                  addi       s3, a2, 677
                  andi       gp, s9, -46
                  xor        a4, a2, s0
                  mul        a6, t2, s5
                  div        zero, a7, s0
                  slli       tp, t1, 9
                  srl        zero, t1, a4
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  div        zero, a7, s0
                  sra        t1, t1, a0
                  sltiu      a2, a0, -848
                  mulhsu     s8, sp, s5
                  andi       gp, s9, -46
                  xori       s3, s8, -101
                  slli       tp, t1, 9
                  srai       s8, t0, 25
                  lui        s6, 496523
                  slt        a1, a1, zero
                  mul        a6, t2, s5
                  srai       s8, t0, 25
                  mul        a6, t2, s5
                  srl        zero, t1, a4
                  sub        ra, t1, s11
                  lui        s6, 496523
                  andi       gp, s9, -46
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  and        sp, s3, s5
                  div        zero, a7, s0
                  divu       s3, gp, a2
                  div        zero, a7, s0
                  add        tp, gp, s11
                  rem        a6, s6, a7
                  sra        t1, t1, a0
                  auipc      a4, 925829
                  sltiu      a2, a0, -848
                  mulhu      s1, s9, a1
                  xor        a4, a2, s0
                  andi       gp, s9, -46
                  lui        s6, 496523
                  add        tp, gp, s11
                  nop
                  xor        a4, a2, s0
                  slti       s10, s8, -890
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  sll        s10, sp, a0
                  mulhsu     s8, sp, s5
                  addi       s3, a2, 677
                  addi       s3, a2, 677
                  or         a7, a0, zero
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  srl        zero, t1, a4
                  div        zero, a7, s0
                  srli       t6, t5, 10
                  or         a7, a0, zero
                  slt        a1, a1, zero
                  slli       tp, t1, 9
                  sub        ra, t1, s11
                  lui        s6, 496523
                  add        tp, gp, s11
                  xor        a4, a2, s0
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  mulh       s2, t1, a3
                  mulh       s2, t1, a3
                  sll        s10, sp, a0
                  sltu       t3, t1, tp
                  nop
                  xori       s3, s8, -101
                  sub        ra, t1, s11
                  divu       s3, gp, a2
                  mulhsu     s8, sp, s5
                  srli       t6, t5, 10
                  mul        a6, t2, s5
                  rem        a6, s6, a7
                  nop
                  srl        zero, t1, a4
                  sltu       t3, t1, tp
                  mulhu      s1, s9, a1
                  mulhsu     s8, sp, s5
                  mulh       s2, t1, a3
                  addi       s3, a2, 677
                  xori       s3, s8, -101
                  ori        t1, ra, -664
                  srai       s8, t0, 25
                  slti       s10, s8, -890
                  mulhsu     s8, sp, s5
                  mul        a6, t2, s5
                  mulh       s2, t1, a3
                  mul        a6, t2, s5
                  slt        a1, a1, zero
                  div        zero, a7, s0
                  slt        a1, a1, zero
                  add        tp, gp, s11
                  sra        t1, t1, a0
                  slli       tp, t1, 9
                  nop
                  srl        zero, t1, a4
                  sltiu      a2, a0, -848
                  srli       t6, t5, 10
                  mul        a6, t2, s5
                  mulh       s2, t1, a3
                  addi       s3, a2, 677
                  srai       s8, t0, 25
                  sub        ra, t1, s11
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  and        sp, s3, s5
                  sltiu      a2, a0, -848
                  add        tp, gp, s11
                  divu       s3, gp, a2
                  sub        ra, t1, s11
                  auipc      a4, 925829
                  divu       s3, gp, a2
                  slli       tp, t1, 9
                  divu       s3, gp, a2
                  lui        s6, 496523
                  rem        a6, s6, a7
                  sltiu      a2, a0, -848
                  sll        s10, sp, a0
                  slt        a1, a1, zero
                  slti       s10, s8, -890
                  xor        a4, a2, s0
                  srli       t6, t5, 10
                  lui        s6, 496523
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  rem        a6, s6, a7
                  div        zero, a7, s0
                  srli       t6, t5, 10
                  mulhsu     s8, sp, s5
                  sra        t1, t1, a0
                  srai       s8, t0, 25
                  andi       gp, s9, -46
                  ori        t1, ra, -664
                  sub        ra, t1, s11
                  rem        a6, s6, a7
                  lui        s6, 496523
                  mul        a6, t2, s5
                  xor        a4, a2, s0
                  or         a7, a0, zero
                  xor        a4, a2, s0
                  srl        zero, t1, a4
                  mulhu      s1, s9, a1
                  sra        t1, t1, a0
                  mul        a6, t2, s5
                  sltiu      a2, a0, -848
                  auipc      a4, 925829
                  andi       gp, s9, -46
                  rem        a6, s6, a7
                  divu       s3, gp, a2
                  sltu       t3, t1, tp
                  mulhsu     s8, sp, s5
                  add        tp, gp, s11
                  auipc      a4, 925829
                  div        zero, a7, s0
                  xori       s3, s8, -101
                  auipc      a4, 925829
                  xor        a4, a2, s0
                  srai       s8, t0, 25
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  srai       s8, t0, 25
                  sll        s10, sp, a0
                  xor        a4, a2, s0
                  addi       s3, a2, 677
                  sll        s10, sp, a0
                  li         t2, 0x80000000 #start riscv_int_numeric_corner_stream_37
                  li         s2, 0x80000000
                  li         s10, 0x80000000
                  li         ra, 0xffffffff
                  li         a6, 0xffffffff
                  li         t6, 0x80000000
                  li         t5, 0x80000000
                  li         s3, 0xffffffff
                  li         t1, 0xffffffff
                  li         tp, 0x80000000
                  add        a6, t2, s2
                  lui        a6, 496523
                  remu       t5, s2, t2
                  mul        s2, s10, s2
                  sub        tp, s3, ra
                  mulhsu     s3, t1, s2
                  mul        s2, s10, s2
                  divu       tp, t2, a6
                  divu       tp, t2, a6
                  div        ra, tp, t5
                  mulhsu     s3, t1, s2
                  mulhsu     s3, t1, s2
                  lui        a6, 496523
                  divu       tp, t2, a6
                  rem        s2, s3, tp
                  lui        a6, 496523
                  nop
                  rem        s2, s3, tp
                  nop #end riscv_int_numeric_corner_stream_37
                  srli       t6, t5, 10
                  slti       s10, s8, -890
                  divu       s3, gp, a2
                  sra        t1, t1, a0
                  xor        a4, a2, s0
                  slli       tp, t1, 9
                  sra        t1, t1, a0
                  slt        a1, a1, zero
                  sub        ra, t1, s11
                  nop
                  mulh       s2, t1, a3
                  remu       s0, t0, gp
                  srl        zero, t1, a4
                  remu       s0, t0, gp
                  xor        a4, a2, s0
                  sltu       t3, t1, tp
                  xori       s3, s8, -101
                  andi       gp, s9, -46
                  andi       gp, s9, -46
                  li         t2, 0x80000000 #start riscv_int_numeric_corner_stream_0
                  li         s8, 0x97cc3ded
                  li         t1, 0xffffffff
                  li         t6, 0x80000000
                  li         sp, 0x80000000
                  li         a2, 0xc4b30cae
                  li         a1, 0x4d4b7afb
                  li         gp, 0x80000000
                  li         s6, 0xffffffff
                  li         s1, 0x80000000
                  remu       s8, a1, t2
                  add        s1, t2, a1
                  mulh       sp, a2, t2
                  add        s1, t2, a1
                  sub        gp, a2, sp
                  mulhsu     a2, t1, a1
                  mulh       sp, a2, t2
                  rem        a1, a2, gp
                  lui        s1, 496523
                  divu       gp, t2, s1
                  nop
                  add        s1, t2, a1
                  sub        gp, a2, sp
                  mulhu      t6, t6, t1
                  remu       s8, a1, t2
                  mulhu      t6, t6, t1
                  divu       gp, t2, s1
                  add        s1, t2, a1
                  div        sp, gp, s8
                  auipc      t6, 925829
                  rem        a1, a2, gp
                  mulh       sp, a2, t2
                  mulhu      t6, t6, t1
                  sub        gp, a2, sp
                  rem        a1, a2, gp #end riscv_int_numeric_corner_stream_0
                  and        sp, s3, s5
                  div        zero, a7, s0
                  remu       s0, t0, gp
                  slti       s10, s8, -890
                  add        tp, gp, s11
                  divu       s3, gp, a2
                  sra        t1, t1, a0
                  lui        s6, 496523
                  sra        t1, t1, a0
                  div        zero, a7, s0
                  slt        a1, a1, zero
                  xor        a4, a2, s0
                  add        tp, gp, s11
                  xori       s3, s8, -101
                  divu       s3, gp, a2
                  sra        t1, t1, a0
                  sltiu      a2, a0, -848
                  sub        ra, t1, s11
                  addi       s3, a2, 677
                  mulhsu     s8, sp, s5
                  addi       s3, a2, 677
                  xori       s3, s8, -101
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  sltu       t3, t1, tp
                  and        sp, s3, s5
                  mulhsu     s8, sp, s5
                  and        sp, s3, s5
                  lui        s6, 496523
                  srl        zero, t1, a4
                  sltu       t3, t1, tp
                  mul        a6, t2, s5
                  slt        a1, a1, zero
                  remu       s0, t0, gp
                  sltiu      a2, a0, -848
                  srl        zero, t1, a4
                  nop
                  slli       tp, t1, 9
                  add        tp, gp, s11
                  divu       s3, gp, a2
                  divu       s3, gp, a2
                  or         a7, a0, zero
                  sra        t1, t1, a0
                  rem        a6, s6, a7
                  add        tp, gp, s11
                  andi       gp, s9, -46
                  auipc      a4, 925829
                  auipc      a4, 925829
                  auipc      a4, 925829
                  slli       tp, t1, 9
                  sltiu      a2, a0, -848
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  remu       s0, t0, gp
                  nop
                  lui        s6, 496523
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  div        zero, a7, s0
                  sltu       t3, t1, tp
                  slti       s10, s8, -890
                  rem        a6, s6, a7
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  nop
                  lui        s6, 496523
                  rem        a6, s6, a7
                  lui        s6, 496523
                  sra        t1, t1, a0
                  sltiu      a2, a0, -848
                  sll        s10, sp, a0
                  auipc      a4, 925829
                  sltiu      a2, a0, -848
                  andi       gp, s9, -46
                  rem        a6, s6, a7
                  remu       s0, t0, gp
                  nop
                  lui        s6, 496523
                  xor        a4, a2, s0
                  divu       s3, gp, a2
                  sra        t1, t1, a0
                  add        tp, gp, s11
                  rem        a6, s6, a7
                  or         a7, a0, zero
                  nop
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  srai       s8, t0, 25
                  xori       s3, s8, -101
                  mulhsu     s8, sp, s5
                  remu       s0, t0, gp
                  divu       s3, gp, a2
                  and        sp, s3, s5
                  and        sp, s3, s5
                  sltu       t3, t1, tp
                  slt        a1, a1, zero
                  addi       s3, a2, 677
                  auipc      a4, 925829
                  remu       s0, t0, gp
                  srl        zero, t1, a4
                  srl        zero, t1, a4
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  srl        zero, t1, a4
                  remu       s0, t0, gp
                  sltu       t3, t1, tp
                  sra        t1, t1, a0
                  xori       s3, s8, -101
                  remu       s0, t0, gp
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  auipc      a4, 925829
                  addi       s3, a2, 677
                  sltu       t3, t1, tp
                  slti       s10, s8, -890
                  mul        a6, t2, s5
                  auipc      a4, 925829
                  div        zero, a7, s0
                  nop
                  and        sp, s3, s5
                  sub        ra, t1, s11
                  nop
                  div        zero, a7, s0
                  srli       t6, t5, 10
                  sra        t1, t1, a0
                  xori       s3, s8, -101
                  or         a7, a0, zero
                  slti       s10, s8, -890
                  srai       s8, t0, 25
                  auipc      a4, 925829
                  nop
                  sra        t1, t1, a0
                  sub        ra, t1, s11
                  srl        zero, t1, a4
                  divu       s3, gp, a2
                  nop
                  srli       t6, t5, 10
                  remu       s0, t0, gp
                  remu       s0, t0, gp
                  addi       s3, a2, 677
                  slt        a1, a1, zero
                  addi       s3, a2, 677
                  div        zero, a7, s0
                  xori       s3, s8, -101
                  sltu       t3, t1, tp
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  mul        a6, t2, s5
                  div        zero, a7, s0
                  andi       gp, s9, -46
                  xor        a4, a2, s0
                  sub        ra, t1, s11
                  sub        ra, t1, s11
                  mul        a6, t2, s5
                  rem        a6, s6, a7
                  divu       s3, gp, a2
                  sub        ra, t1, s11
                  andi       gp, s9, -46
                  sltu       t3, t1, tp
                  sra        t1, t1, a0
                  slt        a1, a1, zero
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  srli       t6, t5, 10
                  sra        t1, t1, a0
                  addi       s3, a2, 677
                  addi       s3, a2, 677
                  nop
                  mulhsu     s8, sp, s5
                  xor        a4, a2, s0
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  or         a7, a0, zero
                  srai       s8, t0, 25
                  sll        s10, sp, a0
                  addi       s3, a2, 677
                  sub        ra, t1, s11
                  div        zero, a7, s0
                  rem        a6, s6, a7
                  divu       s3, gp, a2
                  xor        a4, a2, s0
                  andi       gp, s9, -46
                  add        tp, gp, s11
                  mul        a6, t2, s5
                  auipc      a4, 925829
                  mulhu      s1, s9, a1
                  sll        s10, sp, a0
                  srai       s8, t0, 25
                  auipc      a4, 925829
                  mulhu      s1, s9, a1
                  rem        a6, s6, a7
                  slt        a1, a1, zero
                  sub        ra, t1, s11
                  mulhu      s1, s9, a1
                  sll        s10, sp, a0
                  remu       s0, t0, gp
                  lui        s6, 496523
                  and        sp, s3, s5
                  andi       gp, s9, -46
                  rem        a6, s6, a7
                  slt        a1, a1, zero
                  mulhu      s1, s9, a1
                  mulhu      s1, s9, a1
                  sub        ra, t1, s11
                  srl        zero, t1, a4
                  slli       tp, t1, 9
                  sub        ra, t1, s11
                  and        sp, s3, s5
                  nop
                  xori       s3, s8, -101
                  sra        t1, t1, a0
                  lui        s6, 496523
                  ori        t1, ra, -664
                  divu       s3, gp, a2
                  or         a7, a0, zero
                  srl        zero, t1, a4
                  sra        t1, t1, a0
                  remu       s0, t0, gp
                  xor        a4, a2, s0
                  sll        s10, sp, a0
                  xori       s3, s8, -101
                  sub        ra, t1, s11
                  xori       s3, s8, -101
                  addi       s3, a2, 677
                  srli       t6, t5, 10
                  mul        a6, t2, s5
                  andi       gp, s9, -46
                  slt        a1, a1, zero
                  or         a7, a0, zero
                  mulhu      s1, s9, a1
                  slt        a1, a1, zero
                  sltiu      a2, a0, -848
                  slti       s10, s8, -890
                  ori        t1, ra, -664
                  srai       s8, t0, 25
                  srai       s8, t0, 25
                  slti       s10, s8, -890
                  sra        t1, t1, a0
                  divu       s3, gp, a2
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  mulhu      s1, s9, a1
                  mulhu      s1, s9, a1
                  addi       s3, a2, 677
                  nop
                  sub        ra, t1, s11
                  or         a7, a0, zero
                  sra        t1, t1, a0
                  addi       s3, a2, 677
                  nop
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  or         a7, a0, zero
                  mulh       s2, t1, a3
                  mulhsu     s8, sp, s5
                  mulh       s2, t1, a3
                  divu       s3, gp, a2
                  xori       s3, s8, -101
                  mul        a6, t2, s5
                  sltiu      a2, a0, -848
                  xor        a4, a2, s0
                  slti       s10, s8, -890
                  rem        a6, s6, a7
                  andi       gp, s9, -46
                  slti       s10, s8, -890
                  slt        a1, a1, zero
                  srl        zero, t1, a4
                  remu       s0, t0, gp
                  xor        a4, a2, s0
                  sra        t1, t1, a0
                  slti       s10, s8, -890
                  div        zero, a7, s0
                  add        tp, gp, s11
                  mulh       s2, t1, a3
                  andi       gp, s9, -46
                  nop
                  nop
                  xori       s3, s8, -101
                  sll        s10, sp, a0
                  and        sp, s3, s5
                  add        tp, gp, s11
                  mulh       s2, t1, a3
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  auipc      a4, 925829
                  slli       tp, t1, 9
                  div        zero, a7, s0
                  mulhu      s1, s9, a1
                  srai       s8, t0, 25
                  mulh       s2, t1, a3
                  mulh       s2, t1, a3
                  sra        t1, t1, a0
                  srli       t6, t5, 10
                  slli       tp, t1, 9
                  mulhsu     s8, sp, s5
                  xori       s3, s8, -101
                  divu       s3, gp, a2
                  divu       s3, gp, a2
                  nop
                  mulhsu     s8, sp, s5
                  slli       tp, t1, 9
                  or         a7, a0, zero
                  andi       gp, s9, -46
                  or         a7, a0, zero
                  ori        t1, ra, -664
                  srl        zero, t1, a4
                  srl        zero, t1, a4
                  mulhsu     s8, sp, s5
                  xori       s3, s8, -101
                  slti       s10, s8, -890
                  ori        t1, ra, -664
                  mulhsu     s8, sp, s5
                  mulh       s2, t1, a3
                  divu       s3, gp, a2
                  addi       s3, a2, 677
                  slti       s10, s8, -890
                  srl        zero, t1, a4
                  slt        a1, a1, zero
                  add        tp, gp, s11
                  add        tp, gp, s11
                  srli       t6, t5, 10
                  mulhsu     s8, sp, s5
                  div        zero, a7, s0
                  slli       tp, t1, 9
                  sltu       t3, t1, tp
                  srai       s8, t0, 25
                  rem        a6, s6, a7
                  srl        zero, t1, a4
                  sltu       t3, t1, tp
                  sltiu      a2, a0, -848
                  sltiu      a2, a0, -848
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  mulh       s2, t1, a3
                  sub        ra, t1, s11
                  slli       tp, t1, 9
                  ori        t1, ra, -664
                  and        sp, s3, s5
                  srl        zero, t1, a4
                  mulhsu     s8, sp, s5
                  sra        t1, t1, a0
                  mulhsu     s8, sp, s5
                  add        tp, gp, s11
                  sltiu      a2, a0, -848
                  mulhu      s1, s9, a1
                  mulh       s2, t1, a3
                  or         a7, a0, zero
                  mul        a6, t2, s5
                  or         a7, a0, zero
                  lui        s6, 496523
                  srli       t6, t5, 10
                  mulhu      s1, s9, a1
                  andi       gp, s9, -46
                  sltiu      a2, a0, -848
                  sltiu      a2, a0, -848
                  sll        s10, sp, a0
                  div        zero, a7, s0
                  xori       s3, s8, -101
                  slli       tp, t1, 9
                  add        tp, gp, s11
                  andi       gp, s9, -46
                  remu       s0, t0, gp
                  divu       s3, gp, a2
                  and        sp, s3, s5
                  or         a7, a0, zero
                  slli       tp, t1, 9
                  srai       s8, t0, 25
                  srl        zero, t1, a4
                  srl        zero, t1, a4
                  or         a7, a0, zero
                  andi       gp, s9, -46
                  mulh       s2, t1, a3
                  sll        s10, sp, a0
                  addi       s3, a2, 677
                  andi       gp, s9, -46
                  sub        ra, t1, s11
                  addi       s3, a2, 677
                  mul        a6, t2, s5
                  xori       s3, s8, -101
                  slt        a1, a1, zero
                  divu       s3, gp, a2
                  sltiu      a2, a0, -848
                  slt        a1, a1, zero
                  mul        a6, t2, s5
                  mulhsu     s8, sp, s5
                  sltu       t3, t1, tp
                  remu       s0, t0, gp
                  and        sp, s3, s5
                  xor        a4, a2, s0
                  sltu       t3, t1, tp
                  slti       s10, s8, -890
                  slt        a1, a1, zero
                  sltiu      a2, a0, -848
                  remu       s0, t0, gp
                  sub        ra, t1, s11
                  ori        t1, ra, -664
                  nop
                  nop
                  divu       s3, gp, a2
                  lui        s6, 496523
                  add        tp, gp, s11
                  xori       s3, s8, -101
                  remu       s0, t0, gp
                  or         a7, a0, zero
                  slti       s10, s8, -890
                  mulhu      s1, s9, a1
                  sll        s10, sp, a0
                  rem        a6, s6, a7
                  divu       s3, gp, a2
                  sltu       t3, t1, tp
                  slli       tp, t1, 9
                  xor        a4, a2, s0
                  or         a7, a0, zero
                  sltiu      a2, a0, -848
                  mulh       s2, t1, a3
                  srli       t6, t5, 10
                  srai       s8, t0, 25
                  slti       s10, s8, -890
                  mul        a6, t2, s5
                  ori        t1, ra, -664
                  and        sp, s3, s5
                  srl        zero, t1, a4
                  mulhu      s1, s9, a1
                  divu       s3, gp, a2
                  lui        s6, 496523
                  ori        t1, ra, -664
                  remu       s0, t0, gp
                  or         a7, a0, zero
                  rem        a6, s6, a7
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  sltiu      a2, a0, -848
                  xori       s3, s8, -101
                  add        tp, gp, s11
                  nop
                  div        zero, a7, s0
                  mulhu      s1, s9, a1
                  sltiu      a2, a0, -848
                  mulh       s2, t1, a3
                  andi       gp, s9, -46
                  slt        a1, a1, zero
                  srli       t6, t5, 10
                  and        sp, s3, s5
                  and        sp, s3, s5
                  xor        a4, a2, s0
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  and        sp, s3, s5
                  addi       s3, a2, 677
                  div        zero, a7, s0
                  div        zero, a7, s0
                  xor        a4, a2, s0
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  mulhu      s1, s9, a1
                  srl        zero, t1, a4
                  slt        a1, a1, zero
                  andi       gp, s9, -46
                  sltu       t3, t1, tp
                  xor        a4, a2, s0
                  srai       s8, t0, 25
                  mulh       s2, t1, a3
                  lui        s6, 496523
                  xori       s3, s8, -101
                  sra        t1, t1, a0
                  ori        t1, ra, -664
                  sra        t1, t1, a0
                  divu       s3, gp, a2
                  mul        a6, t2, s5
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  sll        s10, sp, a0
                  xori       s3, s8, -101
                  sub        ra, t1, s11
                  lui        s6, 496523
                  andi       gp, s9, -46
                  sltiu      a2, a0, -848
                  xori       s3, s8, -101
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  div        zero, a7, s0
                  mulhsu     s8, sp, s5
                  divu       s3, gp, a2
                  rem        a6, s6, a7
                  slli       tp, t1, 9
                  nop
                  sll        s10, sp, a0
                  or         a7, a0, zero
                  and        sp, s3, s5
                  div        zero, a7, s0
                  rem        a6, s6, a7
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  sltu       t3, t1, tp
                  srl        zero, t1, a4
                  mulhu      s1, s9, a1
                  or         a7, a0, zero
                  remu       s0, t0, gp
                  xor        a4, a2, s0
                  sltiu      a2, a0, -848
                  xori       s3, s8, -101
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  srl        zero, t1, a4
                  addi       s3, a2, 677
                  mulh       s2, t1, a3
                  andi       gp, s9, -46
                  div        zero, a7, s0
                  srai       s8, t0, 25
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  srl        zero, t1, a4
                  andi       gp, s9, -46
                  srai       s8, t0, 25
                  mulhsu     s8, sp, s5
                  mulhsu     s8, sp, s5
                  srai       s8, t0, 25
                  mulh       s2, t1, a3
                  lui        s6, 496523
                  auipc      a4, 925829
                  sra        t1, t1, a0
                  slt        a1, a1, zero
                  auipc      a4, 925829
                  xor        a4, a2, s0
                  divu       s3, gp, a2
                  srai       s8, t0, 25
                  sltu       t3, t1, tp
                  or         a7, a0, zero
                  xor        a4, a2, s0
                  mulhsu     s8, sp, s5
                  mulh       s2, t1, a3
                  mul        a6, t2, s5
                  add        tp, gp, s11
                  sltu       t3, t1, tp
                  addi       s3, a2, 677
                  nop
                  sub        ra, t1, s11
                  slli       tp, t1, 9
                  sll        s10, sp, a0
                  mulhsu     s8, sp, s5
                  lui        s6, 496523
                  rem        a6, s6, a7
                  mulh       s2, t1, a3
                  srai       s8, t0, 25
                  add        tp, gp, s11
                  nop
                  sra        t1, t1, a0
                  srl        zero, t1, a4
                  srai       s8, t0, 25
                  auipc      a4, 925829
                  addi       s3, a2, 677
                  xori       s3, s8, -101
                  or         a7, a0, zero
                  rem        a6, s6, a7
                  sra        t1, t1, a0
                  srai       s8, t0, 25
                  sltu       t3, t1, tp
                  srli       t6, t5, 10
                  mul        a6, t2, s5
                  addi       s3, a2, 677
                  sra        t1, t1, a0
                  sub        ra, t1, s11
                  slti       s10, s8, -890
                  sll        s10, sp, a0
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  lui        s6, 496523
                  auipc      a4, 925829
                  divu       s3, gp, a2
                  add        tp, gp, s11
                  auipc      a4, 925829
                  sltiu      a2, a0, -848
                  sltiu      a2, a0, -848
                  mulh       s2, t1, a3
                  srai       s8, t0, 25
                  div        zero, a7, s0
                  srli       t6, t5, 10
                  or         a7, a0, zero
                  slt        a1, a1, zero
                  mul        a6, t2, s5
                  andi       gp, s9, -46
                  xori       s3, s8, -101
                  sll        s10, sp, a0
                  nop
                  srli       t6, t5, 10
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  srli       t6, t5, 10
                  sub        ra, t1, s11
                  and        sp, s3, s5
                  sltu       t3, t1, tp
                  ori        t1, ra, -664
                  sub        ra, t1, s11
                  srai       s8, t0, 25
                  addi       s3, a2, 677
                  rem        a6, s6, a7
                  mulh       s2, t1, a3
                  slti       s10, s8, -890
                  sltu       t3, t1, tp
                  sltiu      a2, a0, -848
                  div        zero, a7, s0
                  andi       gp, s9, -46
                  mulhu      s1, s9, a1
                  divu       s3, gp, a2
                  add        tp, gp, s11
                  nop
                  srai       s8, t0, 25
                  divu       s3, gp, a2
                  auipc      a4, 925829
                  mulhsu     s8, sp, s5
                  remu       s0, t0, gp
                  sub        ra, t1, s11
                  sra        t1, t1, a0
                  ori        t1, ra, -664
                  mul        a6, t2, s5
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  mulhu      s1, s9, a1
                  divu       s3, gp, a2
                  and        sp, s3, s5
                  remu       s0, t0, gp
                  sra        t1, t1, a0
                  mulh       s2, t1, a3
                  mulhsu     s8, sp, s5
                  addi       s3, a2, 677
                  auipc      a4, 925829
                  xor        a4, a2, s0
                  or         a7, a0, zero
                  div        zero, a7, s0
                  xori       s3, s8, -101
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  mulhsu     s8, sp, s5
                  srai       s8, t0, 25
                  mulhsu     s8, sp, s5
                  mulhsu     s8, sp, s5
                  srli       t6, t5, 10
                  rem        a6, s6, a7
                  remu       s0, t0, gp
                  mulhsu     s8, sp, s5
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  mulh       s2, t1, a3
                  sra        t1, t1, a0
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  mulh       s2, t1, a3
                  nop
                  srl        zero, t1, a4
                  slti       s10, s8, -890
                  srai       s8, t0, 25
                  srl        zero, t1, a4
                  srli       t6, t5, 10
                  divu       s3, gp, a2
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  div        zero, a7, s0
                  or         a7, a0, zero
                  mulhsu     s8, sp, s5
                  and        sp, s3, s5
                  li         t0, 0x553f798 #start riscv_int_numeric_corner_stream_32
                  li         t6, 0x80000000
                  li         s4, 0x80000000
                  li         s5, 0x80000000
                  li         s9, 0x80000000
                  li         t5, 0xffffffff
                  li         sp, 0x7ee75c6
                  li         a2, 0x0
                  li         s0, 0x80000000
                  li         a6, 0x80000000
                  auipc      t6, 925829
                  mul        s4, s9, s4
                  divu       t0, a2, a6
                  nop
                  mulhu      t6, t6, s0
                  divu       t0, a2, a6
                  divu       t0, a2, a6
                  addi       t0, t0, 677
                  mul        s4, s9, s4
                  mulhsu     s5, s0, s4
                  auipc      t6, 925829
                  mulh       sp, s5, a2
                  mulhsu     s5, s0, s4
                  rem        s4, s5, t0
                  div        sp, t0, t5
                  rem        s4, s5, t0
                  remu       t5, s4, a2
                  mulhu      t6, t6, s0
                  mul        s4, s9, s4
                  mulhsu     s5, s0, s4
                  mul        s4, s9, s4
                  remu       t5, s4, a2
                  mulh       sp, s5, a2
                  rem        s4, s5, t0
                  sub        t0, s5, sp #end riscv_int_numeric_corner_stream_32
                  and        sp, s3, s5
                  nop
                  rem        a6, s6, a7
                  sub        ra, t1, s11
                  remu       s0, t0, gp
                  srli       t6, t5, 10
                  add        tp, gp, s11
                  sltiu      a2, a0, -848
                  xori       s3, s8, -101
                  divu       s3, gp, a2
                  andi       gp, s9, -46
                  lui        s6, 496523
                  slti       s10, s8, -890
                  mulhsu     s8, sp, s5
                  sub        ra, t1, s11
                  mul        a6, t2, s5
                  sub        ra, t1, s11
                  slli       tp, t1, 9
                  nop
                  mulhsu     s8, sp, s5
                  sltu       t3, t1, tp
                  slti       s10, s8, -890
                  or         a7, a0, zero
                  srai       s8, t0, 25
                  addi       s3, a2, 677
                  mulhsu     s8, sp, s5
                  or         a7, a0, zero
                  andi       gp, s9, -46
                  sub        ra, t1, s11
                  or         a7, a0, zero
                  mulhsu     s8, sp, s5
                  auipc      a4, 925829
                  mul        a6, t2, s5
                  or         a7, a0, zero
                  andi       gp, s9, -46
                  mulhsu     s8, sp, s5
                  sltiu      a2, a0, -848
                  mulhsu     s8, sp, s5
                  srli       t6, t5, 10
                  auipc      a4, 925829
                  mulhsu     s8, sp, s5
                  sltu       t3, t1, tp
                  sltiu      a2, a0, -848
                  sra        t1, t1, a0
                  slt        a1, a1, zero
                  divu       s3, gp, a2
                  sltiu      a2, a0, -848
                  addi       s3, a2, 677
                  divu       s3, gp, a2
                  sub        ra, t1, s11
                  add        tp, gp, s11
                  xori       s3, s8, -101
                  sltu       t3, t1, tp
                  sltu       t3, t1, tp
                  sra        t1, t1, a0
                  mulhu      s1, s9, a1
                  ori        t1, ra, -664
                  and        sp, s3, s5
                  srai       s8, t0, 25
                  remu       s0, t0, gp
                  rem        a6, s6, a7
                  ori        t1, ra, -664
                  and        sp, s3, s5
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  mulhsu     s8, sp, s5
                  slti       s10, s8, -890
                  slti       s10, s8, -890
                  sub        ra, t1, s11
                  and        sp, s3, s5
                  slti       s10, s8, -890
                  mulhu      s1, s9, a1
                  add        tp, gp, s11
                  sltu       t3, t1, tp
                  ori        t1, ra, -664
                  slli       tp, t1, 9
                  slt        a1, a1, zero
                  or         a7, a0, zero
                  nop
                  xor        a4, a2, s0
                  slt        a1, a1, zero
                  xori       s3, s8, -101
                  srai       s8, t0, 25
                  sltu       t3, t1, tp
                  mul        a6, t2, s5
                  addi       s3, a2, 677
                  and        sp, s3, s5
                  and        sp, s3, s5
                  xor        a4, a2, s0
                  lui        s6, 496523
                  nop
                  srl        zero, t1, a4
                  slti       s10, s8, -890
                  slti       s10, s8, -890
                  or         a7, a0, zero
                  mulhu      s1, s9, a1
                  remu       s0, t0, gp
                  mulhu      s1, s9, a1
                  add        tp, gp, s11
                  lui        s6, 496523
                  srli       t6, t5, 10
                  and        sp, s3, s5
                  mulh       s2, t1, a3
                  mulhu      s1, s9, a1
                  andi       gp, s9, -46
                  andi       gp, s9, -46
                  div        zero, a7, s0
                  slt        a1, a1, zero
                  nop
                  slti       s10, s8, -890
                  lui        s6, 496523
                  sub        ra, t1, s11
                  slli       tp, t1, 9
                  auipc      a4, 925829
                  sra        t1, t1, a0
                  mulhu      s1, s9, a1
                  mul        a6, t2, s5
                  sltiu      a2, a0, -848
                  mul        a6, t2, s5
                  addi       s3, a2, 677
                  srli       t6, t5, 10
                  div        zero, a7, s0
                  slti       s10, s8, -890
                  divu       s3, gp, a2
                  mul        a6, t2, s5
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  mulhu      s1, s9, a1
                  srl        zero, t1, a4
                  slt        a1, a1, zero
                  div        zero, a7, s0
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  nop
                  and        sp, s3, s5
                  sltu       t3, t1, tp
                  andi       gp, s9, -46
                  nop
                  sra        t1, t1, a0
                  srai       s8, t0, 25
                  remu       s0, t0, gp
                  auipc      a4, 925829
                  sub        ra, t1, s11
                  sltu       t3, t1, tp
                  sltu       t3, t1, tp
                  sltu       t3, t1, tp
                  xori       s3, s8, -101
                  addi       s3, a2, 677
                  srli       t6, t5, 10
                  auipc      a4, 925829
                  andi       gp, s9, -46
                  andi       gp, s9, -46
                  lui        s6, 496523
                  andi       gp, s9, -46
                  sub        ra, t1, s11
                  sltu       t3, t1, tp
                  sltu       t3, t1, tp
                  nop
                  srai       s8, t0, 25
                  sra        t1, t1, a0
                  divu       s3, gp, a2
                  srai       s8, t0, 25
                  and        sp, s3, s5
                  sltu       t3, t1, tp
                  divu       s3, gp, a2
                  add        tp, gp, s11
                  mulh       s2, t1, a3
                  slti       s10, s8, -890
                  div        zero, a7, s0
                  mulhsu     s8, sp, s5
                  or         a7, a0, zero
                  sub        ra, t1, s11
                  sub        ra, t1, s11
                  slli       tp, t1, 9
                  nop
                  nop
                  ori        t1, ra, -664
                  xori       s3, s8, -101
                  srai       s8, t0, 25
                  rem        a6, s6, a7
                  slli       tp, t1, 9
                  sub        ra, t1, s11
                  and        sp, s3, s5
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  add        tp, gp, s11
                  sll        s10, sp, a0
                  nop
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  srai       s8, t0, 25
                  sub        ra, t1, s11
                  slti       s10, s8, -890
                  srai       s8, t0, 25
                  xori       s3, s8, -101
                  srai       s8, t0, 25
                  srai       s8, t0, 25
                  srai       s8, t0, 25
                  mulh       s2, t1, a3
                  slt        a1, a1, zero
                  slli       tp, t1, 9
                  mulh       s2, t1, a3
                  remu       s0, t0, gp
                  mulhu      s1, s9, a1
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  andi       gp, s9, -46
                  mulhu      s1, s9, a1
                  srl        zero, t1, a4
                  srli       t6, t5, 10
                  rem        a6, s6, a7
                  slli       tp, t1, 9
                  add        tp, gp, s11
                  srai       s8, t0, 25
                  mulhsu     s8, sp, s5
                  sra        t1, t1, a0
                  div        zero, a7, s0
                  nop
                  ori        t1, ra, -664
                  addi       s3, a2, 677
                  mulh       s2, t1, a3
                  xor        a4, a2, s0
                  mulhsu     s8, sp, s5
                  andi       gp, s9, -46
                  add        tp, gp, s11
                  slli       tp, t1, 9
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  andi       gp, s9, -46
                  xor        a4, a2, s0
                  sltu       t3, t1, tp
                  mulhu      s1, s9, a1
                  rem        a6, s6, a7
                  add        tp, gp, s11
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  addi       s3, a2, 677
                  auipc      a4, 925829
                  or         a7, a0, zero
                  div        zero, a7, s0
                  slt        a1, a1, zero
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  divu       s3, gp, a2
                  slli       tp, t1, 9
                  mulh       s2, t1, a3
                  sra        t1, t1, a0
                  sll        s10, sp, a0
                  mulhsu     s8, sp, s5
                  sltiu      a2, a0, -848
                  srli       t6, t5, 10
                  lui        s6, 496523
                  or         a7, a0, zero
                  sub        ra, t1, s11
                  mulh       s2, t1, a3
                  slt        a1, a1, zero
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  auipc      a4, 925829
                  ori        t1, ra, -664
                  and        sp, s3, s5
                  srl        zero, t1, a4
                  auipc      a4, 925829
                  or         a7, a0, zero
                  mulhu      s1, s9, a1
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  mulhsu     s8, sp, s5
                  mulhsu     s8, sp, s5
                  mulhu      s1, s9, a1
                  xor        a4, a2, s0
                  remu       s0, t0, gp
                  or         a7, a0, zero
                  add        tp, gp, s11
                  xor        a4, a2, s0
                  div        zero, a7, s0
                  mulhu      s1, s9, a1
                  sll        s10, sp, a0
                  sll        s10, sp, a0
                  srl        zero, t1, a4
                  nop
                  divu       s3, gp, a2
                  divu       s3, gp, a2
                  sub        ra, t1, s11
                  rem        a6, s6, a7
                  addi       s3, a2, 677
                  add        tp, gp, s11
                  srli       t6, t5, 10
                  sub        ra, t1, s11
                  ori        t1, ra, -664
                  sub        ra, t1, s11
                  mul        a6, t2, s5
                  slti       s10, s8, -890
                  mul        a6, t2, s5
                  or         a7, a0, zero
                  xor        a4, a2, s0
                  div        zero, a7, s0
                  slt        a1, a1, zero
                  or         a7, a0, zero
                  sra        t1, t1, a0
                  srl        zero, t1, a4
                  srli       t6, t5, 10
                  mulh       s2, t1, a3
                  slt        a1, a1, zero
                  mulh       s2, t1, a3
                  mulhsu     s8, sp, s5
                  srli       t6, t5, 10
                  sra        t1, t1, a0
                  slt        a1, a1, zero
                  mulh       s2, t1, a3
                  auipc      a4, 925829
                  addi       s3, a2, 677
                  divu       s3, gp, a2
                  rem        a6, s6, a7
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  div        zero, a7, s0
                  addi       s3, a2, 677
                  auipc      a4, 925829
                  divu       s3, gp, a2
                  sltu       t3, t1, tp
                  sltu       t3, t1, tp
                  and        sp, s3, s5
                  sltiu      a2, a0, -848
                  sra        t1, t1, a0
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  mulhsu     s8, sp, s5
                  rem        a6, s6, a7
                  lui        s6, 496523
                  and        sp, s3, s5
                  mulhu      s1, s9, a1
                  sltiu      a2, a0, -848
                  xori       s3, s8, -101
                  xori       s3, s8, -101
                  slti       s10, s8, -890
                  xori       s3, s8, -101
                  rem        a6, s6, a7
                  mul        a6, t2, s5
                  sll        s10, sp, a0
                  mulhsu     s8, sp, s5
                  and        sp, s3, s5
                  mulhu      s1, s9, a1
                  mul        a6, t2, s5
                  mulhu      s1, s9, a1
                  srl        zero, t1, a4
                  slti       s10, s8, -890
                  sll        s10, sp, a0
                  add        tp, gp, s11
                  xor        a4, a2, s0
                  xori       s3, s8, -101
                  sra        t1, t1, a0
                  add        tp, gp, s11
                  divu       s3, gp, a2
                  slt        a1, a1, zero
                  or         a7, a0, zero
                  xori       s3, s8, -101
                  mulh       s2, t1, a3
                  div        zero, a7, s0
                  sll        s10, sp, a0
                  sltu       t3, t1, tp
                  srl        zero, t1, a4
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  remu       s0, t0, gp
                  andi       gp, s9, -46
                  slli       tp, t1, 9
                  rem        a6, s6, a7
                  remu       s0, t0, gp
                  or         a7, a0, zero
                  mulh       s2, t1, a3
                  ori        t1, ra, -664
                  mulh       s2, t1, a3
                  and        sp, s3, s5
                  add        tp, gp, s11
                  sltiu      a2, a0, -848
                  sub        ra, t1, s11
                  srli       t6, t5, 10
                  xor        a4, a2, s0
                  slli       tp, t1, 9
                  sltiu      a2, a0, -848
                  sltiu      a2, a0, -848
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  remu       s0, t0, gp
                  or         a7, a0, zero
                  mulhsu     s8, sp, s5
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  mulh       s2, t1, a3
                  slti       s10, s8, -890
                  remu       s0, t0, gp
                  mulhu      s1, s9, a1
                  sub        ra, t1, s11
                  mulh       s2, t1, a3
                  slt        a1, a1, zero
                  add        tp, gp, s11
                  srli       t6, t5, 10
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  slt        a1, a1, zero
                  xori       s3, s8, -101
                  mulhsu     s8, sp, s5
                  slt        a1, a1, zero
                  sub        ra, t1, s11
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  andi       gp, s9, -46
                  sub        ra, t1, s11
                  or         a7, a0, zero
                  addi       s3, a2, 677
                  sltu       t3, t1, tp
                  divu       s3, gp, a2
                  xori       s3, s8, -101
                  sub        ra, t1, s11
                  mulh       s2, t1, a3
                  addi       s3, a2, 677
                  divu       s3, gp, a2
                  sltu       t3, t1, tp
                  srl        zero, t1, a4
                  add        tp, gp, s11
                  sltiu      a2, a0, -848
                  lui        s6, 496523
                  or         a7, a0, zero
                  andi       gp, s9, -46
                  sltiu      a2, a0, -848
                  lui        s6, 496523
                  sra        t1, t1, a0
                  srl        zero, t1, a4
                  xori       s3, s8, -101
                  andi       gp, s9, -46
                  sra        t1, t1, a0
                  sltiu      a2, a0, -848
                  divu       s3, gp, a2
                  xori       s3, s8, -101
                  xor        a4, a2, s0
                  add        tp, gp, s11
                  lui        s6, 496523
                  xor        a4, a2, s0
                  slli       tp, t1, 9
                  sub        ra, t1, s11
                  sltu       t3, t1, tp
                  add        tp, gp, s11
                  add        tp, gp, s11
                  srai       s8, t0, 25
                  mulhu      s1, s9, a1
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  slti       s10, s8, -890
                  xori       s3, s8, -101
                  srai       s8, t0, 25
                  remu       s0, t0, gp
                  mulh       s2, t1, a3
                  sltiu      a2, a0, -848
                  slti       s10, s8, -890
                  mulhu      s1, s9, a1
                  ori        t1, ra, -664
                  remu       s0, t0, gp
                  mul        a6, t2, s5
                  andi       gp, s9, -46
                  div        zero, a7, s0
                  sra        t1, t1, a0
                  xor        a4, a2, s0
                  or         a7, a0, zero
                  ori        t1, ra, -664
                  sll        s10, sp, a0
                  srli       t6, t5, 10
                  addi       s3, a2, 677
                  xori       s3, s8, -101
                  auipc      a4, 925829
                  add        tp, gp, s11
                  auipc      a4, 925829
                  sll        s10, sp, a0
                  div        zero, a7, s0
                  sll        s10, sp, a0
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  div        zero, a7, s0
                  srai       s8, t0, 25
                  rem        a6, s6, a7
                  nop
                  sltiu      a2, a0, -848
                  addi       s3, a2, 677
                  div        zero, a7, s0
                  mulhu      s1, s9, a1
                  sra        t1, t1, a0
                  div        zero, a7, s0
                  nop
                  andi       gp, s9, -46
                  srai       s8, t0, 25
                  sltu       t3, t1, tp
                  auipc      a4, 925829
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  srli       t6, t5, 10
                  nop
                  auipc      a4, 925829
                  mulh       s2, t1, a3
                  slt        a1, a1, zero
                  slt        a1, a1, zero
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  xori       s3, s8, -101
                  div        zero, a7, s0
                  xori       s3, s8, -101
                  remu       s0, t0, gp
                  remu       s0, t0, gp
                  slli       tp, t1, 9
                  mul        a6, t2, s5
                  nop
                  nop
                  slt        a1, a1, zero
                  srli       t6, t5, 10
                  and        sp, s3, s5
                  srli       t6, t5, 10
                  remu       s0, t0, gp
                  slti       s10, s8, -890
                  divu       s3, gp, a2
                  and        sp, s3, s5
                  sra        t1, t1, a0
                  or         a7, a0, zero
                  lui        s6, 496523
                  lui        s6, 496523
                  div        zero, a7, s0
                  slti       s10, s8, -890
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  srli       t6, t5, 10
                  mulh       s2, t1, a3
                  sll        s10, sp, a0
                  srl        zero, t1, a4
                  sltu       t3, t1, tp
                  lui        s6, 496523
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  mul        a6, t2, s5
                  sll        s10, sp, a0
                  mulh       s2, t1, a3
                  mulhu      s1, s9, a1
                  ori        t1, ra, -664
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  sltu       t3, t1, tp
                  sll        s10, sp, a0
                  sltu       t3, t1, tp
                  and        sp, s3, s5
                  nop
                  slti       s10, s8, -890
                  and        sp, s3, s5
                  divu       s3, gp, a2
                  sltu       t3, t1, tp
                  div        zero, a7, s0
                  lui        s6, 496523
                  mul        a6, t2, s5
                  sll        s10, sp, a0
                  sub        ra, t1, s11
                  slli       tp, t1, 9
                  remu       s0, t0, gp
                  mul        a6, t2, s5
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  addi       s3, a2, 677
                  nop
                  srli       t6, t5, 10
                  xori       s3, s8, -101
                  nop
                  sltiu      a2, a0, -848
                  xori       s3, s8, -101
                  sltu       t3, t1, tp
                  mul        a6, t2, s5
                  sra        t1, t1, a0
                  srl        zero, t1, a4
                  slli       tp, t1, 9
                  lui        s6, 496523
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  addi       s3, a2, 677
                  and        sp, s3, s5
                  remu       s0, t0, gp
                  mulh       s2, t1, a3
                  div        zero, a7, s0
                  addi       s3, a2, 677
                  mul        a6, t2, s5
                  mulhu      s1, s9, a1
                  srai       s8, t0, 25
                  mulh       s2, t1, a3
                  sra        t1, t1, a0
                  rem        a6, s6, a7
                  auipc      a4, 925829
                  xor        a4, a2, s0
                  xori       s3, s8, -101
                  srli       t6, t5, 10
                  addi       s3, a2, 677
                  ori        t1, ra, -664
                  mulhu      s1, s9, a1
                  div        zero, a7, s0
                  sub        ra, t1, s11
                  remu       s0, t0, gp
                  div        zero, a7, s0
                  rem        a6, s6, a7
                  lui        s6, 496523
                  andi       gp, s9, -46
                  sltu       t3, t1, tp
                  sra        t1, t1, a0
                  lui        s6, 496523
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  and        sp, s3, s5
                  divu       s3, gp, a2
                  srai       s8, t0, 25
                  mulhsu     s8, sp, s5
                  or         a7, a0, zero
                  div        zero, a7, s0
                  divu       s3, gp, a2
                  mulh       s2, t1, a3
                  xori       s3, s8, -101
                  ori        t1, ra, -664
                  srl        zero, t1, a4
                  mulh       s2, t1, a3
                  or         a7, a0, zero
                  srli       t6, t5, 10
                  nop
                  srl        zero, t1, a4
                  add        tp, gp, s11
                  sll        s10, sp, a0
                  slli       tp, t1, 9
                  xori       s3, s8, -101
                  slti       s10, s8, -890
                  and        sp, s3, s5
                  xori       s3, s8, -101
                  div        zero, a7, s0
                  srli       t6, t5, 10
                  srai       s8, t0, 25
                  sll        s10, sp, a0
                  srl        zero, t1, a4
                  mulhu      s1, s9, a1
                  slli       tp, t1, 9
                  ori        t1, ra, -664
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  xori       s3, s8, -101
                  remu       s0, t0, gp
                  srai       s8, t0, 25
                  rem        a6, s6, a7
                  ori        t1, ra, -664
                  auipc      a4, 925829
                  and        sp, s3, s5
                  remu       s0, t0, gp
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  remu       s0, t0, gp
                  ori        t1, ra, -664
                  srai       s8, t0, 25
                  srai       s8, t0, 25
                  div        zero, a7, s0
                  slti       s10, s8, -890
                  remu       s0, t0, gp
                  ori        t1, ra, -664
                  sltu       t3, t1, tp
                  mul        a6, t2, s5
                  mulh       s2, t1, a3
                  sll        s10, sp, a0
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  srli       t6, t5, 10
                  auipc      a4, 925829
                  nop
                  divu       s3, gp, a2
                  remu       s0, t0, gp
                  addi       s3, a2, 677
                  sltiu      a2, a0, -848
                  srai       s8, t0, 25
                  rem        a6, s6, a7
                  sltu       t3, t1, tp
                  mulhu      s1, s9, a1
                  add        tp, gp, s11
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  ori        t1, ra, -664
                  srli       t6, t5, 10
                  srl        zero, t1, a4
                  srli       t6, t5, 10
                  addi       s3, a2, 677
                  div        zero, a7, s0
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  or         a7, a0, zero
                  or         a7, a0, zero
                  addi       s3, a2, 677
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  slti       s10, s8, -890
                  slli       tp, t1, 9
                  sra        t1, t1, a0
                  lui        s6, 496523
                  sra        t1, t1, a0
                  sltu       t3, t1, tp
                  div        zero, a7, s0
                  remu       s0, t0, gp
                  mul        a6, t2, s5
                  mulhsu     s8, sp, s5
                  srli       t6, t5, 10
                  auipc      a4, 925829
                  mul        a6, t2, s5
                  mul        a6, t2, s5
                  sltiu      a2, a0, -848
                  divu       s3, gp, a2
                  remu       s0, t0, gp
                  sub        ra, t1, s11
                  mul        a6, t2, s5
                  add        tp, gp, s11
                  sll        s10, sp, a0
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  nop
                  sra        t1, t1, a0
                  slt        a1, a1, zero
                  xor        a4, a2, s0
                  or         a7, a0, zero
                  xori       s3, s8, -101
                  nop
                  sltiu      a2, a0, -848
                  mulh       s2, t1, a3
                  mul        a6, t2, s5
                  ori        t1, ra, -664
                  srl        zero, t1, a4
                  slli       tp, t1, 9
                  mulhu      s1, s9, a1
                  rem        a6, s6, a7
                  add        tp, gp, s11
                  slli       tp, t1, 9
                  or         a7, a0, zero
                  slti       s10, s8, -890
                  remu       s0, t0, gp
                  sra        t1, t1, a0
                  sll        s10, sp, a0
                  addi       s3, a2, 677
                  srai       s8, t0, 25
                  mulh       s2, t1, a3
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  srl        zero, t1, a4
                  mulhu      s1, s9, a1
                  slt        a1, a1, zero
                  mul        a6, t2, s5
                  sll        s10, sp, a0
                  sra        t1, t1, a0
                  slli       tp, t1, 9
                  lui        s6, 496523
                  sll        s10, sp, a0
                  ori        t1, ra, -664
                  sub        ra, t1, s11
                  nop
                  lui        s6, 496523
                  ori        t1, ra, -664
                  rem        a6, s6, a7
                  remu       s0, t0, gp
                  xori       s3, s8, -101
                  auipc      a4, 925829
                  divu       s3, gp, a2
                  or         a7, a0, zero
                  sub        ra, t1, s11
                  lui        s6, 496523
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  or         a7, a0, zero
                  remu       s0, t0, gp
                  srai       s8, t0, 25
                  slli       tp, t1, 9
                  xor        a4, a2, s0
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  andi       gp, s9, -46
                  sub        ra, t1, s11
                  andi       gp, s9, -46
                  lui        s6, 496523
                  sltu       t3, t1, tp
                  sub        ra, t1, s11
                  xori       s3, s8, -101
                  auipc      a4, 925829
                  rem        a6, s6, a7
                  mulh       s2, t1, a3
                  slt        a1, a1, zero
                  auipc      a4, 925829
                  mulhu      s1, s9, a1
                  sltu       t3, t1, tp
                  sll        s10, sp, a0
                  ori        t1, ra, -664
                  srai       s8, t0, 25
                  srli       t6, t5, 10
                  div        zero, a7, s0
                  sll        s10, sp, a0
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  srli       t6, t5, 10
                  sltiu      a2, a0, -848
                  slti       s10, s8, -890
                  srai       s8, t0, 25
                  and        sp, s3, s5
                  ori        t1, ra, -664
                  mul        a6, t2, s5
                  divu       s3, gp, a2
                  slli       tp, t1, 9
                  srli       t6, t5, 10
                  srl        zero, t1, a4
                  auipc      a4, 925829
                  or         a7, a0, zero
                  mulh       s2, t1, a3
                  sub        ra, t1, s11
                  addi       s3, a2, 677
                  lui        s6, 496523
                  nop
                  div        zero, a7, s0
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  or         a7, a0, zero
                  andi       gp, s9, -46
                  xor        a4, a2, s0
                  mulh       s2, t1, a3
                  nop
                  sltu       t3, t1, tp
                  remu       s0, t0, gp
                  sub        ra, t1, s11
                  xor        a4, a2, s0
                  xor        a4, a2, s0
                  sltu       t3, t1, tp
                  addi       s3, a2, 677
                  slt        a1, a1, zero
                  auipc      a4, 925829
                  nop
                  xori       s3, s8, -101
                  ori        t1, ra, -664
                  ori        t1, ra, -664
                  andi       gp, s9, -46
                  srl        zero, t1, a4
                  andi       gp, s9, -46
                  add        tp, gp, s11
                  and        sp, s3, s5
                  addi       s3, a2, 677
                  srai       s8, t0, 25
                  and        sp, s3, s5
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  sltu       t3, t1, tp
                  div        zero, a7, s0
                  sll        s10, sp, a0
                  xori       s3, s8, -101
                  slti       s10, s8, -890
                  sltu       t3, t1, tp
                  xor        a4, a2, s0
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  slti       s10, s8, -890
                  lui        s6, 496523
                  sltiu      a2, a0, -848
                  srai       s8, t0, 25
                  sll        s10, sp, a0
                  lui        s6, 496523
                  lui        s6, 496523
                  rem        a6, s6, a7
                  div        zero, a7, s0
                  sra        t1, t1, a0
                  lui        s6, 496523
                  auipc      a4, 925829
                  divu       s3, gp, a2
                  srl        zero, t1, a4
                  srli       t6, t5, 10
                  and        sp, s3, s5
                  mulhsu     s8, sp, s5
                  addi       s3, a2, 677
                  div        zero, a7, s0
                  divu       s3, gp, a2
                  sra        t1, t1, a0
                  sll        s10, sp, a0
                  sll        s10, sp, a0
                  mulhsu     s8, sp, s5
                  srai       s8, t0, 25
                  srl        zero, t1, a4
                  srli       t6, t5, 10
                  nop
                  mulh       s2, t1, a3
                  mulhsu     s8, sp, s5
                  andi       gp, s9, -46
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  srli       t6, t5, 10
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  add        tp, gp, s11
                  slli       tp, t1, 9
                  ori        t1, ra, -664
                  add        tp, gp, s11
                  auipc      a4, 925829
                  slti       s10, s8, -890
                  slli       tp, t1, 9
                  mulhsu     s8, sp, s5
                  sll        s10, sp, a0
                  auipc      a4, 925829
                  and        sp, s3, s5
                  sub        ra, t1, s11
                  rem        a6, s6, a7
                  mulhu      s1, s9, a1
                  mulhsu     s8, sp, s5
                  mulh       s2, t1, a3
                  xor        a4, a2, s0
                  xori       s3, s8, -101
                  addi       s3, a2, 677
                  sll        s10, sp, a0
                  srli       t6, t5, 10
                  mulh       s2, t1, a3
                  mulh       s2, t1, a3
                  sltiu      a2, a0, -848
                  rem        a6, s6, a7
                  srai       s8, t0, 25
                  remu       s0, t0, gp
                  ori        t1, ra, -664
                  lui        s6, 496523
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  srl        zero, t1, a4
                  or         a7, a0, zero
                  slli       tp, t1, 9
                  sltiu      a2, a0, -848
                  srl        zero, t1, a4
                  div        zero, a7, s0
                  andi       gp, s9, -46
                  slli       tp, t1, 9
                  rem        a6, s6, a7
                  andi       gp, s9, -46
                  div        zero, a7, s0
                  add        tp, gp, s11
                  xori       s3, s8, -101
                  remu       s0, t0, gp
                  mulh       s2, t1, a3
                  slli       tp, t1, 9
                  srli       t6, t5, 10
                  xor        a4, a2, s0
                  divu       s3, gp, a2
                  add        tp, gp, s11
                  auipc      a4, 925829
                  mulhsu     s8, sp, s5
                  srli       t6, t5, 10
                  and        sp, s3, s5
                  srai       s8, t0, 25
                  nop
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  slt        a1, a1, zero
                  mulhu      s1, s9, a1
                  ori        t1, ra, -664
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  remu       s0, t0, gp
                  remu       s0, t0, gp
                  ori        t1, ra, -664
                  nop
                  rem        a6, s6, a7
                  addi       s3, a2, 677
                  xori       s3, s8, -101
                  sltu       t3, t1, tp
                  sltu       t3, t1, tp
                  xor        a4, a2, s0
                  mulhu      s1, s9, a1
                  or         a7, a0, zero
                  mulh       s2, t1, a3
                  or         a7, a0, zero
                  xori       s3, s8, -101
                  addi       s3, a2, 677
                  div        zero, a7, s0
                  sltu       t3, t1, tp
                  addi       s3, a2, 677
                  slt        a1, a1, zero
                  sll        s10, sp, a0
                  slt        a1, a1, zero
                  remu       s0, t0, gp
                  srl        zero, t1, a4
                  xori       s3, s8, -101
                  sltu       t3, t1, tp
                  auipc      a4, 925829
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  auipc      a4, 925829
                  nop
                  srli       t6, t5, 10
                  slti       s10, s8, -890
                  slti       s10, s8, -890
                  sra        t1, t1, a0
                  xori       s3, s8, -101
                  mulhsu     s8, sp, s5
                  srai       s8, t0, 25
                  xori       s3, s8, -101
                  xori       s3, s8, -101
                  add        tp, gp, s11
                  sltiu      a2, a0, -848
                  div        zero, a7, s0
                  sltu       t3, t1, tp
                  div        zero, a7, s0
                  srli       t6, t5, 10
                  mul        a6, t2, s5
                  mulhu      s1, s9, a1
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  slli       tp, t1, 9
                  mulhsu     s8, sp, s5
                  srl        zero, t1, a4
                  sltu       t3, t1, tp
                  sub        ra, t1, s11
                  sltiu      a2, a0, -848
                  xori       s3, s8, -101
                  xori       s3, s8, -101
                  auipc      a4, 925829
                  srl        zero, t1, a4
                  divu       s3, gp, a2
                  sra        t1, t1, a0
                  sll        s10, sp, a0
                  slli       tp, t1, 9
                  or         a7, a0, zero
                  srli       t6, t5, 10
                  xor        a4, a2, s0
                  sltu       t3, t1, tp
                  slli       tp, t1, 9
                  slti       s10, s8, -890
                  add        tp, gp, s11
                  srai       s8, t0, 25
                  slti       s10, s8, -890
                  sra        t1, t1, a0
                  srli       t6, t5, 10
                  mulhu      s1, s9, a1
                  and        sp, s3, s5
                  remu       s0, t0, gp
                  sra        t1, t1, a0
                  mul        a6, t2, s5
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  divu       s3, gp, a2
                  mulhu      s1, s9, a1
                  mulh       s2, t1, a3
                  sra        t1, t1, a0
                  div        zero, a7, s0
                  div        zero, a7, s0
                  sltiu      a2, a0, -848
                  remu       s0, t0, gp
                  xori       s3, s8, -101
                  mulh       s2, t1, a3
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  ori        t1, ra, -664
                  srli       t6, t5, 10
                  slli       tp, t1, 9
                  remu       s0, t0, gp
                  sra        t1, t1, a0
                  sub        ra, t1, s11
                  sltu       t3, t1, tp
                  sll        s10, sp, a0
                  xori       s3, s8, -101
                  and        sp, s3, s5
                  or         a7, a0, zero
                  sll        s10, sp, a0
                  add        tp, gp, s11
                  sltiu      a2, a0, -848
                  slt        a1, a1, zero
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  auipc      a4, 925829
                  divu       s3, gp, a2
                  srli       t6, t5, 10
                  slti       s10, s8, -890
                  srli       t6, t5, 10
                  slt        a1, a1, zero
                  lui        s6, 496523
                  xori       s3, s8, -101
                  slti       s10, s8, -890
                  remu       s0, t0, gp
                  remu       s0, t0, gp
                  and        sp, s3, s5
                  slli       tp, t1, 9
                  sltu       t3, t1, tp
                  mulh       s2, t1, a3
                  and        sp, s3, s5
                  slli       tp, t1, 9
                  div        zero, a7, s0
                  slli       tp, t1, 9
                  remu       s0, t0, gp
                  mulhu      s1, s9, a1
                  divu       s3, gp, a2
                  divu       s3, gp, a2
                  rem        a6, s6, a7
                  slt        a1, a1, zero
                  and        sp, s3, s5
                  andi       gp, s9, -46
                  srl        zero, t1, a4
                  sub        ra, t1, s11
                  or         a7, a0, zero
                  mulhsu     s8, sp, s5
                  sra        t1, t1, a0
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  divu       s3, gp, a2
                  and        sp, s3, s5
                  slt        a1, a1, zero
                  div        zero, a7, s0
                  rem        a6, s6, a7
                  xori       s3, s8, -101
                  slt        a1, a1, zero
                  slt        a1, a1, zero
                  divu       s3, gp, a2
                  and        sp, s3, s5
                  xori       s3, s8, -101
                  sub        ra, t1, s11
                  rem        a6, s6, a7
                  andi       gp, s9, -46
                  srli       t6, t5, 10
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  ori        t1, ra, -664
                  xori       s3, s8, -101
                  slli       tp, t1, 9
                  ori        t1, ra, -664
                  sub        ra, t1, s11
                  slli       tp, t1, 9
                  sra        t1, t1, a0
                  srl        zero, t1, a4
                  xori       s3, s8, -101
                  rem        a6, s6, a7
                  sll        s10, sp, a0
                  lui        s6, 496523
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  slt        a1, a1, zero
                  mulhsu     s8, sp, s5
                  srl        zero, t1, a4
                  addi       s3, a2, 677
                  srli       t6, t5, 10
                  slt        a1, a1, zero
                  auipc      a4, 925829
                  mul        a6, t2, s5
                  sll        s10, sp, a0
                  div        zero, a7, s0
                  ori        t1, ra, -664
                  slti       s10, s8, -890
                  nop
                  lui        s6, 496523
                  sra        t1, t1, a0
                  sltiu      a2, a0, -848
                  divu       s3, gp, a2
                  lui        s6, 496523
                  addi       s3, a2, 677
                  remu       s0, t0, gp
                  xori       s3, s8, -101
                  divu       s3, gp, a2
                  srl        zero, t1, a4
                  sltiu      a2, a0, -848
                  slti       s10, s8, -890
                  sltu       t3, t1, tp
                  and        sp, s3, s5
                  or         a7, a0, zero
                  xori       s3, s8, -101
                  or         a7, a0, zero
                  srli       t6, t5, 10
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  andi       gp, s9, -46
                  slli       tp, t1, 9
                  slt        a1, a1, zero
                  sub        ra, t1, s11
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  srai       s8, t0, 25
                  mul        a6, t2, s5
                  sltu       t3, t1, tp
                  sltiu      a2, a0, -848
                  slti       s10, s8, -890
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  sltiu      a2, a0, -848
                  srli       t6, t5, 10
                  sltiu      a2, a0, -848
                  rem        a6, s6, a7
                  or         a7, a0, zero
                  xor        a4, a2, s0
                  xori       s3, s8, -101
                  ori        t1, ra, -664
                  mulh       s2, t1, a3
                  srli       t6, t5, 10
                  xor        a4, a2, s0
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  divu       s3, gp, a2
                  sub        ra, t1, s11
                  sll        s10, sp, a0
                  srl        zero, t1, a4
                  andi       gp, s9, -46
                  or         a7, a0, zero
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  mul        a6, t2, s5
                  nop
                  xori       s3, s8, -101
                  ori        t1, ra, -664
                  mulhu      s1, s9, a1
                  sra        t1, t1, a0
                  divu       s3, gp, a2
                  andi       gp, s9, -46
                  mulhu      s1, s9, a1
                  divu       s3, gp, a2
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  xor        a4, a2, s0
                  mul        a6, t2, s5
                  mul        a6, t2, s5
                  mul        a6, t2, s5
                  remu       s0, t0, gp
                  divu       s3, gp, a2
                  sltiu      a2, a0, -848
                  addi       s3, a2, 677
                  ori        t1, ra, -664
                  mulhu      s1, s9, a1
                  mulhu      s1, s9, a1
                  andi       gp, s9, -46
                  or         a7, a0, zero
                  mulh       s2, t1, a3
                  auipc      a4, 925829
                  srli       t6, t5, 10
                  div        zero, a7, s0
                  or         a7, a0, zero
                  nop
                  mulhu      s1, s9, a1
                  mul        a6, t2, s5
                  nop
                  mulhu      s1, s9, a1
                  xor        a4, a2, s0
                  lui        s6, 496523
                  div        zero, a7, s0
                  mul        a6, t2, s5
                  sltu       t3, t1, tp
                  div        zero, a7, s0
                  slli       tp, t1, 9
                  and        sp, s3, s5
                  sltiu      a2, a0, -848
                  mulh       s2, t1, a3
                  sra        t1, t1, a0
                  slli       tp, t1, 9
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  mulhsu     s8, sp, s5
                  slli       tp, t1, 9
                  remu       s0, t0, gp
                  xori       s3, s8, -101
                  xori       s3, s8, -101
                  remu       s0, t0, gp
                  srli       t6, t5, 10
                  addi       s3, a2, 677
                  andi       gp, s9, -46
                  slli       tp, t1, 9
                  xori       s3, s8, -101
                  auipc      a4, 925829
                  mulh       s2, t1, a3
                  and        sp, s3, s5
                  slt        a1, a1, zero
                  sub        ra, t1, s11
                  div        zero, a7, s0
                  xor        a4, a2, s0
                  sra        t1, t1, a0
                  or         a7, a0, zero
                  and        sp, s3, s5
                  sra        t1, t1, a0
                  slli       tp, t1, 9
                  srai       s8, t0, 25
                  sra        t1, t1, a0
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  xor        a4, a2, s0
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  divu       s3, gp, a2
                  sra        t1, t1, a0
                  mulhsu     s8, sp, s5
                  srli       t6, t5, 10
                  div        zero, a7, s0
                  ori        t1, ra, -664
                  slt        a1, a1, zero
                  and        sp, s3, s5
                  divu       s3, gp, a2
                  sub        ra, t1, s11
                  auipc      a4, 925829
                  slt        a1, a1, zero
                  sub        ra, t1, s11
                  rem        a6, s6, a7
                  srli       t6, t5, 10
                  mulhu      s1, s9, a1
                  slt        a1, a1, zero
                  sub        ra, t1, s11
                  nop
                  lui        s6, 496523
                  srl        zero, t1, a4
                  srai       s8, t0, 25
                  ori        t1, ra, -664
                  lui        s6, 496523
                  xor        a4, a2, s0
                  andi       gp, s9, -46
                  or         a7, a0, zero
                  sra        t1, t1, a0
                  mulhsu     s8, sp, s5
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  sltu       t3, t1, tp
                  mul        a6, t2, s5
                  nop
                  srai       s8, t0, 25
                  mulh       s2, t1, a3
                  or         a7, a0, zero
                  sra        t1, t1, a0
                  sltiu      a2, a0, -848
                  and        sp, s3, s5
                  divu       s3, gp, a2
                  sltu       t3, t1, tp
                  ori        t1, ra, -664
                  lui        s6, 496523
                  xor        a4, a2, s0
                  addi       s3, a2, 677
                  xori       s3, s8, -101
                  mulh       s2, t1, a3
                  slli       tp, t1, 9
                  addi       s3, a2, 677
                  mul        a6, t2, s5
                  rem        a6, s6, a7
                  mul        a6, t2, s5
                  slti       s10, s8, -890
                  srl        zero, t1, a4
                  sltiu      a2, a0, -848
                  rem        a6, s6, a7
                  mulhsu     s8, sp, s5
                  add        tp, gp, s11
                  addi       s3, a2, 677
                  slli       tp, t1, 9
                  rem        a6, s6, a7
                  sltiu      a2, a0, -848
                  or         a7, a0, zero
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  and        sp, s3, s5
                  and        sp, s3, s5
                  lui        s6, 496523
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  mulhsu     s8, sp, s5
                  remu       s0, t0, gp
                  sub        ra, t1, s11
                  mulhu      s1, s9, a1
                  sll        s10, sp, a0
                  auipc      a4, 925829
                  sra        t1, t1, a0
                  slt        a1, a1, zero
                  mulhsu     s8, sp, s5
                  sll        s10, sp, a0
                  and        sp, s3, s5
                  div        zero, a7, s0
                  lui        s6, 496523
                  sll        s10, sp, a0
                  srli       t6, t5, 10
                  slli       tp, t1, 9
                  lui        s6, 496523
                  add        tp, gp, s11
                  sub        ra, t1, s11
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  mulhu      s1, s9, a1
                  mul        a6, t2, s5
                  slt        a1, a1, zero
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  slt        a1, a1, zero
                  nop
                  and        sp, s3, s5
                  srai       s8, t0, 25
                  auipc      a4, 925829
                  sub        ra, t1, s11
                  slti       s10, s8, -890
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  mulhsu     s8, sp, s5
                  sub        ra, t1, s11
                  rem        a6, s6, a7
                  xori       s3, s8, -101
                  sll        s10, sp, a0
                  lui        s6, 496523
                  divu       s3, gp, a2
                  srli       t6, t5, 10
                  sltiu      a2, a0, -848
                  sub        ra, t1, s11
                  sltu       t3, t1, tp
                  auipc      a4, 925829
                  andi       gp, s9, -46
                  or         a7, a0, zero
                  mulh       s2, t1, a3
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  add        tp, gp, s11
                  add        tp, gp, s11
                  slli       tp, t1, 9
                  mulh       s2, t1, a3
                  and        sp, s3, s5
                  slt        a1, a1, zero
                  lui        s6, 496523
                  sltu       t3, t1, tp
                  slti       s10, s8, -890
                  sub        ra, t1, s11
                  mul        a6, t2, s5
                  srli       t6, t5, 10
                  srai       s8, t0, 25
                  add        tp, gp, s11
                  sub        ra, t1, s11
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  sltiu      a2, a0, -848
                  remu       s0, t0, gp
                  sltu       t3, t1, tp
                  slli       tp, t1, 9
                  lui        s6, 496523
                  slli       tp, t1, 9
                  ori        t1, ra, -664
                  div        zero, a7, s0
                  auipc      a4, 925829
                  srli       t6, t5, 10
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  mulhsu     s8, sp, s5
                  srai       s8, t0, 25
                  sltiu      a2, a0, -848
                  auipc      a4, 925829
                  divu       s3, gp, a2
                  addi       s3, a2, 677
                  sub        ra, t1, s11
                  divu       s3, gp, a2
                  auipc      a4, 925829
                  sub        ra, t1, s11
                  andi       gp, s9, -46
                  nop
                  ori        t1, ra, -664
                  sltu       t3, t1, tp
                  slli       tp, t1, 9
                  mulhu      s1, s9, a1
                  slt        a1, a1, zero
                  srai       s8, t0, 25
                  srli       t6, t5, 10
                  remu       s0, t0, gp
                  slt        a1, a1, zero
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  slli       tp, t1, 9
                  divu       s3, gp, a2
                  slli       tp, t1, 9
                  xor        a4, a2, s0
                  mul        a6, t2, s5
                  mulhsu     s8, sp, s5
                  sltu       t3, t1, tp
                  mulh       s2, t1, a3
                  remu       s0, t0, gp
                  srli       t6, t5, 10
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  add        tp, gp, s11
                  slli       tp, t1, 9
                  sra        t1, t1, a0
                  srli       t6, t5, 10
                  addi       s3, a2, 677
                  remu       s0, t0, gp
                  divu       s3, gp, a2
                  sltiu      a2, a0, -848
                  sll        s10, sp, a0
                  sltu       t3, t1, tp
                  div        zero, a7, s0
                  sll        s10, sp, a0
                  addi       s3, a2, 677
                  div        zero, a7, s0
                  xor        a4, a2, s0
                  and        sp, s3, s5
                  and        sp, s3, s5
                  add        tp, gp, s11
                  slli       tp, t1, 9
                  add        tp, gp, s11
                  mulhsu     s8, sp, s5
                  slli       tp, t1, 9
                  slti       s10, s8, -890
                  mulh       s2, t1, a3
                  mulhsu     s8, sp, s5
                  srl        zero, t1, a4
                  sltiu      a2, a0, -848
                  sll        s10, sp, a0
                  xor        a4, a2, s0
                  divu       s3, gp, a2
                  mulhu      s1, s9, a1
                  and        sp, s3, s5
                  or         a7, a0, zero
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  or         a7, a0, zero
                  srli       t6, t5, 10
                  and        sp, s3, s5
                  ori        t1, ra, -664
                  rem        a6, s6, a7
                  srli       t6, t5, 10
                  div        zero, a7, s0
                  and        sp, s3, s5
                  mulh       s2, t1, a3
                  auipc      a4, 925829
                  sltiu      a2, a0, -848
                  add        tp, gp, s11
                  xor        a4, a2, s0
                  srli       t6, t5, 10
                  sll        s10, sp, a0
                  slli       tp, t1, 9
                  sll        s10, sp, a0
                  sra        t1, t1, a0
                  srli       t6, t5, 10
                  addi       s3, a2, 677
                  div        zero, a7, s0
                  mul        a6, t2, s5
                  mulh       s2, t1, a3
                  slt        a1, a1, zero
                  mulhu      s1, s9, a1
                  sltiu      a2, a0, -848
                  and        sp, s3, s5
                  addi       s3, a2, 677
                  add        tp, gp, s11
                  nop
                  mul        a6, t2, s5
                  srli       t6, t5, 10
                  sll        s10, sp, a0
                  xor        a4, a2, s0
                  sltu       t3, t1, tp
                  or         a7, a0, zero
                  rem        a6, s6, a7
                  srai       s8, t0, 25
                  srli       t6, t5, 10
                  addi       s3, a2, 677
                  sll        s10, sp, a0
                  addi       s3, a2, 677
                  sra        t1, t1, a0
                  mulhu      s1, s9, a1
                  ori        t1, ra, -664
                  divu       s3, gp, a2
                  sll        s10, sp, a0
                  auipc      a4, 925829
                  div        zero, a7, s0
                  or         a7, a0, zero
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  sub        ra, t1, s11
                  remu       s0, t0, gp
                  srli       t6, t5, 10
                  lui        s6, 496523
                  or         a7, a0, zero
                  rem        a6, s6, a7
                  and        sp, s3, s5
                  andi       gp, s9, -46
                  mulhsu     s8, sp, s5
                  srli       t6, t5, 10
                  add        tp, gp, s11
                  sra        t1, t1, a0
                  addi       s3, a2, 677
                  srli       t6, t5, 10
                  remu       s0, t0, gp
                  andi       gp, s9, -46
                  sra        t1, t1, a0
                  srai       s8, t0, 25
                  mulhu      s1, s9, a1
                  slti       s10, s8, -890
                  mulh       s2, t1, a3
                  nop
                  xor        a4, a2, s0
                  andi       gp, s9, -46
                  and        sp, s3, s5
                  addi       s3, a2, 677
                  add        tp, gp, s11
                  divu       s3, gp, a2
                  auipc      a4, 925829
                  srl        zero, t1, a4
                  andi       gp, s9, -46
                  nop
                  and        sp, s3, s5
                  ori        t1, ra, -664
                  xori       s3, s8, -101
                  nop
                  add        tp, gp, s11
                  sltiu      a2, a0, -848
                  mulhsu     s8, sp, s5
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  sltiu      a2, a0, -848
                  nop
                  sltiu      a2, a0, -848
                  auipc      a4, 925829
                  srl        zero, t1, a4
                  lui        s6, 496523
                  div        zero, a7, s0
                  sra        t1, t1, a0
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  srai       s8, t0, 25
                  sra        t1, t1, a0
                  div        zero, a7, s0
                  nop
                  divu       s3, gp, a2
                  or         a7, a0, zero
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  ori        t1, ra, -664
                  rem        a6, s6, a7
                  sltiu      a2, a0, -848
                  andi       gp, s9, -46
                  mulhsu     s8, sp, s5
                  sltu       t3, t1, tp
                  rem        a6, s6, a7
                  nop
                  sltiu      a2, a0, -848
                  sltiu      a2, a0, -848
                  mul        a6, t2, s5
                  addi       s3, a2, 677
                  slt        a1, a1, zero
                  mulhu      s1, s9, a1
                  div        zero, a7, s0
                  div        zero, a7, s0
                  add        tp, gp, s11
                  div        zero, a7, s0
                  xori       s3, s8, -101
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  lui        s6, 496523
                  slt        a1, a1, zero
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  sra        t1, t1, a0
                  srl        zero, t1, a4
                  srai       s8, t0, 25
                  slt        a1, a1, zero
                  sra        t1, t1, a0
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  mul        a6, t2, s5
                  sra        t1, t1, a0
                  sub        ra, t1, s11
                  auipc      a4, 925829
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  mulhu      s1, s9, a1
                  srai       s8, t0, 25
                  rem        a6, s6, a7
                  remu       s0, t0, gp
                  lui        s6, 496523
                  ori        t1, ra, -664
                  slti       s10, s8, -890
                  srai       s8, t0, 25
                  slli       tp, t1, 9
                  and        sp, s3, s5
                  mulhsu     s8, sp, s5
                  slt        a1, a1, zero
                  addi       s3, a2, 677
                  or         a7, a0, zero
                  sltiu      a2, a0, -848
                  or         a7, a0, zero
                  srl        zero, t1, a4
                  rem        a6, s6, a7
                  slli       tp, t1, 9
                  srli       t6, t5, 10
                  auipc      a4, 925829
                  or         a7, a0, zero
                  mul        a6, t2, s5
                  addi       s3, a2, 677
                  lui        s6, 496523
                  auipc      a4, 925829
                  mul        a6, t2, s5
                  mulhu      s1, s9, a1
                  sub        ra, t1, s11
                  lui        s6, 496523
                  srai       s8, t0, 25
                  sltiu      a2, a0, -848
                  sll        s10, sp, a0
                  andi       gp, s9, -46
                  slt        a1, a1, zero
                  slli       tp, t1, 9
                  auipc      a4, 925829
                  sra        t1, t1, a0
                  mulhsu     s8, sp, s5
                  srl        zero, t1, a4
                  sll        s10, sp, a0
                  add        tp, gp, s11
                  and        sp, s3, s5
                  sltu       t3, t1, tp
                  sltiu      a2, a0, -848
                  sltu       t3, t1, tp
                  sll        s10, sp, a0
                  lui        s6, 496523
                  add        tp, gp, s11
                  sll        s10, sp, a0
                  sub        ra, t1, s11
                  mul        a6, t2, s5
                  sltiu      a2, a0, -848
                  slt        a1, a1, zero
                  andi       gp, s9, -46
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  divu       s3, gp, a2
                  or         a7, a0, zero
                  mulh       s2, t1, a3
                  xori       s3, s8, -101
                  nop
                  mulhu      s1, s9, a1
                  sltu       t3, t1, tp
                  sltiu      a2, a0, -848
                  slt        a1, a1, zero
                  slti       s10, s8, -890
                  remu       s0, t0, gp
                  and        sp, s3, s5
                  srli       t6, t5, 10
                  rem        a6, s6, a7
                  mulhu      s1, s9, a1
                  mulhsu     s8, sp, s5
                  lui        s6, 496523
                  and        sp, s3, s5
                  sll        s10, sp, a0
                  divu       s3, gp, a2
                  mulhsu     s8, sp, s5
                  and        sp, s3, s5
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  xor        a4, a2, s0
                  and        sp, s3, s5
                  and        sp, s3, s5
                  slt        a1, a1, zero
                  sltu       t3, t1, tp
                  mul        a6, t2, s5
                  slti       s10, s8, -890
                  nop
                  rem        a6, s6, a7
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  addi       s3, a2, 677
                  slti       s10, s8, -890
                  and        sp, s3, s5
                  divu       s3, gp, a2
                  addi       s3, a2, 677
                  xori       s3, s8, -101
                  mul        a6, t2, s5
                  mulhsu     s8, sp, s5
                  sra        t1, t1, a0
                  addi       s3, a2, 677
                  or         a7, a0, zero
                  slti       s10, s8, -890
                  sltiu      a2, a0, -848
                  mulh       s2, t1, a3
                  nop
                  and        sp, s3, s5
                  srai       s8, t0, 25
                  mul        a6, t2, s5
                  slt        a1, a1, zero
                  or         a7, a0, zero
                  lui        s6, 496523
                  mul        a6, t2, s5
                  srl        zero, t1, a4
                  srl        zero, t1, a4
                  mulhsu     s8, sp, s5
                  xor        a4, a2, s0
                  div        zero, a7, s0
                  mul        a6, t2, s5
                  add        tp, gp, s11
                  mulhsu     s8, sp, s5
                  add        tp, gp, s11
                  lui        s6, 496523
                  rem        a6, s6, a7
                  mulhu      s1, s9, a1
                  sub        ra, t1, s11
                  remu       s0, t0, gp
                  xor        a4, a2, s0
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  or         a7, a0, zero
                  mulh       s2, t1, a3
                  ori        t1, ra, -664
                  lui        s6, 496523
                  mul        a6, t2, s5
                  divu       s3, gp, a2
                  sra        t1, t1, a0
                  divu       s3, gp, a2
                  xor        a4, a2, s0
                  divu       s3, gp, a2
                  mulh       s2, t1, a3
                  or         a7, a0, zero
                  slli       tp, t1, 9
                  mulhu      s1, s9, a1
                  mulh       s2, t1, a3
                  mulhsu     s8, sp, s5
                  mul        a6, t2, s5
                  add        tp, gp, s11
                  ori        t1, ra, -664
                  sub        ra, t1, s11
                  divu       s3, gp, a2
                  auipc      a4, 925829
                  lui        s6, 496523
                  divu       s3, gp, a2
                  remu       s0, t0, gp
                  remu       s0, t0, gp
                  sltu       t3, t1, tp
                  sub        ra, t1, s11
                  rem        a6, s6, a7
                  nop
                  srl        zero, t1, a4
                  mulhu      s1, s9, a1
                  slli       tp, t1, 9
                  srli       t6, t5, 10
                  andi       gp, s9, -46
                  xor        a4, a2, s0
                  and        sp, s3, s5
                  mulhu      s1, s9, a1
                  sltiu      a2, a0, -848
                  ori        t1, ra, -664
                  xor        a4, a2, s0
                  sltu       t3, t1, tp
                  div        zero, a7, s0
                  slti       s10, s8, -890
                  sll        s10, sp, a0
                  add        tp, gp, s11
                  slli       tp, t1, 9
                  andi       gp, s9, -46
                  rem        a6, s6, a7
                  add        tp, gp, s11
                  auipc      a4, 925829
                  mulh       s2, t1, a3
                  slli       tp, t1, 9
                  sll        s10, sp, a0
                  sll        s10, sp, a0
                  ori        t1, ra, -664
                  ori        t1, ra, -664
                  addi       s3, a2, 677
                  auipc      a4, 925829
                  and        sp, s3, s5
                  and        sp, s3, s5
                  sll        s10, sp, a0
                  addi       s3, a2, 677
                  sltiu      a2, a0, -848
                  srai       s8, t0, 25
                  nop
                  slli       tp, t1, 9
                  rem        a6, s6, a7
                  and        sp, s3, s5
                  sub        ra, t1, s11
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  slti       s10, s8, -890
                  mulhsu     s8, sp, s5
                  sub        ra, t1, s11
                  lui        s6, 496523
                  srai       s8, t0, 25
                  lui        s6, 496523
                  and        sp, s3, s5
                  andi       gp, s9, -46
                  andi       gp, s9, -46
                  and        sp, s3, s5
                  mulh       s2, t1, a3
                  or         a7, a0, zero
                  sub        ra, t1, s11
                  remu       s0, t0, gp
                  sltiu      a2, a0, -848
                  addi       s3, a2, 677
                  remu       s0, t0, gp
                  ori        t1, ra, -664
                  divu       s3, gp, a2
                  rem        a6, s6, a7
                  mulh       s2, t1, a3
                  or         a7, a0, zero
                  xor        a4, a2, s0
                  slti       s10, s8, -890
                  xori       s3, s8, -101
                  add        tp, gp, s11
                  nop
                  sra        t1, t1, a0
                  sltu       t3, t1, tp
                  andi       gp, s9, -46
                  mul        a6, t2, s5
                  auipc      a4, 925829
                  divu       s3, gp, a2
                  add        tp, gp, s11
                  nop
                  slti       s10, s8, -890
                  and        sp, s3, s5
                  andi       gp, s9, -46
                  slt        a1, a1, zero
                  rem        a6, s6, a7
                  nop
                  mul        a6, t2, s5
                  addi       s3, a2, 677
                  slli       tp, t1, 9
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  sll        s10, sp, a0
                  sll        s10, sp, a0
                  rem        a6, s6, a7
                  add        tp, gp, s11
                  slli       tp, t1, 9
                  srl        zero, t1, a4
                  or         a7, a0, zero
                  sub        ra, t1, s11
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  srl        zero, t1, a4
                  divu       s3, gp, a2
                  auipc      a4, 925829
                  mulh       s2, t1, a3
                  and        sp, s3, s5
                  div        zero, a7, s0
                  sra        t1, t1, a0
                  slt        a1, a1, zero
                  srai       s8, t0, 25
                  nop
                  ori        t1, ra, -664
                  sll        s10, sp, a0
                  mul        a6, t2, s5
                  xor        a4, a2, s0
                  lui        s6, 496523
                  andi       gp, s9, -46
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  mul        a6, t2, s5
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  mulhu      s1, s9, a1
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  add        tp, gp, s11
                  rem        a6, s6, a7
                  or         a7, a0, zero
                  or         a7, a0, zero
                  mul        a6, t2, s5
                  sltu       t3, t1, tp
                  mul        a6, t2, s5
                  addi       s3, a2, 677
                  sltu       t3, t1, tp
                  addi       s3, a2, 677
                  sll        s10, sp, a0
                  sra        t1, t1, a0
                  ori        t1, ra, -664
                  mul        a6, t2, s5
                  ori        t1, ra, -664
                  sltu       t3, t1, tp
                  srai       s8, t0, 25
                  add        tp, gp, s11
                  sltiu      a2, a0, -848
                  srl        zero, t1, a4
                  srai       s8, t0, 25
                  addi       s3, a2, 677
                  mulh       s2, t1, a3
                  remu       s0, t0, gp
                  ori        t1, ra, -664
                  nop
                  sll        s10, sp, a0
                  sub        ra, t1, s11
                  add        tp, gp, s11
                  sltu       t3, t1, tp
                  add        tp, gp, s11
                  sub        ra, t1, s11
                  mul        a6, t2, s5
                  sub        ra, t1, s11
                  sub        ra, t1, s11
                  slli       tp, t1, 9
                  mulhsu     s8, sp, s5
                  nop
                  mulhsu     s8, sp, s5
                  lui        s6, 496523
                  srl        zero, t1, a4
                  andi       gp, s9, -46
                  srli       t6, t5, 10
                  xori       s3, s8, -101
                  slli       tp, t1, 9
                  nop
                  nop
                  sltu       t3, t1, tp
                  sra        t1, t1, a0
                  div        zero, a7, s0
                  srl        zero, t1, a4
                  slti       s10, s8, -890
                  addi       s3, a2, 677
                  xori       s3, s8, -101
                  sltiu      a2, a0, -848
                  srl        zero, t1, a4
                  slti       s10, s8, -890
                  slli       tp, t1, 9
                  lui        s6, 496523
                  slt        a1, a1, zero
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  slti       s10, s8, -890
                  div        zero, a7, s0
                  mulhsu     s8, sp, s5
                  remu       s0, t0, gp
                  andi       gp, s9, -46
                  srli       t6, t5, 10
                  slti       s10, s8, -890
                  slli       tp, t1, 9
                  andi       gp, s9, -46
                  rem        a6, s6, a7
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  xor        a4, a2, s0
                  sra        t1, t1, a0
                  nop
                  remu       s0, t0, gp
                  rem        a6, s6, a7
                  slli       tp, t1, 9
                  slti       s10, s8, -890
                  sub        ra, t1, s11
                  ori        t1, ra, -664
                  xor        a4, a2, s0
                  mulhu      s1, s9, a1
                  nop
                  srli       t6, t5, 10
                  slti       s10, s8, -890
                  add        tp, gp, s11
                  add        tp, gp, s11
                  lui        s6, 496523
                  add        tp, gp, s11
                  nop
                  or         a7, a0, zero
                  auipc      a4, 925829
                  xor        a4, a2, s0
                  nop
                  mulhsu     s8, sp, s5
                  nop
                  mulhsu     s8, sp, s5
                  sltu       t3, t1, tp
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  div        zero, a7, s0
                  or         a7, a0, zero
                  div        zero, a7, s0
                  mul        a6, t2, s5
                  srli       t6, t5, 10
                  divu       s3, gp, a2
                  remu       s0, t0, gp
                  mulh       s2, t1, a3
                  slli       tp, t1, 9
                  add        tp, gp, s11
                  srli       t6, t5, 10
                  slt        a1, a1, zero
                  mulh       s2, t1, a3
                  xori       s3, s8, -101
                  xori       s3, s8, -101
                  sltiu      a2, a0, -848
                  sra        t1, t1, a0
                  sltiu      a2, a0, -848
                  and        sp, s3, s5
                  andi       gp, s9, -46
                  mulhu      s1, s9, a1
                  or         a7, a0, zero
                  and        sp, s3, s5
                  sltu       t3, t1, tp
                  sltu       t3, t1, tp
                  nop
                  xor        a4, a2, s0
                  andi       gp, s9, -46
                  srai       s8, t0, 25
                  slt        a1, a1, zero
                  slti       s10, s8, -890
                  mulhsu     s8, sp, s5
                  mulhsu     s8, sp, s5
                  nop
                  or         a7, a0, zero
                  nop
                  sll        s10, sp, a0
                  remu       s0, t0, gp
                  mul        a6, t2, s5
                  sra        t1, t1, a0
                  slti       s10, s8, -890
                  xori       s3, s8, -101
                  add        tp, gp, s11
                  div        zero, a7, s0
                  sra        t1, t1, a0
                  mulh       s2, t1, a3
                  slti       s10, s8, -890
                  xor        a4, a2, s0
                  mulhu      s1, s9, a1
                  slti       s10, s8, -890
                  sltiu      a2, a0, -848
                  xori       s3, s8, -101
                  mul        a6, t2, s5
                  sll        s10, sp, a0
                  add        tp, gp, s11
                  sra        t1, t1, a0
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  slt        a1, a1, zero
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  rem        a6, s6, a7
                  srli       t6, t5, 10
                  srl        zero, t1, a4
                  and        sp, s3, s5
                  srai       s8, t0, 25
                  sltu       t3, t1, tp
                  divu       s3, gp, a2
                  mulhu      s1, s9, a1
                  mulhsu     s8, sp, s5
                  xor        a4, a2, s0
                  sra        t1, t1, a0
                  sltu       t3, t1, tp
                  rem        a6, s6, a7
                  srli       t6, t5, 10
                  div        zero, a7, s0
                  addi       s3, a2, 677
                  add        tp, gp, s11
                  sll        s10, sp, a0
                  xori       s3, s8, -101
                  mulhsu     s8, sp, s5
                  sltiu      a2, a0, -848
                  srli       t6, t5, 10
                  and        sp, s3, s5
                  sltiu      a2, a0, -848
                  slli       tp, t1, 9
                  slti       s10, s8, -890
                  rem        a6, s6, a7
                  slli       tp, t1, 9
                  xor        a4, a2, s0
                  mul        a6, t2, s5
                  lui        s6, 496523
                  xor        a4, a2, s0
                  nop
                  sub        ra, t1, s11
                  lui        s6, 496523
                  mulhsu     s8, sp, s5
                  slti       s10, s8, -890
                  xor        a4, a2, s0
                  slli       tp, t1, 9
                  sltu       t3, t1, tp
                  sra        t1, t1, a0
                  srai       s8, t0, 25
                  slt        a1, a1, zero
                  sll        s10, sp, a0
                  slt        a1, a1, zero
                  sub        ra, t1, s11
                  slli       tp, t1, 9
                  xori       s3, s8, -101
                  div        zero, a7, s0
                  sra        t1, t1, a0
                  srai       s8, t0, 25
                  sll        s10, sp, a0
                  srl        zero, t1, a4
                  mul        a6, t2, s5
                  srl        zero, t1, a4
                  sltu       t3, t1, tp
                  andi       gp, s9, -46
                  auipc      a4, 925829
                  srli       t6, t5, 10
                  sub        ra, t1, s11
                  and        sp, s3, s5
                  divu       s3, gp, a2
                  slli       tp, t1, 9
                  auipc      a4, 925829
                  mulhu      s1, s9, a1
                  slt        a1, a1, zero
                  slti       s10, s8, -890
                  nop
                  mulhsu     s8, sp, s5
                  nop
                  div        zero, a7, s0
                  nop
                  mulh       s2, t1, a3
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  remu       s0, t0, gp
                  sltiu      a2, a0, -848
                  or         a7, a0, zero
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  nop
                  mulhsu     s8, sp, s5
                  and        sp, s3, s5
                  mul        a6, t2, s5
                  add        tp, gp, s11
                  lui        s6, 496523
                  nop
                  mul        a6, t2, s5
                  mulhu      s1, s9, a1
                  sltu       t3, t1, tp
                  xori       s3, s8, -101
                  srai       s8, t0, 25
                  sltiu      a2, a0, -848
                  div        zero, a7, s0
                  div        zero, a7, s0
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  add        tp, gp, s11
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  xor        a4, a2, s0
                  lui        s6, 496523
                  sltu       t3, t1, tp
                  addi       s3, a2, 677
                  or         a7, a0, zero
                  sltu       t3, t1, tp
                  or         a7, a0, zero
                  sll        s10, sp, a0
                  slli       tp, t1, 9
                  divu       s3, gp, a2
                  rem        a6, s6, a7
                  and        sp, s3, s5
                  sll        s10, sp, a0
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  divu       s3, gp, a2
                  add        tp, gp, s11
                  srai       s8, t0, 25
                  mulhsu     s8, sp, s5
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  xor        a4, a2, s0
                  ori        t1, ra, -664
                  add        tp, gp, s11
                  lui        s6, 496523
                  mul        a6, t2, s5
                  srai       s8, t0, 25
                  or         a7, a0, zero
                  slti       s10, s8, -890
                  sub        ra, t1, s11
                  addi       s3, a2, 677
                  mulhsu     s8, sp, s5
                  andi       gp, s9, -46
                  slti       s10, s8, -890
                  sra        t1, t1, a0
                  sub        ra, t1, s11
                  slti       s10, s8, -890
                  srai       s8, t0, 25
                  xori       s3, s8, -101
                  lui        s6, 496523
                  nop
                  auipc      a4, 925829
                  or         a7, a0, zero
                  sub        ra, t1, s11
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  mul        a6, t2, s5
                  mulhsu     s8, sp, s5
                  mul        a6, t2, s5
                  lui        s6, 496523
                  div        zero, a7, s0
                  auipc      a4, 925829
                  mulhsu     s8, sp, s5
                  addi       s3, a2, 677
                  andi       gp, s9, -46
                  rem        a6, s6, a7
                  srl        zero, t1, a4
                  slti       s10, s8, -890
                  divu       s3, gp, a2
                  sltu       t3, t1, tp
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  ori        t1, ra, -664
                  and        sp, s3, s5
                  mulhsu     s8, sp, s5
                  andi       gp, s9, -46
                  srli       t6, t5, 10
                  sra        t1, t1, a0
                  sltu       t3, t1, tp
                  sub        ra, t1, s11
                  slt        a1, a1, zero
                  addi       s3, a2, 677
                  div        zero, a7, s0
                  srai       s8, t0, 25
                  or         a7, a0, zero
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  srl        zero, t1, a4
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  add        tp, gp, s11
                  xori       s3, s8, -101
                  mulhsu     s8, sp, s5
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  srl        zero, t1, a4
                  slti       s10, s8, -890
                  remu       s0, t0, gp
                  remu       s0, t0, gp
                  remu       s0, t0, gp
                  auipc      a4, 925829
                  nop
                  or         a7, a0, zero
                  addi       s3, a2, 677
                  sltiu      a2, a0, -848
                  andi       gp, s9, -46
                  mulh       s2, t1, a3
                  add        tp, gp, s11
                  and        sp, s3, s5
                  ori        t1, ra, -664
                  slli       tp, t1, 9
                  srli       t6, t5, 10
                  rem        a6, s6, a7
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  divu       s3, gp, a2
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  auipc      a4, 925829
                  nop
                  andi       gp, s9, -46
                  lui        s6, 496523
                  div        zero, a7, s0
                  rem        a6, s6, a7
                  srli       t6, t5, 10
                  mulh       s2, t1, a3
                  mulh       s2, t1, a3
                  slt        a1, a1, zero
                  andi       gp, s9, -46
                  sltu       t3, t1, tp
                  rem        a6, s6, a7
                  and        sp, s3, s5
                  add        tp, gp, s11
                  slt        a1, a1, zero
                  div        zero, a7, s0
                  divu       s3, gp, a2
                  mul        a6, t2, s5
                  lui        s6, 496523
                  srl        zero, t1, a4
                  mul        a6, t2, s5
                  sub        ra, t1, s11
                  slt        a1, a1, zero
                  mulhsu     s8, sp, s5
                  lui        s6, 496523
                  rem        a6, s6, a7
                  sub        ra, t1, s11
                  lui        s6, 496523
                  mul        a6, t2, s5
                  auipc      a4, 925829
                  xori       s3, s8, -101
                  or         a7, a0, zero
                  mulh       s2, t1, a3
                  xor        a4, a2, s0
                  sll        s10, sp, a0
                  remu       s0, t0, gp
                  mulhsu     s8, sp, s5
                  mul        a6, t2, s5
                  mulhu      s1, s9, a1
                  and        sp, s3, s5
                  mulhu      s1, s9, a1
                  slli       tp, t1, 9
                  remu       s0, t0, gp
                  sltu       t3, t1, tp
                  sltu       t3, t1, tp
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  slt        a1, a1, zero
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  mulhu      s1, s9, a1
                  remu       s0, t0, gp
                  divu       s3, gp, a2
                  mul        a6, t2, s5
                  mulh       s2, t1, a3
                  and        sp, s3, s5
                  mulhu      s1, s9, a1
                  sll        s10, sp, a0
                  addi       s3, a2, 677
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  mulhu      s1, s9, a1
                  or         a7, a0, zero
                  and        sp, s3, s5
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  xor        a4, a2, s0
                  slti       s10, s8, -890
                  divu       s3, gp, a2
                  or         a7, a0, zero
                  xor        a4, a2, s0
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  ori        t1, ra, -664
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  rem        a6, s6, a7
                  mulhu      s1, s9, a1
                  sra        t1, t1, a0
                  addi       s3, a2, 677
                  sll        s10, sp, a0
                  sub        ra, t1, s11
                  mulh       s2, t1, a3
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  divu       s3, gp, a2
                  divu       s3, gp, a2
                  rem        a6, s6, a7
                  and        sp, s3, s5
                  nop
                  sltu       t3, t1, tp
                  or         a7, a0, zero
                  xor        a4, a2, s0
                  xor        a4, a2, s0
                  nop
                  srai       s8, t0, 25
                  sltu       t3, t1, tp
                  sltiu      a2, a0, -848
                  xor        a4, a2, s0
                  lui        s6, 496523
                  srl        zero, t1, a4
                  nop
                  srli       t6, t5, 10
                  rem        a6, s6, a7
                  lui        s6, 496523
                  srai       s8, t0, 25
                  srai       s8, t0, 25
                  srl        zero, t1, a4
                  add        tp, gp, s11
                  or         a7, a0, zero
                  slti       s10, s8, -890
                  slt        a1, a1, zero
                  mulhu      s1, s9, a1
                  xori       s3, s8, -101
                  sltiu      a2, a0, -848
                  srli       t6, t5, 10
                  andi       gp, s9, -46
                  slli       tp, t1, 9
                  and        sp, s3, s5
                  mulh       s2, t1, a3
                  lui        s6, 496523
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  srai       s8, t0, 25
                  slli       tp, t1, 9
                  rem        a6, s6, a7
                  lui        s6, 496523
                  sltu       t3, t1, tp
                  rem        a6, s6, a7
                  ori        t1, ra, -664
                  xor        a4, a2, s0
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  srl        zero, t1, a4
                  xori       s3, s8, -101
                  ori        t1, ra, -664
                  slt        a1, a1, zero
                  slli       tp, t1, 9
                  divu       s3, gp, a2
                  divu       s3, gp, a2
                  add        tp, gp, s11
                  sll        s10, sp, a0
                  sub        ra, t1, s11
                  rem        a6, s6, a7
                  add        tp, gp, s11
                  or         a7, a0, zero
                  rem        a6, s6, a7
                  lui        s6, 496523
                  add        tp, gp, s11
                  remu       s0, t0, gp
                  srl        zero, t1, a4
                  remu       s0, t0, gp
                  lui        s6, 496523
                  xori       s3, s8, -101
                  slt        a1, a1, zero
                  xor        a4, a2, s0
                  andi       gp, s9, -46
                  or         a7, a0, zero
                  mul        a6, t2, s5
                  sll        s10, sp, a0
                  lui        s6, 496523
                  xori       s3, s8, -101
                  slli       tp, t1, 9
                  mulh       s2, t1, a3
                  xor        a4, a2, s0
                  mulh       s2, t1, a3
                  slli       tp, t1, 9
                  xor        a4, a2, s0
                  slli       tp, t1, 9
                  sra        t1, t1, a0
                  sltiu      a2, a0, -848
                  xor        a4, a2, s0
                  mul        a6, t2, s5
                  mulhsu     s8, sp, s5
                  mulh       s2, t1, a3
                  and        sp, s3, s5
                  rem        a6, s6, a7
                  lui        s6, 496523
                  remu       s0, t0, gp
                  xori       s3, s8, -101
                  mulh       s2, t1, a3
                  srai       s8, t0, 25
                  divu       s3, gp, a2
                  nop
                  sll        s10, sp, a0
                  mul        a6, t2, s5
                  srl        zero, t1, a4
                  sub        ra, t1, s11
                  lui        s6, 496523
                  andi       gp, s9, -46
                  and        sp, s3, s5
                  sll        s10, sp, a0
                  ori        t1, ra, -664
                  rem        a6, s6, a7
                  andi       gp, s9, -46
                  sltiu      a2, a0, -848
                  mulh       s2, t1, a3
                  auipc      a4, 925829
                  sll        s10, sp, a0
                  ori        t1, ra, -664
                  ori        t1, ra, -664
                  sra        t1, t1, a0
                  mulhsu     s8, sp, s5
                  lui        s6, 496523
                  mulhu      s1, s9, a1
                  add        tp, gp, s11
                  or         a7, a0, zero
                  sltiu      a2, a0, -848
                  sub        ra, t1, s11
                  lui        s6, 496523
                  mul        a6, t2, s5
                  mul        a6, t2, s5
                  srai       s8, t0, 25
                  andi       gp, s9, -46
                  addi       s3, a2, 677
                  xor        a4, a2, s0
                  lui        s6, 496523
                  lui        s6, 496523
                  mulh       s2, t1, a3
                  slli       tp, t1, 9
                  srai       s8, t0, 25
                  nop
                  xor        a4, a2, s0
                  srl        zero, t1, a4
                  lui        s6, 496523
                  add        tp, gp, s11
                  srai       s8, t0, 25
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  sll        s10, sp, a0
                  addi       s3, a2, 677
                  sltu       t3, t1, tp
                  auipc      a4, 925829
                  div        zero, a7, s0
                  or         a7, a0, zero
                  sub        ra, t1, s11
                  addi       s3, a2, 677
                  and        sp, s3, s5
                  div        zero, a7, s0
                  sltu       t3, t1, tp
                  mulhsu     s8, sp, s5
                  slti       s10, s8, -890
                  mulh       s2, t1, a3
                  mul        a6, t2, s5
                  slt        a1, a1, zero
                  mulhsu     s8, sp, s5
                  mul        a6, t2, s5
                  nop
                  rem        a6, s6, a7
                  andi       gp, s9, -46
                  sltu       t3, t1, tp
                  xori       s3, s8, -101
                  slt        a1, a1, zero
                  srli       t6, t5, 10
                  slt        a1, a1, zero
                  and        sp, s3, s5
                  or         a7, a0, zero
                  xori       s3, s8, -101
                  mulhu      s1, s9, a1
                  lui        s6, 496523
                  sltiu      a2, a0, -848
                  li         t4, 0x80000000 #start riscv_int_numeric_corner_stream_1
                  li         s3, 0xffffffff
                  li         s5, 0x0
                  li         t3, 0x0
                  li         s8, 0x80000000
                  li         s2, 0xd4ef659c
                  li         s4, 0x766e6df4
                  li         a6, 0x0
                  li         t6, 0xffffffff
                  li         s6, 0x80000000
                  mulh       a6, s8, s4
                  sub        s2, s8, a6
                  add        s5, s4, s6
                  mul        s6, t3, s6
                  mulh       a6, s8, s4
                  auipc      t6, 925829
                  mulhu      t6, t6, s3
                  addi       s2, s2, 677
                  divu       s2, s4, s5
                  divu       s2, s4, s5
                  auipc      t6, 925829
                  mulhsu     s8, s3, s6
                  lui        s5, 496523
                  auipc      t6, 925829
                  nop #end riscv_int_numeric_corner_stream_1
                  and        sp, s3, s5
                  sub        ra, t1, s11
                  mul        a6, t2, s5
                  slli       tp, t1, 9
                  sra        t1, t1, a0
                  xori       s3, s8, -101
                  mul        a6, t2, s5
                  divu       s3, gp, a2
                  nop
                  sltiu      a2, a0, -848
                  remu       s0, t0, gp
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  sra        t1, t1, a0
                  addi       s3, a2, 677
                  div        zero, a7, s0
                  divu       s3, gp, a2
                  mul        a6, t2, s5
                  andi       gp, s9, -46
                  ori        t1, ra, -664
                  xor        a4, a2, s0
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  nop
                  mulhu      s1, s9, a1
                  sub        ra, t1, s11
                  xor        a4, a2, s0
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  mulhsu     s8, sp, s5
                  slt        a1, a1, zero
                  mulh       s2, t1, a3
                  mulhu      s1, s9, a1
                  sub        ra, t1, s11
                  sub        ra, t1, s11
                  mul        a6, t2, s5
                  sub        ra, t1, s11
                  sra        t1, t1, a0
                  remu       s0, t0, gp
                  srai       s8, t0, 25
                  slli       tp, t1, 9
                  mulhu      s1, s9, a1
                  ori        t1, ra, -664
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  xor        a4, a2, s0
                  div        zero, a7, s0
                  andi       gp, s9, -46
                  divu       s3, gp, a2
                  ori        t1, ra, -664
                  mul        a6, t2, s5
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  slti       s10, s8, -890
                  sltiu      a2, a0, -848
                  auipc      a4, 925829
                  mul        a6, t2, s5
                  sub        ra, t1, s11
                  mulhsu     s8, sp, s5
                  slli       tp, t1, 9
                  mul        a6, t2, s5
                  nop
                  andi       gp, s9, -46
                  mulhu      s1, s9, a1
                  rem        a6, s6, a7
                  mul        a6, t2, s5
                  andi       gp, s9, -46
                  or         a7, a0, zero
                  add        tp, gp, s11
                  ori        t1, ra, -664
                  ori        t1, ra, -664
                  mulhu      s1, s9, a1
                  sltu       t3, t1, tp
                  xori       s3, s8, -101
                  rem        a6, s6, a7
                  remu       s0, t0, gp
                  srai       s8, t0, 25
                  xori       s3, s8, -101
                  slt        a1, a1, zero
                  add        tp, gp, s11
                  sra        t1, t1, a0
                  xor        a4, a2, s0
                  sltu       t3, t1, tp
                  mul        a6, t2, s5
                  sltiu      a2, a0, -848
                  andi       gp, s9, -46
                  ori        t1, ra, -664
                  slti       s10, s8, -890
                  srli       t6, t5, 10
                  xori       s3, s8, -101
                  srli       t6, t5, 10
                  mul        a6, t2, s5
                  sll        s10, sp, a0
                  srli       t6, t5, 10
                  sll        s10, sp, a0
                  slt        a1, a1, zero
                  slli       tp, t1, 9
                  slt        a1, a1, zero
                  sra        t1, t1, a0
                  sltiu      a2, a0, -848
                  lui        s6, 496523
                  divu       s3, gp, a2
                  mulh       s2, t1, a3
                  divu       s3, gp, a2
                  sltiu      a2, a0, -848
                  addi       s3, a2, 677
                  nop
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  remu       s0, t0, gp
                  srl        zero, t1, a4
                  sll        s10, sp, a0
                  srai       s8, t0, 25
                  srai       s8, t0, 25
                  sub        ra, t1, s11
                  addi       s3, a2, 677
                  srai       s8, t0, 25
                  ori        t1, ra, -664
                  add        tp, gp, s11
                  slt        a1, a1, zero
                  mulh       s2, t1, a3
                  xori       s3, s8, -101
                  slli       tp, t1, 9
                  sub        ra, t1, s11
                  sltu       t3, t1, tp
                  andi       gp, s9, -46
                  sltiu      a2, a0, -848
                  lui        s6, 496523
                  slti       s10, s8, -890
                  mulhu      s1, s9, a1
                  slt        a1, a1, zero
                  mulhsu     s8, sp, s5
                  slli       tp, t1, 9
                  div        zero, a7, s0
                  slt        a1, a1, zero
                  slt        a1, a1, zero
                  mul        a6, t2, s5
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  lui        s6, 496523
                  slti       s10, s8, -890
                  slli       tp, t1, 9
                  slli       tp, t1, 9
                  mulhsu     s8, sp, s5
                  slt        a1, a1, zero
                  srli       t6, t5, 10
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  sub        ra, t1, s11
                  or         a7, a0, zero
                  lui        s6, 496523
                  slti       s10, s8, -890
                  mulhsu     s8, sp, s5
                  remu       s0, t0, gp
                  lui        s6, 496523
                  xor        a4, a2, s0
                  mulhsu     s8, sp, s5
                  sra        t1, t1, a0
                  div        zero, a7, s0
                  andi       gp, s9, -46
                  sra        t1, t1, a0
                  srai       s8, t0, 25
                  nop
                  sra        t1, t1, a0
                  sll        s10, sp, a0
                  srai       s8, t0, 25
                  lui        s6, 496523
                  slli       tp, t1, 9
                  slt        a1, a1, zero
                  slti       s10, s8, -890
                  srai       s8, t0, 25
                  sub        ra, t1, s11
                  slli       tp, t1, 9
                  slti       s10, s8, -890
                  addi       s3, a2, 677
                  nop
                  xori       s3, s8, -101
                  xori       s3, s8, -101
                  mulhu      s1, s9, a1
                  remu       s0, t0, gp
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  add        tp, gp, s11
                  div        zero, a7, s0
                  ori        t1, ra, -664
                  andi       gp, s9, -46
                  and        sp, s3, s5
                  and        sp, s3, s5
                  ori        t1, ra, -664
                  srai       s8, t0, 25
                  srl        zero, t1, a4
                  srai       s8, t0, 25
                  andi       gp, s9, -46
                  mulhu      s1, s9, a1
                  andi       gp, s9, -46
                  remu       s0, t0, gp
                  sltiu      a2, a0, -848
                  sltu       t3, t1, tp
                  andi       gp, s9, -46
                  div        zero, a7, s0
                  div        zero, a7, s0
                  sub        ra, t1, s11
                  mulh       s2, t1, a3
                  xor        a4, a2, s0
                  srai       s8, t0, 25
                  andi       gp, s9, -46
                  mulh       s2, t1, a3
                  andi       gp, s9, -46
                  sub        ra, t1, s11
                  ori        t1, ra, -664
                  mul        a6, t2, s5
                  remu       s0, t0, gp
                  add        tp, gp, s11
                  andi       gp, s9, -46
                  add        tp, gp, s11
                  andi       gp, s9, -46
                  srli       t6, t5, 10
                  srli       t6, t5, 10
                  slt        a1, a1, zero
                  srai       s8, t0, 25
                  divu       s3, gp, a2
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  add        tp, gp, s11
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  nop
                  addi       s3, a2, 677
                  sll        s10, sp, a0
                  sra        t1, t1, a0
                  sll        s10, sp, a0
                  srli       t6, t5, 10
                  remu       s0, t0, gp
                  mul        a6, t2, s5
                  slti       s10, s8, -890
                  divu       s3, gp, a2
                  nop
                  mulhsu     s8, sp, s5
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  slt        a1, a1, zero
                  srli       t6, t5, 10
                  srl        zero, t1, a4
                  div        zero, a7, s0
                  remu       s0, t0, gp
                  andi       gp, s9, -46
                  rem        a6, s6, a7
                  lui        s6, 496523
                  or         a7, a0, zero
                  sltiu      a2, a0, -848
                  mulh       s2, t1, a3
                  sltu       t3, t1, tp
                  mulhsu     s8, sp, s5
                  rem        a6, s6, a7
                  addi       s3, a2, 677
                  sltu       t3, t1, tp
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  srl        zero, t1, a4
                  nop
                  sltu       t3, t1, tp
                  rem        a6, s6, a7
                  sub        ra, t1, s11
                  addi       s3, a2, 677
                  mulhsu     s8, sp, s5
                  and        sp, s3, s5
                  add        tp, gp, s11
                  srli       t6, t5, 10
                  sltu       t3, t1, tp
                  sltiu      a2, a0, -848
                  mul        a6, t2, s5
                  remu       s0, t0, gp
                  mulhu      s1, s9, a1
                  slti       s10, s8, -890
                  divu       s3, gp, a2
                  divu       s3, gp, a2
                  sub        ra, t1, s11
                  slti       s10, s8, -890
                  add        tp, gp, s11
                  auipc      a4, 925829
                  slti       s10, s8, -890
                  mulhu      s1, s9, a1
                  srl        zero, t1, a4
                  mul        a6, t2, s5
                  srl        zero, t1, a4
                  mul        a6, t2, s5
                  srai       s8, t0, 25
                  sltiu      a2, a0, -848
                  ori        t1, ra, -664
                  lui        s6, 496523
                  mulhsu     s8, sp, s5
                  mulhsu     s8, sp, s5
                  srai       s8, t0, 25
                  mulhu      s1, s9, a1
                  sltu       t3, t1, tp
                  ori        t1, ra, -664
                  divu       s3, gp, a2
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  mulhsu     s8, sp, s5
                  sll        s10, sp, a0
                  sra        t1, t1, a0
                  mulhsu     s8, sp, s5
                  sll        s10, sp, a0
                  remu       s0, t0, gp
                  divu       s3, gp, a2
                  srli       t6, t5, 10
                  slt        a1, a1, zero
                  slti       s10, s8, -890
                  mul        a6, t2, s5
                  auipc      a4, 925829
                  slli       tp, t1, 9
                  add        tp, gp, s11
                  xori       s3, s8, -101
                  addi       s3, a2, 677
                  remu       s0, t0, gp
                  rem        a6, s6, a7
                  srl        zero, t1, a4
                  srl        zero, t1, a4
                  mulh       s2, t1, a3
                  mulh       s2, t1, a3
                  remu       s0, t0, gp
                  sltu       t3, t1, tp
                  add        tp, gp, s11
                  srl        zero, t1, a4
                  sltu       t3, t1, tp
                  slt        a1, a1, zero
                  and        sp, s3, s5
                  lui        s6, 496523
                  slli       tp, t1, 9
                  div        zero, a7, s0
                  slt        a1, a1, zero
                  div        zero, a7, s0
                  mulhsu     s8, sp, s5
                  remu       s0, t0, gp
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  slt        a1, a1, zero
                  ori        t1, ra, -664
                  rem        a6, s6, a7
                  nop
                  sra        t1, t1, a0
                  srai       s8, t0, 25
                  nop
                  or         a7, a0, zero
                  mulhsu     s8, sp, s5
                  auipc      a4, 925829
                  nop
                  add        tp, gp, s11
                  slti       s10, s8, -890
                  divu       s3, gp, a2
                  sub        ra, t1, s11
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  xori       s3, s8, -101
                  andi       gp, s9, -46
                  srl        zero, t1, a4
                  nop
                  ori        t1, ra, -664
                  lui        s6, 496523
                  srli       t6, t5, 10
                  slti       s10, s8, -890
                  add        tp, gp, s11
                  xori       s3, s8, -101
                  mul        a6, t2, s5
                  xor        a4, a2, s0
                  addi       s3, a2, 677
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  add        tp, gp, s11
                  mulh       s2, t1, a3
                  rem        a6, s6, a7
                  sltiu      a2, a0, -848
                  addi       s3, a2, 677
                  rem        a6, s6, a7
                  sra        t1, t1, a0
                  mulh       s2, t1, a3
                  div        zero, a7, s0
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  ori        t1, ra, -664
                  srl        zero, t1, a4
                  add        tp, gp, s11
                  nop
                  slt        a1, a1, zero
                  add        tp, gp, s11
                  sra        t1, t1, a0
                  mul        a6, t2, s5
                  remu       s0, t0, gp
                  add        tp, gp, s11
                  andi       gp, s9, -46
                  slli       tp, t1, 9
                  add        tp, gp, s11
                  divu       s3, gp, a2
                  mul        a6, t2, s5
                  xori       s3, s8, -101
                  ori        t1, ra, -664
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  sltiu      a2, a0, -848
                  lui        s6, 496523
                  slti       s10, s8, -890
                  mulh       s2, t1, a3
                  or         a7, a0, zero
                  slt        a1, a1, zero
                  srai       s8, t0, 25
                  addi       s3, a2, 677
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  sltiu      a2, a0, -848
                  mul        a6, t2, s5
                  nop
                  addi       s3, a2, 677
                  srai       s8, t0, 25
                  sltiu      a2, a0, -848
                  srl        zero, t1, a4
                  mulh       s2, t1, a3
                  mulhsu     s8, sp, s5
                  srli       t6, t5, 10
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  xori       s3, s8, -101
                  remu       s0, t0, gp
                  sltu       t3, t1, tp
                  lui        s6, 496523
                  sll        s10, sp, a0
                  srl        zero, t1, a4
                  lui        s6, 496523
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  lui        s6, 496523
                  srli       t6, t5, 10
                  or         a7, a0, zero
                  add        tp, gp, s11
                  sub        ra, t1, s11
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  addi       s3, a2, 677
                  auipc      a4, 925829
                  xor        a4, a2, s0
                  remu       s0, t0, gp
                  slli       tp, t1, 9
                  srl        zero, t1, a4
                  add        tp, gp, s11
                  auipc      a4, 925829
                  mulhu      s1, s9, a1
                  slti       s10, s8, -890
                  sll        s10, sp, a0
                  xori       s3, s8, -101
                  xor        a4, a2, s0
                  xori       s3, s8, -101
                  ori        t1, ra, -664
                  xori       s3, s8, -101
                  xor        a4, a2, s0
                  slt        a1, a1, zero
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  mulhsu     s8, sp, s5
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  remu       s0, t0, gp
                  rem        a6, s6, a7
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  slt        a1, a1, zero
                  slt        a1, a1, zero
                  srli       t6, t5, 10
                  mulhsu     s8, sp, s5
                  slli       tp, t1, 9
                  divu       s3, gp, a2
                  slt        a1, a1, zero
                  ori        t1, ra, -664
                  nop
                  nop
                  sll        s10, sp, a0
                  sub        ra, t1, s11
                  mulh       s2, t1, a3
                  divu       s3, gp, a2
                  slti       s10, s8, -890
                  sra        t1, t1, a0
                  slti       s10, s8, -890
                  add        tp, gp, s11
                  slli       tp, t1, 9
                  slt        a1, a1, zero
                  add        tp, gp, s11
                  andi       gp, s9, -46
                  slli       tp, t1, 9
                  and        sp, s3, s5
                  auipc      a4, 925829
                  or         a7, a0, zero
                  rem        a6, s6, a7
                  add        tp, gp, s11
                  nop
                  xor        a4, a2, s0
                  mulhu      s1, s9, a1
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  sll        s10, sp, a0
                  slt        a1, a1, zero
                  div        zero, a7, s0
                  lui        s6, 496523
                  sltu       t3, t1, tp
                  div        zero, a7, s0
                  srli       t6, t5, 10
                  add        tp, gp, s11
                  mul        a6, t2, s5
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  sra        t1, t1, a0
                  add        tp, gp, s11
                  remu       s0, t0, gp
                  xori       s3, s8, -101
                  xor        a4, a2, s0
                  xori       s3, s8, -101
                  srli       t6, t5, 10
                  sub        ra, t1, s11
                  remu       s0, t0, gp
                  mul        a6, t2, s5
                  div        zero, a7, s0
                  slli       tp, t1, 9
                  mulhsu     s8, sp, s5
                  xori       s3, s8, -101
                  addi       s3, a2, 677
                  nop
                  nop
                  slli       tp, t1, 9
                  divu       s3, gp, a2
                  xori       s3, s8, -101
                  sll        s10, sp, a0
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  sltiu      a2, a0, -848
                  sltiu      a2, a0, -848
                  sub        ra, t1, s11
                  mulhu      s1, s9, a1
                  add        tp, gp, s11
                  mulhu      s1, s9, a1
                  divu       s3, gp, a2
                  mulh       s2, t1, a3
                  sltiu      a2, a0, -848
                  srai       s8, t0, 25
                  andi       gp, s9, -46
                  mulhu      s1, s9, a1
                  sll        s10, sp, a0
                  sub        ra, t1, s11
                  sra        t1, t1, a0
                  sltiu      a2, a0, -848
                  mulhsu     s8, sp, s5
                  divu       s3, gp, a2
                  xori       s3, s8, -101
                  andi       gp, s9, -46
                  xori       s3, s8, -101
                  div        zero, a7, s0
                  srl        zero, t1, a4
                  srl        zero, t1, a4
                  and        sp, s3, s5
                  slli       tp, t1, 9
                  div        zero, a7, s0
                  srli       t6, t5, 10
                  auipc      a4, 925829
                  mul        a6, t2, s5
                  mul        a6, t2, s5
                  mulh       s2, t1, a3
                  mulh       s2, t1, a3
                  divu       s3, gp, a2
                  slti       s10, s8, -890
                  sltu       t3, t1, tp
                  auipc      a4, 925829
                  sltu       t3, t1, tp
                  or         a7, a0, zero
                  srl        zero, t1, a4
                  remu       s0, t0, gp
                  sltiu      a2, a0, -848
                  li         a1, 0x0 #start riscv_int_numeric_corner_stream_12
                  li         ra, 0x80000000
                  li         t0, 0xffffffff
                  li         t4, 0xffffffff
                  li         s5, 0xffffffff
                  li         s7, 0x563b6c30
                  li         s6, 0xffffffff
                  li         t3, 0x80000000
                  li         t2, 0x42a052a5
                  li         t5, 0xcfdf4dce
                  mulhsu     s7, t2, s6
                  mulhsu     s7, t2, s6
                  remu       t4, s6, a1
                  mulhsu     s7, t2, s6
                  sub        t0, s7, ra
                  nop
                  remu       t4, s6, a1
                  divu       t0, a1, s5
                  remu       t4, s6, a1
                  mulhu      t5, t5, t2
                  add        s5, a1, s6
                  mulh       ra, s7, a1
                  rem        s6, s7, t0
                  sub        t0, s7, ra
                  div        ra, t0, t4
                  mulhsu     s7, t2, s6
                  mulh       ra, s7, a1
                  mulhsu     s7, t2, s6
                  mulhsu     s7, t2, s6
                  mul        s6, t3, s6
                  mulhu      t5, t5, t2
                  div        ra, t0, t4
                  mulhu      t5, t5, t2
                  auipc      t5, 925829
                  remu       t4, s6, a1
                  remu       t4, s6, a1 #end riscv_int_numeric_corner_stream_12
                  slli       tp, t1, 9
                  add        tp, gp, s11
                  divu       s3, gp, a2
                  sub        ra, t1, s11
                  andi       gp, s9, -46
                  sra        t1, t1, a0
                  nop
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  ori        t1, ra, -664
                  mulh       s2, t1, a3
                  andi       gp, s9, -46
                  sub        ra, t1, s11
                  mulh       s2, t1, a3
                  remu       s0, t0, gp
                  rem        a6, s6, a7
                  mulhu      s1, s9, a1
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  div        zero, a7, s0
                  rem        a6, s6, a7
                  sltu       t3, t1, tp
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  srai       s8, t0, 25
                  xor        a4, a2, s0
                  nop
                  or         a7, a0, zero
                  sltu       t3, t1, tp
                  mulh       s2, t1, a3
                  srl        zero, t1, a4
                  div        zero, a7, s0
                  srai       s8, t0, 25
                  or         a7, a0, zero
                  xori       s3, s8, -101
                  srl        zero, t1, a4
                  andi       gp, s9, -46
                  nop
                  lui        s6, 496523
                  srli       t6, t5, 10
                  sll        s10, sp, a0
                  auipc      a4, 925829
                  andi       gp, s9, -46
                  srai       s8, t0, 25
                  xori       s3, s8, -101
                  li         t5, 0xffffffff #start riscv_int_numeric_corner_stream_36
                  li         s2, 0xaea4e654
                  li         t2, 0x0
                  li         s10, 0x5bb9a757
                  li         t0, 0x0
                  li         t3, 0xffffffff
                  li         a2, 0xffffffff
                  li         a4, 0x0
                  li         s9, 0x80000000
                  li         s7, 0x80000000
                  div        t0, t2, t3
                  mulh       t0, s9, a4
                  remu       t3, s7, a4
                  mulhsu     s9, a2, s7
                  lui        s2, 496523
                  div        t0, t2, t3
                  sub        t2, s9, t0
                  add        s2, a4, s7
                  div        t0, t2, t3
                  nop
                  mulhu      t5, t5, a2
                  addi       t2, t2, 677
                  mul        s7, s10, s7
                  addi       t2, t2, 677
                  divu       t2, a4, s2
                  remu       t3, s7, a4
                  mulhsu     s9, a2, s7
                  div        t0, t2, t3
                  remu       t3, s7, a4
                  mulhu      t5, t5, a2
                  rem        s7, s9, t2
                  mulhu      t5, t5, a2
                  mulhsu     s9, a2, s7
                  divu       t2, a4, s2
                  mulh       t0, s9, a4
                  add        s2, a4, s7
                  mul        s7, s10, s7
                  div        t0, t2, t3
                  nop
                  div        t0, t2, t3 #end riscv_int_numeric_corner_stream_36
                  sltiu      a2, a0, -848
                  slti       s10, s8, -890
                  sra        t1, t1, a0
                  srli       t6, t5, 10
                  andi       gp, s9, -46
                  div        zero, a7, s0
                  srl        zero, t1, a4
                  mul        a6, t2, s5
                  srai       s8, t0, 25
                  div        zero, a7, s0
                  mulh       s2, t1, a3
                  divu       s3, gp, a2
                  mulhsu     s8, sp, s5
                  slt        a1, a1, zero
                  srai       s8, t0, 25
                  remu       s0, t0, gp
                  ori        t1, ra, -664
                  slt        a1, a1, zero
                  rem        a6, s6, a7
                  remu       s0, t0, gp
                  lui        s6, 496523
                  sra        t1, t1, a0
                  add        tp, gp, s11
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  slt        a1, a1, zero
                  sltu       t3, t1, tp
                  srl        zero, t1, a4
                  mulhu      s1, s9, a1
                  remu       s0, t0, gp
                  sll        s10, sp, a0
                  and        sp, s3, s5
                  divu       s3, gp, a2
                  srli       t6, t5, 10
                  slli       tp, t1, 9
                  add        tp, gp, s11
                  nop
                  ori        t1, ra, -664
                  slt        a1, a1, zero
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  lui        s6, 496523
                  andi       gp, s9, -46
                  auipc      a4, 925829
                  ori        t1, ra, -664
                  auipc      a4, 925829
                  srl        zero, t1, a4
                  slli       tp, t1, 9
                  div        zero, a7, s0
                  slti       s10, s8, -890
                  divu       s3, gp, a2
                  srai       s8, t0, 25
                  ori        t1, ra, -664
                  srli       t6, t5, 10
                  addi       s3, a2, 677
                  sltu       t3, t1, tp
                  sltu       t3, t1, tp
                  andi       gp, s9, -46
                  xori       s3, s8, -101
                  srai       s8, t0, 25
                  mulhsu     s8, sp, s5
                  andi       gp, s9, -46
                  sll        s10, sp, a0
                  mul        a6, t2, s5
                  divu       s3, gp, a2
                  nop
                  rem        a6, s6, a7
                  or         a7, a0, zero
                  sltu       t3, t1, tp
                  div        zero, a7, s0
                  sub        ra, t1, s11
                  divu       s3, gp, a2
                  sltiu      a2, a0, -848
                  sub        ra, t1, s11
                  lui        s6, 496523
                  srai       s8, t0, 25
                  xori       s3, s8, -101
                  xori       s3, s8, -101
                  auipc      a4, 925829
                  andi       gp, s9, -46
                  remu       s0, t0, gp
                  sltu       t3, t1, tp
                  and        sp, s3, s5
                  div        zero, a7, s0
                  add        tp, gp, s11
                  srli       t6, t5, 10
                  sltiu      a2, a0, -848
                  mulhsu     s8, sp, s5
                  div        zero, a7, s0
                  nop
                  xor        a4, a2, s0
                  sll        s10, sp, a0
                  slt        a1, a1, zero
                  xori       s3, s8, -101
                  lui        s6, 496523
                  and        sp, s3, s5
                  or         a7, a0, zero
                  lui        s6, 496523
                  sll        s10, sp, a0
                  mulhsu     s8, sp, s5
                  or         a7, a0, zero
                  remu       s0, t0, gp
                  remu       s0, t0, gp
                  nop
                  sltiu      a2, a0, -848
                  mulhu      s1, s9, a1
                  sll        s10, sp, a0
                  slli       tp, t1, 9
                  srl        zero, t1, a4
                  mulh       s2, t1, a3
                  xori       s3, s8, -101
                  divu       s3, gp, a2
                  andi       gp, s9, -46
                  andi       gp, s9, -46
                  or         a7, a0, zero
                  auipc      a4, 925829
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  srl        zero, t1, a4
                  srli       t6, t5, 10
                  sub        ra, t1, s11
                  auipc      a4, 925829
                  addi       s3, a2, 677
                  mulhsu     s8, sp, s5
                  mulhu      s1, s9, a1
                  addi       s3, a2, 677
                  remu       s0, t0, gp
                  mulh       s2, t1, a3
                  mulhu      s1, s9, a1
                  mulhsu     s8, sp, s5
                  mul        a6, t2, s5
                  nop
                  slti       s10, s8, -890
                  div        zero, a7, s0
                  mulhsu     s8, sp, s5
                  srai       s8, t0, 25
                  sltu       t3, t1, tp
                  slli       tp, t1, 9
                  sub        ra, t1, s11
                  divu       s3, gp, a2
                  srai       s8, t0, 25
                  div        zero, a7, s0
                  div        zero, a7, s0
                  sll        s10, sp, a0
                  div        zero, a7, s0
                  andi       gp, s9, -46
                  lui        s6, 496523
                  remu       s0, t0, gp
                  srai       s8, t0, 25
                  and        sp, s3, s5
                  or         a7, a0, zero
                  rem        a6, s6, a7
                  slt        a1, a1, zero
                  xori       s3, s8, -101
                  add        tp, gp, s11
                  sltu       t3, t1, tp
                  sll        s10, sp, a0
                  add        tp, gp, s11
                  xor        a4, a2, s0
                  mulhu      s1, s9, a1
                  srl        zero, t1, a4
                  ori        t1, ra, -664
                  andi       gp, s9, -46
                  divu       s3, gp, a2
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  lui        s6, 496523
                  sra        t1, t1, a0
                  srai       s8, t0, 25
                  srai       s8, t0, 25
                  srli       t6, t5, 10
                  sra        t1, t1, a0
                  slli       tp, t1, 9
                  divu       s3, gp, a2
                  and        sp, s3, s5
                  rem        a6, s6, a7
                  slti       s10, s8, -890
                  addi       s3, a2, 677
                  slli       tp, t1, 9
                  divu       s3, gp, a2
                  ori        t1, ra, -664
                  auipc      a4, 925829
                  add        tp, gp, s11
                  sub        ra, t1, s11
                  sltu       t3, t1, tp
                  slt        a1, a1, zero
                  or         a7, a0, zero
                  nop
                  lui        s6, 496523
                  lui        s6, 496523
                  slti       s10, s8, -890
                  mulhu      s1, s9, a1
                  mulh       s2, t1, a3
                  slli       tp, t1, 9
                  sll        s10, sp, a0
                  lui        s6, 496523
                  remu       s0, t0, gp
                  sltu       t3, t1, tp
                  andi       gp, s9, -46
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  div        zero, a7, s0
                  sltiu      a2, a0, -848
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  auipc      a4, 925829
                  addi       s3, a2, 677
                  divu       s3, gp, a2
                  mul        a6, t2, s5
                  xori       s3, s8, -101
                  and        sp, s3, s5
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  xori       s3, s8, -101
                  slti       s10, s8, -890
                  mulh       s2, t1, a3
                  xor        a4, a2, s0
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  xor        a4, a2, s0
                  lui        s6, 496523
                  srli       t6, t5, 10
                  slli       tp, t1, 9
                  andi       gp, s9, -46
                  sra        t1, t1, a0
                  mulhsu     s8, sp, s5
                  slti       s10, s8, -890
                  sltiu      a2, a0, -848
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  srl        zero, t1, a4
                  srli       t6, t5, 10
                  xor        a4, a2, s0
                  mulhu      s1, s9, a1
                  add        tp, gp, s11
                  mulhsu     s8, sp, s5
                  add        tp, gp, s11
                  remu       s0, t0, gp
                  srli       t6, t5, 10
                  srl        zero, t1, a4
                  and        sp, s3, s5
                  sll        s10, sp, a0
                  slt        a1, a1, zero
                  div        zero, a7, s0
                  or         a7, a0, zero
                  slt        a1, a1, zero
                  nop
                  andi       gp, s9, -46
                  div        zero, a7, s0
                  andi       gp, s9, -46
                  auipc      a4, 925829
                  rem        a6, s6, a7
                  auipc      a4, 925829
                  and        sp, s3, s5
                  mulh       s2, t1, a3
                  divu       s3, gp, a2
                  div        zero, a7, s0
                  nop
                  and        sp, s3, s5
                  sltu       t3, t1, tp
                  mulhu      s1, s9, a1
                  or         a7, a0, zero
                  slti       s10, s8, -890
                  add        tp, gp, s11
                  mulh       s2, t1, a3
                  srli       t6, t5, 10
                  or         a7, a0, zero
                  lui        s6, 496523
                  mulhu      s1, s9, a1
                  xori       s3, s8, -101
                  slti       s10, s8, -890
                  xor        a4, a2, s0
                  divu       s3, gp, a2
                  rem        a6, s6, a7
                  andi       gp, s9, -46
                  sub        ra, t1, s11
                  mul        a6, t2, s5
                  xor        a4, a2, s0
                  sra        t1, t1, a0
                  mul        a6, t2, s5
                  ori        t1, ra, -664
                  remu       s0, t0, gp
                  and        sp, s3, s5
                  ori        t1, ra, -664
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  auipc      a4, 925829
                  remu       s0, t0, gp
                  rem        a6, s6, a7
                  srl        zero, t1, a4
                  sra        t1, t1, a0
                  srli       t6, t5, 10
                  xor        a4, a2, s0
                  slti       s10, s8, -890
                  and        sp, s3, s5
                  lui        s6, 496523
                  slt        a1, a1, zero
                  auipc      a4, 925829
                  slti       s10, s8, -890
                  or         a7, a0, zero
                  div        zero, a7, s0
                  slt        a1, a1, zero
                  lui        s6, 496523
                  div        zero, a7, s0
                  srli       t6, t5, 10
                  add        tp, gp, s11
                  srai       s8, t0, 25
                  auipc      a4, 925829
                  slti       s10, s8, -890
                  sra        t1, t1, a0
                  divu       s3, gp, a2
                  slti       s10, s8, -890
                  mulhsu     s8, sp, s5
                  slt        a1, a1, zero
                  sll        s10, sp, a0
                  mulhu      s1, s9, a1
                  srl        zero, t1, a4
                  srai       s8, t0, 25
                  sltiu      a2, a0, -848
                  mulh       s2, t1, a3
                  srli       t6, t5, 10
                  nop
                  andi       gp, s9, -46
                  rem        a6, s6, a7
                  xor        a4, a2, s0
                  mul        a6, t2, s5
                  and        sp, s3, s5
                  xori       s3, s8, -101
                  and        sp, s3, s5
                  sub        ra, t1, s11
                  xori       s3, s8, -101
                  sll        s10, sp, a0
                  slli       tp, t1, 9
                  sra        t1, t1, a0
                  mul        a6, t2, s5
                  add        tp, gp, s11
                  ori        t1, ra, -664
                  divu       s3, gp, a2
                  andi       gp, s9, -46
                  andi       gp, s9, -46
                  mul        a6, t2, s5
                  srli       t6, t5, 10
                  mulhu      s1, s9, a1
                  divu       s3, gp, a2
                  addi       s3, a2, 677
                  sltiu      a2, a0, -848
                  and        sp, s3, s5
                  rem        a6, s6, a7
                  rem        a6, s6, a7
                  mulhsu     s8, sp, s5
                  remu       s0, t0, gp
                  slti       s10, s8, -890
                  andi       gp, s9, -46
                  mul        a6, t2, s5
                  slli       tp, t1, 9
                  remu       s0, t0, gp
                  or         a7, a0, zero
                  sltiu      a2, a0, -848
                  sra        t1, t1, a0
                  lui        s6, 496523
                  and        sp, s3, s5
                  addi       s3, a2, 677
                  slli       tp, t1, 9
                  mulh       s2, t1, a3
                  mulh       s2, t1, a3
                  and        sp, s3, s5
                  mulhu      s1, s9, a1
                  remu       s0, t0, gp
                  mulhsu     s8, sp, s5
                  slli       tp, t1, 9
                  ori        t1, ra, -664
                  addi       s3, a2, 677
                  slli       tp, t1, 9
                  remu       s0, t0, gp
                  mulhu      s1, s9, a1
                  srli       t6, t5, 10
                  sra        t1, t1, a0
                  and        sp, s3, s5
                  and        sp, s3, s5
                  remu       s0, t0, gp
                  nop
                  mul        a6, t2, s5
                  xor        a4, a2, s0
                  addi       s3, a2, 677
                  or         a7, a0, zero
                  div        zero, a7, s0
                  or         a7, a0, zero
                  sub        ra, t1, s11
                  slt        a1, a1, zero
                  slli       tp, t1, 9
                  or         a7, a0, zero
                  srl        zero, t1, a4
                  auipc      a4, 925829
                  slli       tp, t1, 9
                  and        sp, s3, s5
                  andi       gp, s9, -46
                  andi       gp, s9, -46
                  or         a7, a0, zero
                  sll        s10, sp, a0
                  and        sp, s3, s5
                  xor        a4, a2, s0
                  mulhu      s1, s9, a1
                  slli       tp, t1, 9
                  sltiu      a2, a0, -848
                  sra        t1, t1, a0
                  andi       gp, s9, -46
                  slt        a1, a1, zero
                  lui        s6, 496523
                  ori        t1, ra, -664
                  auipc      a4, 925829
                  sub        ra, t1, s11
                  or         a7, a0, zero
                  ori        t1, ra, -664
                  xori       s3, s8, -101
                  or         a7, a0, zero
                  mulhu      s1, s9, a1
                  sub        ra, t1, s11
                  srai       s8, t0, 25
                  and        sp, s3, s5
                  divu       s3, gp, a2
                  mulh       s2, t1, a3
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  or         a7, a0, zero
                  divu       s3, gp, a2
                  xori       s3, s8, -101
                  or         a7, a0, zero
                  srai       s8, t0, 25
                  auipc      a4, 925829
                  divu       s3, gp, a2
                  sll        s10, sp, a0
                  xor        a4, a2, s0
                  lui        s6, 496523
                  srai       s8, t0, 25
                  sltu       t3, t1, tp
                  xori       s3, s8, -101
                  addi       s3, a2, 677
                  and        sp, s3, s5
                  sltiu      a2, a0, -848
                  remu       s0, t0, gp
                  andi       gp, s9, -46
                  sub        ra, t1, s11
                  remu       s0, t0, gp
                  and        sp, s3, s5
                  sll        s10, sp, a0
                  slti       s10, s8, -890
                  sub        ra, t1, s11
                  xor        a4, a2, s0
                  and        sp, s3, s5
                  srai       s8, t0, 25
                  li         s7, 0x0 #start riscv_int_numeric_corner_stream_29
                  li         t2, 0x80000000
                  li         a6, 0x0
                  li         s1, 0x80000000
                  li         a2, 0x80000000
                  li         s3, 0xb79b6707
                  li         ra, 0xffffffff
                  li         s5, 0xffffffff
                  li         s9, 0xffffffff
                  li         s6, 0x3d041890
                  div        ra, t2, s7
                  sub        t2, s5, ra
                  div        ra, t2, s7
                  addi       t2, t2, 677
                  mulhu      s9, s9, s1
                  divu       t2, a2, a6
                  lui        a6, 496523
                  nop
                  remu       s7, s3, a2
                  lui        a6, 496523
                  lui        a6, 496523
                  nop
                  mulhu      s9, s9, s1
                  mul        s3, s6, s3
                  mulhu      s9, s9, s1
                  rem        s3, s5, t2
                  addi       t2, t2, 677
                  mulhu      s9, s9, s1
                  divu       t2, a2, a6
                  rem        s3, s5, t2
                  rem        s3, s5, t2
                  divu       t2, a2, a6
                  rem        s3, s5, t2
                  addi       t2, t2, 677
                  mulhu      s9, s9, s1 #end riscv_int_numeric_corner_stream_29
                  srai       s8, t0, 25
                  remu       s0, t0, gp
                  nop
                  ori        t1, ra, -664
                  slt        a1, a1, zero
                  srli       t6, t5, 10
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  srai       s8, t0, 25
                  nop
                  srli       t6, t5, 10
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  lui        s6, 496523
                  ori        t1, ra, -664
                  addi       s3, a2, 677
                  addi       s3, a2, 677
                  rem        a6, s6, a7
                  sra        t1, t1, a0
                  rem        a6, s6, a7
                  mulh       s2, t1, a3
                  sll        s10, sp, a0
                  auipc      a4, 925829
                  mulhsu     s8, sp, s5
                  ori        t1, ra, -664
                  srai       s8, t0, 25
                  srli       t6, t5, 10
                  addi       s3, a2, 677
                  remu       s0, t0, gp
                  sub        ra, t1, s11
                  or         a7, a0, zero
                  xori       s3, s8, -101
                  xori       s3, s8, -101
                  sll        s10, sp, a0
                  sll        s10, sp, a0
                  sltiu      a2, a0, -848
                  mulh       s2, t1, a3
                  mulh       s2, t1, a3
                  sll        s10, sp, a0
                  sub        ra, t1, s11
                  and        sp, s3, s5
                  ori        t1, ra, -664
                  nop
                  xor        a4, a2, s0
                  sltiu      a2, a0, -848
                  div        zero, a7, s0
                  mulhsu     s8, sp, s5
                  xor        a4, a2, s0
                  nop
                  mulhsu     s8, sp, s5
                  srl        zero, t1, a4
                  slti       s10, s8, -890
                  lui        s6, 496523
                  sltiu      a2, a0, -848
                  rem        a6, s6, a7
                  mulhsu     s8, sp, s5
                  sltu       t3, t1, tp
                  srai       s8, t0, 25
                  addi       s3, a2, 677
                  mulhu      s1, s9, a1
                  lui        s6, 496523
                  srli       t6, t5, 10
                  mulhu      s1, s9, a1
                  sra        t1, t1, a0
                  ori        t1, ra, -664
                  andi       gp, s9, -46
                  auipc      a4, 925829
                  add        tp, gp, s11
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  ori        t1, ra, -664
                  xor        a4, a2, s0
                  srai       s8, t0, 25
                  lui        s6, 496523
                  rem        a6, s6, a7
                  auipc      a4, 925829
                  mulh       s2, t1, a3
                  sltu       t3, t1, tp
                  mul        a6, t2, s5
                  sra        t1, t1, a0
                  or         a7, a0, zero
                  ori        t1, ra, -664
                  lui        s6, 496523
                  sub        ra, t1, s11
                  xor        a4, a2, s0
                  nop
                  remu       s0, t0, gp
                  addi       s3, a2, 677
                  div        zero, a7, s0
                  xor        a4, a2, s0
                  rem        a6, s6, a7
                  xori       s3, s8, -101
                  xori       s3, s8, -101
                  slt        a1, a1, zero
                  mulhsu     s8, sp, s5
                  mul        a6, t2, s5
                  sltu       t3, t1, tp
                  nop
                  nop
                  xor        a4, a2, s0
                  slt        a1, a1, zero
                  divu       s3, gp, a2
                  add        tp, gp, s11
                  mul        a6, t2, s5
                  xori       s3, s8, -101
                  remu       s0, t0, gp
                  mulh       s2, t1, a3
                  ori        t1, ra, -664
                  or         a7, a0, zero
                  remu       s0, t0, gp
                  sub        ra, t1, s11
                  sltu       t3, t1, tp
                  remu       s0, t0, gp
                  slt        a1, a1, zero
                  addi       s3, a2, 677
                  slli       tp, t1, 9
                  sltu       t3, t1, tp
                  sra        t1, t1, a0
                  sltu       t3, t1, tp
                  sltiu      a2, a0, -848
                  xori       s3, s8, -101
                  srai       s8, t0, 25
                  sra        t1, t1, a0
                  addi       s3, a2, 677
                  slt        a1, a1, zero
                  srl        zero, t1, a4
                  mulhsu     s8, sp, s5
                  and        sp, s3, s5
                  mulhsu     s8, sp, s5
                  slli       tp, t1, 9
                  sub        ra, t1, s11
                  sll        s10, sp, a0
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  xor        a4, a2, s0
                  andi       gp, s9, -46
                  xor        a4, a2, s0
                  slt        a1, a1, zero
                  sra        t1, t1, a0
                  sltiu      a2, a0, -848
                  divu       s3, gp, a2
                  srl        zero, t1, a4
                  xor        a4, a2, s0
                  auipc      a4, 925829
                  or         a7, a0, zero
                  srl        zero, t1, a4
                  sltu       t3, t1, tp
                  divu       s3, gp, a2
                  nop
                  sra        t1, t1, a0
                  sra        t1, t1, a0
                  srl        zero, t1, a4
                  la x10, test_done
                  jalr x0, x10, 0
test_done:        
                  li gp, 1
                  ecall
write_tohost:     
                  sw gp, tohost, t5

_exit:            
                  j write_tohost

instr_end:        
                  nop

.section .data
.align 6; .global tohost; tohost: .dword 0;
.align 6; .global fromhost; fromhost: .dword 0;
.section .user_stack,"aw",@progbits;
.align 2
user_stack_start:
.rept 4999
.4byte 0x0
.endr
user_stack_end:
.4byte 0x0
.align 2
kernel_instr_start:
.text
.align           2
mtvec_handler:    
                  1: addi x27, x27, -124
                  sw  x1, 4(x27)
                  sw  x2, 8(x27)
                  sw  x3, 12(x27)
                  sw  x4, 16(x27)
                  sw  x5, 20(x27)
                  sw  x6, 24(x27)
                  sw  x7, 28(x27)
                  sw  x8, 32(x27)
                  sw  x9, 36(x27)
                  sw  x10, 40(x27)
                  sw  x11, 44(x27)
                  sw  x12, 48(x27)
                  sw  x13, 52(x27)
                  sw  x14, 56(x27)
                  sw  x15, 60(x27)
                  sw  x16, 64(x27)
                  sw  x17, 68(x27)
                  sw  x18, 72(x27)
                  sw  x19, 76(x27)
                  sw  x20, 80(x27)
                  sw  x21, 84(x27)
                  sw  x22, 88(x27)
                  sw  x23, 92(x27)
                  sw  x24, 96(x27)
                  sw  x25, 100(x27)
                  sw  x26, 104(x27)
                  sw  x27, 108(x27)
                  sw  x28, 112(x27)
                  sw  x29, 116(x27)
                  sw  x30, 120(x27)
                  sw  x31, 124(x27)
                  csrr x17, 0x300 # MSTATUS
                  csrr x17, 0x342 # MCAUSE
                  srli x17, x17, 31
                  bne x17, x0, mmode_intr_handler

mmode_exception_handler:
                  csrr x17, 0x341 # MEPC
                  csrr x17, 0x342 # MCAUSE
                  li x16, 0x3 # BREAKPOINT
                  beq x17, x16, ebreak_handler
                  li x16, 0x8 # ECALL_UMODE
                  beq x17, x16, ecall_handler
                  li x16, 0x9 # ECALL_SMODE
                  beq x17, x16, ecall_handler
                  li x16, 0xb # ECALL_MMODE
                  beq x17, x16, ecall_handler
                  li x16, 0x1
                  beq x17, x16, instr_fault_handler
                  li x16, 0x5
                  beq x17, x16, load_fault_handler
                  li x16, 0x7
                  beq x17, x16, store_fault_handler
                  li x16, 0xc
                  beq x17, x16, pt_fault_handler
                  li x16, 0xd
                  beq x17, x16, pt_fault_handler
                  li x16, 0xf
                  beq x17, x16, pt_fault_handler
                  li x16, 0x2 # ILLEGAL_INSTRUCTION
                  beq x17, x16, illegal_instr_handler
                  csrr x16, 0x343 # MTVAL
                  1: la x10, test_done
                  jalr x1, x10, 0

ecall_handler:    
                  la x17, _start
                  sw x0, 0(x17)
                  sw x1, 4(x17)
                  sw x2, 8(x17)
                  sw x3, 12(x17)
                  sw x4, 16(x17)
                  sw x5, 20(x17)
                  sw x6, 24(x17)
                  sw x7, 28(x17)
                  sw x8, 32(x17)
                  sw x9, 36(x17)
                  sw x10, 40(x17)
                  sw x11, 44(x17)
                  sw x12, 48(x17)
                  sw x13, 52(x17)
                  sw x14, 56(x17)
                  sw x15, 60(x17)
                  sw x16, 64(x17)
                  sw x17, 68(x17)
                  sw x18, 72(x17)
                  sw x19, 76(x17)
                  sw x20, 80(x17)
                  sw x21, 84(x17)
                  sw x22, 88(x17)
                  sw x23, 92(x17)
                  sw x24, 96(x17)
                  sw x25, 100(x17)
                  sw x26, 104(x17)
                  sw x27, 108(x17)
                  sw x28, 112(x17)
                  sw x29, 116(x17)
                  sw x30, 120(x17)
                  sw x31, 124(x17)
                  la x10, write_tohost
                  jalr x0, x10, 0

instr_fault_handler:
                  li x17, 0
                  csrw 0x340, x17
                  li x29, 0
                  0: csrr x17, 0x340
                  mv x10, x17
                  li x10, 0
                  beq x17, x10, 1f
                  1: csrr x16, 0x3b0
                  csrr x30, 0x3a0
                  j 17f
                  17: li x11, 4
                  csrr x17, 0x340
                  slli x17, x17, 30
                  srli x17, x17, 30
                  sub x10, x11, x17
                  addi x10, x10, -1
                  slli x10, x10, 3
                  sll x11, x30, x10
                  slli x17, x17, 3
                  add x10, x10, x17
                  srl x11, x11, x10
                  slli x10, x11, 27
                  srli x10, x10, 30
                  beqz x10, 20f
                  li x17, 1
                  beq x10, x17, 21f
                  li x17, 2
                  beq x10, x17, 25f
                  li x17, 3
                  beq x10, x17, 27f
                  la x17, test_done
                  jalr x0, x17, 0
                  18: csrr x17, 0x340
                  mv x29, x16
                  addi x17, x17, 1
                  csrw 0x340, x17
                  li x16, 1
                  ble x16, x17, 19f
                  j 0b
                  19: la x17, test_done
                  jalr x0, x17, 0
                  20: j 18b
                  21: csrr x17, 0x340
                  csrr x10, 0x343
                  srli x10, x10, 2
                  bnez x17, 22f
                  bltz x10, 18b
                  j 23f
                  22: bgtu x29, x10, 18b
                  23: bleu x16, x10, 18b
                  andi x10, x11, 128
                  beqz x10, 24f
                  la x17, test_done
                  jalr x0, x17, 0
                  24: j 29f
                  25: csrr x17, 0x343
                  srli x17, x17, 2
                  slli x10, x16, 2
                  srli x10, x10, 2
                  bne x17, x10, 18b
                  andi x10, x11, 128
                  beqz x10, 26f
                  la x17, test_done
                  jalr x0, x17, 0
                  26: j 29f
                  27: csrr x17, 0x343
                  srli x17, x17, 2
                  srli x17, x17, 0
                  slli x17, x17, 0
                  slli x10, x16, 2
                  srli x10, x10, 2
                  srli x10, x10, 0
                  slli x10, x10, 0
                  bne x17, x10, 18b
                  andi x10, x11, 128
                  beqz x10, 29f
                  la x17, test_done
                  jalr x0, x17, 0
                  28: j 29f
                  29: ori x11, x11, 4
                  csrr x17, 0x340
                  li x10, 30
                  sll x17, x17, x10
                  srl x17, x17, x10
                  slli x10, x17, 3
                  sll x11, x11, x10
                  or x30, x30, x11
                  csrr x17, 0x340
                  srli x17, x17, 2
                  beqz x17, 30f
                  li x10, 1
                  beq x17, x10, 31f
                  li x10, 2
                  beq x17, x10, 32f
                  li x10, 3
                  beq x17, x10, 33f
                  30: csrw 0x3a0, x30
                  j 34f
                  31: csrw 0x3a1, x30
                  j 34f
                  32: csrw 0x3a2, x30
                  j 34f
                  33: csrw 0x3a3, x30
                  34: nop
                  lw  x1, 4(x27)
                  lw  x2, 8(x27)
                  lw  x3, 12(x27)
                  lw  x4, 16(x27)
                  lw  x5, 20(x27)
                  lw  x6, 24(x27)
                  lw  x7, 28(x27)
                  lw  x8, 32(x27)
                  lw  x9, 36(x27)
                  lw  x10, 40(x27)
                  lw  x11, 44(x27)
                  lw  x12, 48(x27)
                  lw  x13, 52(x27)
                  lw  x14, 56(x27)
                  lw  x15, 60(x27)
                  lw  x16, 64(x27)
                  lw  x17, 68(x27)
                  lw  x18, 72(x27)
                  lw  x19, 76(x27)
                  lw  x20, 80(x27)
                  lw  x21, 84(x27)
                  lw  x22, 88(x27)
                  lw  x23, 92(x27)
                  lw  x24, 96(x27)
                  lw  x25, 100(x27)
                  lw  x26, 104(x27)
                  lw  x27, 108(x27)
                  lw  x28, 112(x27)
                  lw  x29, 116(x27)
                  lw  x30, 120(x27)
                  lw  x31, 124(x27)
                  addi x27, x27, 124
                  mret

load_fault_handler:
                  li x17, 0
                  csrw 0x340, x17
                  li x29, 0
                  0: csrr x17, 0x340
                  mv x10, x17
                  li x10, 0
                  beq x17, x10, 1f
                  1: csrr x16, 0x3b0
                  csrr x30, 0x3a0
                  j 17f
                  17: li x11, 4
                  csrr x17, 0x340
                  slli x17, x17, 30
                  srli x17, x17, 30
                  sub x10, x11, x17
                  addi x10, x10, -1
                  slli x10, x10, 3
                  sll x11, x30, x10
                  slli x17, x17, 3
                  add x10, x10, x17
                  srl x11, x11, x10
                  slli x10, x11, 27
                  srli x10, x10, 30
                  beqz x10, 20f
                  li x17, 1
                  beq x10, x17, 21f
                  li x17, 2
                  beq x10, x17, 25f
                  li x17, 3
                  beq x10, x17, 27f
                  la x17, test_done
                  jalr x0, x17, 0
                  18: csrr x17, 0x340
                  mv x29, x16
                  addi x17, x17, 1
                  csrw 0x340, x17
                  li x16, 1
                  ble x16, x17, 19f
                  j 0b
                  19: la x17, test_done
                  jalr x0, x17, 0
                  20: j 18b
                  21: csrr x17, 0x340
                  csrr x10, 0x343
                  srli x10, x10, 2
                  bnez x17, 22f
                  bltz x10, 18b
                  j 23f
                  22: bgtu x29, x10, 18b
                  23: bleu x16, x10, 18b
                  andi x10, x11, 128
                  beqz x10, 24f
                  la x17, test_done
                  jalr x0, x17, 0
                  24: j 29f
                  25: csrr x17, 0x343
                  srli x17, x17, 2
                  slli x10, x16, 2
                  srli x10, x10, 2
                  bne x17, x10, 18b
                  andi x10, x11, 128
                  beqz x10, 26f
                  la x17, test_done
                  jalr x0, x17, 0
                  26: j 29f
                  27: csrr x17, 0x343
                  srli x17, x17, 2
                  srli x17, x17, 0
                  slli x17, x17, 0
                  slli x10, x16, 2
                  srli x10, x10, 2
                  srli x10, x10, 0
                  slli x10, x10, 0
                  bne x17, x10, 18b
                  andi x10, x11, 128
                  beqz x10, 29f
                  la x17, test_done
                  jalr x0, x17, 0
                  28: j 29f
                  29: ori x11, x11, 1
                  csrr x17, 0x340
                  li x10, 30
                  sll x17, x17, x10
                  srl x17, x17, x10
                  slli x10, x17, 3
                  sll x11, x11, x10
                  or x30, x30, x11
                  csrr x17, 0x340
                  srli x17, x17, 2
                  beqz x17, 30f
                  li x10, 1
                  beq x17, x10, 31f
                  li x10, 2
                  beq x17, x10, 32f
                  li x10, 3
                  beq x17, x10, 33f
                  30: csrw 0x3a0, x30
                  j 34f
                  31: csrw 0x3a1, x30
                  j 34f
                  32: csrw 0x3a2, x30
                  j 34f
                  33: csrw 0x3a3, x30
                  34: nop
                  lw  x1, 4(x27)
                  lw  x2, 8(x27)
                  lw  x3, 12(x27)
                  lw  x4, 16(x27)
                  lw  x5, 20(x27)
                  lw  x6, 24(x27)
                  lw  x7, 28(x27)
                  lw  x8, 32(x27)
                  lw  x9, 36(x27)
                  lw  x10, 40(x27)
                  lw  x11, 44(x27)
                  lw  x12, 48(x27)
                  lw  x13, 52(x27)
                  lw  x14, 56(x27)
                  lw  x15, 60(x27)
                  lw  x16, 64(x27)
                  lw  x17, 68(x27)
                  lw  x18, 72(x27)
                  lw  x19, 76(x27)
                  lw  x20, 80(x27)
                  lw  x21, 84(x27)
                  lw  x22, 88(x27)
                  lw  x23, 92(x27)
                  lw  x24, 96(x27)
                  lw  x25, 100(x27)
                  lw  x26, 104(x27)
                  lw  x27, 108(x27)
                  lw  x28, 112(x27)
                  lw  x29, 116(x27)
                  lw  x30, 120(x27)
                  lw  x31, 124(x27)
                  addi x27, x27, 124
                  mret

store_fault_handler:
                  li x17, 0
                  csrw 0x340, x17
                  li x29, 0
                  0: csrr x17, 0x340
                  mv x10, x17
                  li x10, 0
                  beq x17, x10, 1f
                  1: csrr x16, 0x3b0
                  csrr x30, 0x3a0
                  j 17f
                  17: li x11, 4
                  csrr x17, 0x340
                  slli x17, x17, 30
                  srli x17, x17, 30
                  sub x10, x11, x17
                  addi x10, x10, -1
                  slli x10, x10, 3
                  sll x11, x30, x10
                  slli x17, x17, 3
                  add x10, x10, x17
                  srl x11, x11, x10
                  slli x10, x11, 27
                  srli x10, x10, 30
                  beqz x10, 20f
                  li x17, 1
                  beq x10, x17, 21f
                  li x17, 2
                  beq x10, x17, 25f
                  li x17, 3
                  beq x10, x17, 27f
                  la x17, test_done
                  jalr x0, x17, 0
                  18: csrr x17, 0x340
                  mv x29, x16
                  addi x17, x17, 1
                  csrw 0x340, x17
                  li x16, 1
                  ble x16, x17, 19f
                  j 0b
                  19: la x17, test_done
                  jalr x0, x17, 0
                  20: j 18b
                  21: csrr x17, 0x340
                  csrr x10, 0x343
                  srli x10, x10, 2
                  bnez x17, 22f
                  bltz x10, 18b
                  j 23f
                  22: bgtu x29, x10, 18b
                  23: bleu x16, x10, 18b
                  andi x10, x11, 128
                  beqz x10, 24f
                  la x17, test_done
                  jalr x0, x17, 0
                  24: j 29f
                  25: csrr x17, 0x343
                  srli x17, x17, 2
                  slli x10, x16, 2
                  srli x10, x10, 2
                  bne x17, x10, 18b
                  andi x10, x11, 128
                  beqz x10, 26f
                  la x17, test_done
                  jalr x0, x17, 0
                  26: j 29f
                  27: csrr x17, 0x343
                  srli x17, x17, 2
                  srli x17, x17, 0
                  slli x17, x17, 0
                  slli x10, x16, 2
                  srli x10, x10, 2
                  srli x10, x10, 0
                  slli x10, x10, 0
                  bne x17, x10, 18b
                  andi x10, x11, 128
                  beqz x10, 29f
                  la x17, test_done
                  jalr x0, x17, 0
                  28: j 29f
                  29: ori x11, x11, 3
                  csrr x17, 0x340
                  li x10, 30
                  sll x17, x17, x10
                  srl x17, x17, x10
                  slli x10, x17, 3
                  sll x11, x11, x10
                  or x30, x30, x11
                  csrr x17, 0x340
                  srli x17, x17, 2
                  beqz x17, 30f
                  li x10, 1
                  beq x17, x10, 31f
                  li x10, 2
                  beq x17, x10, 32f
                  li x10, 3
                  beq x17, x10, 33f
                  30: csrw 0x3a0, x30
                  j 34f
                  31: csrw 0x3a1, x30
                  j 34f
                  32: csrw 0x3a2, x30
                  j 34f
                  33: csrw 0x3a3, x30
                  34: nop
                  lw  x1, 4(x27)
                  lw  x2, 8(x27)
                  lw  x3, 12(x27)
                  lw  x4, 16(x27)
                  lw  x5, 20(x27)
                  lw  x6, 24(x27)
                  lw  x7, 28(x27)
                  lw  x8, 32(x27)
                  lw  x9, 36(x27)
                  lw  x10, 40(x27)
                  lw  x11, 44(x27)
                  lw  x12, 48(x27)
                  lw  x13, 52(x27)
                  lw  x14, 56(x27)
                  lw  x15, 60(x27)
                  lw  x16, 64(x27)
                  lw  x17, 68(x27)
                  lw  x18, 72(x27)
                  lw  x19, 76(x27)
                  lw  x20, 80(x27)
                  lw  x21, 84(x27)
                  lw  x22, 88(x27)
                  lw  x23, 92(x27)
                  lw  x24, 96(x27)
                  lw  x25, 100(x27)
                  lw  x26, 104(x27)
                  lw  x27, 108(x27)
                  lw  x28, 112(x27)
                  lw  x29, 116(x27)
                  lw  x30, 120(x27)
                  lw  x31, 124(x27)
                  addi x27, x27, 124
                  mret

ebreak_handler:   
                  csrr  x17, 0x341
                  addi  x17, x17, 4
                  csrw  0x341, x17
                  lw  x1, 4(x27)
                  lw  x2, 8(x27)
                  lw  x3, 12(x27)
                  lw  x4, 16(x27)
                  lw  x5, 20(x27)
                  lw  x6, 24(x27)
                  lw  x7, 28(x27)
                  lw  x8, 32(x27)
                  lw  x9, 36(x27)
                  lw  x10, 40(x27)
                  lw  x11, 44(x27)
                  lw  x12, 48(x27)
                  lw  x13, 52(x27)
                  lw  x14, 56(x27)
                  lw  x15, 60(x27)
                  lw  x16, 64(x27)
                  lw  x17, 68(x27)
                  lw  x18, 72(x27)
                  lw  x19, 76(x27)
                  lw  x20, 80(x27)
                  lw  x21, 84(x27)
                  lw  x22, 88(x27)
                  lw  x23, 92(x27)
                  lw  x24, 96(x27)
                  lw  x25, 100(x27)
                  lw  x26, 104(x27)
                  lw  x27, 108(x27)
                  lw  x28, 112(x27)
                  lw  x29, 116(x27)
                  lw  x30, 120(x27)
                  lw  x31, 124(x27)
                  addi x27, x27, 124
                  mret

illegal_instr_handler:
                  csrr  x17, 0x341
                  addi  x17, x17, 4
                  csrw  0x341, x17
                  lw  x1, 4(x27)
                  lw  x2, 8(x27)
                  lw  x3, 12(x27)
                  lw  x4, 16(x27)
                  lw  x5, 20(x27)
                  lw  x6, 24(x27)
                  lw  x7, 28(x27)
                  lw  x8, 32(x27)
                  lw  x9, 36(x27)
                  lw  x10, 40(x27)
                  lw  x11, 44(x27)
                  lw  x12, 48(x27)
                  lw  x13, 52(x27)
                  lw  x14, 56(x27)
                  lw  x15, 60(x27)
                  lw  x16, 64(x27)
                  lw  x17, 68(x27)
                  lw  x18, 72(x27)
                  lw  x19, 76(x27)
                  lw  x20, 80(x27)
                  lw  x21, 84(x27)
                  lw  x22, 88(x27)
                  lw  x23, 92(x27)
                  lw  x24, 96(x27)
                  lw  x25, 100(x27)
                  lw  x26, 104(x27)
                  lw  x27, 108(x27)
                  lw  x28, 112(x27)
                  lw  x29, 116(x27)
                  lw  x30, 120(x27)
                  lw  x31, 124(x27)
                  addi x27, x27, 124
                  mret

pt_fault_handler: 
                  nop

.align 2
mmode_intr_handler:
                  csrr  x17, 0x300 # MSTATUS;
                  csrr  x17, 0x304 # MIE;
                  csrr  x17, 0x344 # MIP;
                  csrrc x17, 0x344, x17 # MIP;
                  lw  x1, 4(x27)
                  lw  x2, 8(x27)
                  lw  x3, 12(x27)
                  lw  x4, 16(x27)
                  lw  x5, 20(x27)
                  lw  x6, 24(x27)
                  lw  x7, 28(x27)
                  lw  x8, 32(x27)
                  lw  x9, 36(x27)
                  lw  x10, 40(x27)
                  lw  x11, 44(x27)
                  lw  x12, 48(x27)
                  lw  x13, 52(x27)
                  lw  x14, 56(x27)
                  lw  x15, 60(x27)
                  lw  x16, 64(x27)
                  lw  x17, 68(x27)
                  lw  x18, 72(x27)
                  lw  x19, 76(x27)
                  lw  x20, 80(x27)
                  lw  x21, 84(x27)
                  lw  x22, 88(x27)
                  lw  x23, 92(x27)
                  lw  x24, 96(x27)
                  lw  x25, 100(x27)
                  lw  x26, 104(x27)
                  lw  x27, 108(x27)
                  lw  x28, 112(x27)
                  lw  x29, 116(x27)
                  lw  x30, 120(x27)
                  lw  x31, 124(x27)
                  addi x27, x27, 124
                  mret;

kernel_instr_end: nop
.section .kernel_stack,"aw",@progbits;
.align 2
kernel_stack_start:
.rept 3999
.4byte 0x0
.endr
kernel_stack_end:
.4byte 0x0
