.data

Y1:		.word 13, 101, 79, 23, 154, 4, 11, 38, 88, 45, 17, 94, 62, 1
lenY1:		.word 14
Y1Address: 	.word 0x10010000
comp:		.word 0x8000
stmt:		.asciz "The sorted array is: \n"
space:		.asciz " "

.text 

main:
addi s6, zero, 2		# size of bits needed to shift to 2^n
lw s3, comp			# stores the sign bit
lw s0, Y1Address		# stores address of the Y1 array
lw s4, lenY1			# stores length of array
sll s11, s4, s6			# stores offset of array word size for printing
add s11, s0, s11		# stop point for print loop

quickSort:
add a1, zero, zero		# left = 0
addi a4, s4, -1			# right = length - 1
jal qSort			# qSort(left, right)

li a7, 4			# loads instruction in a7
la a0, stmt			# stores stmt address in a0
ecall				# performes instruction
	
print:
li a7, 1			# loads instruction in a7
lw a0, 0(s0)			# stores s0[0] in a0
ecall				# performs instruction
li a7, 4			# loads instruction in a7
la a0, space			# stores space address in a0
ecall				# performs instruction
addi s0, s0, 4			# Makes s0 the left address
sub t0, s0, s11			# t0 = current postion in array - size of array
and t2, t0, s3			# t0 && sign bit
beq t2, s3, print		# if (size of array > current postion in array) -> print

j done				# program is finished

qSort:
addi sp, sp, -20		# push stack for ra, left, middle, middle + 1, right
sw a4, 16(sp) 			# sp[4] = right
sw a1, 4(sp)			# sp[1] = left
sw ra, 0(sp)			# sp[0] = ra

	qIf:
	# if (right > left) -> partition
	sub t0, a1, a4		# t0 = a1 - a4 = right - left
	and t2, t0, s3		# t2 = t0 && sign bit
	beq t2, s3, partition	# if (t2 == sign bit) -> partition
	j qsExit		# else -> exit
	
	partitionExit:
	lw a3, 8(sp)		# a3 = sp[2]	// a3 = middle value
	addi a3, a3, 1		# 		// middle = middle + 1
	sw a3, 12(sp)		# sp[3] = a3	// sp[3] = middle + 1
	lw a1, 4(sp)		# a1 = sp[1]	// left = left
	lw a4, 8(sp)		# a4 = sp[2]	// right = middle
	jal qSort		# qSort(left, middle)
	lw a1, 12(sp)		# a1 = sp[3]	// left = middle + 1
	lw a4, 16(sp)		# a4 = sp[4]	// right = right
	jal qSort		# qSort(middle + 1, right)
	
	qsExit:
	lw ra, 0(sp)		# ra = return address
	addi sp, sp, 20		# pop stack
	jalr tp, ra, 0          # jump to return address
	
partition:
add s1, zero, zero
add s1, a1, zero		# s1 = l = left
sll s5, s1, s6			# s5 = the address shift of l
add s0, s0, s5			# s0 = s0[l]
lw s7, 0(s0)			# s7 = pivot = s0[l]
sub s0, s0, s5			# s0 = s0[0]
addi s1, a1, -1			# l = left - 1
addi s2, a4, 1			# r = right + 1	 

	doWhileR:
	# do
	addi s2, s2, -1		# r--
	# while
	sll s5, s2, s6		# s5 = address shift of r
	add s0, s0, s5		# s0 = s0[r]
	lw t5, 0(s0)		# t5 = s0[r]
	sub s0, s0, s5		# s0 = s0[0]
	sub t0, s7, t5		# t0 = pivot - s0[r]
	and t2, t0, s3		# t0 && sign bit
	beq t2, s3, doWhileR	# while (s0[r] > pivot) -> do
	
	doWhileL:
	# do
	addi s1, s1, 1		# l++
	# while
	sll s5, s1, s6		# s5 = l * 4 = address shift of l
	add s0, s0, s5		# s0 = s0[l]
	lw t6, 0(s0)		# t6 = s0[l]
	sub s0, s0, s5		# s0 = s0[0]
	sub t0, t6, s7		# t0 = s0[l] - pivot
	and t2, t0, s3		# t0 && sign bit
	beq t2, s3, doWhileL	# while (pivot > s0[l]) -> do
	
	sub t0, s1, s2		# t0 = l - r
	and t2, t0, s3		# t0 && sign bit
	beq t2, s3, pIf		# if (r > l) -> swap variables
	j pElse
	
	pIf:
	sll s5, s1, s6		# s5 = l * 4 = address shift of l
	add s0, s0, s5		# s0 = s0[l]
	sw t5, 0(s0)		# s0[l] = t5 = s0[r]
	sub s0, s0, s5		# s0 = s0[0]
	sll s5, s2, s6		# s5 = r * 4 = address shift of r
	add s0, s0, s5		# s0 = s0[r]
	sw t6, 0(s0)		# s0[r] = t6 = s0[l]
	sub s0, s0, s5		# s0 = s0[0]

	j doWhileR		# jump to doWhileR
	
	pElse:
	sw s2, 8(sp)		# sp[2] = s2 = middle
	j partitionExit		# jump to partitionExit

done:
