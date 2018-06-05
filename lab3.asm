# Student: Vy Doan
# Lab 3: Implement the recursive Factorial program from the text in Mars.
# Prompt the user for N and return N!
# Print out the Factorial arguments as they are put on and taken off the stack. 
# After you’ve verified that it is all working properly, upload it to Canvas.

# Question 1:
# Observe carefully the operation of the stack to see how procedure calls work. 
# Observe carefully what things are saved on the stack and why it is necessary to do so. 
# Answer: 
# The program saves argument N and N-1 on the stack until n=0. If n=0, it returns value 1. 
# Then the program restores the argument it previously put on stack, multiplies the return value with 
# restored argument, then returns the value. The process is repeated until it takes off the 
# original argument (input N from user) from the stack, multiplies the argument by the return value 
# from procedure call, and returns value to main.

# Question 2:
# What is the largest factorial that your program can compute? 12 
# Why? Any integer n > 12 has a factorial value larger than what can be shown in a 32-bit integer.

.text
main:	
	# prompt user for input
	li $v0,4 # load service number to print string
	la $a0,prompt # print prompt
	syscall
	# read input
	li $v0,5 # load service number to read integer
	syscall
	move $a1,$v0 # save input to a1
	# calculate factorial
	jal fact # call procedure fact
	move $t0,$v0 # save return value to t0	
	# print output
	li $v0,4 # load service number to print string
	la $a0,newline # print new line
	syscall
	la $a0,output # print output
	syscall
	li $v0,1 # load service call to print integer
	move $a0,$t0 # save t0 to a0 to print
	syscall
	# exit program
	li $v0,10
	syscall
fact:
	# Print out the Factorial arguments as they are put on stack
	li $v0,4 # load service number to print string
	la $a0,newline # print new line
	syscall
	la $a0,putOn # print putOn
	syscall
	li $v0,1 # load service call to print integer
	move $a0,$a1 # print a1 value
	syscall
	# implementation of fact
	addi $sp,$sp,-8 # adjust stack for 2 items
	sw $ra,4($sp) # save the return address
	sw $a1,0($sp) # save the argument n
	slti $t0,$a1,1 # test for n < 1
	beq $t0,$zero,L1 # if n >= 1, go to L1
	addi $v0,$zero,1 # return 1
	addi $sp,$sp,8 # pop 2 items off stack
	jr $ra # return to caller
L1: 
	# L1 implementation
	addi $a1,$a1,-1 # n >= 1: argument gets (n – 1)
	jal fact # call fact with (n –1)
	move $t0,$v0
	lw $a1, 0($sp) # return from jal: restore argument n
	lw $ra, 4($sp) # restore the return address
	addi $sp, $sp, 8 # adjust stack pointer to pop 2 items
	# Print out the Factorial arguments as they are taken off the stack.
	li $v0,4 # load service number to print string
	la $a0,newline # print new line
	syscall
	la $a0,takeOff # print takeOff
	syscall
	li $v0,1 # load service number to print integer
	move $a0,$a1 # print a1 value
	syscall
	# L1 implementation
	mul $v0,$a1,$t0 # return n * fact (n – 1)
	jr $ra # return to the caller
	
.data
prompt: .asciiz "Enter integer N: "
output: .asciiz "N!= "
putOn: .asciiz "Argument put on stack:"
takeOff: .asciiz "Argument taken off stack:"
newline: .asciiz "\n"
