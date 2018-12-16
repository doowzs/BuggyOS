_init:
xor $k0, $k0, $k0
xor $k1, $k1, $k1
xor $s0, $s0, $s0
addi $k0, $k0, 0x10000000
addi $k1, $k1, 0x10000118
addi $s0, $s0, 0x0000000d # ENTER KEY
j _read

_read:
lw $a0, 0x100020D0 # read this key
lw $t0, 0x100020D4 # load last key
sw $a0, 0x100020D4 # save this key
beq $a0, $zero, _read  # key != 0
beq $a0, $t0, _read    # key != last
# if =0x8, goto backspace
# otherwise, print the character
add $t0, $zero, 0x8
beq $a0, $t0, _backspace
j _write

_write:
sw $a0, ($k0)
addi $k0, $k0, 0x4
beq $a0, $s0, _newline
beq $k0, $k1, _newline
j _read

_backspace:
subi $k1, $k1, 0x118
beq $k0, $k1, _backspace_ret
subi $k0, $k0, 0x4
sw $zero, ($k0)
_backspace_ret:
addi $k1, $k1, 0x118
j _read

_newline:
xor $k0, $k0, $k0
add $k0, $k0, $k1
addi $k1, $k1, 0x118 # 70 * 4 
j _read
