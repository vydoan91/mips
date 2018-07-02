# Lab6_Part 1: Take your matrix multiply program C = AxB and change it to use 8x8 matrices. 
# Don’t read in the matrices,just initialize them in the array declarations. 

# Change the cache size and/or block size if necessary so that when you change the associativity 
# (but not the size – keep the total cache size the same!) between runs that the performance improves (lower miss rate). 

# 1st run: Run it with a cache containing 64 words direct mapped. 
#	Placement policy: Direct Mapping
#	Set size (blocks): 1
#	Number of blocks: 64
#	Cache Block size(words): 1

#	Memory Access Count: 1719
#	Cache hit count: 1190
#	Cache miss count: 529
#	Cache hit rate: 69%


# 2nd run: Run it with 64 words 2-way set associative. 
#	Placement policy: N-way Set Associative
#	Set size (blocks): 2
#	Number of blocks: 64
#	Cache Block size(words): 1

#	Memory Access Count: 1719
#	Cache hit count: 1095
#	Cache miss count: 624
#	Cache hit rate: 64%

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
	la $a2, matrixMul	# load matrixMul's address to a2
	addi $a3, $s0, 0	# s0 = a3 = 8

	jal MatMult		# multiply matrix1 and matrix2

	la $a0, matrixMul	# load matrixMul's address to a0
	addi $a1, $s0, 0	# a1 = s0 = 8
	jal printMatrix		# print matrixMul 
		
return:
	li	$v0, 17		# Return value
	li	$a0, 0
	syscall			# Return
			
printMatrix:
	addi	$t0, $a0, 0	# $t0 = base address of array
	addi	$t1, $a1, 0	# $t1 = matrixSize
		
	la	$a0, newline	# Load the address of the string 
	li	$v0, 4		# Load the system call number
	syscall 

	sll $t2, $t1, 2  	# t2 is row length in bytes
	mul $t3, $t1, $t2	# t3 total bytes in array
	add $t4, $t0, $t2	# t4 terminates row
	add $t5, $t3, $t0	# t5 = address after end of array

colLoop:
	la	$a0, space	# Load the address of the string 
	li	$v0, 4		# Load the system call number
	syscall 

	lw $a0, 0($t0)		# set $a0 to matrix entry
	addi $v0, $zero, 1
	syscall			# print matrix entry
		
	addi $t0, $t0, 4
	bne $t0, $t4, colLoop
		
	# Print newline 
	la	$a0, newline	# Load the address of the string 
	li	$v0, 4		# Load the system call number
	syscall 

	add 	$t4, $t4, $t2
	bne	$t0, $t5, colLoop
		
	jr $ra
		
MatMult:

	addi $t0, $zero 0 	# $t0 = i = 0, init for first loop
Loop1:	
	addi $t1, $zero 0 	# $t1 = j = 0, init for second loop
Loop2:	
	addi $t8, $zero, 0	# $t8 will accumulate Z[i][j], initially 0
	addi $t2, $zero, 0 	# $t2 = k = 0, init for inner loop
Loop3:
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
	bne $a3, $t2, Loop3	# continue Loop3 if k != matrixSize, end of row
		
	mul $t5, $t0, $a3	# $t5 = matrixSize * i 
	addu $t5, $t5, $t1	# $t5 = matrixSize * i + j
	sll $t5, $t5, 2		# $t5 = 4-byte offset of above
	addu $t5, $t5, $a2	# $t5 = address of Z[i][[j]

	sw $t8, 0($t5)		# store value to Z[i][j]

	addiu $t1, $t1, 1	# j = j+1
	bne $a3, $t1, Loop2	# continue Loop2 if j != matrixSize
	addiu $t0, $t0, 1	# i = i+1
	bne $a3, $t0, Loop1	# continue Loop2 if i != matrixSize

	jr $ra
		
.data
matrixSize: .word 8
matrix1: .word	0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,4
matrix2: .word	1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1
matrixMul: .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
newline: .asciiz "\n" 
space:	 .asciiz " "









