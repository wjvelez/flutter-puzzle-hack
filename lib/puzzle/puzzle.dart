// import 'package:flutter/material.dart';
// import 'package:game_board/game_board.dart';

// class Puzzle {
//   Puzzle(this.controller);

//   int _size;
//   int get size => _size;

//   final BoardController controller;

//   late List<BoardCell<int>> _tiles;

//   void initialize(List<BoardCell<int>> tiles) {
//     _tiles = List.from(tiles);
//   }

//   bool isSolvable() {
//     if (_size.isOdd) {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   int inversions() {
//     var count = 0;
//     for (var i = 0; i < tiles.length; i++) {
//       final tileA = tiles[i];
//       if (tileA.data == null) {
//         continue;
//       }

//       for (var j = i + 1; j < tiles.length; j++) {
//         final tileB = tiles[j];
//         if (_isInversion(tileA, tileB)) {
//           count++;
//         }
//       }
//     }
//     return count;
//   }

//   bool _isInversion(BoardCell<int> a, BoardCell<int> b) {
//     if (b.data != null && a.data != b.data) {
//       if (b.data! < a.data!) {
//         return b.rowIndex > a.rowIndex || b.columnIndex > a.columnIndex;
//       }
//     }
//     return false;
//   }

// /*
//   * 1. If N is odd, then puzzle instance is solvable if number of inversions is even in the input state.
//   * 2. If N is even, puzzle instance is solvable if 
//   *  the blank is on an even row counting from the bottom (second-last, fourth-last, etc.) and number of inversions is odd.
//   *  the blank is on an odd row counting from the bottom (last, third-last, fifth-last, etc.) and number of inversions is even.
//   * 3. For all other cases, the puzzle instance is not solvable.
// */
// }
