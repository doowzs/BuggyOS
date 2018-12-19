ledctr:
sw $ra, ($sp) 
subi $sp, $sp, 0x4
add $t0, $zero, $a0
addi $t1, $zero, 0x1
_ledctr_loop:
beq $t0, $zero, _ledctr_handle
sll $t1, $t1, 0x1
subi $t0, $t0, 0x1
j _ledctr_loop
_ledctr_handle:
addi $a0, $zero, 0x1000D000
addi $a0, $a0, 0x18
addi $a1, $zero, 0x10002A40
sw $a0, ($sp) 
subi $sp, $sp, 0x4
jal strcmp
addi $sp, $sp, 0x4
lw $a0, ($sp)
bne $v0, $zero, _ledctr_off
addi $a1, $zero, 0x10002A50
sw $a0, ($sp) 
subi $sp, $sp, 0x4
jal strcmp
addi $sp, $sp, 0x4
lw $a0, ($sp)
bne $v0, $zero, _ledctr_on
xor $s7, $s7, $t1# default
j _ledctr_ret
_ledctr_off:
nor $t1, $t1, $t1
and $s7, $s7, $t1
j _ledctr_ret
_ledctr_on:
or $s7, $s7, $t1
_ledctr_ret:
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra

