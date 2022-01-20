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

.macro end
li $v0, 10
syscall
.end_macro

.data
s: .space 80
one: .asciiz "1"
zero: .asciiz "0"
newline: .asciiz "\n"

.text
getInt($s0)
sra $s1, $s0, 1
lw $s2, newline

li $t0, 0
for_begin_1:
beq $t0, $s0, for_end_1
	li $v0, 12
	syscall
	move $t3, $v0
	beq $s2, $t3, for_begin_1
	sll $t1, $t0, 2
	sw $t3, s($t1)
addi $t0, $t0, 1
j for_begin_1 # input is over
for_end_1: 

li $t0, 0
for_begin_2:
beq $t0, $s1, for_end_2
	sll $t1, $t0, 2
	lw $t4, s($t1)
	
	sub $t2, $s0, $t0
	subi $t2, $t2, 1
	sll $t2, $t2, 2
	lw $t5, s($t2)
	bne $t4, $t5, is0
addi $t0, $t0, 1
j for_begin_2
for_end_2:

printStr(one)
end

is0:
printStr(zero)
end
