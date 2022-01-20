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
getInt($s0)
getInt($s1)
getInt($s2)
getInt($s3)
sub $s4, $s0, $2
addi $s4, $s4, 1
sub $s5, $s1, $s3
addi $s5, $s5, 1

li $t0, 0
for_begin_1:
beq $t0, $s0, for_end_1
	li $t1, 0
	for_begin_2:
	beq $t1, $s1, for_end_2
		getInt($t8)
		getIndex($t0, $t1, $t9)
		sw $t8, f($t9)
	addi $t1, $t1, 1
	j for_begin_2
	for_end_2:
addi $t0, $t0, 1
j for_begin_1
for_end_1:

li $t0, 0
for_begin_3:
beq $t0, $s2, for_end_3
	li $t1, 0
	for_begin_4:
	beq $t1, $s3, for_end_4
		getInt($t8)
		getIndex($t0, $t1, $t9)
		sw $t8, h($t9)
	addi $t1, $t1, 1
	j for_begin_4
	for_end_4:
addi $t0, $t0, 1
j for_begin_3
for_end_3:

li $t0, 0
for_begin_5:
beq $t0, $s4, for_end_5
	li $t1, 0
	for_begin_6:
	beq $t1, $s5, for_end_6
		li $a0, 0
		
		li $t2, 0
		for_begin_7:
		beq $t2, $s2, for_end_7
			li $t3, 0
			for_begin_8:
			beq $t3, $s3, for_end_8
				add $t5, $t0, $t2
				add $t6, $t1, $t3
				getIndex($t5, $t6, $t9)
				lw $t4, f($t9)
				getIndex($t2, $t3, $t9)
				lw $t7, h($9)
				mul $t8, $t4, $t7
				add $a0, $a0, $t8
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