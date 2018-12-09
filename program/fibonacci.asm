sub $v0, $v0, $v0
sub $v1, $v1, $v1
addi $v0, $v0, 1
addi $v1, $v1, 1
fibb:
sw $v0, 0x10000000
add $v0, $v0, $v1
lw $v1, 0x10000000
j fibb
