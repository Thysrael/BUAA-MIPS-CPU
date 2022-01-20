#除了数组需要使用变量，其他的重要变量最好存在S寄存器中，起码要以S寄存器为根本
#一定要注意寄存器的覆盖问题，不要为了减少使用寄存器，而使数据发生覆盖
#所谓的store，load，都是以寄存器为主体，内存为客体的说法，寄存器之间就用move了
#显然，对于寄存器的操作要多一些(比如内存中的数据只能通过寄存器得到，不能通过立即数)，对于简单的程序，还是尽量减少内存的使用
#地址的一个1是一个字节，一个字节是8位，也就是两位的16进制数，汇编里数组是没有办法使用index的，只能使用地址计算
#16bit就是2字节，一个寄存器是32位，也就是4字节
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

.macro getInt(%r) #只能是寄存器
li $v0, 5 
syscall
move %r, $v0
.end_macro

.macro inc(%r, %num)
add %r, %r, %num
.end_macro

.macro end
li $v0, 10
syscall
.end_macro

# 这里使用了宏，%i 为存储当前行数的寄存器，%j 为存储当前列数的寄存器
# 把 (%i * 8 + %j) * 4 存入 %ans 寄存器中
.macro  getIndex(%ans, %i, %j)
    sll %ans, %i, 3             # %ans = %i * 8
    add %ans, %ans, %j          # %ans = %ans + %j
    sll %ans, %ans, 2           # %ans = %ans * 4
.end_macro

.data
array: .space 256
vis: .space 32
true: .asciiz "1"
false: .asciiz "0"

.text
main:
getInt($s0) #s0中储存的是n
getInt($s1) #s1中储存的是m
li $s2 1 #const = s2 = 1
li $s3 0 #flag = s3 = 0
li $t0, 0 #t0是循环变量
for_1:
beq $t0, $s1, for_1_end
getInt($t1) #t1是u
getInt($t2) #t2是v
getIndex($t3, $t1, $t2) #计算出地址
sw $s2, array($t3) #无向图赋值两遍
getIndex($t3, $t2, $t1)
sw $s2, array($t3)
inc($t0, 1)
j for_1
for_1_end:

li $t0, 4
sw $s2, vis($t0)#vis[1] = 1

li $a0, 1
li $a1, 1 #DFS(1, 1)
jal DFS #DFS(int pos, int step)

#后面是输出部分
beqz $s3 print
nop
printStr(true)
j main_end

print:
printStr(false)

main_end:
end

DFS:
#上面是一个嵌套if结构
bne $a1, $s0, work #step == n?
nop
getIndex($t0, $a2, $a0)
lw $t1, array($t0) #t1 = array[start][pos]
bne $t1, $s2, work #edge[start][pos] == 1?
nop
li $s3, 1 #flag = 1
jr $ra #return

work:
#先保存状态
#先进行for循化， 在开始调用函数之间在入栈
li $t0 1 #t0 = i
for_2:
bgt $t0, $s0, for_2_end #如果i比n大了，就循环结束
getIndex($t1, $a0, $t0) #获得[pos][i]坐标
lw $t1, array($t1) #此时t1中存的就是edge[pos][i]
beqz $t1 for_2_inc #如果edge[pos][i]是0的话就要continue了
sll $t5, $t0, 2 #这是为了计算vis[i]的相对地址
lw $t2, vis($t5)
bnez $t2, for_2_inc #如果vis[i] == 1就要continue了
#从这里开始入栈，因为此时的i是符合继续DFS条件的
#入栈入得是不受保护的寄存器，不是参数
#规定栈指针是指向第一个空元素的
sw $s2, vis($t5) #vis[i] = 1
sw $ra, 0($sp)
inc($sp, -4)
sw $t0, 0($sp)
inc($sp, -4)
sw $a0, 0($sp)
inc($sp, -4)
sw $a1, 0($sp)
inc($sp, -4)
#下面两步是准备新的参数
inc($a1, 1) #step++
move $a0, $t0 #pos = i
jal DFS
#出栈过程
inc($sp, 4)
lw $a1, 0($sp)
inc($sp, 4)
lw $a0, 0($sp)
inc($sp, 4)
lw $t0, 0($sp)
inc($sp, 4)
lw $ra, 0($sp)

sll $t5, $t0, 2 #这是为了计算vis[i]的相对地址
sw $0, vis($t5) #vis[i] = 0
for_2_inc:
inc($t0, 1)
j for_2
for_2_end:
#只会在最后有一个return
jr $ra


