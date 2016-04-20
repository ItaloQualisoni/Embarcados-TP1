	.text
	.align 2

	.global _entry
	.ent	_entry
_entry:
	.set noreorder
	.set noat

	la	$a1, __bss_start
	la	$a0, _end
	#la	$gp, _gp
	la	$sp, _stack

$BSS_CLEAR:
	# clear the .bss
	sw	$zero, 0($a1)
	slt	$v1, $a1, $a0
	addiu	$a1, $a1, 4
	bnez	$v1, $BSS_CLEAR
	nop

	# configure IRQ_VECTOR
	la	$k1, _isr
	li	$k0, 0xf0000000
	sw	$k1, 0($k0)

	# mark GPRs as unused, except $sp
	li	$at, 0xdeadbeef
	addiu	$v0, $at, 0
	addiu	$v1, $at, 0
	addiu	$a0, $at, 0
	addiu	$a1, $at, 0
	addiu	$a2, $at, 0
	addiu	$a3, $at, 0
	addiu	$t0, $at, 0
	addiu	$t1, $at, 0
	addiu	$t2, $at, 0
	addiu	$t3, $at, 0
	addiu	$t4, $at, 0
	addiu	$t5, $at, 0
	addiu	$t6, $at, 0
	addiu	$t7, $at, 0
	addiu	$s0, $at, 0
	addiu	$s1, $at, 0
	addiu	$s2, $at, 0
	addiu	$s3, $at, 0
	addiu	$s4, $at, 0
	addiu	$s5, $at, 0
	addiu	$s6, $at, 0
	addiu	$s7, $at, 0
	addiu	$t8, $at, 0
	addiu	$t9, $at, 0
	addiu	$k0, $at, 0
	addiu	$k1, $at, 0
	addiu	$fp, $at, 0
	addiu	$ra, $at, 0
	
	# jump to main
	jal	HF_Main
	nop

	li	$k0, 0xe0000000		# this will interrupt the simulation (assertion)
	sw	$zero, 0($k0)

$L1:
	beq	$zero, $zero, $L1
	nop
.end _entry

# the non-vectored interrupt service routine
	.org 0x100
	.global _isr
	.ent _isr
_isr:
	.set noreorder
	.set noat

	nop				# this must be a NOP
	# save all temporary registers
	addiu	$sp, $sp, -104
#	sw	$at, 16($sp)
	sw	$v0, 20($sp)
	sw	$v1, 24($sp)
	sw	$a0, 28($sp)
	sw	$a1, 32($sp)
	sw	$a2, 36($sp)
	sw	$a3, 40($sp)
	sw	$t0, 44($sp)
	sw	$t1, 48($sp)
	sw	$t2, 52($sp)
	sw	$t3, 56($sp)
	sw	$t4, 60($sp)
	sw	$t5, 64($sp)
	sw	$t6, 68($sp)
	sw	$t7, 72($sp)
	sw	$t8, 76($sp)
	sw	$t9, 80($sp)
	sw	$ra, 84($sp)
	li	$k0, 0xf0000040		# read IRQ_EPC
	lw	$k0, 0($k0)
	addiu	$k0, $k0, -4		# last instruction was not commited, rollback!
	sw	$k0, 88($sp)
	mfhi	$k1
	sw	$k1, 92($sp)
	mflo	$k1
	sw	$k1, 96($sp)
	lui	$a1,  0xf000
	lw	$a0,  0x10($a1)		# read IRQ_CAUSE
	lw	$a2,  0x20($a1)		# read IRQ_MASK
	and	$a0,  $a0, $a2		# pass CAUSE and MASK and the stack pointer to the C handler
	jal	HF_InterruptServiceRoutine	# jump to C handler
	addiu	$a1,  $sp, 0

	# restore all temporary registers
