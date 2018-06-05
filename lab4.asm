# Student: Vy Doan
# Lab 4: Program that reads in a 4x4 integer matrix to allow the user to
# input two 4x4 matrices by row, then multiply the integer matrices and print out the results by
# row.
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
multiply: # need argument a1,a2,a3 to execute this procedure				
	li $t1, 4 		# $t1 = 4 (row-size and loop end)
	li $s0, 0 		# i = 0; initialize 1st for loop
	L1: 
		li $s1, 0 		# j = 0; inititalize 2nd for loop
	L2: 
		li $s2, 0 		# k = 0; initialize 3rd for loop
		sll $t2, $s0, 2 	# $t2 = i * 4 (size of row of c)
		addu $t2, $t2, $s1 	# $t2 = i * size(row) + j
		sll $t2, $t2, 2 	# $t2 = byte offset of c[i][j]
		addu $t2, $a2, $t2 	# $t2 = byte address of c[i][j]
		lw $t4, 0($t2) 		# $t4 = c[i][j]
	L3:
		sll $t0, $s2, 2 	# $t0 = k * 4 (size of row of b)
		addu $t0, $t0, $s1 	# $t0 = k * size(row) + j
		sll $t0, $t0, 2 	# $t0 = byte offset off [k][j]
		addu $t0, $a1, $t0 	# $t0 = byte address of b[k][j]
		lw $t5, 0($t0) 		# $t5 = b[k][j]
		
		sll $t0, $s0, 2 	# $t0 = i * 4 (size of row of a)
		addu $t0, $t0, $s2 	# $t0 = i * size(row) + k
		sll $t0, $t0, 2 	# $t0 = byte offset of [i][k]
		addu $t0, $a3, $t0 	# $t0 = byte address of a[i][k]
		lw $t6, 0($t0) 		# $t6 = a[i][k]
		
		mul $t5, $t6, $t5 	# $t5 = a[i][k] * b[k][j]
		add $t4, $t4, $t5 	# $t4 = c[i][j] + a[i][k] * b[k][j]
		
		addiu $s2, $s2, 1 	# $k = k + 1
		bne $s2, $t1, L3 	# if (k != 4) go to loop3
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
