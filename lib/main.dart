// main.dart
// Michelle Lee

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "game_state.dart";
import "tile_widget.dart";

void main()
{ runApp(MyApp());
}

class MyApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  { return MaterialApp
    ( title: "2048",
      home: GameHome(),
    );
  }
}

class GameHome extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  { return BlocProvider<GameCubit>
    ( create: (context) => GameCubit(),
      child: BlocBuilder<GameCubit, GameState>
      ( builder: (context, state) => GameView(),
      ),
    );
  }
}

class GameView extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    GameCubit gc = BlocProvider.of<GameCubit>(context);
    GameState gs = gc.state;

    // Create the 4x4 grid using TileWidgets
    Row theGrid = Row(mainAxisSize: MainAxisSize.min, children: []);
    for (int i = 0; i < 4; i++)
    { Column col = Column(children: []);
      for (int j = 0; j < 4; j++)
      { col.children.add(TileWidget(gs.board[i][j])); }
      theGrid.children.add(col);
    }
    // keyboard implementation
    return Focus
    ( autofocus: true,
      onKeyEvent: (_, event)
      {
        if (event is! KeyDownEvent)
        {
          return KeyEventResult.ignored;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowUp)
        {
          gc.moveUp();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowDown)
        {
          gc.moveDown();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft)
        {
          gc.moveLeft();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight)
        {
          gc.moveRight();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold
      ( appBar: AppBar(title: Text("2048")),
        // swipe implementation
        body: GestureDetector
        ( onVerticalDragEnd: (details)
          { if (details.primaryVelocity! < 0) { gc.moveUp(); }
            else { gc.moveDown(); }
          },
          onHorizontalDragEnd: (details)
          { if (details.primaryVelocity! < 0) { gc.moveLeft(); }
            else { gc.moveRight(); }
          },
          child: Column
          ( children:
            [ Container(height: 20),
              Text("Score: ${gs.score}", style: TextStyle(fontSize: 24)),
              Text("Best: ${gs.highScore}", style: TextStyle(fontSize: 18)),
              Container(height: 20),
              Container // brown game board background
              ( color: Color(0xFFBBADA0),
                padding: EdgeInsets.all(8),
                child: theGrid,
              ),
              Container(height: 20),
              gs.isGameOver()
                ? Text("Game Over!", style: TextStyle(fontSize: 32, color: Colors.red))
                : Container(),
              Container(height: 10),
              Row // up button
              ( mainAxisAlignment: MainAxisAlignment.center,
                children:
                [ ElevatedButton(onPressed: () => gc.moveUp(), child: Text("↑")),
                ],
              ),
              Row // left, down, right buttons
              ( mainAxisAlignment: MainAxisAlignment.center,
                children:
                [ ElevatedButton(onPressed: () => gc.moveLeft(), child: Text("←")),
                  Container(width: 10),
                  ElevatedButton(onPressed: () => gc.moveDown(), child: Text("↓")),
                  Container(width: 10),
                  ElevatedButton(onPressed: () => gc.moveRight(), child: Text("→")),
                ],
              ),
              Container(height: 10),
              ElevatedButton(onPressed: () => gc.restart(), child: Text("Restart")),
            ],
          ),
        ),
      ),
    );
  }
}