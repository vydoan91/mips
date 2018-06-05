# Lab 5a:  Take your matrix multiply program from Lab#4 and 
# unroll the inner loop completely (no iterations of the inner loop)

# Compare the program length, register usage and conceptual complexity. 
# Answer: 
# Length: lab 5a is longer than lab 5b because lab 5a's inner loop is completely unrolled
# and uses more registers than lab 5b's
# Register usage: lab 5a's unrolled loop uses more registers than lab 5b's. In lab 5a, I run 
# out of temporary registers, so I used s registers instead.
# Conceptual complexity: lab 5a with unrolled loop performs better than lab 5b because loop is 
# completely unrolled in lab 5a
.text
main:
	# Prompt for user input for 1st array
	li $v0,4 		# load service number to print string
	la $a0,prompt3 		# print prompt3
	syscall
	la $a0,newline		# print new line
	syscall
	la $s2,matrix1		# load matrix1's address to s2
	jal matrix		# call matrix procedure
	# prompt user input for 2nd array
	li $v0,4		# load service number to print string
	la $a0,prompt4		# print prompt4
	syscall
	la $a0,newline		# print new line
	syscall
	la $s2,matrix2		# load matrix2's address to s2
	jal matrix
	la $a3, matrix1 	# base address for matrix1 loaded into $a3
	la $a1, matrix2 	# base address for matrix2 loaded into $a1
	la $a2, outputMatrix 	# base address for outputMatrix loaded into $a2
	jal multiply		# call multiply procedure
	jal printResult		# call printResult procedure
	# exit program
	li $v0,10		
	syscall
	
matrix: # need address of matrix1 or 2 in s2 to execute this procedure
	la $s1,input			# load input's address to s1
	li $t0,4			# t0 is constant 4(number of bytes per rows)
	li $t1,0			# t1 is a counter 
	inputloop:
		# prompt user for inputs
		li $v0,4			# load service number to print string
		la $a0,prompt1			# print prompt1
		syscall
		li $v0,1			# load service number to print enteger
		add $t3,$t1,1			# counter t1 + 1 (row number)
		move $a0,$t3			# print out row number
		syscall
		li $v0,4			# load service number to print string
		la $a0,prompt2			# print promp2
		syscall
		# Save user's input to input array
		sll $t2,$t1,3			# counter t1 * 8
		add $t2,$t2,$s1			# address = t2 + input's base address
		addi $t1,$t1,1			# increment counter
		# Read user's input as string
		li $v0,8 			# load service number to read in String
		la $a0,($t2)			# load address to a0
		la $a1,32			# max number of characters to read (32 characters)
		syscall
		beq $t0,$t1,exitInputLoop	# if counter = 4, exit inputloop
		j inputloop			# jump to inputloop	
	exitInputLoop:	
		# save input(string) as integers to output array
		li $t2,0			# t2 is a counter for each character/element in input array 
		li $t4,32			# t4 = 32, total elements in input array
		li $t5,0			# t5 is counter for each element of output array	
	outputLoop:
		beq $t2,$t4,exitOutputLoop	# if counter = 32, end of input array, exit loop
		add $t3,$t2,$s1			# t3 = t2 + input's base address s1
		addi $t2,$t2,1			# increment input's counter
		lb $t0,($t3)			# load byte from input array to t0 
		beq $t0,' ',outputLoop		# if t0=space, jump to printSpace
		beq $t0,'\n',outputLoop		# if t0="\n", jump to printNewline
		addi $t0,$t0,-48		# convert Ascii to int and save in t0	
		sll $t1,$t5,2			# output's counter * 4
		addi $t5,$t5,1			# increment output's counter
		add $t1,$t1,$s2			# t1 = output's base address s2 + t1
		sw $t0,0($t1)			# store integer t0 to output array
		j outputLoop			# jump to ouputLoop	
	exitOutputLoop:
		jr $ra
