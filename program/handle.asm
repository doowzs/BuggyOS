handle:
#save return addr in stack
sw $ra, ($sp) 
subi $sp, $sp, 0x4

#find the start of buffer
add $t0, $zero, $k1
#2 lines up
subi $t0, $t0, 0x118
subi $t0, $t0, 0x118
#omit '# '
addi $t0, $t0, 0x8

#set pram1 strcmp: buffer
addi $a0, $zero, $t0


##### cmd analyzers #####

### cmd #1: "hello" ###
#set pram2 strcmp: (cmd #1:)"hello"
addi $a1, $zero, 0x10002800
jal strcmp
#valid cmd is handled
bne $v0, $zero, _cmd_01_handle
### end ##

#<<< new cmd anayzer here

#recover return addr from stack
_handler_fin:
lw $ra, ($sp)
jr $ra

##### cmd handlers #####

### cmd #1: "hello" ###
_cmd_01_handle:
addi $a0, $zero, 0x10002800
jal print
j _handler_fin
### end ###

#<<< new cmd handler here
