// game_state.dart
// Michelle Lee

import "dart:io";
import "dart:math";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:just_audio/just_audio.dart";
import "package:path_provider/path_provider.dart";

class GameState
{
  AudioPlayer player;
  List<List<int>> board;
  int score;
  int highScore;

  // constructor for emit() - keeps the existing player
  GameState
  ({ required this.player,
     required this.board,
     required this.score,
     required this.highScore,
  });

  GameState.init( this.board, this.score, this.highScore )
  : player = AudioPlayer();

  void dispose()
  { player.dispose(); }

  bool isGameOver()
  {
    for ( int r = 0; r < 4; r++ )
    { for ( int c = 0; c < 4; c++ )
      { // empty cell
        if (board[r][c] == 0) return false;
        // check right
        if (c < 3 && board[r][c] == board[r][c + 1]) return false;
        // check below
        if (r < 3 && board[r][c] == board[r + 1][c]) return false;
      }
    }
    return true;
  }
}

class GameCubit extends Cubit<GameState>
{
  GameCubit() : super( GameState.init(_newBoard(), 0, 0) )
  {
    _addRandomTile();
    _addRandomTile();
    loadHighScore();
  }

  // create a new 4x4 list filled with 0s
  static List<List<int>> _newBoard()
  {
    List<List<int>> board = [];
    for ( int i = 0; i < 4; i++ )
    { List<int> row = [];
      for ( int j = 0; j < 4; j++ )
      { row.add(0); }
      board.add(row);
    }
    return board;
  }

  void update()
  { emit
    ( GameState
      ( player: state.player,
        board: state.board,
        score: state.score,
        highScore: state.highScore,
      ),
    );
  }

  // play the merge sound effect
  Future<void> playMergeSound() async
  {
    await state.player.setAsset('assets/sounds/sound.mp3');
    state.player.play();
  }

  Future<String> whereAmI() async
  {
    Directory mainDir = await getApplicationDocumentsDirectory();
    String mainDirPath = mainDir.path;
    return mainDirPath;
  }

  Future<void> loadHighScore() async
  {
    String myStuff = await whereAmI();
    String filePath = "$myStuff/highscore.txt";
    File fodder = File(filePath);
    
      String contents = fodder.readAsStringSync();
      state.highScore = int.parse(contents.trim());
    
    update();
  }

  Future<void> saveHighScore() async
  {
    String myStuff = await whereAmI();
    String filePath = "$myStuff/highscore.txt";
    File fodder = File(filePath);
    fodder.writeAsStringSync("${state.highScore}");
  }

  void _checkHighScore()
  {
    if (state.score > state.highScore)
    {
      state.highScore = state.score;
      saveHighScore();
    }
  }

  void _addRandomTile()
  {
    List<List<int>> empty = [];
    //loop through and we find all empty cells
    for ( int i = 0; i < 4; i++ )
    { for ( int j = 0; j < 4; j++ )
      { if (state.board[i][j] == 0) empty.add([i, j]); }
    }
    if (empty.isEmpty) return;
    var spot = empty[Random().nextInt(empty.length)];

    state.board[spot[0]][spot[1]] = 2;
  }

  void moveUp()
  {
    // gets current baord
    List<List<int>> before = List.generate(4, (r) => List.from(state.board[r]));
    for ( int r = 0; r < 4; r++ )
    {
      // find all nonzero values in the row and put them in a list
      List<int> row = state.board[r].where((v) => v != 0).toList();
      for ( int c = 0; c < row.length - 1; c++ )
      {
        // if value to the right is the same, merge and update score
        if (row[c] == row[c + 1])
        {
          row[c] *= 2;
          state.score += row[c];
          row.removeAt(c + 1);
          playMergeSound();
        }
      }
      // add back empty cells to the end of the row
      while (row.length < 4){
        row.add(0);
      } 
      state.board[r] = row;
    }
    // it any blocks are merged
    if (_boardChanged(before, state.board)) _addRandomTile();
    _checkHighScore();
    update();
  }

  void moveDown()
  {
    List<List<int>> before = List.generate(4, (r) => List.from(state.board[r]));
    for ( int r = 0; r < 4; r++ )
    {
      List<int> row = state.board[r].where((v) => v != 0).toList().reversed.toList();
      for ( int c = 0; c < row.length - 1; c++ )
      {
        if (row[c] == row[c + 1])
        {
          row[c] *= 2;
          state.score += row[c];
          row.removeAt(c + 1);
          playMergeSound();
        }
      }
      while (row.length < 4) row.add(0);
      state.board[r] = row.reversed.toList();
    }
    if (_boardChanged(before, state.board)) _addRandomTile();
    _checkHighScore();
    update();
  }

  void moveLeft()
  {
    List<List<int>> before = List.generate(4, (r) => List.from(state.board[r]));
    for ( int c = 0; c < 4; c++ )
    {
      List<int> col = [ for (int r = 0; r < 4; r++) state.board[r][c] ]
                      .where((v) => v != 0)
                      .toList();
      for ( int r = 0; r < col.length - 1; r++ )
      {
        if (col[r] == col[r + 1])
        {
          col[r] *= 2;
          state.score += col[r];
          col.removeAt(r + 1);
          playMergeSound();
        }
      }
      while (col.length < 4) col.add(0);
      for ( int r = 0; r < 4; r++ ) state.board[r][c] = col[r];
    }
    if (_boardChanged(before, state.board)) _addRandomTile();
    _checkHighScore();
    update();
  }

  void moveRight()
  {
    List<List<int>> before = List.generate(4, (r) => List.from(state.board[r]));
    for ( int c = 0; c < 4; c++ )
    {
      List<int> col = [ for (int r = 0; r < 4; r++) state.board[r][c] ]
                      .where((v) => v != 0)
                      .toList()
                      .reversed
                      .toList();
      for ( int r = 0; r < col.length - 1; r++ )
      {
        if (col[r] == col[r + 1])
        {
          col[r] *= 2;
          state.score += col[r];
          col.removeAt(r + 1);
          playMergeSound();
        }
      }
      while (col.length < 4) col.add(0);
      col = col.reversed.toList();
      for ( int r = 0; r < 4; r++ ) state.board[r][c] = col[r];
    }
    if (_boardChanged(before, state.board)) _addRandomTile();
    _checkHighScore();
    update();
  }

  bool _boardChanged( List<List<int>> before, List<List<int>> after )
  {
    for ( int r = 0; r < 4; r++ )
    { for ( int c = 0; c < 4; c++ )
      { if (before[r][c] != after[r][c]) return true; }
    }
    return false;
  }

  void restart()
  {
    state.board = _newBoard();
    state.score = 0;
    _addRandomTile();
    _addRandomTile();
    update();
  }
}