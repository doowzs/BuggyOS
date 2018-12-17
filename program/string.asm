_init:
#for testing
addi $a0, $zero, 0x10010000
addi $a1, $zero, 0x10010100
addi $a2, $zero, 0x3
#string constants are preloaded
jal scanhex
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
addi $t0, $t0, 0x4
addi $t1, $t1, 0x4
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




strncmp:
#save return addr in stack
sw $ra, ($sp) 
subi $sp, $sp, 0x4
#load param
add $t0, $zero, $a0
add $t1, $zero, $a1
add $t2, $zero, $a2
#return 1 by default
addi $v0, $zero, 1
_cmpn_loop:
#load char
lw $a0, ($t0)
lw $a1, ($t1)
#shift pointer
addi $t0, $t0, 0x4
addi $t1, $t1, 0x4
#decrease counter
subi $t2, $t2, 1
#compare char
bne $a0, $a1, _cmpn_false
#reach the end of string
beq $a0, $zero, _cmpn_fin
#reach counter 0
beq $t2, $zero, _cmpn_fin
j _cmpn_loop
_cmpn_false:
#set return value 0
xor $v0, $v0, $v0
_cmpn_fin:
#recover return addr from stack
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra

scanhex:
#save return addr in stack
sw $ra, ($sp) 
subi $sp, $sp, 0x4
xor $v0, $v0, $v0
xor $t2, $t2, $t2
addi $t2, $t2, 0x10
#load param
add $t0, $zero, $a0
_scanhex_loop:
lw $t1, ($t0)
addi $t0, $t0, 0x4
beq $t1, $zero, _scanhex_ret
subi $t1, $t1, 0x30
slt $t3, $t1, $t2
bne $t3, $zero, _scanhex_add
subi $t1, $t1, 0x27
_scanhex_add:
sll $v0, $v0, 0x4
add $v0, $v0, $t1
j _scanhex_loop
_scanhex_ret:
#recover return addr from stack
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra









#recover return addr from stack
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra























_test_fin:
addi $s6, $zero, 0x99