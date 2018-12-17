_init:
addi $k0, $zero, 0x10000000
addi $k1, $zero, 0x10000118
addi $gp, $zero, 0x1000D000
addi $sp, $zero, 0x1000FFFC
addi $s0, $zero, 0x0000000D # ENTER KEY
addi $s1, $zero, 0x0000000A # NEW LINE
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
addi $a1, $zero, 0x1
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
xor $a1, $a1, $a1
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
##### cmd analyzers #####
addi $a1, $zero, 0x10002800
sw $a0, ($sp) 
subi $sp, $sp, 0x4
jal strcmp
addi $sp, $sp, 0x4
lw $a0, ($sp)
bne $v0, $zero, _cmd_01_hello
addi $a1, $zero, 0x100029A0
sw $a0, ($sp) 
subi $sp, $sp, 0x4
jal strcmp
addi $sp, $sp, 0x4
lw $a0, ($sp)
bne $v0, $zero, _cmd_02_meme
addi $a1, $zero, 0x10002A00
sw $a0, ($sp) 
subi $sp, $sp, 0x4
addi $a2, $zero, 0x4
jal strncmp
addi $sp, $sp, 0x4
lw $a0, ($sp)
bne $v0, $zero, _cmd_03_fibo
addi $a1, $zero, 0x100029C0
sw $a0, ($sp) 
subi $sp, $sp, 0x4
jal strcmp
addi $sp, $sp, 0x4
lw $a0, ($sp)
bne $v0, $zero, _cmd_restart
addi $a1, $zero, 0x100029E0
sw $a0, ($sp) 
subi $sp, $sp, 0x4
jal strcmp
addi $sp, $sp, 0x4
lw $a0, ($sp)
bne $v0, $zero, _cmd_clear
j _cmd_fail
##### cmd handlers #####
_cmd_01_hello:
addi $a0, $zero, 0x10002820
jal print
j _handler_ret
_cmd_02_meme:
addi $a0, $zero, 0x10006000
jal print
j _handler_ret
_cmd_03_fibo:
addi $a0, $zero, 0x1000D000
addi $a0, $a0, 0x14
jal scanhex
add $a0, $zero, $v0
jal fibonacci
add $a0, $zero, $v0
jal printhex
add $a0, $zero, $gp
jal print
j _handler_ret
_cmd_restart:
j _init
_cmd_clear:
addi $a0, $zero, 0x10000000
addi $a1, $zero, 0x100020D0
jal _clear
j _handler_ret
_cmd_fail:
addi $a0, $zero, 0x10002900
jal print
_handler_ret:
jal _prompt
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra

strcmp:
sw $ra, ($sp) 
subi $sp, $sp, 0x4
add $t0, $zero, $a0
add $t1, $zero, $a1
addi $v0, $zero, 1 # default: return 1
_cmp_loop:
lw $a0, ($t0)
lw $a1, ($t1)
addi $t0, $t0, 0x4
addi $t1, $t1, 0x4
bne $a0, $a1, _cmp_false
beq $a0, $zero, _cmp_fin
j _cmp_loop
_cmp_false:
xor $v0, $v0, $v0 # failed compare
_cmp_fin:
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra

strncmp:
sw $ra, ($sp) 
subi $sp, $sp, 0x4
add $t0, $zero, $a0
add $t1, $zero, $a1
add $t2, $zero, $a2
addi $v0, $zero, 1
_cmpn_loop:
lw $a0, ($t0)
lw $a1, ($t1)
addi $t0, $t0, 0x4
addi $t1, $t1, 0x4
subi $t2, $t2, 1
bne $a0, $a1, _cmpn_false
beq $a0, $zero, _cmpn_fin
beq $t2, $zero, _cmpn_fin
j _cmpn_loop
_cmpn_false:
xor $v0, $v0, $v0
_cmpn_fin:
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra


scanhex:
sw $ra, ($sp) 
subi $sp, $sp, 0x4
xor $v0, $v0, $v0
xor $t2, $t2, $t2
addi $t2, $t2, 0x10
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
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra

fibonacci:
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
_fido_ret:
add $v0, $zero, $t1
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra

printhex:
sw $ra, ($sp) 
subi $sp, $sp, 0x4
addi $gp, $zero, 0x1000D020 #end of print
add $t0, $zero, $a0  #value to be printed
addi $t1, $zero, 0xf #mask
addi $t2, $zero, 0xa
sw $zero, ($gp)
_printhex_loop:
subi $gp, $gp, 0x4
and $t3, $t1, $t0
srl $t0, $t0, 0x4
slt $t4, $t3, $t2
bne $t4, $zero, _printhex_char
addi $t3, $t3, 0x27
_printhex_char:
addi $t3, $t3, 0x30
sw $t3, ($gp)
addi $t4, $zero, 0x1000D000
bne $gp, $t4, _printhex_loop
addi $sp, $sp, 0x4
lw $ra, ($sp)
jr $ra

_cursor:
lw $t0, ($k0)
beq $t0, $zero, _cursor_0
j _cursor_1
_cursor_0:
addi $t0, $zero, 0x5F # print "_"
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
beq $a0, $s0, _write_handle
beq $a0, $s1, _write_newline
beq $a1, $zero, _write_skip_input
sw $a0, ($gp)
addi $gp, $gp, 0x4
_write_skip_input:
sw $a0, ($k0)
addi $k0, $k0, 0x4
beq $k0, $k1, _write_newline
j _write_ret
_write_newline:
jal _newline
j _write_ret
_write_handle:
sw $zero, ($gp)
jal _newline
addi $a0, $zero, 0x1000D000
jal print
addi $a0, $zero, 0x1000D000
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
subi $gp, $gp, 0x4
sw $zero, ($gp)
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
xor $a1, $a1, $a1
jal _write
# print " "
addi $a0, $zero, 0x20
xor $a1, $a1, $a1
jal _write
addi $gp, $zero, 0x1000D000 # reset string pointer here
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
