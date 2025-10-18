# Program File: sudoku_validator.asm 
# Author: Matvey Oborotov
# Purpose: validate sudoku configuration from files 'te0.txt' through 'te9.txt'

.data
	#ascii values;
	#'x' = 120, '0'-'9' = 48-57
		
	opening: .asciiz "Opening file: "
	newline: .asciiz "\n"
	valid: .asciiz "valid"
	not_valid: .asciiz "not valid, because "
	r: .asciiz "R('"
	c: .asciiz "C('"
	bb: .asciiz "B('"
	in: .asciiz "' in ["
	comma: .asciiz ","
	andd: .asciiz "] & '"
	output_end: .asciiz "])"
	
	sudoku: .space 89 #file contains 89 symbols
	
	te: .asciiz "te"
	txt: .asciiz ".txt"
	file: .space 7 #all file names are 7 symbols long
.text
    	# Execution flow: main -> load_and_check_files -> load_and_validate_sudoku -> validation functions
	main:
	
	jal load_and_check_files
	
	#halt
	li $v0, 10
	syscall
	
	load_and_check_files:
		load_and_check_files_setup:
			addi $sp, $sp, -12
			sw $ra, 0($sp)
			sw $s0, 4($sp)
			sw $s1, 8($sp)
			
			#go through the files from 0 to 9
			addi $s0, $zero, 0
			addi $s1, $zero, 9
			
			addi $a1, $s0, 0
			jal load_and_validate_sudoku
			addi $s0, $s0, 1
		load_and_check_files_loop:
			bgt $s0, $s1, load_and_check_files_end
			
			li $v0, 4
			la $a0, newline
			syscall
			
			li $v0, 4
			la $a0, newline
			syscall
			
			addi $a1, $s0, 0
			jal load_and_validate_sudoku
			addi $s0, $s0, 1
			
			j load_and_check_files_loop
		load_and_check_files_end:		
			lw $ra, 0($sp)
			lw $s0, 4($sp)
			lw $s1, 8($sp)
			addi $sp, $sp, 12
		
			jr $ra
			
	
	#input: a1 is number of the file from 0 to 9
	load_and_validate_sudoku:
		load_and_validate_sudoku_setup:
			addi $sp, $sp, -16
			sw $ra, 0($sp)
			sw $s0, 4($sp)
			sw $s1, 8($sp)
			sw $s6, 12($sp)
			
			#get the name of the file
			jal concatenate
			move $a0, $v1
			
			#open file and get file descriptor
			li $v0, 13
			addi $a1, $zero, 0
			addi $a2, $zero, 0
			syscall
			move $s6, $v0 #file descriptor
			move $a0, $v0
	
			#read file
			li $v0, 14
			la $a1, sudoku #array
			li $a2, 89
			syscall
			
			#right now the array is in a1
			
			#print: "Opening file: te{num}.txt\n"
			li $v0, 4
			la $a0, opening
			syscall
			
			li $v0, 4
			move $a0, $v1
			syscall
			
			li $v0, 4
			la $a0, newline
			syscall
			
			jal output_sudoku
			
			li $v0, 4
			la $a0, newline
			syscall
			
		load_and_validate_sudoku_load:		
			jal check_rows
			beq $v1, -1, load_and_validate_sudoku_not_valid
			
			jal check_columns		
			beq $v1, -1, load_and_validate_sudoku_not_valid
			
			jal check_boxes
			beq $v1, -1, load_and_validate_sudoku_not_valid
			
		load_and_validate_sudoku_valid:
			li $v0, 4
			la $a0, valid
			syscall
		load_and_validate_sudoku_not_valid:
			lw $ra, 0($sp)
			lw $s0, 4($sp)
			lw $s1, 8($sp)
			lw $s6, 12($sp)
			addi $sp, $sp, 16
			jr $ra
	
	#all of the procedures below are needed for load_and_check	
	#input: a1 is the array
	#output: v1 = -1 and output message if not valid, and base adress of the array if valid
	check_rows:
		check_rows_setup:
			addi $sp, $sp, -32
			sw $s0, 0($sp)
			sw $s1, 4($sp)
			sw $s2, 8($sp)
			sw $s3, 12($sp)
			sw $s4, 16($sp)
			sw $s5, 20($sp)
			sw $s6, 24($sp)
			sw $s7, 28($sp)
		
			move $v1, $a1 #to preserve a1
			addi $s0, $zero, -10 #rows counter (i), -10 to start from 0
			addi $s1, $zero, 0 #num1 counter (j)
			addi $s2, $zero, 0 #num2 counter (k)
			addi $s3, $zero, 90 #max value for i
			
		#rows
		#for (int i = 0; i < 90; i += 10)
		check_rows_loop1:
			addi $s0, $s0, 10
			bge $s0, $s3, check_rows_end
				
		#num1
		#for (int j = i; j < i + 8; j++)
		check_rows_loop2_setup:
			addi $s1, $s0, 0 # int j = i
			addi $s4, $s0, 8 # i + 8
		check_rows_loop2:
			bge $s1, $s4, check_rows_loop1
			
			add $a1, $a1, $s1
			lb $s6, 0($a1) #num1
			sub $a1, $a1, $s1 #to preserve a1
			
			addi $s1, $s1, 1
			
			beq $s6, 120, check_rows_loop2
						
		#num2 for (int k = j + 1; k < i + 9; k++)
		check_rows_loop3_setup:
			addi $s2, $s1, 0 # k = j + 1 (because s1 is already incremented)
			addi $s5, $s0, 9 # i + 9
		check_rows_loop3:
			bge $s2, $s5, check_rows_loop2
			
			add $a1, $a1, $s2
			lb $s7, 0($a1)
			sub $a1, $a1, $s2 #to preserve a1
			
			addi $s2, $s2, 1 
			beq $s7, 120, check_rows_loop3 #skip the current character is 'x'
			
			beq $s6, $s7, check_rows_not_valid
			
			j check_rows_loop3
						
		check_rows_not_valid:
			# print to screen:
			# "now valid, because "
			li $v0, 4
			la $a0, not_valid
			syscall
			# "R('"
			li $v0, 4
			la $a0, r
			syscall
			# "{num1}"
			li $v0, 11
			addi $a0, $s6, 0
			syscall
			# "' in ["
			li $v0, 4
			la $a0, in
			syscall	
			# "{i / 10}"
			li $v0, 1
			addi $s3, $zero, 10
			div $a0, $s0, $s3
			syscall
			# ","
			li $v0, 4
			la $a0, comma
			syscall
			# "{j - i - 1}"
			li $v0, 1
			sub $a0, $s1, $s0 # j - i
			addi $a0, $a0, -1 # (j - i) - 1
			syscall
			# "] & '"
			li $v0, 4
			la $a0, andd
			syscall
			# "{num2}"
			li $v0, 11
			addi $a0, $s7, 0
			syscall
			# "' in ["
			li $v0, 4
			la $a0, in
			syscall
			# "{i / 10}"
			li $v0, 1
			div $a0, $s0, $s3
			syscall
			# ","
			li $v0, 4
			la $a0, comma
			syscall
			# "{k - i - 1}"
			li $v0, 1
			sub $a0, $s2, $s0 # k - i
			addi $a0, $a0, -1 # (k - i) - 1
			syscall
			# "])"
			li $v0, 4
			la $a0, output_end
			syscall
			
			addi $v1, $zero, -1
			
		check_rows_end:
			lw $s0, 0($sp)
			lw $s1, 4($sp)
			lw $s2, 8($sp)
			lw $s3, 12($sp)
			lw $s4, 16($sp)
			lw $s5, 20($sp)
			lw $s6, 24($sp)
			lw $s7, 28($sp)
			addi $sp, $sp, 32
		
			jr $ra
			
	#input: a1 is the array
	#output: v1 = -1 and output message if not valid, and base adress of the array if valid
	check_columns:
		check_columns_setup:
			addi $sp, $sp, -32
			sw $s0, 0($sp)
			sw $s1, 4($sp)
			sw $s2, 8($sp)
			sw $s3, 12($sp)
			sw $s4, 16($sp)
			sw $s5, 20($sp)
			sw $s6, 24($sp)
			sw $s7, 28($sp)
		
			move $v1, $a1 #to preserve a1
			addi $s0, $zero, -1 #rows counter (i), -1 to start from 0
			addi $s1, $zero, 0 #num1 counter (j)
			addi $s2, $zero, 0 #num2 counter (k)
			addi $s3, $zero, 9 #max value for i
			
		#rows
		# for (int i = 0; i < 9; i++)
		check_columns_loop1:
			addi $s0, $s0, 1
			bge $s0, $s3, check_columns_end
				
		#num1
		#for (int j = i; j < 80; j += 10)
		check_columns_loop2_setup:
			addi $s1, $s0, 0 # int j = i
			addi $s4, $zero, 80
		check_columns_loop2:
			bge $s1, $s4, check_columns_loop1
			
			add $a1, $a1, $s1
			lb $s6, 0($a1) #num1
			sub $a1, $a1, $s1 #to preserve a1
			
			addi $s1, $s1, 10 # j += 10
			
			beq $s6, 120, check_columns_loop2
						
		#num2 for (int k = j + 10; k < 90; k += 10)
		check_columns_loop3_setup:
			addi $s2, $s1, 10 # k = j + 10
			addi $s5, $zero, 90
		check_columns_loop3:
			bge $s2, $s5, check_columns_loop2
			
			add $a1, $a1, $s2
			lb $s7, 0($a1) #num2
			sub $a1, $a1, $s2 #to preserve a1
			
			addi $s2, $s2, 10 # k += 10
			beq $s7, 120, check_columns_loop3 #skip 'x'
			
			beq $s6, $s7, check_columns_not_valid
			
			j check_columns_loop3
						
		check_columns_not_valid:
			# print to the screen:
			# "not valid, because "
			li $v0, 4
			la $a0, not_valid
			syscall
			# "C('"
			li $v0, 4
			la $a0, c
			syscall
			# "{num1}"
			li $v0, 11
			addi $a0, $s6, 0
			syscall
			# "' in ["
			li $v0, 4
			la $a0, in
			syscall	
			# "{j / 10 - 1}"
			li $v0, 1
			addi $s3, $zero, 10
			div $s1, $s3 # j / 10
			mflo $a0
			addi $a0, $a0, -1 # (j / 10) -  1
			syscall
			# ","
			li $v0, 4
			la $a0, comma
			syscall
			# "{i}"
			li $v0, 1
			addi $a0, $s0, 0
			syscall
			# "] & '"
			li $v0, 4
			la $a0, andd
			syscall
			# "{num2}"
			li $v0, 11
			addi $a0, $s7, 0
			syscall
			# "' in ["
			li $v0, 4
			la $a0, in
			syscall
			# "{k / 10 - 1}"
			li $v0, 1
			div $s2, $s3 # k / 10
			mflo $a0
			addi $a0, $a0, -1 # (k / 10) - 1
			syscall
			# ","
			li $v0, 4
			la $a0, comma
			syscall
			# "{i}"
			li $v0, 1
			addi $a0, $s0, 0
			syscall
			# "])"
			li $v0, 4
			la $a0, output_end
			syscall
			
			addi $v1, $zero, -1
			
		check_columns_end:
			lw $s0, 0($sp)
			lw $s1, 4($sp)
			lw $s2, 8($sp)
			lw $s3, 12($sp)
			lw $s4, 16($sp)
			lw $s5, 20($sp)
			lw $s6, 24($sp)
			lw $s7, 28($sp)
			addi $sp, $sp, 32
			
			jr $ra
	
	#input: a1 is the sudoku array
	#output: v1 = -1 and output message if not valid, and base adress of the array if valid
	check_boxes:
		check_boxes_setup:
			addi $sp, $sp, -8
			sw $ra, 0($sp)
			sw $s0, 4($sp)
			
			addi $s0, $a1, 0
		check_boxes_main:
			#box1
			jal from_box_to_array		
			move $a2, $v0
			addi $a0, $zero, 0
			addi $a1, $zero, 0
			jal check_one_box
			beq $v1, -1, check_boxes_end
			#box2
			addi $s0, $s0, 3
			addi $a1, $s0, 0
			jal from_box_to_array
			move $a2, $v0
			addi $a0, $zero, 0
			addi $a1, $zero, 3
			jal check_one_box
			beq $v1, -1, check_boxes_end
			#box3
			addi $s0, $s0, 3
			addi $a1, $s0, 0
			jal from_box_to_array
			move $a2, $v0
			addi $a0, $zero, 0
			addi $a1, $zero, 6
			jal check_one_box
			beq $v1, -1, check_boxes_end
			#box4
			addi $s0, $s0, 24
			addi $a1, $s0, 0
			jal from_box_to_array
			move $a2, $v0
			addi $a0, $zero, 3
			addi $a1, $zero, 0
			jal check_one_box
			beq $v1, -1, check_boxes_end
			#box5
			addi $s0, $s0, 3
			addi $a1, $s0, 0
			jal from_box_to_array
			move $a2, $v0
			addi $a0, $zero, 3
			addi $a1, $zero, 3
			jal check_one_box
			beq $v1, -1, check_boxes_end
			#box6
			addi $s0, $s0, 3
			addi $a1, $s0, 0
			jal from_box_to_array
			move $a2, $v0
			addi $a0, $zero, 3
			addi $a1, $zero, 6
			jal check_one_box
			beq $v1, -1, check_boxes_end
			#box7
			addi $s0, $s0, 24
			addi $a1, $s0, 0
			jal from_box_to_array
			move $a2, $v0
			addi $a0, $zero, 6
			addi $a1, $zero, 0
			jal check_one_box
			beq $v1, -1, check_boxes_end
			#box8
			addi $s0, $s0, 3
			addi $a1, $s0, 0
			jal from_box_to_array	
			move $a2, $v0
			addi $a0, $zero, 6
			addi $a1, $zero, 3
			jal check_one_box
			beq $v1, -1, check_boxes_end
			#box9
			addi $s0, $s0, 3
			addi $a1, $s0, 0
			jal from_box_to_array
			move $a2, $v0
			addi $a0, $zero, 6
			addi $a1, $zero, 6
			jal check_one_box
			beq $v1, -1, check_boxes_end
		check_boxes_end:
			
			lw $ra, 0($sp)
			lw $s0, 4($sp)
			addi $sp, $sp, 8
			
			jr $ra
			
	#input: a2 is base adress of the array, $a0 is its row number, $a1 is its column number
	#output: v1 is -1 and output message if not valid 
	check_one_box:
		check_one_box_setup:
			addi $sp, $sp, -36
			sw $ra, 0($sp)
			sw $s0, 4($sp)
			sw $s1, 8($sp)
			sw $s2, 12($sp)
			sw $s3, 16($sp)
			sw $s4, 20($sp)
			sw $s5, 24($sp)
			sw $s6, 28($sp)
			sw $s7, 32($sp)
		
			addi $s0, $zero, 0 # i
			addi $s1, $zero, 8
			addi $s6, $a0, 0 #row of the top left element
			addi $s7, $a1, 0 #column of the top left element
		#for (int i = 0; i < 8; i++)
		check_one_box_loop1:
			bge $s0, $s1, check_one_box_end
			
			add $a2, $a2, $s0
			lb $s4, 0($a2) #num1
			sub $a2, $a2, $s0 # preserve a2
			
			addi $s0, $s0, 1
			
			beq $s4, 120, check_one_box_loop1
			
		#for (int j = i + 1; j < 9; j++)
		check_one_box_loop2_setup:
			addi $s2, $s0, 0 # j = i + 1 (s0 is already incremented)
			addi $s3, $zero, 9
		check_one_box_loop2:
			bge $s2, $s3, check_one_box_loop1
			
			add $a2, $a2, $s2
			lb $s5, 0($a2) #num2
			sub $a2, $a2, $s2 # preserve a2
			
			addi $s2, $s2, 1
			
			beq $s5, 120, check_one_box_loop2
			
			beq $s4, $s5, check_one_box_not_valid
			
			j check_one_box_loop2
			
		check_one_box_not_valid:
			addi $s0, $s0, -1 
			addi $s2, $s2, -1 
			addi $s3, $zero, 3 # initialize for division 
		
			# print to the screen:
			# "not valid, because "
			li $v0, 4
			la $a0, not_valid
			syscall
			# "R('"
			li $v0, 4
			la $a0, bb
			syscall
			# "{num1}"
			li $v0, 11
			addi $a0, $s4, 0
			syscall
			# "' in ["
			li $v0, 4
			la $a0, in
			syscall	
			# s6 + i / 3
			li $v0, 1
			div $s0, $s3 # i / 3
			mflo $a0
			add $a0, $a0, $s6 # s6 + i / 3
			syscall
			# ","
			li $v0, 4
			la $a0, comma
			syscall
			# s7 + i % 3
			li $v0, 1
			div $s0, $s3 # i % 3
			mfhi $a0
			add $a0, $a0, $s7 # s6 + (i % 3)
			syscall
			# "] & '"
			li $v0, 4
			la $a0, andd
			syscall
			# {num2}
			li $v0, 11
			addi $a0, $s5, 0
			syscall
			# "' in ["
			li $v0, 4
			la $a0, in
			syscall
			# s6 + j / 3
			li $v0, 1
			div $s2, $s3 # j / 3
			mflo $a0
			add $a0, $a0, $s6 # s6 + j / 3
			syscall
			# ","
			li $v0, 4
			la $a0, comma
			syscall
			# s7 + j % 3
			li $v0, 1
			div $s2, $s3 # j % 3
			mfhi $a0
			add $a0, $a0, $s7 # s6 + (j % 3)
			syscall
			# "])"
			li $v0, 4
			la $a0, output_end
			syscall
			
			addi $v1, $zero, -1
		check_one_box_end:
			lw $ra, 0($sp)
			lw $s0, 4($sp)
			lw $s1, 8($sp)
			lw $s2, 12($sp)
			lw $s3, 16($sp)
			lw $s4, 20($sp)
			lw $s5, 24($sp)
			lw $s6, 28($sp)
			lw $s7, 32($sp)
			addi $sp, $sp, 36
			
			jr $ra
		
		
	#input: $a1 is the top left corner adress
	#output: $v0 is the base adress of the array, representing 3x3 box
	from_box_to_array:
		#allocate for array
		addi $sp, $sp, -12
		sw $ra, 0($sp)
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		
		li $v0, 9
		addi $a0, $zero, 9
		syscall
		move $s0, $v0
	
		lb $s1, 0($a1)
		sb $s1, 0($s0)
		
		addi $a1, $a1, 1
		addi $s0, $s0, 1
		lb $s1, 0($a1)
		sb $s1, 0($s0)
		
		addi $a1, $a1, 1
		addi $s0, $s0, 1
		lb $s1, 0($a1)
		sb $s1, 0($s0)
		
		addi $a1, $a1, 8
		addi $s0, $s0, 1
		lb $s1, 0($a1)
		sb $s1, 0($s0)
		
		addi $a1, $a1, 1
		addi $s0, $s0, 1
		lb $s1, 0($a1)
		sb $s1, 0($s0)
		
		addi $a1, $a1, 1
		addi $s0, $s0, 1
		lb $s1, 0($a1)
		sb $s1, 0($s0)
		
		addi $a1, $a1, 8
		addi $s0, $s0, 1
		lb $s1, 0($a1)
		sb $s1, 0($s0)
		
		addi $a1, $a1, 1
		addi $s0, $s0, 1
		lb $s1, 0($a1)
		sb $s1, 0($s0)
		
		addi $a1, $a1, 1
		addi $s0, $s0, 1
		lb $s1, 0($a1)
		sb $s1, 0($s0)	
		
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		addi $sp, $sp, 12
		
		jr $ra
		
		
	#input: a1 is the array of symbols from file
	#output: sudoku grid to the screen
	output_sudoku:
		output_sudoku_setup:
			addi $sp, $sp, -16
			sw $s1, 0($sp)
			sw $s2, 4($sp)
			sw $s5, 8($sp)
			sw $s7, 12($sp)			
		
			addi $s7, $zero, 0
			addi $s5, $zero, 89
			move $s1, $a1 #to preserve a1 (array of symbols)
		output_sudoku_main:
			beq $s5, $s7, output_sudoku_end
		
			lb $s2, 0($a1)
			addi $a1, $a1, 1
			addi $s7, $s7, 1
		
			li $v0, 11
			move $a0, $s2
			syscall
				
			j output_sudoku_main
		output_sudoku_end:
			move $a1, $s1 # to preserve a1
			
			lw $s1, 0($sp)
			lw $s2, 4($sp)
			lw $s5, 8($sp)
			lw $s7, 12($sp)
			addi $sp, $sp, 16
			
			jr $ra
		
	
	#input: a1 - num of file in ascii
	#output: v1 = filename
	concatenate:
		concatenate_setup:
			addi $sp, $sp, -24
			sw $ra, 0($sp)
			sw $s0, 4($sp)
			sw $s1, 8($sp)
			sw $s2, 12($sp)
			sw $s3, 16($sp)
			sw $s4, 20($sp)
			
			#a0 = s2, a1 = s3, a2 = s4
			la $s2, te
			la $s3, txt
			la $s4, file
			
			#save base adress of the result
			move $s1, $s4
		concatenate_str1:
			lb $s0, 0($s2)
			beqz $s0, concatenate_fileNum
			sb $s0, 0($s4)
			addi $s2, $s2, 1
			addi $s4, $s4, 1
			
			j concatenate_str1			
		concatenate_fileNum:
			addi $s0, $a1, 48 #convert from integer to ascii ('0' = 48)
			sb $s0, 0($s4)
			addi $s4, $s4, 1
			
			j concatenate_str2
		concatenate_str2:
			lb $s0, 0($s3)
			beqz $s0, concatenate_end
			sb $s0, 0($s4)
			addi $s3, $s3, 1
			addi $s4, $s4, 1
			
			j concatenate_str2 			
		concatenate_end:
			move $v1, $s1
			
			lw $ra, 0($sp)
			lw $s0, 4($sp)
			lw $s1, 8($sp)
			lw $s2, 12($sp)
			lw $s3, 16($sp)
			lw $s4, 20($sp)
			addi $sp, $sp, 24
			
			jr $ra
