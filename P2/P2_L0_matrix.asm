.macro printStr(%str)
la $a0, %str
li $v0, 4
syscall
.end_macro

.macro getInt(%num)
li $v0, 5
syscall
move %num, $v0
.end_macro

.macro getIndex(%i, %j, %ans)
sll %ans, %i, 3
add %ans, %ans, %j
sll %ans, %ans, 2
.end_macro

.macro end
li $v0, 10
syscall
.end_macro

.data
A: .space 256
B: .space 256
C: .space 256
space: .asciiz " "
newline: .asciiz "\n"

.text
getInt($s0)

li $t0, 0
for_begin_1:
	beq $t0, $s0, for_end_1
		li $t1, 0
		for_begin_2:
		beq $t1, $s0, for_end_2
		getInt($t3)
		getIndex($t0, $t1, $t6)
		sw $t3, A($t6)
		addi $t1, $t1, 1
		j for_begin_2
	for_end_2:	
	addi $t0, $t0, 1
	j for_begin_1
for_end_1:

li $t0, 0
for_begin_3:
beq $t0, $s0, for_end_3
	li $t1, 0
	for_begin_4:
	beq $t1, $s0, for_end_4
		getInt($t4)
		getIndex($t0, $t1, $t7)
		sw $t4, B($t7)
	addi $t1, $t1, 1
	j for_begin_4
	for_end_4:
addi $t0, $t0, 1 
j for_begin_3
for_end_3:

li $t0, 0
for_begin_5:
beq $t0, $s0, for_end_5
	li $t1, 0
	for_begin_6:
	beq $t1, $s0, for_end_6
		li $t5, 0
		li $t2, 0
		for_begin_7:
		beq $t2, $s0, for_end_7
			getIndex($t0, $t2, $t6)
			lw $t3, A($t6)
			getIndex($t2, $t1, $t7)
			lw $t4, B($t7)
			mult $t3, $t4
			mflo $t9
			add $t5, $t5, $t9
			getIndex($t0, $t1, $t8)
			sw $t5, C($t8)
		addi $t2, $t2, 1
		j for_begin_7
		for_end_7:
	addi $t1, $t1, 1
	j for_begin_6
	for_end_6:
addi $t0, $t0, 1
j for_begin_5
for_end_5:

li $t0, 0
for_begin_8:
beq $t0, $s0, for_end_8
	li $t1, 0
	for_begin_9:
	beq $t1, $s0, for_end_9
		getIndex($t0, $t1, $t8)
		lw $a0, C($t8)
		li $v0, 1
		syscall
		printStr(space)
	addi $t1, $t1, 1
	j for_begin_9
	for_end_9:
	printStr(newline)
addi $t0, $t0, 1
j for_begin_8
for_end_8:

end
