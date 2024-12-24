#include <iostream>
#include <vector>
#include <ctime>
#include <cstdlib>
#include <iomanip>
#include <conio.h>
#include "game.h"

using namespace std;

const int SIZE = 4;
const int WINNING_TILE = 2048;

Game::Game() {
    board.resize(SIZE, vector<int>(SIZE, 0));
    srand(time(0));
    addRandomTile();
    addRandomTile();
}

void Game::play() {
    while (true) {
        printBoard();
        if (isGameOver()) {
            printGameOver(false);
            break;
        }

        char move = getInput();

        bool moved = false;
        switch (move) {
        case 'w': moved = moveUp(); break;
        case 'a': moved = moveLeft(); break;
        case 's': moved = moveDown(); break;
        case 'd': moved = moveRight(); break;
        default: continue;
        }

        if (moved) {
            addRandomTile();
            if (checkWin()) {
                printGameOver(true);
                break;
            }
        }
    }
}

void Game::addRandomTile() {
    vector<pair<int, int>> emptySpaces;
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            if (board[i][j] == 0) {
                emptySpaces.push_back({ i, j });
            }
        }
    }

    if (emptySpaces.empty()) return;

    int idx = rand() % emptySpaces.size();
    pair<int, int> selected = emptySpaces[idx];
    board[selected.first][selected.second] = (rand() % 10 == 0) ? 4 : 2;
}

bool Game::moveUp() {
    bool moved = false;
    vector<vector<int>> originalBoard = board;

    for (int col = 0; col < SIZE; col++) {
        vector<int> column;
        for (int row = 0; row < SIZE; row++) {
            if (board[row][col] != 0) column.push_back(board[row][col]);
        }
        vector<int> mergedColumn = merge(column);
        int index = 0;
        for (int row = 0; row < SIZE; row++) {
            if (index < mergedColumn.size()) {
                board[row][col] = mergedColumn[index++];
            }
            else {
                board[row][col] = 0;
            }
        }
    }
    if (board != originalBoard) {
        moved = true;
    }
    return moved;
}

bool Game::moveLeft() {
    bool moved = false;
    vector<vector<int>> originalBoard = board;

    for (int row = 0; row < SIZE; row++) {
        vector<int> line;
        for (int col = 0; col < SIZE; col++) {
            if (board[row][col] != 0) line.push_back(board[row][col]);
        }
        vector<int> mergedLine = merge(line);
        int index = 0;
        for (int col = 0; col < SIZE; col++) {
            if (index < mergedLine.size()) {
                board[row][col] = mergedLine[index++];
            }
            else {
                board[row][col] = 0;
            }
        }
    }
    if (board != originalBoard) {
        moved = true;
    }
    return moved;
}

bool Game::moveDown() {
    bool moved = false;
    vector<vector<int>> originalBoard = board;

    for (int col = 0; col < SIZE; col++) {
        vector<int> column;
        for (int row = SIZE - 1; row >= 0; row--) {
            if (board[row][col] != 0) column.push_back(board[row][col]);
        }
        vector<int> mergedColumn = merge(column);
        int index = 0;
        for (int row = SIZE - 1; row >= 0; row--) {
            if (index < mergedColumn.size()) {
                board[row][col] = mergedColumn[index++];
            }
            else {
                board[row][col] = 0;
            }
        }
    }
    if (board != originalBoard) {
        moved = true;
    }
    return moved;
}

bool Game::moveRight() {
    bool moved = false;
    vector<vector<int>> originalBoard = board;

    for (int row = 0; row < SIZE; row++) {
        vector<int> line;
        for (int col = SIZE - 1; col >= 0; col--) {
            if (board[row][col] != 0) line.push_back(board[row][col]);
        }
        vector<int> mergedLine = merge(line);
        int index = 0;
        for (int col = SIZE - 1; col >= 0; col--) {
            if (index < mergedLine.size()) {
                board[row][col] = mergedLine[index++];
            }
            else {
                board[row][col] = 0;
            }
        }
    }
    if (board != originalBoard) {
        moved = true;
    }
    return moved;
}


vector<int> Game::merge(vector<int>& line) {
    vector<int> newLine;
    for (int i = 0; i < line.size(); i++) {
        if (i + 1 < line.size() && line[i] == line[i + 1]) {
            newLine.push_back(line[i] * 2);
            score += line[i] * 2;
            i++;
        }
        else {
            newLine.push_back(line[i]);
        }
    }
    while (newLine.size() < SIZE) newLine.push_back(0);
    return newLine;
}

bool Game::isGameOver() {
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            if (board[i][j] == 0) return false;
            if (i + 1 < SIZE && board[i][j] == board[i + 1][j]) return false;
            if (j + 1 < SIZE && board[i][j] == board[i][j + 1]) return false;
        }
    }
    return true;
}

bool Game::checkWin() {
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            if (board[i][j] == WINNING_TILE) return true;
        }
    }
    return false;
}

char Game::getInput() {
    char dir;
    dir = _getch();
    return dir;
}

void Game::printBoard() {
    system("cls");
    cout << "score: " << score << endl << endl;
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            if (board[i][j] == 0)
                cout << setw(5) << '.';
            else
                cout << setw(5) << board[i][j];
        }
        cout << endl;
    }
}

void Game::printGameOver(bool suc){
    if (suc) cout << "You Win!" << endl;
    else cout << "Game Over!" << endl;
    _getch();
}