xor $v0, $v0, $v0
xor $v1, $v1, $v1
addi $v1, $v1, 5

loop:
addi $v0, $v0, 1
beq $v0, $v1, fin
j loop

fin:
xor $v0, $v0, $v0

loop2:
addi $v0, $v0, 1
bne $v0, $v1, loop2
j fin2

fin2:
xor $v0, $v0, $v0