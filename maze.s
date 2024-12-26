.text
    addi x1, x0, 21
    addi x2, x0, 26
    addi x6, x0, 5144
    addi x12, x0, 39
    addi x13, x0, 38
    addi x8, x0, 47
    addi x9, x0, 59
    addi x10, x0, 0xF00
    addi x11, x0, 0x0F0
    addi x14, x0, 0x00F
loop:
    bne x1, x12, loop
    bne x2, x13, loop
    j loop

int_up:
    beq x0, x1, retup
    lw x7, -240(x6)
    beq x7, x10, retup
    sw x11, 0(x6)
    addi x6, x6, -240
    sw x14, 0(x6)
    addi x1, x1, -1
    addi x5, x5, 1
retup:
    uret

int_left:
    beq x0, x2, retleft
    lw x7, -4(x6)
    beq x7, x10, retleft
    sw x11, 0(x6)
    addi x6, x6, -4
    sw x14, 0(x6)
    addi x2, x2, -1
    addi x5, x5, 1
retleft:
    uret

int_right:
    beq x2, x9, retright
    lw x7, 4(x6)
    beq x7, x10, retright
    sw x11, 0(x6)
    addi x6, x6, 4
    sw x14, 0(x6)
    addi x2, x2, 1
    addi x5, x5, 1
retright:
    uret

int_down:
    beq x1, x8, retdown
    lw x7, 240(x6)
    beq x7, x10, retdown
    sw x11, 0(x6)
    addi x6, x6, 240
    sw x14, 0(x6)
    addi x1, x1, 1
    addi x5, x5, 1
retdown:
    uret