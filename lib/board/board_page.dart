import 'package:flutter/material.dart';
import 'package:cubef/cubef.dart';
import 'package:flutter_puzzle_hack/app/app_provider.dart';
import 'package:game_board/game_board.dart';
import 'package:provider/provider.dart';

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
  GlobalKey<CubefState> cubefKey = GlobalKey<CubefState>();

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback(
      (_) => loadSides(),
    );

    super.initState();
  }

  var _width = 300.0;
  var _height = 300.0;

  List<Widget> sides = [];

  void loadSides() async {
    final prov = context.read<AppProvider>();
    for (var side in CubeSide.values) {
      final boardCtrl = prov.boardControllers[side];
      sides.add(Board<int>(
        cellHeight: _height / 4.5,
        cellBuilder: cellBuilder,
        cellDecorator: (cell) => cellDecorator(cell, side),
        onCellTap: onCellTap,
        controller: boardCtrl!,
      ));
    }
    setState(() {});
  }

  void onCellTap(BoardCell<int> boardCell) {}

  BoxDecoration cellDecorator(BoardCell<int> boardCell, CubeSide side) {
    final color = boardCell.data != 0 ? side.color : Colors.black12;
    return BoxDecoration(
      border: Border.all(
        color: Colors.white,
      ),
      color: color,
    );
  }

  Widget cellBuilder(BoardCell<int> boardCell) {
    final value = boardCell.data != 0 ? '${boardCell.data}' : '';
    return Container(
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 28,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          child: sides.isEmpty
              ? const CircularProgressIndicator()
              : Cubef(
                  key: cubefKey,
                  animationDuration: 2000,
                  sides: sides,
                  width: _width,
                  height: _height,
                ),
        ),
        const SizedBox(height: 64),
        CubeButtonRow(cubefKey: cubefKey),
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
