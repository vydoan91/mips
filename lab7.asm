# Lab 7: In this lab we want to simulate request level parallelism, RLP, 
# and multithreading (like that used/found in Map-Reduce). 

# To do this, take your matrix multiply program from Lab#4 and do the inner 
# loop using a subroutine call. Pass the parameters necessary per the MIPS 
# subroutine calling conventions. Arguments in a0, a1, a2, a3 and the stack 
# if there are more than 4 arguments needed. Results in v0, v1, etc.  
# (the subroutine call is simulating the instantiation of one of the inner loops on a separate processor)  
# Just like there were 16 iterations of the inner loop, there are now 16 subroutine calls in your program.
 
# To simulate the Reduce function, sum all of the elements of the result matrix into one value and output 
# this value as a result. 

.text
main:
	la $t0, matrixSize	# load matrixSize's address to t0
	lw $s0, 0($t0)		# s0 = 8

	la $a0, matrix1		# load matrix1's address to a0
	addi $a1, $s0, 0	# a1 = s0 = 8
	jal printMatrix		# print matrix 1
		
	la $a0, matrix2		# load matrix2's address to a0
	addi $a1, $s0, 0	# a1 = s0 = 8
	jal printMatrix		# print matrix 2
		
	la $a0, matrix1		# load matrix1's address to a0
	la $a1, matrix2		# load matrix2's address to a1
	la $a2, matrixResult	# load matrixResult's address to a2
	addi $a3, $s0, 0	# s0 = a3 = 8

	jal MatMult		# multiply matrix1 and matrix2

	la $a0, matrixResult	# load matrixResult's address to a0
	addi $a1, $s0, 0	# a1 = s0 = 8
	jal printMatrix		# print matrixResult 
	
	la $a0, newline	# Load the address of the string 
	li $v0, 4		# Load the system call number
	syscall
	
	j Reduce		# jump to reduce function
		
return:
	li $v0, 17		# Return value
	li $a0, 0
	syscall			# Return
			
printMatrix:
	addi $t0, $a0, 0	# $t0 = base address of array
	addi $t1, $a1, 0	# $t1 = matrixSize
		
	la $a0, newline		# Load the address of the string 
	li $v0, 4		# Load the system call number
	syscall 

	sll $t2, $t1, 2  	# t2 is row length in bytes
	mul $t3, $t1, $t2	# t3 total bytes in array
	add $t4, $t0, $t2	# t4 terminates row
	add $t5, $t3, $t0	# t5 = address after end of array

colLoop:
	la $a0, space		# Load the address of the string 
	li $v0, 4		# Load the system call number
	syscall 

	lw $a0, 0($t0)		# set $a0 to matrix entry
	addi $v0, $zero, 1
	syscall			# print matrix entry
		
	addi $t0, $t0, 4
	bne $t0, $t4, colLoop
		
	la $a0, newline		# Load the address of the string 
	li $v0, 4		# Load the system call number
	syscall 

	add 	$t4, $t4, $t2
	bne	$t0, $t5, colLoop
		
	jr $ra
		
MatMult:
	addi $t0, $zero, 0 	# $t0 = i = 0, init for first loop
Loop:	
	addi $t1, $zero, 0 	# $t1 = j = 0, init for second loop
	
	move $s1, $ra		# store $ra address to s1
	jal Subroutine1		# call Subroutine1
	move $ra, $s1		# restore $ra address
	
	addiu $t0, $t0, 1	# i = i+1
	bne $a3, $t0, Loop	# continue Loop if i != matrixSize
	
	jr $ra
	
Subroutine1:	
	addi $t8, $zero, 0	# $t8 will accumulate Z[i][j], initially 0
	addi $t2, $zero, 0 	# $t2 = k = 0, init for inner loop
	
	move $s2, $ra		# store $ra address to s2
	jal Subroutine2		# call Subroutine2
	move $ra, $s2		# restore $ra address
	
	addiu $t1, $t1, 1	# j = j+1
	bne $a3, $t1, Subroutine1	# continue Subroutine1 if j != matrixSize
	
	jr $ra
	
Subroutine2:
	mul $t3, $t0, $a3	# $t3 = matrixSize * i 
	addu $t3, $t3, $t2	# $t3 = matrixSize * i + k
	sll $t3, $t3, 2		# $t3 = 4-byte offset of above
	addu $t3, $t3, $a0	# $t3 = address of x[i][[k]

	lw $t3, 0($t3)		# $t3 = x[j][k]

	mul $t4, $t2, $a3	# $t4 = matrixSize * k 
	addu $t4, $t4, $t1	# $t4 = matrixSize * k + j
	sll $t4, $t4, 2		# $t4 = 4-byte offset of above
	addu $t4, $t4, $a1	# $t4 = address of y[k][[j]

	lw $t4, 0($t4)		# $t4 = y[k][j]

	mul $t7, $t3, $t4	# $t8 = x[i][k]*y[k][j]
	add $t8, $t8, $t7       # add product to Z[i][j]

	addiu $t2, $t2, 1	# k = k+1
	bne $a3, $t2, Subroutine2	# continue Subroutine2 if k != matrixSize, end of row
		
	mul $t5, $t0, $a3	# $t5 = matrixSize * i 
	addu $t5, $t5, $t1	# $t5 = matrixSize * i + j
	sll $t5, $t5, 2		# $t5 = 4-byte offset of above
	addu $t5, $t5, $a2	# $t5 = address of Z[i][[j]
	sw $t8, 0($t5)		# store value to Z[i][j]

	jr $ra
	
Reduce:
	li $s0, 0	# counter s0=0
  	li $a0, 0	# reduce result = a0 = 0
  	la $t0, matrixResult	# load matrixResult address to t0
	forsum:    
  		bge $s0, 16, end_forsum   # jump to end_forsum if s0 > 16 (end of array) 
  		lw $t1,0($t0)  # Load the number from array 
  		addu $a0, $a0, $t1 # Compute the sum

  		addi $t0,$t0,4	# t0 = t0 + 4. move to next element in array
  		addi $s0,$s0,1	# increment counter      
  		j forsum	# repeat forsum	
	end_forsum:
  		li $v0,1	# service 1 is print integer
  		syscall		# Print sum
		
.data
matrixSize: .word 4
matrix1: .word	9,8,7,6,5,4,3,2,1,0,1,2,3,4,5,6
matrix2: .word	1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1
matrixResult: .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
newline: .asciiz "\n" 
space:	 .asciiz " "









