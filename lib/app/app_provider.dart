import 'dart:developer';

import 'package:cubef/cubef.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_board/game_board.dart';

class AppProvider extends ChangeNotifier {
  AppProvider() {
    initialize();
  }

  final cubefKey = GlobalKey<CubefState>();

  var boardControllers = <CubeSide, BoardController<int>>{};

  int boardSize = 3;

  int get numberOfTiles => boardSize * boardSize;

  CubeSide cubeSide = CubeSide.front;

  void initialize() async {
    await Future.forEach<CubeSide>(CubeSide.values, (side) {
      final _controller = BoardController<int>(
        totalRows: boardSize,
        totalColumns: boardSize,
      );
      _controller.loadCells(fillBoard());
      boardControllers[side] = _controller;
    });
    printLog('boardControllers $boardControllers');
    updateLoadingCube(false);
  }

  List<BoardCell<int>> fillBoard() {
    List<BoardCell<int>> boardCells = [];
    try {
      var _boardSolvable = false;
      while (!_boardSolvable) {
        var rowIndex = 0;
        var cellValues = List.generate(
          numberOfTiles - 1,
          (index) => index + 1,
        );
        cellValues.shuffle();
        printLog('cellValues $cellValues');
        for (var i = 0; i < numberOfTiles; i++) {
          final colIndex = i % boardSize;
          if (colIndex == 0 && i != 0) {
            rowIndex++;
          }
          boardCells.add(
            BoardCell(
              columnIndex: colIndex,
              rowIndex: rowIndex,
              // data: cellValues[i],
              data: (i < numberOfTiles - 1) ? cellValues[i] : 0,
            ),
          );
        }
        if (isSolvable(boardCells)) {
          _boardSolvable = true;
          printLog('scapping from while loop');
        } else {
          boardCells.clear();
        }
      }
      printLog('boardCells $boardCells');
      return boardCells;
    } catch (error) {
      printLog('fillBoard error ${error.toString()}');
      return boardCells;
    }
  }

  bool _loadingCube = true;
  bool get loadingCube => _loadingCube;
  void updateLoadingCube(bool value) {
    _loadingCube = value;
    notifyListeners();
  }

  void printLog(String message) {
    if (kDebugMode) {
      log('(AppProvider) | $message');
    }
  }

  BoardController<int> get currentBoardCtrl => boardControllers[cubeSide]!;
  List<BoardCell<int>> get currentPuzzle => boardControllers[cubeSide]!.board;

  BoardCell<int> get emptyTile => currentPuzzle.singleWhere(
        (e) => e.data == 0,
      );

  bool isSolvable(List<BoardCell<int>> puzzle) {
    final _inversions = inversions(puzzle);
    if (boardSize.isOdd) {
      return _inversions.isEven;
    }
    final emptyTileeRow = puzzle
        .singleWhere(
          (e) => e.data == 0,
        )
        .rowIndex;
    if ((boardSize - emptyTileeRow).isOdd) {
      return _inversions.isEven;
    } else {
      return _inversions.isOdd;
    }
  }

  int inversions(List<BoardCell<int>> puzzle) {
    var count = 0;
    for (var i = 0; i < numberOfTiles; i++) {
      final tileA = puzzle[i];
      if (tileA.data == 0) {
        continue;
      }

      for (var j = i + 1; j < puzzle.length; j++) {
        final tileB = puzzle[j];
        if (_isInversion(tileA, tileB)) {
          count++;
        }
      }
    }
    printLog('inversions >> $count');
    return count;
  }

  bool _isInversion(BoardCell<int> a, BoardCell<int> b) {
    if (b.data != 0 && a.data != b.data) {
      if (b.data! < a.data!) {
        return b.rowIndex > a.rowIndex || b.columnIndex > a.columnIndex;
      }
    }
    return false;
  }

  bool isSolved(List<BoardCell<int>> puzzle) {
    final _puzzleValues = puzzle.map((e) => e.data);
    final _solvedPuzzle = List.generate(
      numberOfTiles - 1,
      (index) => index + 1,
    );
    final isSolved = _puzzleValues == _solvedPuzzle;
    printLog('isSolved $isSolved');
    return isSolved;
  }

  bool isTileMovable(BoardCell<int> boardCell) {
    printLog('isTileMovable >> $boardCell');
    printLog('isTileMovable >> $currentPuzzle');

    if (boardCell.data == 0) return false;

    if (boardCell.areNeighbors(emptyTile) || emptyTile.areNeighbors(boardCell)) {
      return true;
    } else {
      return false;
    }
  }

