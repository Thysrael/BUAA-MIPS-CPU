.macro printStr(%str)
la $a0 %str
li $v0 4
syscall
.end_macro

.macro printInt(%num)
lw $a0 %num
li $v0 1
syscall
.end_macro

.macro getInt(%address)
li $v0 5 
syscall
sw $v0 %address
.end_macro

.macro end
li $v0 10
syscall
.end_macro

.data
year: .space 4
space: .asciiz " "
newline: .asciiz "\n"
true: .asciiz "1"
false: .asciiz "0"

.text
getInt(year)
lw $t1, year
li $t2, 4
div $t1, $t2
mfhi $t3
beqz $t3 else_1
nop
printStr(false)
j end_1

else_1:#能被4整除
li $t2, 100
div $t1, $t2
mfhi $t3
beqz $t3 else_2
nop
printStr(true)#能被4整除不能被100整除
j end_1

else_2:
li $t2, 400
div $t1, $t2
mfhi $t3
beqz $t3 else_3
nop
printStr(false)
j end_1

else_3:#能被400整除
printStr(true)
j end_1

end_1:
end