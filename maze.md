- size: $48\times 64$

Registers:

```asm
    // x1: nowa x
    // x2: nowa y
    // x3: new x
    // x4: new y
    // x5: step count
    // x6: nowa position addr in memory
    // x7: nowa position object
    // x8: x upper bound
    // x9: y upper bound
    // x10: wall
    // x11: road
    // x12: target x
    // x13: target y
    // x14: position
    // maze: 48x60, range: [0,47]x[0,59]
    // Memory: 0x0 - 0xB40
    // (i,j) offset: 60*i + j
```