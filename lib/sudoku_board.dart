import 'dart:math';

class Sudoku {
  late List<List<int>> board;
  late List<List<bool>> _fixedCells;

  static const int boardSize = 9; // Size of the Sudoku board

  Sudoku({required int level}) {
    board = List.generate(boardSize, (_) => List.generate(boardSize, (_) => 0));
    _fixedCells = List.generate(
      boardSize,
      (_) => List.generate(boardSize, (_) => false),
    );
    _generateValidSudoku(level);
  }

  void _generateValidSudoku(int level) {
    _fillBoard(0, 0);
    _removeRandomNumbers(level);
  }

  // Recursive method to fill the board with valid numbers
  bool _fillBoard(int row, int col) {
    if (row == boardSize) return true;
    if (col == boardSize) return _fillBoard(row + 1, 0);
    if (board[row][col] != 0) return _fillBoard(row, col + 1);

    var numbers = List.generate(boardSize, (index) => index + 1)..shuffle();
    for (int num in numbers) {
      if (_isValidMove(row, col, num)) {
        board[row][col] = num;
        if (_fillBoard(row, col + 1)) return true;
        board[row][col] = 0;
      }
    }
    return false;
  }

  // Randomly remove numbers based on the difficulty level
  void _removeRandomNumbers(int level) {
    Random random = Random();
    int cellsToRemove = _getCellsToRemove(level);

    while (cellsToRemove > 0) {
      int row = random.nextInt(boardSize);
      int col = random.nextInt(boardSize);
      if (board[row][col] != 0) {
        board[row][col] = 0;
        _fixedCells[row][col] = false;
        cellsToRemove--;
      }
    }

    _markFixedCells();
  }

  // Return the number of cells to remove based on the level
  int _getCellsToRemove(int level) {
    switch (level) {
      case 1:
        return 30; // Easy
      case 2:
        return 40; // Medium
      case 3:
        return 50; // Hard
      default:
        return 30;
    }
  }

  // Mark cells that should be fixed (non-editable by user)
  void _markFixedCells() {
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (board[row][col] != 0) {
          _fixedCells[row][col] = true;
        }
      }
    }
  }

  // Check if placing 'num' at (row, col) is a valid move
  bool _isValidMove(int row, int col, int num) {
    for (int i = 0; i < boardSize; i++) {
      if (board[row][i] == num || board[i][col] == num) return false;
    }

    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[startRow + i][startCol + j] == num) return false;
      }
    }
    return true;
  }

  // Check if the user input is valid
  bool isValidInput(int row, int col, int num) {
    return num == 0 || _isValidMove(row, col, num);
  }

  // Check if the board is completely and correctly solved
  bool isSolved() {
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (board[row][col] == 0 || !_isValidMove(row, col, board[row][col])) {
          return false;
        }
      }
    }
    return true;
  }

  // Check if a cell is fixed (cannot be edited)
  bool isCellFixed(int row, int col) {
    return _fixedCells[row][col];
  }

  // Reset the board to its initial state
  void resetBoard() {
    board = List.generate(boardSize, (_) => List.generate(boardSize, (_) => 0));
    _fixedCells = List.generate(
      boardSize,
      (_) => List.generate(boardSize, (_) => false),
    );
  }
}
