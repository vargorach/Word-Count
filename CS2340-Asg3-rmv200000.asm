## Rachel Vargo RMV200000 CS2340.005
## Started on Feburary 16, 2022
## This opens a user inputed file and scans through blocks of text in order
# to find words and count the amount each word appears. At the end it will 
# print out a list of the words and the count of each word.

	.data
	.include	"SysCalls.asm"
	
prompt:	.asciiz		"Enter a file name: "
fileW:	.asciiz		"\nFile opened successfully\n"	#REMOVE LATER
fileC:	.asciiz		"File closed successfully\n"	#REMOVE LATER
wordLabel:
	.asciiz		"Words:\n"
countLabel:
	.asciiz		"Counts:"
filename:
	.space		256		#filename to be entered
filelengh:
	.space		256		#length of the file
words:	.word		4000		#initializes words in list, shown in class 	0 to 4000
	.align		4	
ptr:	.space		4096		#to save the pointers	
buffer:
	.space		1024		#space for block of word
	.align		2	
	.globl		main
	.eqv		block	1024
	.eqv		count	0	#count of uniqueness
	.eqv		length	4	#length count of word
	.eqv		word	8	#store the word
	.text
main:					#gets the user entered filename
	la	$a0, prompt		#asks user to enter the file name
	li	$v0, SysPrintString
	syscall
	la	$v0, SysReadString	#reads user inputed string
	la	$a0, filename		#stores name in filename
	li	$a1, 256		#holds the length of the filename
	syscall
	li	$t1, '\n'		#load $t1 with newline character
findnl:					#remove newline from file name
	lbu	$t0, 0($a0)		#go through file name one byte at a time	
	beq	$t0, $t1, openFile	#finds the newline to remove it
	addi	$a0, $a0, 1		#moves to next byte in string
	b	findnl			#loops till newline is found
openFile:				#opens the file
	sb	$zero, ($a0)		#overwrites the newline with 0
	li	$v0, SysOpenFile	#opens the user inputed file
	li	$a1, 0			#flags the file to read mode
	la	$a0, filename		#loads the filename
	syscall
	move	$s0, $v0		#load file descriptor
	bltz	$v0, exit		#if file error ends program
	la	$a0, fileW
	li	$v0, SysPrintString
	syscall
	move	$a0, $s0		#file descriptor
	la	$a1, buffer		#buffer address
	li	$a2, block		#buffer length block of 1024
	li	$v0, SysReadFile
	syscall
	add	$s0, $a0, $zero		#save file descriptor
	move	$s1, $v0		#save the length of the file	
	
	
	addi	$t3, $t3, 1		#word count initiate
	la	$s4, ptr		#to add to pointer counts
	la	$t2, words		#for the words
wordListing:				#checks words and makes them uppercase/add to the list	
	beq	$t4, $s1, closeFile	#this is the end of the file
	beq	$t4, block, nextBlock	#branches to the next block  
	li	$t1, 0			#reset $t1 to use as my counter length of word
	jal	checkWord
	addi	$t7, $t1, 8		#add 9 for binary 0 prof says 9, i like 8
	move	$a0, $t7
	li	$v0, SysAlloc
	syscall
	move	$s3, $v0
	move	$s4, $v0
	sw	$s4, ptr		#saves pointer
	addi	$s4, $s4, 4		#for next pointer
	subu	$a1, $a1, $t1		#reset $a1 to make uppercase
	sb	$t3, count($s3)		#saves word count in space 0
	sb	$t1, length($s3)	#saves word length 4 bytes
	jal	toUpper
	addi	$a1, $a1, 1		#for checkWord to go to next word
	sw	$s3, 0($t2)		#0 or 4?
	addi	$t2, $t2, 4
	jal	StringComp
nextWord:
	addi	$t4, $t4, 1		#counter for how many cells of words
	b	wordListing		#move to next word
	
nextBlock:				#continues the wordlisting with next block of code
	li	$t4, 0			#reset end of file count
	move	$a0, $s0		#file descriptor
	la	$a1, buffer		#buffer address
	li	$a2, block		#buffer length block of 1024
	li	$v0, SysReadFile
	syscall
	move	$s2, $a1		#save block
	add	$s0, $a0, $zero		#save file descriptor
	beq	$v0, $zero, closeFile
	b	wordListing
closeFile:
	move	$a0, $s1		#restore file 
	li	$v0, SysCloseFile	#closes file
	syscall
	la	$a0, fileC		#prints that the file closed correctly
	li	$v0, SysPrintString
	syscall
print:					#prints the words and lengths
	la	$a0, countLabel		#label for counts
	li	$v0, SysPrintString
	syscall
	jal	Space
	la	$a0, wordLabel		#label for words
	li	$v0, SysPrintString
	syscall
	jal	printList		#jumps to printing the list in functions
exit:
	li	$v0, SysExit		#terminates program
	syscall
	
	
