.macro getIndex(%i, %j, %ans)
	sll %ans, %i, 4
	add %ans, %ans, %j
	sll %ans, %ans, 2
.end_macro

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

.data
puzzle: .word 1:256
vis: .word 0:256
dirx: 
.word 0:1
.word 1:1 
.word 0:1 
.word -1:1
diry: 
.word 1:1
.word 0:1
.word -1:1
.word 0:1

.text
getInt($s0) # s0 = n;
getInt($s1) # s1 = m;

li $t0, 1
for_begin_1:
bgt $t0, $s0, for_end_1
	li $t1, 1
	for_begin_2:
	bgt $t1, $s1, for_end_2
		getIndex($t0, $t1, $t9)
		getInt($t8)
		sw $t8, puzzle($t9) # cin>>puzzle[i][j]
	addi $t1, $t1, 1
	j for_begin_2
	for_end_2:
addi $t0, $t0, 1
j for_begin_1
for_end_1:

getInt($s2) # s2 = sx
getInt($s3) # s3 = sy
getInt($s4) # s4 = ex
getInt($s5) # s5 = ey
move $s6, $zero # s6 = cnt
li $s7, 4 # s7 = 4
li $t7, 1 # t7 = 1

getIndex($s2, $s3, $t9)
sw $t7, vis($t9) #vis[i][j] = 1
move $a0, $s2 
move $a1, $s3
jal DFS
printInt($s6)
end

DFS:
	push($ra)
	push($t1) # t1 = curx
	push($t2) # t2 = cury
	push($t3) # t3 = tmpx
	push($t4) # t4 = tmpy
	push($t9)
	push($t0)
	move $t1, $a0 
	move $t2, $a1
	
	bne $t1, $s4, else_1
	bne $t2, $s5, else_1
		addi $s6, $s6, 1 # cnt++
		j if_end_1
	else_1:
		li $t0, 0
		for_begin_3:
		beq $t0, $s7, for_end_3
			sll $t9, $t0, 2
			lw $t8, dirx($t9)
			add $t3, $t1, $t8 # t3 = tmpx = curx + dirx[i]
			lw $t8, diry($t9)
			add $t4, $t2, $t8 # t4 = tmpy = cury + diry[i]
			getIndex($t3, $t4, $t9)
			lw $t8, vis($t9) # t8 = vis[tmpx][tmpy]
			bnez $t8, else_2
			lw $t8, puzzle($t9) # t8 = puzzle[tmpx][tmpy]
			bnez $t8, else_2
				sw $t7, vis($t9) # vis[tmpx][tmpy] = 1
				move $a0, $t3
				move $a1, $t4
				jal DFS
				sw $zero, vis($t9) # vis[tmpx][tmpy] = 0
			else_2:
		addi $t0, $t0, 1
		j for_begin_3
		for_end_3:
		
	if_end_1:
	pop($t0)
	pop($t9)
	pop($t4)
	pop($t3)
	pop($t2)
	pop($t1)
	pop($ra)
	jr $ra