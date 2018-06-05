# Lab1_Exercise 3:
# Student: Vy Doan
# Program that plays the first dozen or so notes of Twinkle Twinkle

.text
main:
 li $v0,33		# load service call 33
 li $a1,550		# Set length of the tone
 li $a2,31		# set instrument
 li $a3,120		# set volume
 la $t2,array		# load address of array to t2
 li $t0,14		# t0 is constant 14 (number of notes)
 li $t1,0		# t1 is a counter
loop:
 beq $t1,$t0,end	# if t1==t0, end loop
 add $t3, $t1, $t1    	# double t1 and save to t3
 add $t3, $t3, $t3   	# double t3 again (now 4x)
 add $t4, $t2, $t3    	# combine the two components of the address
 addi $t1, $t1,1	# add 1 to t1 (increment counter)
 lw $a0, 0($t4)
 syscall
 j loop			# jump back to the top
end:
 
.data
 array:	.word 72,72,67,67,69,69,67,65,65,64,64,62,62,72	# array of notes
