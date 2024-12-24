#pragma once
#include <vector>
using namespace std;

class Game {
public:
    Game();
    void play();

private:
    vector<vector<int>> board;
    int score;
    void addRandomTile();
    bool moveUp();
    bool moveLeft();
    bool moveDown();
    bool moveRight();
    vector<int> merge(vector<int>& line);
    bool isGameOver();
    bool checkWin();
    char getInput();
    void printBoard();
    void printGameOver(bool suc);
};
