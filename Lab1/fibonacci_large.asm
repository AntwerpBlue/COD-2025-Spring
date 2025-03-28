# 쳲��������м������32 λ��
# ����: a0 = n (1 <= n <= 80)
# ���: a1 = F(n) �ĵ� 32 λ��a2 = F(n) �ĸ� 32 λ

    .text
    .globl _start

_start:
    # ��ʼ��
    li a0, 5
    li t0, 0          # t0 = F(0) �ĵ� 32 λ
    li t1, 0          # t1 = F(0) �ĸ� 32 λ
    li t2, 1          # t2 = F(1) �ĵ� 32 λ
    li t3, 0          # t3 = F(1) �ĸ� 32 λ
    li t4, 1          # t4 = 2 (ѭ������������ 2 ��ʼ)

    # ��� n �Ƿ�Ϊ 1
    li t5, 1
    beq a0, t5, fib_done # ��� n == 1����ת�� fib_done

fib_loop:
    # ���� F(i) = F(i-1) + F(i-2)
    add t6, t0, t2    # t6 = F(i-1) �� 32 λ + F(i-2) �� 32 λ
    sltu t5, t6, t0   # ����Ƿ������t5 = 1 ��������
    add a7, t1, t3    # t7 = F(i-1) �� 32 λ + F(i-2) �� 32 λ
    add a7, a7, t5    # t7 = t7 + ��λ

    # ���� F(i-2) �� F(i-1)
    mv t0, t2         # t0 = F(i-1) �� 32 λ
    mv t1, t3         # t1 = F(i-1) �� 32 λ
    mv t2, t6         # t2 = F(i) �� 32 λ
    mv t3, a7         # t3 = F(i) �� 32 λ

    # ����Ƿ�ﵽ n
    addi t4, t4, 1    # t4 = t4 + 1
    bge t4, a0, fib_done # ��� t4 >= n����ת�� fib_done
    j fib_loop         # �������ѭ��

fib_done:
    # ��������浽 a1 �� a2
    mv a1, t2         # a1 = F(n) �� 32 λ
    mv a2, t3         # a2 = F(n) �� 32 λ

    # �������
    li a7, 93         # �˳�ϵͳ���ú�
    ecall             # ����ϵͳ����
