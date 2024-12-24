#include "key.h"

int get_key() {
  int key = *(int*)0x600000;
  while (key != 0) {
    key = *(int*)0x600000;
  }
  return key;
}