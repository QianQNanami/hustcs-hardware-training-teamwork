#include "vga.h"

void set_pixel(int x, int y, int c) {
  if (x < 0 || x >= VRAM_WIDTH || y < 0 || y >= VRAM_HEIGHT) {
    return;
  }
  int *vram = (int *)VRAM_BASE_ADDR;
  vram[VRAM_OFFSET(x, y)] = c;
  // for (int i = 0; i < x; i++)
  //   vram += VRAM_WIDTH;
  // vram += y;
  // *vram = c;
}

void clear_screen() {
  int *vram = (int *)VRAM_BASE_ADDR;
  for (int i = 0; i < VRAM_SIZE; i++) {
    vram[i] = 0;
  }
}

void render_screen(int *image) {
  int *vram = (int *)VRAM_BASE_ADDR;
  for (int i = 0; i < VRAM_SIZE; i++) {
    vram[i] = image[i];
  }
}