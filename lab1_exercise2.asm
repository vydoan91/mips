# Lab1_Exercise 2:
# Student: Vy Doan
# Program that prompts you for your name and age, and outputs a message 
# that greets you and tells you how old you will be in 4 years.

.text
main:
# Prompt for name to enter
 li $v0,4		# load service number to print string
 la $a0,prompt_name	# load address of string to be printed to a0
 syscall
# Read in name 
 li $v0,8 		# load service number to read string
 la $a0,answer		# put address of answer string in $a0
 lw $a1,alength 	# put length of string in $a1
 syscall 
# Prompt for age (integer) to enter
 li $v0,4 		# load service number to print string 
 la $a0,prompt_age	# load address of string to be printed to a0
 syscall
# Read in age
 li $v0,5		# load service number to read integer
 syscall
 move $t1,$v0 		# Save age to temp1 
 addi $t2,$t1, 4 	# Add age with 4 and save in temp2

# Output greeting and name
 li $v0,4		# load service number to print string
 la $a0,greeting	# load address of string to be printed to a0
 syscall
 la $a0, answer		# load address of string to be printed to a0
 syscall
# Output age
 li $v0,4		# load service number to print string
 la $a0,greeting_age	# load address of string to be printed to a0
 syscall
 li $v0,1		# load service number to print integer
 move $a0, $t2		# save value in t2 to a0
 syscall 
 li $v0,4		# load service number to print string
 la $a0,greeting_age1	# load address of string to be printed to a0
 syscall

# End program
 li $v0, 10 
 syscall 
 
.data
prompt_name: .asciiz "What is your name? "
prompt_age: .asciiz "What is your age?  "
greeting: .asciiz "Hello, "
greeting_age: .asciiz "You will be "
greeting_age1: .asciiz " years old in 4 years."
answer: .space 51 
alength: .word 50
