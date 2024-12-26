.text
    addi t0, x0, 0x0      # t0 = 0x0

    # ������ 0xF00 �洢���Ĵ��� t1
    addi t1, x0, 0xF0        # t1 = 0xF0
    slli t1, t1, 4           # t1 = 0xF00

    # ������ 0x0F0 �洢���Ĵ��� t2
    addi t2, x0, 0xF0        # t2 = 0x0F0

    # ������ 0x00F �洢���Ĵ��� t3
    addi t3, x0, 0xF         # t3 = 0x00F

    # ������ 0xFFF �洢���Ĵ��� t4
    addi t4, x0, 0xFF        # t4 = 0xFF
    slli t4, t4, 4           # t4 = 0xFF0
    addi t4, t4, 0xF         # t4 = 0xFFF

    # ������д��ָ����ַ
    sw t1, 0(t0)            # �� t1 ��ֵ�洢����ַ t0 (�� 0x10008)
    
loop:
    beq x0, x0, loop        # endless loop


# UP ���ж�
int_up:
    addi t0, t0, 0x4
    sw t1, 0(t0)
    uret

# DOWN ���ж�
int_down:
    addi t0, t0, 0x4
    sw t2, 0(t0)
    uret

# LEFT ���ж�
int_left:
    addi t0, t0, 0x4
    sw t3, 0(t0)
    uret

# RIGHT ���ж�
int_right:
    addi t0, t0, 0x4
    sw t4, 0(t0)
    uret
