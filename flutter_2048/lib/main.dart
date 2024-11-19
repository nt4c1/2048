import 'package:flutter/material.dart';
import 'game_logic.dart';

void main() {
  runApp(Game2048App());
}

class Game2048App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Game2048Screen(),
    );
  }
}

class Game2048Screen extends StatefulWidget {
  @override
  _Game2048ScreenState createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  late Game2048 game;

  @override
  void initState() {
    super.initState();
    game = Game2048(gridSize: 4);
  }

  void handleSwipe(DragEndDetails details, Offset velocity) {
    if (velocity.dx.abs() > velocity.dy.abs()) {
      if (velocity.dx > 0) {
        game.moveRight();
      } else {
        game.moveLeft();
      }
    } else {
      if (velocity.dy > 0) {
        game.moveDown();
      } else {
        game.moveUp();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('2048 Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                game.resetGame();
              });
            },
          )
        ],
      ),
      body: GestureDetector(
        onPanEnd: (details) =>
            handleSwipe(details, details.velocity.pixelsPerSecond),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: game.grid
              .map((row) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((value) {
              return Container(
                margin: EdgeInsets.all(4),
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: value == 0
                      ? Colors.grey[300]
                      : Colors.orangeAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value == 0 ? '' : '$value',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              );
            }).toList(),
          ))
              .toList(),
        ),
      ),
    );
  }
}
