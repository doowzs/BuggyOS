sub $v0, $v0, $v0
addi $v0, $v0, 5
ori $v0, $v0, 8
xori $v0, $v0, 5

add $v1, $v1, $v0
xor $v1, $v1, $v1

nor $v1, $v0, $v1
slt $a0, $v0, $v1
slt $a1, $v1, $v0