multiply: 
# Unrolling inner loop (L3) completely in C language
#	void mm (int c[][], int a[][], int b[][])
#    int i, j ,k;
#    for (i = 0; i != 4; i = i + 1)
#        for (j = 0; j != 4; j = j + 1)
#                c[i][j] = a[i][0]*b[0][j] + a[i][1]*b[1][j] + a[i][2]*b[2][j] + a[i][3]*b[3][j]
					
	li $t1, 4 		# $t1 = 4 (row-size and loop end)
	li $s0, 0 		# i = 0; initialize 1st for loop
	L1: 
		li $s1, 0 		# j = 0; inititalize 2nd for loop
	L2: 
		sll $t2, $s0, 2 	# $t2 = i * 4 (size of row of c)
		addu $t2, $t2, $s1 	# $t2 = i * size(row) + j
		sll $t2, $t2, 2 	# $t2 = byte offset of c[i][j]
		addu $t2, $a2, $t2 	# $t2 = byte address of c[i][j]
		lw $t4, 0($t2) 		# $t4 = c[i][j]
	#L3(unrolling completely):
		li $s2, 0 		# k = 0; initialize 3rd for loop
		li $s3, 1		# s3 = k+1
		li $s4, 2
		li $s5, 3 
		
		sll $t0, $s2, 2 	# $t0 = k * 4 (size of row of b)
		sll $t5, $s0, 2 	# $t5 = i * 4 (size of row of a)	
		sll $t6, $s3, 2 	# $t6 = k * 4 (size of row of b)
		sll $t7, $s0, 2 	# $t7 = i * 4 (size of row of a)	
		sll $t8, $s4, 2 	# $t8 = k * 4 (size of row of b)
		sll $t9, $s0, 2 	# $t9 = i * 4 (size of row of a)
		sll $s6, $s5, 2 	# $s6 = k * 4 (size of row of b)
		sll $s7, $s0, 2 	# $s7 = i * 4 (size of row of a)
		
		addu $t0, $t0, $s1 	# $t0 = k * size(row) + j
		addu $t5, $t5, $s2 	# $t5 = i * size(row) + k
		addu $t6, $t6, $s1 	# $t6 = k * size(row) + j
		addu $t7, $t7, $s3 	# $t7 = i * size(row) + k		
		addu $t8, $t8, $s1 	# $t8 = k * size(row) + j
		addu $t9, $t9, $s4 	# $t9 = i * size(row) + k	
		addu $s6, $s6, $s1 	# $s6 = k * size(row) + j
		addu $s7, $s7, $s5 	# $s7 = i * size(row) + k
		
		sll $t0, $t0, 2 	# $t0 = byte offset off [k][j]
		sll $t5, $t5, 2 	# $t5 = byte offset of [i][k]
		sll $t6, $t6, 2 	# $t6 = byte offset off [k][j]
		sll $t7, $t7, 2 	# $t7 = byte offset of [i][k]
		sll $t8, $t8, 2 	# $t8 = byte offset off [k][j]
		sll $t9, $t9, 2 	# $t9 = byte offset of [i][k]
		sll $s6, $s6, 2 	# $s6 = byte offset off [k][j]
		sll $s7, $s7, 2 	# $s7 = byte offset of [i][k]
		
		addu $t0, $a1, $t0 	# $t0 = byte address of b[k][j]
		addu $t5, $a3, $t5 	# $t5 = byte address of a[i][k]
		addu $t6, $a1, $t6 	# $t6 = byte address of b[k][j]
		addu $t7, $a3, $t7 	# $t7 = byte address of a[i][k]
		addu $t8, $a1, $t8 	# $t8 = byte address of b[k][j]
		addu $t9, $a3, $t9 	# $t9 = byte address of a[i][k]
		addu $s6, $a1, $s6 	# $s6 = byte address of b[k][j]
		addu $s7, $a3, $s7 	# $s7 = byte address of a[i][k]
		
		lw $t0, 0($t0) 		# $t0 = b[k][j]
		lw $t5, 0($t5) 		# $t5 = a[i][k]
		lw $t6, 0($t6) 		# $t6 = b[k][j]
		lw $t7, 0($t7) 		# $t7 = a[i][k]
		lw $t8, 0($t8) 		# $t8 = b[k][j]
		lw $t9, 0($t9) 		# $t9 = a[i][k]
		lw $s6, 0($s6) 		# $s6 = b[k][j]
		lw $s7, 0($s7) 		# $s7 = a[i][k]
	
		mul $t0, $t5, $t0 	# $t0 = a[i][k] * b[k][j]
		add $t4, $t4, $t0 	# $t4 = c[i][j] + a[i][k] * b[k][j]
		mul $t6, $t7, $t6 	# $t6 = a[i][k] * b[k][j]
		add $t4, $t4, $t6 	# $t4 = c[i][j] + a[i][k] * b[k][j]
		mul $t8, $t9, $t8 	# $t8 = a[i][k] * b[k][j]
		add $t4, $t4, $t8 	# $t4 = c[i][j] + a[i][k] * b[k][j]
		mul $s6, $s7, $s6 	# $s6 = a[i][k] * b[k][j]
		add $t4, $t4, $s6 	# $t4 = c[i][j] + a[i][k] * b[k][j]
		
		sw $t4, 0($t2) 		# c[i][j] = $t4 
		addi $s1, $s1, 1 	# $j = j + 1
		bne $s1, $t1,L2 	# if (j != 4) go to loop2
		addiu $s0, $s0,1 	# $i = i + 1
		bne $s0,$t1,L1 		# if (i != 4) go to L1 	
		jr $ra
printResult:
	li $v0,4	# load service number to print string
	la $a0,prompt5	# print prompt5
	syscall
	la $a0,newline	# print new line
	syscall	
	li $t2,0	# byte offset of outputMatrix
	li $t3,64	# total bytes of outputMatrix
	printRow:
		li $t0,4	# t0 = number of elements each row (max 4)
		li $t1,0	# counter to count elements each row	
	printNumber:
		li $v0,1	# load service number to print integer
		add $t4,$t2,$a2	# t4 = offset + outputMatrix's base address
		lw $a0,0($t4)	# load 1st integer to a0 to print
		syscall
		addi $t1,$t1,1	# increment counter
		addi $t2,$t2,4	# offset = offset + 4
		beq  $t2,$t3,exitPrintloop	# if offset = 64, exit loop
		beq $t0,$t1,printNewline	# if number of element = 4, print new line
		j printSpace	# else, jump to printSpace
	printSpace:
		li $v0,4	# load service number to print string
		la $a0,space	# print space
		syscall
		j printNumber
	printNewline:
		li $v0,4	# load service number to print string
		la $a0,newline	# print newline
		syscall
		j printRow	# jump to printRow
	exitPrintloop:
		jr $ra
.data
matrix1: .space 64 
matrix2: .space 64 
outputMatrix: .space 64
prompt1: .asciiz "Input row "
prompt2: .asciiz ": "
prompt3: .asciiz "__________Matrix #1________"
prompt4: .asciiz "__________Matrix #2________"
prompt5: .asciiz "___Matrix multiplication___"
space: .asciiz " "
newline: .asciiz "\n"
input:	.space 32
