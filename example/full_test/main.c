#include "lib/vga.h"
#include "lib/key.h"
#include "lib/std.h"

extern void int_up(void);
extern void int_down(void);
extern void int_left(void);
extern void int_right(void);
extern void int_center(void);

int main() {
  int colors[4] = {0xFFF, 0x00F, 0x0F0, 0xF00};

  int x = 0, y = 0, c = 0, key;
  // int image[VRAM_HEIGHT][VRAM_WIDTH];

  clear_screen();

  while (1) {
    key = get_key();
    // clear current pixel
    // image[x][y] = 0;
    set_pixel(x, y, 0);

    switch (key)
    {
    case UP:
      y = (y - 1 + VRAM_HEIGHT) % VRAM_HEIGHT;
      break;
    case DOWN:
      y = (y + 1) % VRAM_HEIGHT;
      break;
    case LEFT:
      x = (x - 1 + VRAM_WIDTH) % VRAM_WIDTH;
      break;
    case RIGHT:
      x = (x + 1) % VRAM_WIDTH;
      break;
    case CENTER:
      c = (c + 1) % 4;
      break;
    }

    // image[x][y] = colors[c];
    // render_screen((int *)image);
    set_pixel(x, y, colors[c]);
  }

  return 0;
}