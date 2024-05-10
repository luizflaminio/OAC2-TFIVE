# sort function
# saving registers
# convention: x0=zero, x1=ra, sp=sp, x5-7=t0-2, x10-11=a0-1, x12-17=a2-7, x18-27=s2-11, x28-31=t3-6
# Posicao dos argumentos: v=a0,n=a1
    .rodata
.ARRAY:
    .word 0x000000010
    .word 0x000000012
    .word 0x00000000F
    .word 0x000000001
    .word 0x00000000C
    .word 0x000000004
    .text

main:
    addi    a0, a0, %lo(.ARRAY)
    addi    a1, a1, 6       
    addi    sp, sp, -20
    sw      ra,16(sp)
    sw      s6,12(sp)
    sw      s5,8(sp)
    sw      s4,4(sp)
    sw      s3,0(sp)
# move parameters
    addi    s5, a0, 0
    addi    s6, a1, 0
# outer loop
    addi    s3, zero, 0
for1tst:    
    blt     s3, s6, continue
    jal     zero, exit1
continue:
# inner loop
    addi    s4, s3, -1
for2tst:
    blt     s4, zero, exit2
    slli    t0, s4, 2
    add     t0, s5, t0
    lw      t1, 0(t0)
    lw      t2, 4(t0)
    blt     t1, t2, exit2
    beq     t1, t2, exit2
# pass parameters and call
    addi    a0,s5,0
    addi    a1,s4,0
    jal     ra, swap
# inner loop
    addi    s4, s4, -1      # j = j - 1
    jal     zero, for2tst
# outer loop
exit2:
    addi    s3, s3, 1       # i = i + 1
    jal     zero, for1tst
# restoring registers
exit1:
    lw      s3, 0(sp)
    lw      s4, 4(sp)
    lw      s5, 8(sp)
    lw      s6, 12(sp)
    lw      ra, 16(sp)
    addi    sp, sp, 20
# procedure return
    jalr    zero, 0(ra)
# swap
swap:
    slli    t1, a1, 2
    add     t1, a0, t1
    lw      t0, 0(t1)
    lw      t2, 4(t1)
    sw      t2,0(t1)
    sw      t0,4(t1)
    jalr    zero, 0(ra)