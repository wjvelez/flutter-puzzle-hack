import 'package:flutter/material.dart';
import 'package:flutter_puzzle_hack/app/app_provider.dart';
import 'package:flutter_puzzle_hack/board/board_page.dart';
import 'package:game_board/game_board.dart';
import 'package:provider/provider.dart';

const _height = 300.0;

class PuzzleBoard extends StatelessWidget {
  const PuzzleBoard({
    Key? key,
    required this.puzzleCtrl,
    this.moveType,
  }) : super(key: key);

  final MoveType? moveType;
  final PuzzleCtrl puzzleCtrl;

  void onCellTap(BuildContext context, BoardCell<int> boardCell) {
    final prov = context.read<AppProvider>();
    prov.moveTile(boardCell);
  }

  BoxDecoration cellDecorator(BoardCell<int> boardCell, CubeSide side) {
    final color = boardCell.data != 0 ? side.color : Colors.black12;
    return BoxDecoration(
      border: Border.all(
        color: Colors.white,
      ),
      color: color,
    );
  }

  bool updateSide(
    BoardCell<int> prev,
    BoardCell<int> current,
  ) {
    final movedHorizontal = prev.columnIndex != current.columnIndex;
    final movedVertical = prev.rowIndex != current.rowIndex;
    final result = movedHorizontal || movedVertical;
    print('result >> $result');
    // forceUpdate(context);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final side = context.select<AppProvider, CubeSide>((prov) => prov.cubeSide);
    return Selector<AppProvider, BoardCell<int>>(
      selector: (context, prov) => prov.emptyTile,
      shouldRebuild: updateSide,
      builder: (context, emptyTile, _) => Container(
        // color: Colors.red,
        child: Board<int>(
          cellHeight: _height / 4.5,
          cellBuilder: (cell) => CubeSideBoardCell(boardCell: cell),
          cellDecorator: (cell) => cellDecorator(cell, side),
          onCellTap: (cell) => onCellTap(context, cell),
          controller: puzzleCtrl,
        ),
      ),
    );
  }
}

class CubeSideBoardCell extends StatelessWidget {
  const CubeSideBoardCell({
    Key? key,
    required this.boardCell,
  }) : super(key: key);

  final BoardCell<int> boardCell;

  @override
  Widget build(BuildContext context) {
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
}
