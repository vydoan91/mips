# Exercise 2:
# Author: Vy Doan
# Program to it prompts you for your name and age, and outputs a message 
# that greets you and tells you how old you will be in 4 years.
.text
main:
# Prompt for name to enter
 li $v0,4 
 la $a0,prompt_name 
 syscall

# Read the name 
 li $v0,8 
 la $a0,answer 		#put address of answer string in $a0
 lw $a1,alength 	#put length of string in $a1
 syscall
 
# Prompt for age (integer) to enter
 li $v0,4 
 la $a0,prompt_age 
 syscall

# Read the age
 li $v0,5
 syscall
 move $t1,$v0 	# Save age to temp 1 
 addi $t2,$t1, 4 # Add age with 4 and save in temp2

# Output greeting and name
 li $v0,4
 la $a0,greeting
 syscall
 la $a0, answer
 syscall

# Output age
 li $v0,4
 la $a0,greeting_age
 syscall
 
 li $v0,1
 move $a0, $t2
 syscall
 
 li $v0,4
 la $a0,greeting_age1
 syscall

# End program
 li $v0, 10 
 syscall 
.data
prompt_name: .asciiz "What is your name? "
prompt_age: .asciiz "What is your age?  "
greeting: .asciiz "Hello, "
greeting_age: .asciiz "You will be "
greeting_age1: .asciiz " years old in 4 years"
answer: .space 51 
alength: .word 50
