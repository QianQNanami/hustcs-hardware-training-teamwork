// #include "lib/vga.h"

// int main() {
//   clear_screen();
//   int image[VRAM_WIDTH * VRAM_HEIGHT];
//   for (int i = 0; i < VRAM_HEIGHT; i++) {
//     for (int j = 0; j < VRAM_WIDTH; j++) {
//       if (i == 0 || i == VRAM_HEIGHT - 1 || j == 0 || j == VRAM_WIDTH - 1)
//         image[VRAM_OFFSET(i, j)] = 0xF00;
//       else
//         image[VRAM_OFFSET(i, j)] = 0x00F;
//     }
//   }
//   render_screen(image);
//   for (;;) {
//   }
//   return 0;
// }

int screen[128][96];

int main() {
  // int* addr = (int*)0x10008;
  // *addr = 0xF0F;

  screen[1][1] = 0xF00;
  return 0;
}