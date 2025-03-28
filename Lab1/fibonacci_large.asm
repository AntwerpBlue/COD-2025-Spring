# 斐波那契数列计算程序（32 位）
# 输入: a0 = n (1 <= n <= 80)
# 输出: a1 = F(n) 的低 32 位，a2 = F(n) 的高 32 位

    .text
    .globl _start

_start:
    # 初始化
    li a0, 5
    li t0, 0          # t0 = F(0) 的低 32 位
    li t1, 0          # t1 = F(0) 的高 32 位
    li t2, 1          # t2 = F(1) 的低 32 位
    li t3, 0          # t3 = F(1) 的高 32 位
    li t4, 1          # t4 = 2 (循环计数器，从 2 开始)

    # 检查 n 是否为 1
    li t5, 1
    beq a0, t5, fib_done # 如果 n == 1，跳转到 fib_done

fib_loop:
    # 计算 F(i) = F(i-1) + F(i-2)
    add t6, t0, t2    # t6 = F(i-1) 低 32 位 + F(i-2) 低 32 位
    sltu t5, t6, t0   # 检查是否溢出（t5 = 1 如果溢出）
    add a7, t1, t3    # t7 = F(i-1) 高 32 位 + F(i-2) 高 32 位
    add a7, a7, t5    # t7 = t7 + 进位

    # 更新 F(i-2) 和 F(i-1)
    mv t0, t2         # t0 = F(i-1) 低 32 位
    mv t1, t3         # t1 = F(i-1) 高 32 位
    mv t2, t6         # t2 = F(i) 低 32 位
    mv t3, a7         # t3 = F(i) 高 32 位

    # 检查是否达到 n
    addi t4, t4, 1    # t4 = t4 + 1
    bge t4, a0, fib_done # 如果 t4 >= n，跳转到 fib_done
    j fib_loop         # 否则继续循环

fib_done:
    # 将结果保存到 a1 和 a2
    mv a1, t2         # a1 = F(n) 低 32 位
    mv a2, t3         # a2 = F(n) 高 32 位

    # 程序结束
    li a7, 93         # 退出系统调用号
    ecall             # 调用系统调用
