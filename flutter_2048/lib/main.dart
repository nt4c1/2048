import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'game_logic.dart';
import 'country_service.dart';

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

class _Game2048ScreenState extends State<Game2048Screen> with TickerProviderStateMixin {
  late Game2048 game;
  String playerName = '';
  String country = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    game = Game2048(gridSize: 4);
    fetchCountry();
  }

  Future<void> fetchCountry() async {
    try {
      country = await CountryService.fetchCountry();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        country = 'Unknown';
      });
    }
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
        content: TextField(
          onChanged: (value) {
            playerName = value;
          },
          decoration: InputDecoration(labelText: 'Enter your name'),
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
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: EdgeInsets.all(4),
      width: 80,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: value == 0 ? Colors.grey[300] : _getTileColor(value),
        borderRadius: BorderRadius.circular(8),
      ),
      child: AnimatedOpacity(
        opacity: value == 0 ? 0.0 : 1.0,
        duration: Duration(milliseconds: 200),
        child: Text(
          value == 0 ? '' : '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Color _getTileColor(int value) {
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
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          Text(
            'Score: ${game.score}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Country: $country',
            style: TextStyle(fontSize: 16),
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
                  children: row.map((value) => buildTile(value)).toList(),
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
