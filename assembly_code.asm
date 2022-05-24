.data
i_1: .word 0
s_1: .word 0
_t_1: .word 0
_t_2: .word 0
_t_3: .word 0
j_3: .word 0
_t_4: .word 0
_t_5: .word 0
_t_6: .word 0
_t_7: .word 0
_t_8: .word 0
_t_9: .word 0
_t_10: .word 0
_t_11: .word 0
_t_12: .word 0
_t_13: .word 0
_t_14: .word 0
_t_15: .word 0
_t_16: .word 0
_t_17: .word 0
k_6: .word 0
_t_18: .word 0
_t_19: .word 0
_t_20: .word 0
_t_21: .word 0
_t_22: .word 0
_t_23: .word 0
arr_8: .word 0
sum_8: .word 0
_t_24: .word 0
b_8: .word 0
_t_25: .word 0
l_9: .word 0
_t_26: .word 0
_t_27: .word 0
_t_28: .word 0
_t_29: .word 0
_t_30: .word 0
_t_31: .word 0
_t_32: .word 0
_t_33: .word 0
_t_34: .word 0
_t_35: .word 0
_t_36: .word 0
_t_37: .word 0
_t_38: .word 0
_t_39: .word 0
_t_40: .word 0
.text 
.globl main 
main:
li $2, 5
syscall
sw $2, i_1
li $8, 0
sw $8, _t_1
lw $8, _t_1
sw $8, s_1
label1:
li $8, 4
sw $8, _t_2
lw $8, i_1
lw $9, _t_2
blt $8, $9, label2
li $8, 0
sw $8, _t_3
j label3
label2:
li $8, 1
sw $8, _t_3
label3:
lw $8, _t_3
beqz $8, label4
li $8, 0
sw $8, _t_4
lw $8, _t_4
sw $8, j_3
label5:
li $8, 5
sw $8, _t_5
lw $8, j_3
lw $9, _t_5
blt $8, $9, label6
li $8, 0
sw $8, _t_6
j label7
label6:
li $8, 1
sw $8, _t_6
label7:
lw $8, _t_6
beqz $8, label8
j label9
label10:
lw $8, j_3
sw $8, _t_7
lw $8, j_3
li $9, 1
addi $10, $8, 1
sw $10, j_3
j label5
label9:
li $8, 3
sw $8, _t_8
lw $8, j_3
lw $9, _t_8
beq $8, $9, label11
li $8, 0
sw $8, _t_9
j label12
label11:
li $8, 1
sw $8, _t_9
label12:
lw $8, _t_9
beqz $8, label13
li $8, 3
sw $8, _t_10
lw $8, i_1
lw $9, _t_10
beq $8, $9, label14
li $8, 0
sw $8, _t_11
j label15
label14:
li $8, 1
sw $8, _t_11
label15:
lw $8, _t_11
beqz $8, label16
li $2, 1
lw $4, i_1
syscall
li $8, 10
sb $8, _t_12
li $2, 11
lb $4, _t_12
syscall
j label8
j label17
label16:
label17:
j label18
label13:
li $8, 1
sw $8, _t_13
lw $8, j_3
lw $9, _t_13
beq $8, $9, label19
li $8, 0
sw $8, _t_14
j label20
label19:
li $8, 1
sw $8, _t_14
label20:
lw $8, _t_14
beqz $8, label21
j label10
j label18
label21:
lw $8, s_1
lw $9, j_3
add $10, $8, $9
sw $10, _t_15
lw $8, _t_15
sw $8, s_1
label18:
j label10
label8:
li $8, 1
sw $8, _t_16
lw $8, i_1
lw $9, _t_16
add $10, $8, $9
sw $10, _t_17
lw $8, _t_17
sw $8, i_1
j label1
label4:
li $8, 1
sw $8, _t_18
lw $8, _t_18
sw $8, k_6
label22:
li $8, 5
sw $8, _t_19
lw $8, k_6
lw $9, _t_19
blt $8, $9, label23
li $8, 0
sw $8, _t_20
j label24
label23:
li $8, 1
sw $8, _t_20
label24:
lw $8, _t_20
beqz $8, label25
j label26
label27:
lw $8, k_6
sw $8, _t_21
lw $8, k_6
li $9, 1
addi $10, $8, 1
sw $10, k_6
j label22
label26:
lw $8, s_1
lw $9, k_6
add $10, $8, $9
sw $10, _t_22
lw $8, _t_22
sw $8, s_1
j label27
label25:
li $8, 5
sw $8, _t_23
li $8, 1
lw $9, _t_23
mul $8, $8, $9
li $10, 4
mul $8, $8, $10
li $2, 9
move $4, $8
syscall
sw $2, arr_8
li $8, 0
sw $8, _t_24
lw $8, _t_24
sw $8, sum_8
li $8, 0
sw $8, _t_25
lw $8, _t_25
sw $8, b_8
li $8, 0
sw $8, _t_26
lw $8, _t_26
sw $8, l_9
label28:
li $8, 5
sw $8, _t_27
lw $8, l_9
lw $9, _t_27
blt $8, $9, label29
li $8, 0
sw $8, _t_28
j label30
label29:
li $8, 1
sw $8, _t_28
label30:
lw $8, _t_28
beqz $8, label31
j label32
label33:
lw $8, l_9
sw $8, _t_29
lw $8, l_9
li $9, 1
addi $10, $8, 1
sw $10, l_9
j label28
label32:
lw $8, l_9
li $9, 4
mul $10, $8, $9
sw $10, _t_30
lw $8, _t_31
lw $9, _t_30
add $10, $8, $9
sw $10, _t_32
lw $8, arr_8
sw $8, _t_33
lw $8, _t_33
lw $9, _t_32
add $10, $8, $9
sw $10, _t_33
lw $8, l_9
lw $11, _t_33
sw $8, ($11)
lw $8, l_9
li $9, 4
mul $10, $8, $9
sw $10, _t_34
lw $8, _t_35
lw $9, _t_34
add $10, $8, $9
sw $10, _t_36
lw $8, arr_8
sw $8, _t_37
lw $8, _t_37
lw $9, _t_36
add $10, $8, $9
sw $10, _t_37
lw $8, _t_37
lw $8, ($8)
sw $8, b_8
lw $8, sum_8
lw $9, b_8
add $10, $8, $9
sw $10, _t_38
lw $8, _t_38
sw $8, sum_8
j label33
label31:
li $2, 1
lw $4, s_1
syscall
li $8, 10
sb $8, _t_39
li $2, 11
lb $4, _t_39
syscall
li $2, 1
lw $4, sum_8
syscall
li $8, 10
sb $8, _t_40
li $2, 11
lb $4, _t_40
syscall
li $v0, 10
syscall

