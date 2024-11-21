import 'dart:math';

class Game2048 {
  late List<List<int>> grid;
  final int gridSize;
  int score = 0;

  Game2048({this.gridSize = 4}) {
    resetGame();
  }

  void resetGame() {
    grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    score = 0;
    generateRandomTile();  // Initial random tile generation
    generateRandomTile();  // Initial random tile generation
  }

  // Generates a random tile (2 or 4) in an empty cell
  void generateRandomTile() {
    List<int> emptyCells = [];

    // Collect all the empty cells (those with value 0)
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == 0) emptyCells.add(i * gridSize + j);
      }
    }

    // If there are any empty cells, place a new tile
    if (emptyCells.isNotEmpty) {
      int randomIndex = emptyCells[Random().nextInt(emptyCells.length)];
      int value = Random().nextDouble() < 0.9 ? 2 : 4;  // 90% chance of 2, 10% chance of 4
      grid[randomIndex ~/ gridSize][randomIndex % gridSize] = value;
    }
  }

  List<int> shiftAndMerge(List<int> line) {
    line = line.where((value) => value != 0).toList();
    for (int i = 0; i < line.length - 1; i++) {
      if (line[i] == line[i + 1]) {
        line[i] *= 2;
        line[i + 1] = 0;
        score += line[i];
      }
    }
    line = line.where((value) => value != 0).toList();
    while (line.length < gridSize) line.add(0);
    return line;
  }

  void moveLeft() {
    List<List<int>> oldGrid = cloneGrid();
    for (int i = 0; i < gridSize; i++) grid[i] = shiftAndMerge(grid[i]);
    if (!areGridsEqual(oldGrid, grid)) generateRandomTile();  // Generate new tile after move
  }

  void moveRight() {
    List<List<int>> oldGrid = cloneGrid();
    for (int i = 0; i < gridSize; i++) {
      grid[i] = shiftAndMerge(grid[i].reversed.toList()).reversed.toList();
    }
    if (!areGridsEqual(oldGrid, grid)) generateRandomTile();  // Generate new tile after move
  }

  void moveUp() {
    List<List<int>> oldGrid = cloneGrid();
    for (int j = 0; j < gridSize; j++) {
      List<int> column = List.generate(gridSize, (i) => grid[i][j]);
      column = shiftAndMerge(column);
      for (int i = 0; i < gridSize; i++) {
        grid[i][j] = column[i];
      }
    }
    if (!areGridsEqual(oldGrid, grid)) generateRandomTile();  // Generate new tile after move
  }

  void moveDown() {
    List<List<int>> oldGrid = cloneGrid();
    for (int j = 0; j < gridSize; j++) {
      List<int> column = List.generate(gridSize, (i) => grid[i][j]).reversed.toList();
      column = shiftAndMerge(column).reversed.toList();
      for (int i = 0; i < gridSize; i++) {
        grid[i][j] = column[i];
      }
    }
    if (!areGridsEqual(oldGrid, grid)) generateRandomTile();  // Generate new tile after move
  }

  bool isGameOver() {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j] == 0) return false;
        // Check for possible merges horizontally and vertically
        if (j < gridSize - 1 && grid[i][j] == grid[i][j + 1]) return false;
        if (i < gridSize - 1 && grid[i][j] == grid[i + 1][j]) return false;
      }
    }
    return true; // No moves left
  }

  List<List<int>> cloneGrid() {
    return grid.map((row) => row.cast<int>()).toList();
  }

  bool areGridsEqual(List<List<int>> grid1, List<List<int>> grid2) {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid1[i][j] != grid2[i][j]) return false;
      }
    }
    return true;
  }
}
