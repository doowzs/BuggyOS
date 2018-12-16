_init:
#for testing
addi $a0, $zero, 0x10010000
addi $a1, $zero, 0x10010100
#string constants are preloaded
jal strcmp
j _test_fin

strcmp:
#save return addr in stack
sw $ra, ($sp) 
subi $sp, $sp, 0x4
#load param
add $t0, $zero, $a0
add $t1, $zero, $a1
#return 1 by default
addi $v0, $zero, 1
_cmp_loop:
#load char
lw $a0, ($t0)
lw $a1, ($t1)
#shift pointer
addi $t0, $t0, 4
addi $t1, $t1, 4
#compare char
bne $a0, $a1, _cmp_false
#reach the end of string
beq $a0, $zero, _cmp_fin
j _cmp_loop
_cmp_false:
#set return value 0
xor $v0, $v0, $v0
_cmp_fin:
#recover return addr from stack
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra


_test_fin:
addi $s6, $zero, 0x99