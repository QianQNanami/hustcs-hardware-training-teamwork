int_up:
  addi sp, sp, -64
  
  sw t0, 0(sp)
  sw t1, 4(sp)
  
  li t0, 0x600000
  li t1, 1
  sw t1, 0(t0)
  
  lw t1, 4(sp)
  lw t0, 0(sp)
  
  addi sp, sp, 64
  uret

int_down:
  addi sp, sp, -64
  
  sw t0, 0(sp)
  sw t1, 4(sp)
  
  li t0, 0x600000
  li t1, 2
  sw t1, 0(t0)
  
  lw t1, 4(sp)
  lw t0, 0(sp)
  
  addi sp, sp, 64
  uret

int_left:
  addi sp, sp, -64
  
  sw t0, 0(sp)
  sw t1, 4(sp)
  
  li t0, 0x600000
  li t1, 3
  sw t1, 0(t0)
  
  lw t1, 4(sp)
  lw t0, 0(sp)
  
  addi sp, sp, 64
  uret

int_right:
  addi sp, sp, -64
  
  sw t0, 0(sp)
  sw t1, 4(sp)
  
  li t0, 0x600000
  li t1, 4
  sw t1, 0(t0)
  
  lw t1, 4(sp)
  lw t0, 0(sp)
  
  addi sp, sp, 64
  uret

int_center:
  addi sp, sp, -64
  
  sw t0, 0(sp)
  sw t1, 4(sp)
  
  li t0, 0x600000
  li t1, 5
  sw t1, 0(t0)
  
  lw t1, 4(sp)
  lw t0, 0(sp)
  
  addi sp, sp, 64
  uret
