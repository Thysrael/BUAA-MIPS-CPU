#����������Ҫʹ�ñ�������������Ҫ������ô���S�Ĵ����У�����Ҫ��S�Ĵ���Ϊ����
#һ��Ҫע��Ĵ����ĸ������⣬��ҪΪ�˼���ʹ�üĴ�������ʹ���ݷ�������
#��ν��store��load�������ԼĴ���Ϊ���壬�ڴ�Ϊ�����˵�����Ĵ���֮�����move��
#��Ȼ�����ڼĴ����Ĳ���Ҫ��һЩ(�����ڴ��е�����ֻ��ͨ���Ĵ����õ�������ͨ��������)�����ڼ򵥵ĳ��򣬻��Ǿ��������ڴ��ʹ��
#��ַ��һ��1��һ���ֽڣ�һ���ֽ���8λ��Ҳ������λ��16�������������������û�а취ʹ��index�ģ�ֻ��ʹ�õ�ַ����
#16bit����2�ֽڣ�һ���Ĵ�����32λ��Ҳ����4�ֽ�
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

.macro getInt(%r) #ֻ���ǼĴ���
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

# ����ʹ���˺꣬%i Ϊ�洢��ǰ�����ļĴ�����%j Ϊ�洢��ǰ�����ļĴ���
# �� (%i * 8 + %j) * 4 ���� %ans �Ĵ�����
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
getInt($s0) #s0�д������n
getInt($s1) #s1�д������m
li $s2 1 #const = s2 = 1
li $s3 0 #flag = s3 = 0
li $t0, 0 #t0��ѭ������
for_1:
beq $t0, $s1, for_1_end
getInt($t1) #t1��u
getInt($t2) #t2��v
getIndex($t3, $t1, $t2) #�������ַ
sw $s2, array($t3) #����ͼ��ֵ����
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

#�������������
beqz $s3 print
nop
printStr(true)
j main_end

print:
printStr(false)

main_end:
end

DFS:
#������һ��Ƕ��if�ṹ
bne $a1, $s0, work #step == n?
nop
getIndex($t0, $a2, $a0)
lw $t1, array($t0) #t1 = array[start][pos]
bne $t1, $s2, work #edge[start][pos] == 1?
nop
li $s3, 1 #flag = 1
jr $ra #return

work:
#�ȱ���״̬
#�Ƚ���forѭ���� �ڿ�ʼ���ú���֮������ջ
li $t0 1 #t0 = i
for_2:
bgt $t0, $s0, for_2_end #���i��n���ˣ���ѭ������
getIndex($t1, $a0, $t0) #���[pos][i]����
lw $t1, array($t1) #��ʱt1�д�ľ���edge[pos][i]
beqz $t1 for_2_inc #���edge[pos][i]��0�Ļ���Ҫcontinue��
sll $t5, $t0, 2 #����Ϊ�˼���vis[i]����Ե�ַ
lw $t2, vis($t5)
bnez $t2, for_2_inc #���vis[i] == 1��Ҫcontinue��
#�����￪ʼ��ջ����Ϊ��ʱ��i�Ƿ��ϼ���DFS������
#��ջ����ǲ��ܱ����ļĴ��������ǲ���
#�涨ջָ����ָ���һ����Ԫ�ص�
sw $s2, vis($t5) #vis[i] = 1
sw $ra, 0($sp)
inc($sp, -4)
sw $t0, 0($sp)
inc($sp, -4)
sw $a0, 0($sp)
inc($sp, -4)
sw $a1, 0($sp)
inc($sp, -4)
#����������׼���µĲ���
inc($a1, 1) #step++
move $a0, $t0 #pos = i
jal DFS
#��ջ����
inc($sp, 4)
lw $a1, 0($sp)
inc($sp, 4)
lw $a0, 0($sp)
inc($sp, 4)
lw $t0, 0($sp)
inc($sp, 4)
lw $ra, 0($sp)

sll $t5, $t0, 2 #����Ϊ�˼���vis[i]����Ե�ַ
sw $0, vis($t5) #vis[i] = 0
for_2_inc:
inc($t0, 1)
j for_2
for_2_end:
#ֻ���������һ��return
jr $ra