  void moveTileOld(BoardCell<int> boardCell) {
    printLog('moveTile cubeSide >> $cubeSide');
    printLog('moveTile boardCell >> $boardCell');
    printLog('moveTile emptyTile >> $emptyTile');

    if (!isTileMovable(boardCell)) return;
    final tempValue = boardCell.data;

    final targetMove = calculateNewCubeSideOld(boardCell, emptyTile);

    currentBoardCtrl.updateCell(
      emptyTile.rowIndex,
      emptyTile.columnIndex,
      emptyTile.updateValue(tempValue),
    );

    currentBoardCtrl.updateCell(
      boardCell.rowIndex,
      boardCell.columnIndex,
      boardCell.updateValue(0),
    );
    notifyListeners();

    printLog('moved completed!');
    printLog('moved $currentPuzzle');

    if (targetMove != null) {
      rotateCubeOld(targetMove);
    }
  }

  MoveType? calculateNewCubeSideOld(
    BoardCell<int> boardCell,
    BoardCell<int> targetEmptyTile,
  ) {
    printLog('calculateNewCubeSide cubeSide >> $cubeSide');
    printLog('calculateNewCubeSide boardCell >> $boardCell');
    printLog('calculateNewCubeSide emptyTile >> $targetEmptyTile');
    MoveType? targetMove;
    if (targetEmptyTile.isTopNeighbor(boardCell) || boardCell.isBottomNeighbor(targetEmptyTile)) {
      targetMove = MoveType.top;
    } else if (targetEmptyTile.isLeftNeighbor(boardCell) || boardCell.isRightNeighbor(targetEmptyTile)) {
      targetMove = MoveType.left;
    } else if (targetEmptyTile.isRightNeighbor(boardCell) || boardCell.isLeftNeighbor(targetEmptyTile)) {
      targetMove = MoveType.right;
    } else if (targetEmptyTile.isBottomNeighbor(boardCell) || boardCell.isTopNeighbor(targetEmptyTile)) {
      targetMove = MoveType.down;
    } else {
      printLog('invalid move!');
    }
    // printLog('calculateNewCubeSide newSide >> $newSide');
    printLog('calculateNewCubeSide targetMove >> $targetMove');
    return targetMove;
  }

  void rotateCubeOld(MoveType targetMove) {
    switch (targetMove) {
      case MoveType.top:
        cubeSide = cubeSide.moveSide(MoveType.top);
        cubefKey.currentState!.rollDown();
        // cubefKey.currentState!.rollUp();
        break;
      case MoveType.down:
        cubeSide = cubeSide.moveSide(MoveType.down);
        cubefKey.currentState!.rollUp();
        // cubefKey.currentState!.rollDown();
        break;
      case MoveType.left:
        cubeSide = cubeSide.moveSide(MoveType.left);
        cubefKey.currentState!.rollLeft();
        break;
      case MoveType.right:
        cubeSide = cubeSide.moveSide(MoveType.right);
        cubefKey.currentState!.rollRight();
        break;
    }
    printLog('newCubeSide >> $cubeSide');
    notifyListeners();
  }

  void moveTile(BoardCell<int> boardCell) {
    printLog('moveTile cubeSide >> $cubeSide');
    printLog('moveTile boardCell >> $boardCell');
    printLog('moveTile emptyTile >> $emptyTile');

    if (!isTileMovable(boardCell)) return;
    final tempValue = boardCell.data;

    final targetMove = calculateNewCubeSideOld(boardCell, emptyTile);

    currentBoardCtrl.updateCell(
      emptyTile.rowIndex,
      emptyTile.columnIndex,
      emptyTile.updateValue(tempValue),
    );

    currentBoardCtrl.updateCell(
      boardCell.rowIndex,
      boardCell.columnIndex,
      boardCell.updateValue(0),
    );
    notifyListeners();

    printLog('moved completed!');
    printLog('moved $currentPuzzle');

    // if (targetMove != null) {
    //   rotateCubeOld(targetMove);
    // }
  }
}

// * Vertical:     1 - 2 - 3 - 4,
// * Horizontal:   1 - 6 - 3 - 5

/*
* Moves:
* L: to Left { F } | to right { B } | to Up { D } | to Down { T }
* F: to Left { R } | to right { L } | to Up { D } | to Down { T }
* R: to Left { B } | to right { F } | to Up { D } | to Down { T }
* B: to Left { L } | to right { R } | to Up { D } | to Down { T }
* T: to Left { R } | to right { L } | to Up { F } | to Down { B }
* D: to Left { R } | to right { L } | to Up { B } | to Down { F }
*/

