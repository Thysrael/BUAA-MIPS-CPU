.macro printStr(%str)
la $a0, %str
li $v0, 4
syscall
.end_macro

.macro printInt(%num)#只能是寄存器
move $a0, %num
li $v0, 1
syscall
.end_macro

.macro getInt(%address) #只能是地址或者标签
li $v0, 5 
syscall
sw $v0, %address
.end_macro
 
.macro end
li $v0, 10
syscall
.end_macro

.data
n: .space 4
m: .space 4
size: .space 4
array: .space 10000
tmp: .space 4
space: .asciiz " "
newline: .asciiz "\n"

.text
getInt(n) #获取n
getInt(m) #获取m
#获取size = m * n
lw $t1, n 
lw $t2, m
mult $t1, $t2
mflo $t3
sw $t3, size 

lw $s0, size #把size存在s0中
li $t0, 0
for_1:
slt $t1, $t0, $s0 #如果i比size小，就把t3设为1，不然就是0
beqz $t1, for_end_1
nop
li $v0, 5
syscall
sll $t2, $t0, 2
sw $v0, array($t2)
add $t0, $t0, 1
j for_1 

for_end_1:

#为逆序遍历做准备
sll $s1, $s0, 2
addi $s1, $s1, -4

#for_2
li $t0, 0
for_2:
slt $t1, $t0, $s0
beqz $t1, for_end_2
nop 
#for_2 statement
sll $t1, $t0, 2
sub $t1, $s1, $t1
lw $t2, array($t1)

#到此时t2中就存储倒叙遍历的元素
beqz $t2 for_last #如果是0的话，就可以continue了，但是不是跳回一开始，还得i++呢
nop

#关于元素不是0的时候的处理
lw $t3, size
sub $t3, $t3, $t0 #此时t3是size - i
sub $t3, $t3, 1 #此时t3是size - i - 1

#计算x坐标
lw $s2, m
div $t3, $s2
mflo $t3
add $t3, $t3, 1
printInt($t3)
printStr(space)

#计算列坐标
lw $t3, size
sub $t3, $t3, $t0 #此时t3是size - i
sub $t3, $t3, 1 #此时t3是size - i - 1

div $t3, $s2
mfhi $t3
add $t3, $t3, 1
printInt($t3)
printStr(space)

#输出元素
printInt($t2)
printStr(newline) 

for_last:
add $t0, $t0, 1
j for_2

for_end_2:
end

