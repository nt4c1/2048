import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'game_logic.dart';
import 'country_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String playerName = '';

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
      showGameOverDialog();
    }
  }

  void showGameOverDialog() {
    showDialog(
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
                  playerName = value;
                });
              },
              decoration: InputDecoration(labelText: 'Enter your name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Save data to Firestore
              await saveToFirestore(playerName, game.score, country);

              // Reset the game after submission
              game.resetGame();
              setState(() {});
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> saveToFirestore(String name, int score, String country) async {
    try {
      await FirebaseFirestore.instance.collection('players').add({
        'name': name,
        'score': score,
        'country': country,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Player data saved to Firestore.');
    } catch (e) {
      print('Error saving player data: $e');
    }
  }

  Widget buildTile(int value) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: EdgeInsets.all(4),
      width: 80,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: getTileColor(value),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value == 0 ? '' : '$value',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: value > 4 ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Color getTileColor(int value) {
    switch (value) {
      case 2:
        return Colors.orange[100]!;
      case 4:
        return Colors.orange[200]!;
      case 8:
        return Colors.orange[300]!;
      case 16:
        return Colors.orange[400]!;
      case 32:
        return Colors.orange[500]!;
      case 64:
        return Colors.orange[600]!;
      case 128:
        return Colors.orange[700]!;
      case 256:
        return Colors.orange[800]!;
      case 512:
        return Colors.orange[900]!;
      case 1024:
        return Colors.redAccent;
      case 2048:
        return Colors.red;
      default:
        return Colors.grey[300]!;
    }
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
