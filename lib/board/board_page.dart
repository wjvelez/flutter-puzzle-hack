import 'package:flutter/material.dart';
import 'package:cubef/cubef.dart';
import 'package:flutter_puzzle_hack/app/app_provider.dart';
import 'package:flutter_puzzle_hack/board/puzzle_board.dart';
import 'package:game_board/game_board.dart';
import 'package:provider/provider.dart';

typedef PuzzleCtrl = BoardController<int>;

class BoardPage extends StatelessWidget {
  const BoardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loadingCube = context.select<AppProvider, bool>(
      (prov) => prov.loadingCube,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Puzzle Hack'),
      ),
      body: Center(
        child: loadingCube ? const CircularProgressIndicator() : const CubePuzzle(),
      ),
    );
  }
}

class CubePuzzle extends StatefulWidget {
  const CubePuzzle({Key? key}) : super(key: key);

  @override
  State<CubePuzzle> createState() => _CubePuzzleState();
}

class _CubePuzzleState extends State<CubePuzzle> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> sides = [];

  @override
  Widget build(BuildContext context) {
    print('CubePuzzle build...');
    final loadingCube = context.select<AppProvider, bool>(
      (prov) => prov.loadingCube,
    );
    final currentCtrl = context.select<AppProvider, BoardController<int>>(
      (prov) => prov.currentBoardCtrl,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          // child: loadingCube ? const CircularProgressIndicator() : const SidePuzzle(),
          child: loadingCube
              ? const CircularProgressIndicator()
              : PuzzleBoard(
                  puzzleCtrl: currentCtrl,
                ),
        ),
        const SizedBox(height: 64),
        CubeButtonRow(
          cubefKey: context.read<AppProvider>().cubefKey,
        ),
        ElevatedButton(
          onPressed: () {
            final prov = context.read<AppProvider>();
            final solved = prov.isSolved(prov.currentPuzzle);
            print('solved $solved');
          },
          child: const Text('is Solved?'),
        ),
      ],
    );
  }
}

class CubeButtonRow extends StatelessWidget {
  const CubeButtonRow({
    Key? key,
    required this.cubefKey,
  }) : super(key: key);

  final GlobalKey<CubefState> cubefKey;

  void rollDown() {
    cubefKey.currentState?.rollDown();
  }

  void rollUp() {
    cubefKey.currentState?.rollUp();
  }

  void rollLeft() {
    cubefKey.currentState?.rollLeft();
  }

  void rollRight() {
    cubefKey.currentState?.rollRight();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: rollUp,
          child: const Text('Roll Up'),
        ),
        ElevatedButton(
          onPressed: rollDown,
          child: const Text('Roll Down'),
        ),
        ElevatedButton(
          onPressed: rollLeft,
          child: const Text('Roll Left'),
        ),
        ElevatedButton(
          onPressed: rollRight,
          child: const Text('Roll Right'),
        ),
      ],
    );
  }
}

// class SidePuzzle extends StatelessWidget {
//   const SidePuzzle({
//     Key? key,
//     // required this.sides,
//     // required this.cubefKey,
//   }) : super(key: key);

//   // final GlobalKey<CubefState> cubefKey = GlobalKey<CubefState>();
//   // final GlobalKey<CubefState> cubefKey;

//   // final List<Widget> sides;

//   final _width = 300.0;
//   final _height = 300.0;

//   List<Widget> buildSides(BuildContext context) {
//     final controllers = context.read<AppProvider>().boardControllers;
//     print('controllers >> $controllers');

//     final sides = <Widget>[];
//     for (var side in CubeSide.values) {
//       final boardCtrl = controllers[side]!;
//       // print('side >> $side');
//       // print('boardCtrl >> ${boardCtrl.board}');
//       sides.add(Board<int>(
//         cellHeight: _height / 4.5,
//         cellBuilder: (cell) => CubeSideBoardCell(boardCell: cell),
//         cellDecorator: (cell) => cellDecorator(cell, side),
//         onCellTap: (cell) => onCellTap(context, cell),
//         controller: boardCtrl,
//       ));
//     }
//     return sides;
//   }

//   void onCellTap(BuildContext context, BoardCell<int> boardCell) {
//     final prov = context.read<AppProvider>();
//     prov.moveTileOld(boardCell);
//   }

//   BoxDecoration cellDecorator(BoardCell<int> boardCell, CubeSide side) {
//     final color = boardCell.data != 0 ? side.color : Colors.black12;
//     return BoxDecoration(
//       border: Border.all(
//         color: Colors.white,
//       ),
//       color: color,
//     );
//   }

//   // void forceUpdate(BuildContext context) {
//   //   // cubefKey.currentState?.initIndexes();
//   //   // cubefKey.currentState?.setState(() {});
//   //   cubefKey.currentState?.rollDown();
//   //   cubefKey.currentState?.rollUp();
//   // }

//   bool updateSide(
//     BuildContext context,
//     BoardCell<int> prev,
//     BoardCell<int> current,
//   ) {
//     final movedHorizontal = prev.columnIndex != current.columnIndex;
//     final movedVertical = prev.rowIndex != current.rowIndex;
//     final result = movedHorizontal || movedVertical;
//     print('result >> $result');
//     // forceUpdate(context);
//     return result;
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('SidePuzzle build >>');
//     return Consumer<AppProvider>(
//       // selector: (_, prov) => prov.emptyTile,
//       // shouldRebuild: (prev, current) => updateSide(context, prev, current),
//       builder: (_, prov, __) {
//         print('cubeSide >> ${prov.cubeSide}');
//         print('cubeSide >> ${prov.currentPuzzle}');
//         return Cubef(
//           key: prov.cubefKey,
//           sides: buildSides(context),
//           animationDuration: 2000,
//           width: _width,
//           height: _height,
//         );
//       },
//     );
//   }
// }