enum CubeSide {
  front,
  top,
  back,
  down,
  left,
  right,
}

enum MoveType {
  top,
  left,
  right,
  down,
}

extension CubeSideExtension on CubeSide {
  CubeSide moveSide(MoveType move) {
    switch (this) {
      case CubeSide.left:
        return leftSideMove(move);
      case CubeSide.front:
        return frontSideMove(move);
      case CubeSide.right:
        return rightSideMove(move);
      case CubeSide.back:
        return backSideMove(move);
      case CubeSide.top:
        return topSideMove(move);
      case CubeSide.down:
        return downSideMove(move);
    }
  }

  CubeSide leftSideMove(MoveType move) {
    switch (move) {
      case MoveType.left:
        return CubeSide.front;
      case MoveType.right:
        return CubeSide.back;
      case MoveType.top:
        return CubeSide.down;
      case MoveType.down:
        return CubeSide.top;
    }
  }

  CubeSide frontSideMove(MoveType move) {
    switch (move) {
      case MoveType.left:
        return CubeSide.right;
      case MoveType.right:
        return CubeSide.left;
      case MoveType.top:
        return CubeSide.down;
      case MoveType.down:
        return CubeSide.top;
    }
  }

  CubeSide rightSideMove(MoveType move) {
    switch (move) {
      case MoveType.left:
        return CubeSide.back;
      case MoveType.right:
        return CubeSide.front;
      case MoveType.top:
        return CubeSide.down;
      case MoveType.down:
        return CubeSide.top;
    }
  }

  CubeSide backSideMove(MoveType move) {
    switch (move) {
      case MoveType.left:
        return CubeSide.left;
      case MoveType.right:
        return CubeSide.right;
      case MoveType.top:
        return CubeSide.down;
      case MoveType.down:
        return CubeSide.top;
    }
  }

  CubeSide topSideMove(MoveType move) {
    switch (move) {
      case MoveType.left:
        return CubeSide.right;
      case MoveType.right:
        return CubeSide.left;
      case MoveType.top:
        return CubeSide.front;
      case MoveType.down:
        return CubeSide.back;
    }
  }

  CubeSide downSideMove(MoveType move) {
    switch (move) {
      case MoveType.left:
        return CubeSide.right;
      case MoveType.right:
        return CubeSide.left;
      case MoveType.top:
        return CubeSide.back;
      case MoveType.down:
        return CubeSide.front;
    }
  }

  Color get color {
    switch (this) {
      case CubeSide.left:
        return Colors.amberAccent;
      case CubeSide.front:
        return Colors.indigoAccent;
      case CubeSide.right:
        return Colors.greenAccent;
      case CubeSide.back:
        return Colors.black;
      case CubeSide.top:
        return Colors.purpleAccent;
      case CubeSide.down:
        return Colors.limeAccent;
    }
  }
}

/*
*
* Vertical:     1 - 2 - 3 - 4,
* Horizontal:   1 - 6 - 3 - 5
*   
*   
*       2
*  5 == 1 == 6 == 3
*       4
* 
*             |============|
*             |=T1==T2==T3=|
*             |============|
*             |=T4==T5==T6=|
*             |============|
*             |=T7==T8==T9=|
* ============|============|============|============
* =L1==L2==L3=|=F1==F2==F3=|=R1==R2==R3=|=B1==B2==B3=
* ============|============|============|============
* =L4==L5==L6=|=F4==F5==F6=|=R4==R5==R6=|=B4==B5==B6=
* ============|============|============|============
* =L7==L8==L9=|=F7==F8==F9=|=R7==R8==R9=|=B7==B8==B9=
* ============|============|============|============
*             |=D1==D2==D3=|
*             |============|
*             |=D4==D5==D6=|
*             |============|
*             |=D7==D8==D9=|
*             |============|

* Moves:
* L: to Left { F } | to right { B } | to Up { D } | to Down { T }
* F: to Left { R } | to right { L } | to Up { D } | to Down { T }
* R: to Left { B } | to right { F } | to Up { D } | to Down { T }
* B: to Left { L } | to right { R } | to Up { D } | to Down { T }
* T: to Left { R } | to right { L } | to Up { F } | to Down { B }
* D: to Left { R } | to right { L } | to Up { B } | to Down { F }
*/
