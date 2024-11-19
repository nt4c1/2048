import 'package:flutter/material.dart';

class GameGrid extends StatelessWidget {
  final List<List<int>> grid;

  const GameGrid({Key? key, required this.grid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: grid.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((tile) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tile == 0 ? Colors.grey[300] : Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                tile == 0 ? '' : '$tile',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
