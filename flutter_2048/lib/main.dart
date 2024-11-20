import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'game_logic.dart';
import 'country_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
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
  String playerName = '';
  String country = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    game = Game2048(gridSize: 4);
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
                playerName = value;
              },
              decoration: InputDecoration(labelText: 'Enter your name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                isLoading = true;
              });

              // Fetch country
              country = await CountryService.fetchCountry();

              // Save data to Firebase
              await CountryService.saveToFirebase(playerName, game.score, country);

              setState(() {
                isLoading = false;
              });

              // Reset the game
              game.resetGame();
              setState(() {});
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('2048 Game'),
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SizedBox(height: 16),
          Text(
            'Score: ${game.score}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: GestureDetector(
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
                        ),
                      ),
                    );
                  }).toList(),
                ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
