#define VRAM_BASE_ADDR 0x100000  // the start address of VRAM
#define SCREEN_WIDTH 1024   // the width of the screen
#define SCREEN_HEIGHT 768   // the height of the screen
#define SCREEN_SIZE 786432
#define SCALE_RATIO \
  8  // the scale ratio of the screen, 8 means 1 pixel in VRAM is 8x8 pixels on
     // the screen
#define VRAM_WIDTH (SCREEN_WIDTH / SCALE_RATIO)    // the width of VRAM: 128
#define VRAM_HEIGHT (SCREEN_HEIGHT / SCALE_RATIO)  // the height of VRAM: 96
#define VRAM_SIZE 12288

#define VRAM_OFFSET(x, y) ((x)*VRAM_WIDTH + (y))  // get the address offset relative to VRAM_ADDR

/*
  the screen is as follows:
  |-------------------|
  |                   |
  |                   |
  |      screen       | HEIGHT->x
  |                   | 
  |                   |
  |-------------------|
        WIDTH->y

  Each pixel in the screen is 8x8 pixels in VRAM.
  The color of each pixel is represented by a 12-bit integer,
  the meaning of each bit is RRRRGGGGBBBB.
*/


// set the color of the pixel at (x, y) to c
// c: RRRRGGGGBBBB
void set_pixel(int x, int y, int c);

// clear the screen
void clear_screen();

// render the screen
// image: an array of **VRAM_WIDTH * VRAM_HEIGHT** integers, each integer represents the color of a pixel
void render_screen(int *image);
