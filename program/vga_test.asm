xor $v0, $v0, $v0
xor $v1, $v1, $v1
addi $v1, $v1, 0x10000000

print:
sw $v0, ($v1)
addi $v0, $v0, 0x1
addi $v1, $v1, 0x4
j print
