#Implement the recursive Factorial program from the text in Mars. 
#If you get it from the risc-v edition you must first modify it to use 
#lw and sw instead of ld and sd so that it will run on MARS and don't 
#forget to modify the multipliers used to handle byte addressing. 
#Prompt the user for N and return N! (Look at the Fibonacci or other 
#programs out in Mars land if you need some scaffolding to help you get started.) 
#Print out the Factorial arguments as they are put on and taken off the stack. 
#Observe carefully the operation of the stack to see how procedure calls 
#(and in this case recursive procedure calls) work. Observe carefully what 
#things are saved on the stack and why it is necessary to do so. What is the 
#largest factorial that your program can compute? Why? After you’ve verified 
#that it is all working properly, upload it to Canvas

.text
main:
li $v0,4	# load service number to print string
la $a0,prompt	# print prompt
syscall
li $v0,5	# load service number to read integer
syscall
move $a0,$v0	# save input to a0
jal fact 	# execute fact procedure
move $t0,$v0
li $v0,1
move $a0,$t0
syscall

fact:
addi $sp,$sp,-8 # adjust stack for 2 items
sw $ra,4($sp) # save the return address
sw $a0,0($sp) # save the argument n
slti $t0,$a0,1 # test for n < 1
beq $t0,$zero,L1 # if n >= 1, go to L1
addi $v0,$zero,1 # return 1
addi $sp,$sp,8 # pop 2 items off stack
jr $ra # return to caller

L1: 
addi $a0,$a0,-1 # n >= 1: argument gets (n – 1)
jal fact # call fact with (n –1)
lw $a0,0($sp) # return from jal: restore argument n
lw $ra,4($sp) # restore the return address
addi $sp,$sp, 8 # adjust stack pointer to pop 2 items
mul $v0,$a0,$v0 # return n * fact (n – 1)
jr $ra # return to the caller

.data
prompt: .asciiz "Enter a number N: "
input: .asciiz "Factorial of N is: "