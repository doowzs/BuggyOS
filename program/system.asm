_init:
addi $k0, $zero, 0x10000000
addi $k1, $zero, 0x10000118
addi $sp, $zero, 0x1000fffc
addi $s0, $zero, 0x0000000d # ENTER KEY
addi $s1, $zero, 0x0000000a # NEW LINE
addi $s2, $zero, 0x100020D0 # frame end
addi $s3, $zero, 0x100020D4 # last key
# clear screen
addi $a0, $zero, 0x10000000
addi $a1, $zero, 0x100020D0
jal _clear
# print hello message
addi $a0, $zero, 0x10002100
jal print
j main

main:
_read:
xor $t8, $t8, $t8
addi $t9, $zero, 0x20000
jal _prompt
_read_loop:
lw $a0, ($s2) # read this key
lw $t0, ($s3) # load last key
sw $a0, ($s3) # save this key
addi $t8, $t8, 1
bne $t8, $t9, _read_judge
xor $t8, $t8, $t8
jal _cursor
j _read_loop
_read_judge:
beq $a0, $zero, _read_loop  # key == 0
beq $a0, $t0, _read_loop    # key == last
# if =0x8, goto backspace
# otherwise, print the character
addi $t0, $zero, 0x8
beq $a0, $t0, _read_backspace
_read_write:
jal _write
j _read_end
_read_backspace:
jal _backspace
_read_end:
j _read_loop

print:
sw $ra, ($sp)
subi $sp, $sp, 0x4
add $t0, $zero, $a0
print_loop:
lw $a0, ($t0)
beq $a0, $zero, print_ret
sw $t0, ($sp)
subi $sp, $sp, 0x4
jal _write
addi $sp, $sp, 0x4
lw $t0, ($sp)
addi $t0, $t0, 0x4
j print_loop
print_ret:
jal _newline
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra

handle:
sw $ra, ($sp)
subi $sp, $sp, 0x4
addi $a0, $zero, 0x10006000
jal print
jal _prompt
_handle_ret:
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra

_cursor:
lw $t0, ($k0)
beq $t0, $zero, _cursor_0
j _cursor_1
_cursor_0:
addi $t0, $zero, 0x5f # print "_"
j _cursor_write
_cursor_1:
xor $t0, $t0, $t0     # print " "
_cursor_write:
sw $t0, ($k0)
jr $ra

_write:
sw $ra, ($sp)
subi $sp, $sp, 0x4
sw $zero, ($k0) # clear cursor
beq $a0, $s0, _write_prompt
beq $a0, $s1, _write_newline
sw $a0, ($k0)
addi $k0, $k0, 0x4
beq $k0, $k1, _write_newline
j _write_ret
_write_newline:
jal _newline
j _write_ret
_write_prompt:
jal handle
_write_ret:
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra

_backspace:
sw $ra, ($sp)
subi $sp, $sp, 0x4
subi $k1, $k1, 0x110 # prompt cannot be deleted
beq $k0, $k1, _backspace_ret
sw $zero, ($k0) # clear cursor
subi $k0, $k0, 0x4
sw $zero, ($k0)
_backspace_ret:
addi $k1, $k1, 0x110
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra

_prompt:
sw $ra, ($sp)
subi $sp, $sp, 0x4
jal _newline
# print "#"
addi $a0, $zero, 0x23
jal _write
# print " "
xor $a0, $a0, $a0
jal _write
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra

_newline:
sw $ra, ($sp)
subi $sp, $sp, 0x4
beq $k1, $s2, _newline_moveup
add $k0, $zero, $k1
addi $k1, $k1, 0x118 # 70 * 4 
j _newline_ret
_newline_moveup:
jal _moveup
subi $k0, $s2, 0x118
add $k1, $zero, $s2
_newline_ret:
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra

_moveup:
sw $ra, ($sp)
subi $sp, $sp, 0x4
addi $t0, $zero, 0x10000000 # start of line 00
addi $t1, $zero, 0x10000118 # start of line 01
_moveup_line:
lw $t2, ($t1)
sw $t2, ($t0)
addi $t0, $t0, 0x4
addi $t1, $t1, 0x4
bne $t1, $s2, _moveup_line
add $a0, $zero, $t0
add $a1, $zero, $t1
jal _clear
_moveup_ret:
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra

_clear:
sw $ra, ($sp)
subi $sp, $sp, 0x4
_clear_loop:
sw $zero, ($a0)
addi $a0, $a0, 0x4
bne $a0, $a1, _clear_loop
_clear_ret:
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra
