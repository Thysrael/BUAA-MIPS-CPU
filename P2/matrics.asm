.macro printStr(%str)
la $a0, %str
li $v0, 4
syscall
.end_macro

.macro printInt(%num)#ֻ���ǼĴ���
move $a0, %num
li $v0, 1
syscall
.end_macro

.macro getInt(%address) #ֻ���ǵ�ַ���߱�ǩ
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
getInt(n) #��ȡn
getInt(m) #��ȡm
#��ȡsize = m * n
lw $t1, n 
lw $t2, m
mult $t1, $t2
mflo $t3
sw $t3, size 

lw $s0, size #��size����s0��
li $t0, 0
for_1:
slt $t1, $t0, $s0 #���i��sizeС���Ͱ�t3��Ϊ1����Ȼ����0
beqz $t1, for_end_1
nop
li $v0, 5
syscall
sll $t2, $t0, 2
sw $v0, array($t2)
add $t0, $t0, 1
j for_1 

for_end_1:

#Ϊ���������׼��
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

#����ʱt2�оʹ洢���������Ԫ��
beqz $t2 for_last #�����0�Ļ����Ϳ���continue�ˣ����ǲ�������һ��ʼ������i++��
nop

#����Ԫ�ز���0��ʱ��Ĵ���
lw $t3, size
sub $t3, $t3, $t0 #��ʱt3��size - i
sub $t3, $t3, 1 #��ʱt3��size - i - 1

#����x����
lw $s2, m
div $t3, $s2
mflo $t3
add $t3, $t3, 1
printInt($t3)
printStr(space)

#����������
lw $t3, size
sub $t3, $t3, $t0 #��ʱt3��size - i
sub $t3, $t3, 1 #��ʱt3��size - i - 1

div $t3, $s2
mfhi $t3
add $t3, $t3, 1
printInt($t3)
printStr(space)

#���Ԫ��
printInt($t2)
printStr(newline) 

for_last:
add $t0, $t0, 1
j for_2

for_end_2:
end

