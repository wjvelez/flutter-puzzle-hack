import 'package:flutter/material.dart';
import 'package:flutter_puzzle_hack/board/board_page.dart';

class SlidePuzzleApp extends StatefulWidget {
  const SlidePuzzleApp({Key? key}) : super(key: key);

  @override
  _SlidePuzzleAppState createState() => _SlidePuzzleAppState();
}

class _SlidePuzzleAppState extends State<SlidePuzzleApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Slide Puzzle',
      home: BoardPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
