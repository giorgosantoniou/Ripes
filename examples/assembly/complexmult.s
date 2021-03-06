.data
aa: .word 1 # Re part of z
bb: .word 3 # Im part of z
cc: .word 5 # Re part of w
dd: .word 4 # Im part of w
str: .string " + i* "

.text
main:
lw a0 , aa
lw a1 , bb
lw a2 , cc
lw a3 , dd

#Do complex multiplication of numbers a0-a3
jal complexMul
nop
mv t0, a1 #Move imaginary value to t0
mv a1, a0 #Move real value to a1

li a0, 1 #Set ecall to print integer
ecall #Print integer

la a1, str
li a0, 4
ecall

mv a1, t0 #Move imaginary value to a1
li a0, 1
ecall #Print integer

j end # Jump to end of program

myMult:
    li t0 32 # Iteration variable
    li t3 0 # initialize temporary product register to 0
    start: 
    mv t1, a1 # move multiplier to temporary register
    andi t1, t1, 1 # isolate first bit
    beq t1, x0, shift
    add t3, t3, a0
    shift: 
    slli a0, a0, 1
    srai a1, a1, 1 # make an arithmetic right shift for signed multiplication
    addi t0, t0, -1 # decrement loop index
    bnez t0 start # branch if loop index is not 0
    mv a0, t3 # move final product to result register
    jalr x0, x1 0

complexMul:
	# Place the 4 input arguments and return address on the stack
	addi sp, sp, -28
    sw x0, 24(sp) # tmp. res 2
    sw x0, 20(sp) # tmp. res 1 
    sw ra, 16(sp) # return address
    sw a0, 12(sp) # a
    sw a1, 8(sp) # b
    sw a2 4(sp) # c
    sw a3 0(sp) # d
    
    # (a + ib)(c + id) = (ac − bd) + i(ad + bc)
    # Step 1: a*c
    mv a1, a2 # Move C from a2 to a1
    jal myMult
    nop
    
    sw a0, 20(sp) # push onto tmp. res 1
    # step 2: b*d
    lw a0 8(sp)
     lw a1 0(sp)
    jal myMult
    nop
    # step 3: (ac − bd)
    lw t0, 20(sp) # Reload a*c from stack
    sub t2 t0 a0 # t2 contains real part of multiplication
	# push (ac − bd) onto tmp. res 1 from stack
    sw t2, 20(sp)

    # Step 1: a*d
    lw a0 12(sp)
    lw a1 0(sp)
    jal myMult
    nop
    sw a0, 24(sp) # store a*d in tmp. res 2
    # step 2: b*c
    lw a0 8(sp)
    lw a1 4(sp)
    jal myMult
    mv a1 a0 # moving result to a1 saves us 1 operation later on
    # step 3: (ad + bc)
    lw t0, 24(sp) # Reload a*c from stack
    add a1 t0 a1 # a1 contains imag part of multiplication
    lw a0 20(sp) # Load real result from tmp. res 1

    lw ra 16(sp) # Reload return address from stack
    addi sp, sp, 28 # Restore stack pointer
    jalr x0 x1 0

end:nop