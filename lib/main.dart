import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Tic Tac Toe',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        // home: Container());
        home: MyHomePage());
  }
}

const EMPTY = 0;
const PLAYER1 = 1;
const PLAYER2 = 2;

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const backgroundColor = Color(0xFF14BDAC);
const List<int> initialSquareList = [0, 0, 0, 0, 0, 0, 0, 0, 0];

class Board {
  final List<int> squareList;
  final int currentPlayer;
  bool hasWinner = false;
  List<int> winCondition = [];
  int winnerPlayer = EMPTY;
  bool isEnded = false;
  Board({this.currentPlayer = 1, this.squareList = initialSquareList});
}

class Score {
  int player1 = 0;
  int player2 = 0;
  Score({this.player1 = 0, this.player2 = 0});
}

class Game {
  List<Board> history = [];
  Board currentBoard = Board();
  int currentBoardIndex = 0;
  Score score = Score();

  Game({int initialPlayer = PLAYER1}) {
    this.currentBoard = Board(currentPlayer: initialPlayer);
    this.history = [];
  }

  void reset() {
    history = [];
    currentBoard = Board();
    currentBoardIndex = 0;
  }

  void resetScore() {
    score = Score();
  }

  void play(squareIndex) {
    insertCurrentPlayerBlow(squareIndex);
    updateHistory();
    if (shouldEndTheGame()) {
      currentBoard.isEnded = true;
    } else {
      nextTurn();
    }
  }

  bool shouldEndTheGame() {
    if (shouldSetCurrentPlayerAsWinner()) {
      currentBoard.hasWinner = true;
      currentBoard.winnerPlayer = currentBoard.currentPlayer;
      if (currentBoard.currentPlayer == PLAYER1) score.player1++;
      if (currentBoard.currentPlayer == PLAYER2) score.player2++;
      return true;
    } else if (checkIfBoardIsFull()) {
      return true;
    }
    return false;
  }

  bool shouldSetCurrentPlayerAsWinner() {
    if (checkWinConditionForRows()) return true;
    if (checkWinConditionForColumns()) return true;
    if (checkWinConditionForDiagonals()) return true;
    return false;
  }

  bool checkIfBoardIsFull() {
    List<int> list = currentBoard.squareList;
    try {
      list.firstWhere((int squareValue) => squareValue == EMPTY);
      return false;
    } catch (error) {
      return true;
    }
  }

  bool checkWinConditionForRows() {
    List<int> list = currentBoard.squareList;
    int player = currentBoard.currentPlayer;

    bool shouldValidateRow(int rowIndex) {
      int index = rowIndex * 3;
      if (list[index] != player) return false;
      if (list[index + 1] != player) return false;
      if (list[index + 2] != player) return false;
      currentBoard.winCondition = [index, index + 1, index + 2];
      return true;
    }

    if (shouldValidateRow(0)) return true;
    if (shouldValidateRow(1)) return true;
    if (shouldValidateRow(2)) return true;
    return false;
  }

  bool checkWinConditionForColumns() {
    List<int> list = currentBoard.squareList;
    int player = currentBoard.currentPlayer;

    bool shouldValidateColumn(int colIndex) {
      if (list[colIndex] != player) return false;
      if (list[colIndex + 3] != player) return false;
      if (list[colIndex + 6] != player) return false;
      currentBoard.winCondition = [colIndex, colIndex + 3, colIndex + 6];
      return true;
    }

    if (shouldValidateColumn(0)) return true;
    if (shouldValidateColumn(1)) return true;
    if (shouldValidateColumn(2)) return true;
    return false;
  }

  bool checkWinConditionForDiagonals() {
    List<int> list = currentBoard.squareList;
    int player = currentBoard.currentPlayer;

    bool shouldValidateTopLeftToBottomRight() {
      if (list[0] != player) return false;
      if (list[4] != player) return false;
      if (list[8] != player) return false;
      currentBoard.winCondition = [0, 4, 8];
      return true;
    }

    bool shouldValidateTopRightToBottomLeft() {
      if (list[2] != player) return false;
      if (list[4] != player) return false;
      if (list[6] != player) return false;
      currentBoard.winCondition = [2, 4, 6];
      return true;
    }

    if (shouldValidateTopLeftToBottomRight()) return true;
    if (shouldValidateTopRightToBottomLeft()) return true;
    return false;
  }

  void returnAtIndexInHistory(boardIndex) {
    Board boardAtIndex = history[boardIndex];
    currentBoardIndex = boardIndex;
    int nextPlayer = boardAtIndex.currentPlayer == PLAYER1 ? PLAYER2 : PLAYER1;
    currentBoard = Board(
      currentPlayer: nextPlayer,
      squareList: boardAtIndex.squareList,
    );
  }

