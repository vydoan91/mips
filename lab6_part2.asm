# Lab 6_Part 2:
# Now block your matrix multiply routine to do the 8x8 multiply using blocking with four(4) 4x4 matrices (4x4 blocks).  
# Using the same cache size that you used in part 1, again, 
# compare the result using direct-mapped and 2-way set associative. 
# Change the cache size and/or block size if necessary so that the result improves after blocking. 


# 1st run: Run it with a cache containing 64 words direct mapped. 
#	Placement policy: Direct Mapping
#	Set size (blocks): 1
#	Number of blocks: 64
#	Cache Block size(words): 1

#	Memory Access Count: 1911
#	Cache hit count: 1090
#	Cache miss count: 821
#	Cache hit rate: 57%


# 2nd run: Run it with 64 words 2-way set associative. 
#	Placement policy: N-way Set Associative
#	Set size (blocks): 2
#	Number of blocks: 64
#	Cache Block size(words): 1

#	Memory Access Count: 1911
#	Cache hit count: 1133
#	Cache miss count: 778
#	Cache hit rate: 59%

.text
main:
	la $t0, matrixSize	# load matrixSize's address to t0
	lw $s7, 0($t0)		# s7 = 8

	la $a0, matrix1		# load matrix1's address to a0
	addi $a1, $s7, 0	# a1 = s7 = 8
	jal printMatrix		# print matrix1
	
	la $a0, matrix2		# load matrix2's address to a0
	addi $a1, $s7, 0	# a1 = s7 = 8
	jal printMatrix		# print matrix2
		
	la $a0, matrix1		# load matrix1's address to a0
	la $a1, matrix2		# load matrix2's address to a1
	la $a2, matrixMul	# load matrixMul's address to a2
	addi $a3, $s7, 0	# a3 = s7 = 8

	jal MatMult		# multiply matrix1 and matrix2

	la $a0, matrixMul	# load matrixMul's address to a0
	addi $a1, $s7, 0	# a1 = s7 = 8
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
		srl $s3, $a3, 2		# $s3 = matrixSize/4
		addi $t9, $zero, 4	# $t9 = 4, to end inner loops

		addi $s0, $zero, 0	# $s0 = Bi = 0, init for first block loop
LoopB1:
		addi $s1, $zero, 0	# $s1 = Bj = 0, init for second block loop
LoopB2:
		addi $s2, $zero, 0	# $s2 = Bk = 0, init for third block loop
LoopB3:
		addi $t0, $zero 0 	# $t0 = i = 0, init for first loop
Loop1:	
		add $s4, $s0, $t0	# $s4 = Bi+i
		addi $t1, $zero 0 	# $t1 = j = 0, init for second loop
Loop2:	
		add $s5, $s1, $t1	# $s5 = Bj+j
		
		mul $t5, $s4, $a3	# $t5 = matrixSize * (Bi+i)
		add $t5, $t5, $s5	# $t5 = matrixSize * (Bi+i) + (Bj+j)
		sll $t5, $t5, 2		# $t5 = 4-byte offset of above
		addu $t5, $t5, $a2	# $t5 = address of Z[Bi+i][Bj+j]
		lw $t8, 0($t5)		# $t8 will accumulate Z[Bi+i][Bj+j], initially from memory
		
		addi $t2, $zero 0 	# $t2 = k = 0, init for inner loop
Loop3:
		add $s6, $s2, $t2	# $s6 = Bk+k
		
		mul $t6, $s4, $a3	# $t6 = matrixSize * (Bi+i)
		addu $t6, $t6, $s6	# $t6 = matrixSize * (Bi+i) + (Bk+k)
		sll $t6, $t6, 2		# $t6 = 4-byte offset of above
		addu $t6, $t6, $a0	# $t6 = address of X[Bi+i][[Bk+k]

		lw $t6, 0($t6)		# $t6 = X[Bi+i][Bk+k]

		mul $t7, $s6, $a3	# $t7 = matrixSize * (Bk+k)
		addu $t7, $t7, $s5	# $t7 = matrixSize * (Bk+k) + (Bj+j)
		sll $t7, $t7, 2		# $t7 = 4-byte offset of above
		addu $t7, $t7, $a1	# $t7 = address of Y[Bk+k][[Bj+j]

		lw $t7, 0($t7)		# $t7 = Y[Bk+k][[Bj+j]

		mul $t7, $t6, $t7	# $t7 = X[i][k]*Y[k][j]
		add $t8, $t8, $t7       # add product to Z[i][j]

		addiu $t2, $t2, 1	# k = k+1
		bne $t2, $t9, Loop3	# continue Loop3 if k != 4, end of row in subblock
endLoop3:		
		sw $t8, 0($t5)		# store value to Z[i][j]

		addiu $t1, $t1, 1	# j = j+1
		bne $t1, $t9, Loop2	# continue Loop2 if j != 4
endLoop2:
		addiu $t0, $t0, 1	# i = i+1
		bne $t0, $t9, Loop1	# continue Loop2 if i != 4
endLoop1:
		addiu $s2, $s2, 4	# Bk = Bk+4
		bne $s2, $a3, LoopB3	# continue LoopB3 if Bk != matrixSize/4
endLoopB3:
		addiu $s1, $s1, 4	# Bj = Bj+4
		bne $s1, $a3, LoopB2	# continue LoopB2 if Bj != matrixSize/4
endLoopB2:
		addiu $s0, $s0, 4	# Bi = Bi+4
		bne $s0, $a3, LoopB1	# continue LoopB1 if Bi != matrixSize/4
endLoopB1:	

		jr $ra
		

.data
matrixSize:	.word	8
matrix1:	.word	0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,4
matrix2:	.word	1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1
matrixMul:	.word	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
newline:	.asciiz		"\n" 
space:		.asciiz		" "
