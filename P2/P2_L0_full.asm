.macro getInt(%des)
	li $v0, 5
	syscall
	move %des, $v0
.end_macro

.macro end
	li $v0, 10
	syscall
.end_macro

.macro printInt(%src)
	move $a0, %src
	li $v0, 1
	syscall
.end_macro

.macro push(%src)
	sw %src, ($sp)
	subi $sp, $sp, 4
.end_macro

.macro pop(%des)
	addi $sp, $sp, 4
	lw %des, ($sp)
.end_macro

.macro printStr(%str)
	la $a0, %str
	li $v0, 4
	syscall
.end_macro

.data
vis: .word 0:8
path: .word 0:8
space: .asciiz " "
enter: .asciiz "\n"

.text
li $s2, 1 # s2 = 1
getInt($s0) # s0 = n
li $s1, 0 # s1 = step
move $a0, $s1
jal DFS

end

DFS:
	push($ra)
	push($s1)
	push($t0) # t0 = i
	move $s1, $a0
	bne $s1, $s0, else_1
		li $t0, 0
		for_begin_1:
		beq $t0, $s0, for_end_1
			sll $t9, $t0, 2
			lw $t8, path($t9)
			printInt($t8)
			printStr(space)
		addi $t0, $t0, 1
		j for_begin_1
		for_end_1:
		printStr(enter)
		j if_end_1
	else_1:
		li $t0, 1
		for_begin_2:
		bgt $t0, $s0, for_end_2
			sll $t9, $t0, 2
			lw $t8, vis($t9)
			bnez $t8, if_end_2
				sw $s2, vis($t9)
				sll $t9, $s1, 2
				sw $t0, path($t9)
				move $a0, $s1
				addi $a0, $a0, 1
				jal DFS
				sll $t9, $t0, 2
				sw $zero, vis($t9)
			if_end_2:
		addi $t0, $t0, 1
		j for_begin_2
		for_end_2: 
	if_end_1:
	pop($t0)
	pop($s1)
	pop($ra)
	jr $ra