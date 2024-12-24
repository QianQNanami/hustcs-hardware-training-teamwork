#include "std.h"

int __modsi3(int a, int b) {
    return a - (a / b) * b;
}

int __mulsi3(int a, int b) {
  int negative = 0;
  if (a < 0) {
    a = -a;
    negative = !negative;
  }
  if (b < 0) {
    b = -b;
    negative = !negative;
  }

  int result = 0;
  while (b != 0) {
    if (b & 1) {
        result += a;
    }
    a <<= 1;
    b >>= 1;
  }

  return negative ? -result : result;
}
