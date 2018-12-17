_init:
addi $a0, $zero, 0x7
jal fibonacci
j _test_fin




fibonacci:
#save return addr in stack
sw $ra, ($sp) 
subi $sp, $sp, 0x4
add $t0, $zero, $a0
addi $t1, $zero, 0x0
addi $t2, $zero, 0x1
xor $t3, $t3, $t3

_fibo_loop:
beq $t0, $zero, _fido_ret
subi $t0, $t0, 0x1
add $t3, $t2, $t1
add $t1, $zero, $t2
add $t2, $zero, $t3
j _fibo_loop
#return $t1
_fido_ret:
add $v0, $zero, $t1
#recover return addr from stack
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra



_test_fin:
addi $s6, $zero, 0x99
