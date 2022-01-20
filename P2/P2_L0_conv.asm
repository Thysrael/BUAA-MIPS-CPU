.macro getInt(%des)
	li $v0, 5
	syscall
	move %des, $v0
.end_macro

.macro printStr(%str)
	la $a0, %str
	li $v0, 4
	syscall
.end_macro

.macro end
	li $v0, 10
	syscall
.end_macro

.macro getIndex(%i, %j, %ans)
	sll %ans, %i, 4
	add %ans, %ans, %j
	sll %ans, %ans, 2
.end_macro

.data
f: .word 0:256
h: .word 0:256
space: .asciiz " "
newline: .asciiz "\n"

.text
getInt($s0) # s0 = m1
getInt($s1) # s1 = n1
getInt($s2) # s2 = m2
getInt($s3) # s3 = n2
sub $s4, $s0, $s2
addi $s4, $s4, 1 # s4 = m1 - m2 + 1 
sub $s5, $s1, $s3
addi $s5, $s5, 1 # s5 = n1 - n2 + 1

li $t0, 0 # t0 = i
for_begin_1:
beq $t0, $s0, for_end_1 # i < m1
	li $t1, 0 # t1 = j
	for_begin_2:
	beq $t1, $s1, for_end_2 # j < m2
		getInt($t4)
		getIndex($t0, $t1, $t9) # t9 = add
		sw $t4, f($t9) # f[i][j] = t4
	addi $t1, $t1, 1
	j for_begin_2
	for_end_2:
addi $t0, $t0, 1
j for_begin_1
for_end_1:

li $t0, 0 # t0 = i
for_begin_3:
beq $t0, $s2, for_end_3 # i < m2
	li $t1, 0 # t1 = j
	for_begin_4:
	beq $t1, $s3, for_end_4 # i < n2
		getInt($t5)
		getIndex($t0, $t1, $t9)
		sw $t5, h($t9) # h[i][j] = t5
	addi $t1, $t1, 1
	j for_begin_4
	for_end_4:
addi $t0, $t0, 1
j for_begin_3
for_end_3:

li $t0, 0 # i = 0
for_begin_5:
beq $t0, $s4, for_end_5 # i < m1 - m2 + 1
	li $t1, 0 # j = 0
	for_begin_6:
	beq $t1, $s5, for_end_6 # j < n1 - n2 + 1
		li $a0, 0 # a0 = tmp = 0
		
		li $t2, 0 # k = 0
		for_begin_7:
		beq $t2, $s2, for_end_7 # k < m2
			li $t3, 0 # l = 0
			for_begin_8:
			beq $t3, $s3, for_end_8 # l < n2
				add $t5, $t0, $t2 # t5 = i + k
				add $t6, $t1, $t3 # t6 = j + l
				getIndex($t5, $t6, $t9)
				lw $t4, f($t9) # t4 = f[i + k][j + l]
				getIndex($t2, $t3, $t9)
				lw $t7, h($t9) # t7 = h[k][l]
				mul $t8, $t4, $t7 # t8 = f[i + k][j + l] * h[k][l]
				add $a0, $a0, $t8 # a0 += f[i + k][j + l] * h[k][l]
			addi $t3, $t3, 1
			j for_begin_8
			for_end_8:
			
		addi $t2, $t2, 1
		j for_begin_7
		for_end_7:
		
		li $v0, 1
		syscall
		printStr(space)
		
	addi $t1, $t1, 1
	j for_begin_6
	for_end_6:
	
	printStr(newline)
addi $t0, $t0, 1
j for_begin_5
for_end_5:

end
