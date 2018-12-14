_init:
xor $k0, $k0, $k0
xor $k1, $k1, $k1
xor $s0, $s0, $s0
addi $k0, $k0, 0x10000000
addi $k1, $k1, 0x10000118
addi $s0, $s0, 0x0000000d # ENTER KEY
j _read

_read:
lw $a0, 0x100020D0
bne $a0, $zero, _write
j _read

_write:
sw $a0, ($k0)
addi $k0, $k0, 0x4
beq $a0, $s0, _newline
beq $k0, $k1, _newline
j _read

_newline:
xor $k0, $k0, $k0
add $k0, $k0, $k1
addi $k1, $k1, 0x118 # 70 * 4 
j _read