#	lw	$at, 16($sp)
	lw	$v0, 20($sp)
	lw	$v1, 24($sp)
	lw	$a0, 28($sp)
	lw	$a1, 32($sp)
	lw	$a2, 36($sp)
	lw	$a3, 40($sp)
	lw	$t0, 44($sp)
	lw	$t1, 48($sp)
	lw	$t2, 52($sp)
	lw	$t3, 56($sp)
	lw	$t4, 60($sp)
	lw	$t5, 64($sp)
	lw	$t6, 68($sp)
	lw	$t7, 72($sp)
	lw	$t8, 76($sp)
	lw	$t9, 80($sp)
	lw	$ra, 84($sp)
	lw	$at, 88($sp)		# we will have problems if $at is used (user asm code)
	lw	$k1, 92($sp)
	mthi	$k1
	lw	$k1, 96($sp)
	mtlo	$k1
	addiu	$sp, $sp, 104
	ori	$k1, $zero, 0x1
	li	$k0, 0xf0000030
	jr	$at			# context restored, continue
	sw	$k1, 0($k0)		# enable interrupts

.end _isr

###################################################
	.global HF_AsmInterruptEnable
	.ent HF_AsmInterruptEnable
HF_AsmInterruptEnable:
	.set noreorder

	li	$k1, 0xf0000030
	lw	$v0, 0($k1)
	jr	$ra
	sw	$a0, 0($k1)

	.set reorder
.end HF_AsmInterruptEnable

###################################################
# saves task registers on a TCB entry
	.global   setjmp
	.ent     setjmp
setjmp:
	.set noreorder

	sw    $s0, 0($a0)
	sw    $s1, 4($a0)
	sw    $s2, 8($a0)
	sw    $s3, 12($a0)
	sw    $s4, 16($a0)
	sw    $s5, 20($a0)
	sw    $s6, 24($a0)
	sw    $s7, 28($a0)
	sw    $fp, 32($a0)
	sw    $gp, 36($a0)
	sw    $sp, 40($a0)
	sw    $ra, 44($a0)

	ori   $v0,  $zero, 0
	jr    $ra
	nop

	.set reorder
.end setjmp


###################################################
# restores task registers from a TCB entry
	.global   longjmp
	.ent     longjmp
longjmp:
	.set noreorder

	lw    $s0, 0($a0)
	lw    $s1, 4($a0)
	lw    $s2, 8($a0)
	lw    $s3, 12($a0)
	lw    $s4, 16($a0)
	lw    $s5, 20($a0)
	lw    $s6, 24($a0)
	lw    $s7, 28($a0)
	lw    $fp, 32($a0)
	lw    $gp, 36($a0)
	lw    $sp, 40($a0)
	lw    $ra, 44($a0)

	ori   $v0,  $a1, 0
	jr    $ra
	nop

	.set reorder
.end longjmp

###################################################
# restores task registers on a TCB entry, then enable interrupts.
	.global   HF_RestoreExecution
	.ent     HF_RestoreExecution
HF_RestoreExecution:
	.set noreorder

	lw    $s0, 0($a0)
	lw    $s1, 4($a0)
	lw    $s2, 8($a0)
	lw    $s3, 12($a0)
	lw    $s4, 16($a0)
	lw    $s5, 20($a0)
	lw    $s6, 24($a0)
	lw    $s7, 28($a0)
	lw    $fp, 32($a0)
	lw    $gp, 36($a0)
	lw    $sp, 40($a0)
	lw    $ra, 44($a0)

	ori   $k1, $zero, 0x1
	li    $k0, 0xf0000030

	ori   $v0,  $a1, 0

	addu    $gp, $a2, $zero				# we a borrowing the $gp as a helper reg (report current task to HDL simulator)

	jr    $ra
	sw    $k1, 0($k0)		# enable interrupts
	nop

	.set reorder
.end HF_RestoreExecution

###################################################
# we don't have a halt instruction on MIPS, just do
# a nop and the idle task will loop

	.global   HF_Halt
	.ent     HF_Halt
HF_Halt:
	.set noreorder

	nop
	nop
	nop
	nop
	nop
	jr    $ra
	nop
	nop

	.set reorder
.end HF_Halt

