import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'game_logic.dart';
import 'country_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(Game2048App());
}

class Game2048App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048 Game',
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
  String country = 'Fetching...';

  @override
  void initState() {
    super.initState();
    game = Game2048(gridSize: 4);
    fetchCountry();
  }

  Future<void> fetchCountry() async {
    country = await CountryService.fetchCountry();
    setState(() {});
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

    if (game.isGameOver()) {
      handleGameOver();
    }
  }

  void handleGameOver() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Game Over!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: ${game.score}'),
            TextField(
              onChanged: (value) {
                setState(() {
                  country = value;
                });
              },
              decoration: InputDecoration(labelText: 'Enter your name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              game.resetGame();
              setState(() {});
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }

  Widget buildTile(int value) {
    return Container(
      margin: EdgeInsets.all(4),
      width: 80,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: value == 0 ? Colors.grey[300] : Colors.orangeAccent,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('2048 - Country: $country'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              game.resetGame();
              setState(() {});
            },
          ),
        ],
      ),
      body: GestureDetector(
        onPanEnd: (details) =>
            handleSwipe(details, details.velocity.pixelsPerSecond),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: game.grid.map((row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((value) => buildTile(value)).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
