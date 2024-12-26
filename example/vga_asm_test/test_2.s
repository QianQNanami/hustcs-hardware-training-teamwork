.text
    addi t0, x0, 0x0      # t0 = 0x0

    # 将数据 0xF00 存储到寄存器 t1
    addi t1, x0, 0xF0        # t1 = 0xF0
    slli t1, t1, 4           # t1 = 0xF00

    # 将数据 0x0F0 存储到寄存器 t2
    addi t2, x0, 0xF0        # t2 = 0x0F0

    # 将数据 0x00F 存储到寄存器 t3
    addi t3, x0, 0xF         # t3 = 0x00F

    # 将数据 0xFFF 存储到寄存器 t4
    addi t4, x0, 0xFF        # t4 = 0xFF
    slli t4, t4, 4           # t4 = 0xFF0
    addi t4, t4, 0xF         # t4 = 0xFFF

    # 将数据写入指定地址
    sw t1, 0(t0)            # 将 t1 的值存储到地址 t0 (即 0x10008)
    
loop:
    beq x0, x0, loop        # endless loop


# UP 键中断
int_up:
    addi t0, t0, 0x4
    sw t1, 0(t0)
    uret

# DOWN 键中断
int_down:
    addi t0, t0, 0x4
    sw t2, 0(t0)
    uret

# LEFT 键中断
int_left:
    addi t0, t0, 0x4
    sw t3, 0(t0)
    uret

# RIGHT 键中断
int_right:
    addi t0, t0, 0x4
    sw t4, 0(t0)
    uret
