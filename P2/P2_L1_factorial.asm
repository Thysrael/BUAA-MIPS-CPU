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

.eqv MOD, 100

.data
ans: .space 120000

.text
getInt($s0) # s0 = n
li $s1, 1 # s1 = len = 1
li $s2, 100 # s2 = 10
li $s5, 10

li $t0, 1 # t0 = i = 1
sll $t9, $t0, 2
sw $t0, ans($t9)

li $t0, 2
for_begin_1:
bgt $t0, $s0 for_end_1
	li $t1, 1 # t1 = j = 1
	for_begin_2:
	bgt $t1, $s1, for_end_2
		sll $t9, $t1, 2
		lw $t8, ans($t9) # t8 = ans[j]
		mul $t8, $t8, $t0 # t8 = ans[j] * i
		sw $t8, ans($t9) # ans[j] = t8
	addi $t1, $t1, 1
	j for_begin_2
	for_end_2: 
	
	li $t1, 1 # t1 = j = 1
	for_begin_3:
	ble $t1, $s1, for_statement_3
	sll $t9, $t1, 2
	lw $t8, ans($t9) # t8 = ans[j]
	bnez $t8, for_statement_3
	j for_end_3
		for_statement_3:
		sll $t9, $t1, 2
		lw $t8, ans($t9) # t8 = ans[j]
		#div $t8, MOD 
		#mflo $t2 # t2 = ans[j] / 10
		div $t2, $t8, MOD
		addi $t3, $t1, 1 # t3 = j + 1
		sll $t9, $t3, 2
		lw $t8, ans($t9) # t8 = ans[j + 1]
		add $t8, $t8, $t2 # t8 = ans[j + 1] + ans[j] / 10
		sw $t8, ans($t9) # ans[j + 1] = ans[j + 1] + ans[j] / 10
		sll $t9, $t1, 2
		lw $t8, ans($t9) # t8 = ans[j]
		li $t7, MOD
		div $t8, $t7
		mfhi $t8 # t8 = ans[j] % 10
		sw $t8, ans($t9) # ans[j] = ans[j] % 10
	addi $t1, $t1, 1
	j for_begin_3
	for_end_3:
	
	subi $s1, $t1, 1 # len = j - 1
	
	addi $s3, $s1, 1 # s3 = cur = len + 1
addi $t0, $t0, 1
j for_begin_1
for_end_1:

move $t0 $s1 
for_begin_4:
beqz $t0, for_end_4
	sll $t9, $t0, 2
	lw $t8, ans($t9)
	bge $t8, $s5 else_1
	beq $t0, $s1, else_1
		printInt($zero)
	else_1:
		printInt($t8)
	if_end_1:
subi $t0, $t0, 1
j for_begin_4
for_end_4:
end
