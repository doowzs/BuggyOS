xor $t0, $t0, $t0
jal test1
jal test2

test1:
addi $t0, $t0, 0x5
jr $ra

test2:
addi $t0, $t0, 0xa
jr $ra