  void insertCurrentPlayerBlow(squareIndex) {
    int currentPlayer = currentBoard.currentPlayer;
    List<int> nextList = [...currentBoard.squareList];
    nextList[squareIndex] = currentPlayer;
    currentBoard = Board(squareList: nextList, currentPlayer: currentPlayer);
  }

  void updateHistory() {
    if (shouldDeleteHistoryAfterCurrentBoard()) {
      deleteHistoryAfterCurrentBoard();
    }
  }

  void deleteHistoryAfterCurrentBoard() {
    history = history.sublist(currentBoardIndex);
  }

  void nextTurn() {
    insertCurrentBoardAtFirstPosition();
    int nextPlayer = currentBoard.currentPlayer == PLAYER1 ? PLAYER2 : PLAYER1;
    currentBoard =
        Board(squareList: currentBoard.squareList, currentPlayer: nextPlayer);
    currentBoardIndex = 0;
  }

  void insertCurrentBoardAtFirstPosition() {
    history.insert(0, currentBoard);
  }

  bool shouldDeleteHistoryAfterCurrentBoard() {
    return currentBoardIndex != 0;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  var game = new Game();
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    // SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    void returnAtIndexInHistory(int index) {
      setState(() {
        game.returnAtIndexInHistory(index);
      });
    }

    void play(int index) {
      if (game.currentBoard.isEnded == false) {
        setState(() {
          game.play(index);
        });
      }
    }

    void replay() {
      setState(() {
        game.reset();
      });
    }

    void resetScore() {
      setState(() {
        game.resetScore();
      });
    }

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        padding: new EdgeInsets.only(top: statusBarHeight),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ScoreSection(
              score: game.score, winnerPlayer: game.currentBoard.winnerPlayer),
          SizedBox(height: 30),
          InfoSection(
            player: game.currentBoard.currentPlayer,
            currentBoard: game.currentBoard,
          ),
          BoardSection(
            board: game.currentBoard,
            onPressSquare: play,
          ),
          Container(
            // color: Colors.amber,
            padding: EdgeInsets.all(20),
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: game.history.length,
              itemBuilder: (context, index) {
                return SmallBoardSection(
                  board: game.history[index],
                  onPressBoard: () => returnAtIndexInHistory(index),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            OutlinedButton(
              onPressed: resetScore,
              child: Text('RESET SCORE'),
              style: OutlinedButton.styleFrom(
                primary: Colors.white,
                side: BorderSide(color: Colors.white),
              ),
            ),
            SizedBox(width: 20),
            OutlinedButton(
              onPressed: replay,
              child: Text('REJOUER'),
              style: OutlinedButton.styleFrom(
                primary: Colors.white,
                side: BorderSide(color: Colors.white),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

void defaultCallback(int index) {}

class BoardSection extends StatelessWidget {
  final bool isSmall;
  final Board board;
  final Function(int) onPressSquare;

  BoardSection({
    this.isSmall = false,
    required this.board,
    required this.onPressSquare,
  });
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double padding = 40;
    double size = screenWidth;
    Color borderColor = Colors.black12;
    double borderWidth = 6;
    BorderSide borderSide = BorderSide(color: borderColor, width: borderWidth);
    Border borderVertical = Border(left: borderSide, right: borderSide);
    Border borderHorizontal = Border(top: borderSide, bottom: borderSide);
    var borderAll = Border.all(color: borderColor, width: borderWidth);

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      child: Column(children: [
        Row(children: [
          BoardSquare(
              player: board.squareList[0],
              onPress: () => onPressSquare(0),
              shiny: board.winCondition.contains(0)),
          BoardSquare(
              player: board.squareList[1],
              border: borderVertical,
              onPress: () => onPressSquare(1),
              shiny: board.winCondition.contains(1)),
          BoardSquare(
              player: board.squareList[2],
              onPress: () => onPressSquare(2),
              shiny: board.winCondition.contains(2)),
        ]),
        Row(children: [
          BoardSquare(
              player: board.squareList[3],
              border: borderHorizontal,
              onPress: () => onPressSquare(3),
              shiny: board.winCondition.contains(3)),
          BoardSquare(
              player: board.squareList[4],
              border: borderAll,
              onPress: () => onPressSquare(4),
              shiny: board.winCondition.contains(4)),
          BoardSquare(
              player: board.squareList[5],
              border: borderHorizontal,
              onPress: () => onPressSquare(5),
              shiny: board.winCondition.contains(5))
        ]),
        Row(children: [
          BoardSquare(
              player: board.squareList[6],
              onPress: () => onPressSquare(6),
              shiny: board.winCondition.contains(6)),
          BoardSquare(
              player: board.squareList[7],
              border: borderVertical,
              onPress: () => onPressSquare(7),
              shiny: board.winCondition.contains(7)),
          BoardSquare(
              player: board.squareList[8],
              onPress: () => onPressSquare(8),
              shiny: board.winCondition.contains(8))
        ]),
      ]),
    );
  }
}

void voidCallback() => {};
Border defaultBorder = Border.all(width: 6, color: Colors.black12);

class BoardSquare extends StatelessWidget {
  final int player;
  final BoxBorder border;
  final VoidCallback onPress;
  final bool shiny;
  BoardSquare({
    this.player = PLAYER1,
    this.border = const Border(),
    this.onPress = voidCallback,
    this.shiny = false,
  });

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var size = (screenWidth - 80) / 3;
    var squareIsEmpty = player == EMPTY;

    void onTap() {
      if (squareIsEmpty) {
        onPress();
      }
    }

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(border: border),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: PlayerIconOutline(player: player, size: 80, shiny: shiny),
        ),
      ),
    );
  }
}

