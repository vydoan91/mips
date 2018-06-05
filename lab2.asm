# Lab 2:
# Student: Vy Doan
# Program that inputs and outputs a 4x4 matrix of single-digit integers

.text
main:
	la $s1,input			# load input's address to s1
	li $t0,4			# t0 is constant 4(number of bytes per rows)
	li $t1,0			# t1 is a counter 
	inputloop:
	# prompt user for inputs
	beq $t0,$t1,exitInputLoop	# if counter = 4, exit inputloop
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
	li $v0,8 			# load service number to read in String
	la $a0,($t2)			# load address to a0
	la $a1,32			# max number of characters to read (32 characters)
	syscall
	j inputloop			# jump to inputloop
	
	exitInputLoop:
	# Output matrix of integers
	li $t2,0			# t2 is a counter for each character/element in input array 
	li $t4,32			# t4 = 32, total elements in input array
	li $t5,0			# t5 is counter for each element of output array
	la $s2,output			# load output's address to s2
	
	outputLoop:
	beq $t2,$t4,exitOutputLoop	# if counter = 32, end of input array, exit loop
	add $t3,$t2,$s1			# t3 = t2 + input's base address s1
	addi $t2,$t2,1			# increment input's counter
	lb $t0,($t3)			# load byte from input array to t0 
	beq $t0,' ',printSpace		# if t0=space, jump to printSpace
	beq $t0,'\n',printNewline	# if t0="\n", jump to printNewline
	addi $t0,$t0,-48		# convert Ascii to int and save in t0	
	
	printInt:
	sll $t1,$t5,2			# output's counter * 4
	addi $t5,$t5,1			# increment output's counter
	add $t1,$t1,$s2			# t1 = output's base address s2 + t1
	sw $t0,0($t1)			# store integer t0 to output array
	lw $a0,0($t1)			# load integer to a0 to print
	li $v0, 1			# load service number to print integer
	syscall	
	j outputLoop			# jump to ouputLoop
	
	printSpace:
	li $v0,4			# load service number to print string
	la $a0,space			# load space's address to a0
	syscall
	j outputLoop			# jump to outputloop

	printNewline:
	li $v0,4			# load service number to print string
	la $a0,newline			# load newline's address to a0
	syscall
	j outputLoop			# jump to outputloop
	
	exitOutputLoop:
.data
input:	.space 32
output: .space 64
prompt1: .asciiz "Input row "
prompt2: .asciiz ": "
space: .asciiz " "
newline: .asciiz "\n"
