// TODO: console io only for test
#include <stdio.h>
#include <conio.h>

#define BOOL unsigned
#define TRUE 1
#define FALSE 0

#define NONE 0
#define UP 1
#define DOWN 2
#define LEFT 3
#define RIGHT 4
#define CENTER 5

#define SIZE 4
#define WINNING_TILE 2048

typedef struct {
    int board[SIZE][SIZE];
    unsigned score;
    unsigned randSeed;
} GameState;

unsigned randSeedNext(GameState* game) {
    game->randSeed = game->randSeed * 1103515245 + 12345;
    return (game->randSeed / 65536) % 32768;
}

void addRandomTile(GameState* game);
void initGame(GameState* game) {
    for (unsigned i = 0; i < SIZE; i++) {
        for (unsigned j = 0; j < SIZE; j++) {
            game->board[i][j] = 0;
        }
    }
    game->score = 0;
    game->randSeed = 0xACE1u;
    addRandomTile(game);
    addRandomTile(game);
}

BOOL isGameOver(GameState* game) {
    for (unsigned i = 0; i < SIZE; i++) {
        for (unsigned j = 0; j < SIZE; j++) {
            if (game->board[i][j] == 0) return FALSE;
            if (i + 1 < SIZE && game->board[i][j] == game->board[i + 1][j]) return FALSE;
            if (j + 1 < SIZE && game->board[i][j] == game->board[i][j + 1]) return FALSE;
        }
    }
    return TRUE;
}

BOOL checkWin(GameState* game) {
    for (unsigned i = 0; i < SIZE; i++) {
        for (unsigned j = 0; j < SIZE; j++) {
            if (game->board[i][j] == WINNING_TILE) return TRUE;
        }
    }
    return FALSE;
}

void addRandomTile(GameState* game) {
    int emptySpaces[SIZE * SIZE][2];
    unsigned emptyCount = 0;

    for (unsigned i = 0; i < SIZE; i++) {
        for (unsigned j = 0; j < SIZE; j++) {
            if (game->board[i][j] == 0) {
                emptySpaces[emptyCount][0] = i;
                emptySpaces[emptyCount][1] = j;
                emptyCount++;
            }
        }
    }

    if (emptyCount == 0) return;

    unsigned idx = randSeedNext(game) % emptyCount;
    unsigned i = emptySpaces[idx][0], j = emptySpaces[idx][1];
    game->board[i][j] = (randSeedNext(game) % 10 == 0) ? 4 : 2;
}

BOOL moveUp(GameState* game) {
    BOOL moved = FALSE;
    int originalBoard[SIZE][SIZE];

    for (unsigned i = 0; i < SIZE; i++) {
        for (unsigned j = 0; j < SIZE; j++) {
            originalBoard[i][j] = game->board[i][j];
        }
    }

    for (unsigned col = 0; col < SIZE; col++) {
        int column[SIZE];
        unsigned len = 0;
        for (unsigned row = 0; row < SIZE; row++) {
            if (game->board[row][col] != 0) column[len++] = game->board[row][col];
        }

        unsigned newLen = 0;
        for (unsigned i = 0; i < len; i++) {
            if (i + 1 < len && column[i] == column[i + 1]) {
                game->board[newLen][col] = column[i] * 2;
                game->score += column[i] * 2;
                i++;
            }
            else {
                game->board[newLen][col] = column[i];
            }
            newLen++;
        }

        for (unsigned i = newLen; i < SIZE; i++) {
            game->board[i][col] = 0;
        }
    }

    for (unsigned i = 0; i < SIZE; i++) {
        for (unsigned j = 0; j < SIZE; j++) {
            if (game->board[i][j] != originalBoard[i][j]) {
                moved = TRUE;
                break;
            }
        }
    }

    return moved;
}

BOOL moveLeft(GameState* game) {
    BOOL moved = FALSE;
    int originalBoard[SIZE][SIZE];

    for (unsigned i = 0; i < SIZE; i++) {
        for (unsigned j = 0; j < SIZE; j++) {
            originalBoard[i][j] = game->board[i][j];
        }
    }

    for (unsigned row = 0; row < SIZE; row++) {
        int line[SIZE];
        unsigned len = 0;

        for (unsigned col = 0; col < SIZE; col++) {
            if (game->board[row][col] != 0) line[len++] = game->board[row][col];
        }

        unsigned newLen = 0;
        for (unsigned i = 0; i < len; i++) {
            if (i + 1 < len && line[i] == line[i + 1]) {
                game->board[row][newLen] = line[i] * 2;
                game->score += line[i] * 2;
                i++;
            }
            else {
                game->board[row][newLen] = line[i];
            }
            newLen++;
        }

        for (unsigned i = newLen; i < SIZE; i++) {
            game->board[row][i] = 0;
        }
    }

    for (unsigned i = 0; i < SIZE; i++) {
        for (unsigned j = 0; j < SIZE; j++) {
            if (game->board[i][j] != originalBoard[i][j]) {
                moved = TRUE;
                break;
            }
        }
    }

    return moved;
}


