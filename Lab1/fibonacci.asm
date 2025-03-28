.text
.global _start

_start:
	li t0, 0
	li t1, 1
	li t2, 2
	
	li t3, 1
	beq a0, t3, fib_done
	
fib_loop:
	add t4, t0, t1
	mv t0, t1
	mv t1, t4
	
	addi t2, t2, 1
	bge t2, a0, fib_done
	j fib_loop
	
fib_done:
	mv a1, t1
	li a7, 93
	ecall
	