class SmallBoardSection extends StatelessWidget {
  final Board board;
  final VoidCallback onPressBoard;
  final bool isFocus;

  SmallBoardSection({
    required this.board,
    required this.onPressBoard,
    this.isFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
      child: InkWell(
        onTap: onPressBoard,
        child: Column(children: [
          Row(children: [
            SmallBoardSquare(player: board.squareList[0]),
            SmallBoardSquare(player: board.squareList[1]),
            SmallBoardSquare(player: board.squareList[2])
          ]),
          Row(children: [
            SmallBoardSquare(player: board.squareList[3]),
            SmallBoardSquare(player: board.squareList[4]),
            SmallBoardSquare(player: board.squareList[5])
          ]),
          Row(children: [
            SmallBoardSquare(player: board.squareList[6]),
            SmallBoardSquare(player: board.squareList[7]),
            SmallBoardSquare(player: board.squareList[8])
          ]),
        ]),
      ),
    );
  }
}

class SmallBoardSquare extends StatelessWidget {
  final int player;

  SmallBoardSquare({
    this.player = PLAYER1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.black12),
      ),
      child: Center(
        child: PlayerIcon(player: player, size: 12),
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  final player;
  final Board currentBoard;
  InfoSection({this.player, required this.currentBoard});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(currentBoard.hasWinner ? "Le joueur " : "C'est a "),
          PlayerIconOutline(
            player: player,
            size: 20,
          ),
          Text(currentBoard.hasWinner ? " a gagné" : " de jouer"),
        ],
      ),
    );
  }
}

class ScoreSection extends StatelessWidget {
  final Score score;
  final int winnerPlayer;

  ScoreSection({required this.score, this.winnerPlayer = EMPTY});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: Row(
        children: [
          PlayerScore(
            player: PLAYER1,
            score: score.player1,
            isWinner: winnerPlayer == PLAYER1,
          ),
          Expanded(child: Container()),
          PlayerScore(
            player: PLAYER2,
            score: score.player2,
            isWinner: winnerPlayer == PLAYER2,
          ),
        ],
      ),
    );
  }
}

class PlayerScore extends StatelessWidget {
  final player;
  final score;
  final bool isWinner;
  PlayerScore({this.player, this.score, this.isWinner = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black12,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          PlayerIconOutline(
            player: player,
            size: 50,
            shiny: isWinner,
          ),
          SizedBox(
            width: 40,
          ),
          Text(
            score.toString(),
            style: TextStyle(fontSize: 30, color: Colors.black87),
          )
        ],
      ),
    );
  }
}

class PlayerIcon extends StatelessWidget {
  final player;
  final double size;
  PlayerIcon({this.player, this.size = 22});
  @override
  Widget build(BuildContext context) {
    if (player == EMPTY) return Container();
    return Icon(
      player == PLAYER1 ? Icons.cancel : Icons.circle,
      color: player == PLAYER1 ? Colors.black54 : Colors.white70,
      size: size,
    );
  }
}

class PlayerIconOutline extends StatelessWidget {
  final player;
  final double size;
  final bool shiny;
  PlayerIconOutline({this.player, this.size = 22, this.shiny = false});
  @override
  Widget build(BuildContext context) {
    if (player == EMPTY) return Container();
    Color color = Colors.white70;
    if (player == PLAYER1) color = Colors.black54;
    if (player == PLAYER2) color = Colors.white70;
    if (shiny) color = Colors.amber.shade400;

    return Icon(
      player == PLAYER1 ? Icons.cancel_outlined : Icons.circle_outlined,
      color: color,
      size: size,
    );
  }
}