BOOL moveDown(GameState* game) {
    BOOL moved = FALSE;
    int originalBoard[SIZE][SIZE];

    for (unsigned i = 0; i < SIZE; i++) {
        for (unsigned j = 0; j < SIZE; j++) {
            originalBoard[i][j] = game->board[i][j];
        }
    }

    for (unsigned col = 0; col < SIZE; col++) {
        int column[SIZE];
        unsigned len = 0;

        for (int row = SIZE - 1; row >= 0; row--) {
            if (game->board[row][col] != 0) column[len++] = game->board[row][col];
        }

        unsigned newLen = 0;
        for (unsigned i = 0; i < len; i++) {
            if (i + 1 < len && column[i] == column[i + 1]) {
                game->board[SIZE - 1 - newLen][col] = column[i] * 2;
                game->score += column[i] * 2;
                i++;
            }
            else {
                game->board[SIZE - 1 - newLen][col] = column[i];
            }
            newLen++;
        }

        for (unsigned i = newLen; i < SIZE; i++) {
            game->board[SIZE - 1 - i][col] = 0;
        }
    }

    for (unsigned i = 0; i < SIZE; i++) {
        for (unsigned j = 0; j < SIZE; j++) {
            if (game->board[i][j] != originalBoard[i][j]) {
                moved = TRUE;
                break;
            }
        }
    }

    return moved;
}

BOOL moveRight(GameState* game) {
    BOOL moved = FALSE;
    int originalBoard[SIZE][SIZE];

    for (unsigned i = 0; i < SIZE; i++) {
        for (unsigned j = 0; j < SIZE; j++) {
            originalBoard[i][j] = game->board[i][j];
        }
    }

    for (unsigned row = 0; row < SIZE; row++) {
        int line[SIZE];
        unsigned len = 0;

        for (int col = SIZE - 1; col >= 0; col--) {
            if (game->board[row][col] != 0) line[len++] = game->board[row][col];
        }

        unsigned newLen = 0;
        for (unsigned i = 0; i < len; i++) {
            if (i + 1 < len && line[i] == line[i + 1]) {
                game->board[row][SIZE - 1 - newLen] = line[i] * 2;
                game->score += line[i] * 2;
                i++;
            }
            else {
                game->board[row][SIZE - 1 - newLen] = line[i];
            }
            newLen++;
        }

        for (unsigned i = newLen; i < SIZE; i++) {
            game->board[row][SIZE - 1 - i] = 0;
        }
    }

    for (unsigned i = 0; i < SIZE; i++) {
        for (unsigned j = 0; j < SIZE; j++) {
            if (game->board[i][j] != originalBoard[i][j]) {
                moved = TRUE;
                break;
            }
        }
    }

    return moved;
}

int get_key() {
    // TODO: input
    int dir;
    dir = _getch();
    dir = (dir == 'w' ? UP : (dir == 'a' ? LEFT : (dir == 's' ? DOWN : (dir == 'd' ? RIGHT : NONE))));
    return dir;
}

void printBoard(GameState* game) {
    // TODO: output
    system("cls");
    printf("\nScore: %u\n\n", game->score);
    for (unsigned i = 0; i < SIZE; i++) {
        for (unsigned j = 0; j < SIZE; j++) {
            if (game->board[i][j] == 0)
                printf("   . ");
            else
                printf("%4d ", game->board[i][j]);
        }
        printf("\n");
    }
}

void printGameOver(BOOL suc) {
    // TODO: output
    suc ? printf("You Win!\n") : printf("Game Over!");
    _getch();
}


int main() {
    while (TRUE) {
        GameState game;
        initGame(&game);
        while (TRUE) {
            printBoard(&game);

            if (isGameOver(&game)) {
                printGameOver(FALSE);
                break;
            }

            int move = get_key();

            BOOL moved = FALSE;
            switch (move) {
            case UP: moved = moveUp(&game); break;
            case LEFT: moved = moveLeft(&game); break;
            case DOWN: moved = moveDown(&game); break;
            case RIGHT: moved = moveRight(&game); break;
            default: continue;
            }

            if (moved) {
                addRandomTile(&game);
                if (checkWin(&game)) {
                    printGameOver(TRUE);
                    break;
                }
            }
        }
    }
    return 0;
}
