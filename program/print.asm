_init:
xor $k0, $k0, $k0
xor $k1, $k1, $k1
xor $s0, $s0, $s0
addi $k0, $k0, 0x10000000
addi $k1, $k1, 0x10000118
addi $s0, $s0, 0x0000000d # ENTER KEY
#string HIT GOOD TRAP
addi $t0, $zero, 0x10002400
addi $t1, $zero, 0x48
sw $t1, ($t0)
addi $t0, $t0, 0x4
addi $t1, $zero, 0x49
sw $t1, ($t0)
addi $t0, $t0, 0x4
addi $t1, $zero, 0x54
sw $t1, ($t0)
addi $t0, $t0, 0x4
addi $t1, $zero, 0x20
sw $t1, ($t0)
addi $t0, $t0, 0x4
addi $t1, $zero, 0x47
sw $t1, ($t0)
addi $t0, $t0, 0x4
addi $t1, $zero, 0x4f
sw $t1, ($t0)
addi $t0, $t0, 0x4
addi $t1, $zero, 0x4f
sw $t1, ($t0)
addi $t0, $t0, 0x4
addi $t1, $zero, 0x44
sw $t1, ($t0)
addi $t0, $t0, 0x4
addi $t1, $zero, 0x20
sw $t1, ($t0)
addi $t0, $t0, 0x4
addi $t1, $zero, 0x54
sw $t1, ($t0)
addi $t0, $t0, 0x4
addi $t1, $zero, 0x52
sw $t1, ($t0)
addi $t0, $t0, 0x4
addi $t1, $zero, 0x41
sw $t1, ($t0)
addi $t0, $t0, 0x4
addi $t1, $zero, 0x50
sw $t1, ($t0)
addi $t0, $t0, 0x4
addi $t1, $zero, 0x0
sw $t1, ($t0)
addi $a0, $zero, 0x10002400
jal _print
j _end

_print:
add $t0, $zero, $a0
_print_start:
lw $a0, ($t0)
beq $a0, $zero, _print_end
add $t1, $zero, $ra
jal _write
add $ra, $zero, $t1
addi $t0, $t0, 0x4
j _print_start
_print_end:
jr $ra


_write:
sw $a0, ($k0)
addi $k0, $k0, 0x4
beq $a0, $s0, _write_newline
beq $k0, $k1, _write_newline
jr $ra
_write_newline:
add $t1, $zero, $ra
jal _newline
add $ra, $zero, $t1
jr $ra


_newline:
xor $k0, $k0, $k0
add $k0, $k0, $k1
addi $k1, $k1, 0x118 # 70 * 4 
jr $ra

_end:
addi $s6, $s6, 0x99