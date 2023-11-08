
.set kScratchStartAddress, 0x00A00000

_start:
  #jal smoke_branch
  #jal smoke_auipc
  jal smoke_load_store
  #jal smoke_alu_i
  #jal smoke_alu_i_imm
  #jal smoke_alu_m
  #jal smoke_alu_zba
  #jal smoke_alu_zbb
  #jal smoke_alu_zbc
  #jal smoke_alu_zbf
  #jal smoke_alu_zbp
  #jal smoke_alu_zbr
  #jal smoke_alu_zbs
  #jal smoke_alu_b_misc
  #jal smoke_alu_zbt
  #jal smoke_alu_b_imm
  #jal smoke_csr
  jal smoke_fence
  unimp

smoke_auipc:
  auipc t0, 0xA
  auipc t1, 0xA
  addi  t0, t0, 4
  bne t0, t1, bad_exit
  ret

smoke_branch:
  li t0, 0x8e9c1d0d
  li t1, 0x3610897a
  addi t2, t1, 0
  bne t0, t1, smoke_beq
  j bad_exit
  smoke_beq:
  beq t1, t2, smoke_blt
  j bad_exit
  smoke_blt:
  blt t0, t1, smoke_bge
  j bad_exit
  smoke_bge:
  bge t2, t1, smoke_bltu
  j bad_exit
  smoke_bltu:
  bltu t1, t0, smoke_bgeu
  j bad_exit
  smoke_bgeu:
  bgeu t2, t1, smoke_branch_ret
  j bad_exit
  smoke_branch_ret:
  ret

smoke_load_store:
  la t0, kScratchStartAddress
  li t1, 0x2d3eae8c

  sb t1, 0(t0)
  lb t2, 0(t0)
  li t3, 0xffffff8c
  bne t2, t3, bad_exit

  lbu t2, 0(t0)
  li t3, 0x0000008c
  bne t2, t3, bad_exit

  sh  t1, 4(t0)
  lh  t2, 4(t0)
  li t3, 0xffffae8c
  bne t2, t3, bad_exit

  lhu t2, 4(t0)
  li t3, 0x0000ae8c
  bne t2, t3, bad_exit

  sw t1, 8(t0)
  lw t2, 8(t0)
  bne t2, t1, bad_exit

  ret

smoke_alu_i:
  li   t0, 0x3217ab08
  li   t1, 0x24e6a04f
  add  t2, t1, t0
  slt  t1, t0, t2
  sll  t0, t2, t1
  sra  t1, t0, t2
  and  t2, t1, t0
  xor  t0, t2, t1
  sub  t1, t0, t2
  or   t2, t1, t0
  sltu t0, t1, t2
  srl  t1, t2, t0

  # check result
  li t0, 0x7b03fdab
  bne t1, t0, bad_exit
  ret

smoke_alu_i_imm:
  li    t0, 0xfcec24cf
  slti  t0, t0, 0x37e
  ori   t0, t0, 0x13b
  sltiu t0, t0, 0x23e
  addi  t0, t0, 0x7c4
  srli  t0, t0, 3
  xori  t0, t0, 0x4f1
  slli  t0, t0, 28
  srai  t0, t0, 30
  andi  t0, t0, 0x76b

  li t1, 0x76a
  bne t1, t0, bad_exit
  ret

smoke_alu_m:
  li      t0, 144
  li      t1, 0x61a061b6
  div     t2, t1, t0
  divu    t2, t2, t0
  rem     t2, t1, t2
  remu    t2, t1, t2
  mulh    t0, t2, t1
  mulhsu  t2, t1, t0
  mul     t0, t2, t1
  mulhu   t2, t1, t0

  # check result
  li t0, 0x25f7c073
  bne t2, t0, bad_exit
  ret

smoke_alu_zba:
  addi t0, zero, 0x2f7
  addi t1, zero, 0x7ce
  sh1add t0, t0, t1
  sh2add t0, t0, t1
  sh3add t0, t0, t1

  li t2, 0x0001fdbe
  bne t2, t0, bad_exit
  ret

smoke_alu_zbb:
  li   t0, 3
  li   t1, 0x2bb36000
  ctz  t2, t1
  clz  t2, t2
  cpop t2, t2
  bne  t0, t2, bad_exit

  li t3, 0x151a2a2a
  andn   t0, t3, t1
  rol    t0, t0, t2
  orn    t0, t3, t0
  sext.h t0, t0
  ror    t0, t0, t2
  xnor   t0, t1, t0
  li  t1, 0x2bb36a2a
  bne t0, t1, bad_exit
  sext.b t0, t0
  li  t1, 0x0000002a
  bne t0, t1, bad_exit

  max  t2, t1, t3
  bne  t2, t3, bad_exit
  min  t2, t1, t3
  bne  t2, t1, bad_exit
  maxu t2, t1, t3
  bne  t2, t3, bad_exit
  minu t2, t1, t3
  bne  t2, t1, bad_exit

  # rev8, orc.b, and zext.h pseudo instructions
  # for grevi, gorci, and pack respectively
  ret

smoke_alu_zbc:
  addi t0, zero, 0x395
  li t1, 0x6ac8234c
  clmul   t0, t0, t1
  clmulr  t0, t0, t1
  clmulh  t0, t0, t1

  li t1, 0x08810f55
  bne t0, t1, bad_exit
  ret

smoke_alu_zbf:
  li t0, 0x0e0a47f3
  li t1, 0x0e1fcff3
  bfp t0, t0, t0
  bne t0, t1, bad_exit
  # pack and packh covered in zbp
  ret

smoke_alu_zbp:
  li t0, 0xcc9fd6b6
  li t1, 0x7ce71003
  pack    t2, t0, t1
  packu   t3, t0, t1
  packh   t2, t2, t3

  li t0, 0x00009fb6
  bne t0, t2, bad_exit

  li t2, 0x04030001
  xperm.n t3, t3, t2
  xperm.b t3, t3, t2
  xperm.h t3, t3, t2
  li t0, 0x000000f7
  bne t3, t0, bad_exit

  li t0, 4
  grev    t1, t1, t0
  shfl    t1, t1, t0
  gorc    t1, t1, t0
  unshfl  t1, t1, t0
  li t0, 0xffff3131
  bne t0, t3, bad_exit

  # andn, orn, xnor, rol, ror covered in zbb
  ret

smoke_alu_zbr:
  li t0, 0xabdca651
  li t1, 0xac605e47
  crc32.b  t0, t0
  crc32.h  t0, t0
  crc32.w  t0, t0
  crc32c.b t0, t0
  crc32c.h t0, t0
  crc32c.w t0, t0
  bne t1, t0, bad_exit
  ret

smoke_alu_zbs:
  addi t0, zero, 0x3
  addi t1, zero, 0x4
  bclr t0, t0, 0
  binv t0, t0, 1
  bset t0, t0, 2
  bne  t0, t1, bad_exit

  bext t1, t0, 1
  bnez t1, bad_exit

  ret

smoke_alu_zbt:
  li t0, 7
  li t1, 4
  li t2, 0x5d76fb6b
  li t3, 0xe5693902
  fsl t2, t2, t3, t0
  fsr t2, t2, t3, t1
  cmix t2, t0, t2, t3

  li   t1, 0xe5693907
  bne  t1, t2, bad_exit

  cmov t2, t0, t3, t2
  bne  t2, t3, bad_exit

  ret

smoke_alu_b_misc:
  li t0, 0x9bfae1bb
  li t1, 8
  li t2, 4
  li t4, 0xffae1bbf
  slo t0, t0, t1
  sro t0, t0, t2
  bne t0, t4, bad_exit
  ret

smoke_alu_b_imm:
  li    t0, 0xfcec24cf
  # ?
  sloi  t0, t0, 7
  # zbs
  bclri t0, t0, 3
  bseti t0, t0, 31
  binvi t0, t0, 19
  bexti t1, t0, 8
  # zbt
  fsri  t0, t0, t1, 4
  # ?
  sroi  t0, t0, 5
  # zbb
  rori  t0, t0, 16
  # zbp
  grevi   t0, t0, 4
  shfli   t0, t0, 4
  gorci   t0, t0, 2
  unshfli t0, t0, 4

  li t1, 0xf0ffafff
  bne t0, t1, bad_exit
  ret

smoke_csr:
  li t0, 0b11100
  li t1, 0b00001
  li t2, 0b01000
  li t3, 0b10101
  csrw mcountinhibit, t0 #Write CSR
  csrs mcountinhibit, t1 #Set bits in CSR
  csrc mcountinhibit, t2 #Clear bits in CSR
  csrr t0, mcountinhibit
  bne t0, t3, bad_exit

  csrwi mcountinhibit, 0b11100 #Write CSR
  csrsi mcountinhibit, 0b00001 #Set bits in CSR
  csrci mcountinhibit, 0b01000 #Clear bits in CSR
  csrr t0, mcountinhibit
  bne t0, t3, bad_exit

  # Clean up, inhibit all counters
  csrw mcountinhibit, x0
  ret

smoke_fence:
  fence
  fence.i
  ret

bad_exit:
  unimp

