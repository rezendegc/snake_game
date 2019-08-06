import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double snakeSize = 15;
  double snakeWidth = 15;
  double snakeOffsetX = 0;
  double snakeOffsetY = 0;
  double snakeSpeedX = 0;
  double snakeSpeedY = 0;
  double snakeBaseSpeed = 1;
  final double canvasTopOffset = 0.2;
  final double canvasLeftOffset = 0.05;
  bool gameIsLive = false;
  double appleX = 0;
  double appleY = 0;
  bool appleIsVisible = false;
  final double appleSize = 10;

  _checkColision(double minX, double minY) {
    final double snakeLeft = minX + snakeOffsetX;
    final double snakeRight = snakeLeft + snakeSize;
    final double snakeTop = minY + snakeOffsetY;
    final double snakeBottom = snakeTop + snakeSize;
    final double appleTop = appleY;
    final double appleBottom = appleY + appleSize;
    final double appleLeft = appleX;
    final double appleRight = appleX + appleSize;

    if ((snakeBottom > appleTop && snakeTop < appleTop) ||
        (snakeTop < appleBottom && snakeBottom > appleBottom)) {
      if (snakeLeft < appleRight && snakeRight > appleRight) // rtl
        return true;
      else if (snakeRight > appleLeft && snakeLeft < appleLeft)
        return true; // ltr
    }

    return false;
  }

  _createApple(double maxX, double maxY, double minX, double minY,
      {bool shouldSetState = false}) {
    final Random random = Random();
    if (shouldSetState)
      setState(() {
        appleX = minX + random.nextDouble() * (maxX - minX);
        appleY = minY + random.nextDouble() * (maxY - minY);
        appleIsVisible = true;
      });
    else {
      appleX = minX + random.nextDouble() * (maxX - minX);
      appleY = minY + random.nextDouble() * (maxY - minY);
      appleIsVisible = true;
    }
  }

  _startGame(double maxX, double maxY, double minX, double minY) {
    _createApple(maxX, maxY, minX, minY, shouldSetState: true);

    setState(() {
      snakeBaseSpeed = 1;
      snakeOffsetX = 0;
      snakeOffsetY = 0;
      snakeSpeedX = snakeBaseSpeed;
      snakeSpeedY = 0;
      gameIsLive = true;
    });
  }

  _finishGame() {
    appleIsVisible = false;
    snakeBaseSpeed = 1;
    snakeOffsetX = 0;
    snakeOffsetY = 0;
    snakeSpeedX = 0;
    snakeSpeedY = 0;
    gameIsLive = false;
  }

  _leftPress() {
    if (snakeSpeedX != 0)
      return;
    else {
      setState(() {
        snakeSpeedY = 0;
        snakeSpeedX = -snakeBaseSpeed;
      });
    }
  }

  _rightPress() {
    if (snakeSpeedX != 0)
      return;
    else {
      setState(() {
        snakeSpeedY = 0;
        snakeSpeedX = snakeBaseSpeed;
      });
    }
  }

  _upwardPress() {
    if (snakeSpeedY != 0)
      return;
    else {
      setState(() {
        snakeSpeedX = 0;
        snakeSpeedY = -snakeBaseSpeed;
      });
    }
  }

  _downwardPress() {
    if (snakeSpeedY != 0)
      return;
    else {
      setState(() {
        snakeSpeedX = 0;
        snakeSpeedY = snakeBaseSpeed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(
      (duration) {
        if (!gameIsLive) return;

        snakeSpeedX != 0
            ? setState(() => snakeOffsetX += snakeSpeedX)
            : setState(() => snakeOffsetY += snakeSpeedY);
      },
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double screenHeight = constraints.maxHeight;
            final double screenWidth = constraints.maxWidth;
            final double snakeInitialY = screenHeight * canvasTopOffset;
            final double snakeInitialX = screenWidth * canvasLeftOffset;
            final double snakeMaxY = screenHeight * 0.6 - snakeSize;
            final double snakeMaxX =
                screenWidth * (1 - canvasLeftOffset) - snakeSize;

            if (_checkColision(screenWidth * canvasLeftOffset,
                screenHeight * canvasTopOffset)) {
              _createApple(
                  snakeMaxX - appleSize,
                  snakeMaxY - appleSize,
                  screenWidth * canvasLeftOffset,
                  screenHeight * canvasTopOffset);
              snakeBaseSpeed += 1;
              if (snakeSpeedX > 0)
                snakeSpeedX = snakeBaseSpeed;
              else if (snakeSpeedX < 0)
                snakeSpeedX = -snakeBaseSpeed;
              else if (snakeSpeedY > 0)
                snakeSpeedY = snakeBaseSpeed;
              else
                snakeSpeedY = -snakeBaseSpeed;
            }

            if ((snakeInitialX + snakeOffsetX) > snakeMaxX ||
                snakeOffsetX < 0) {
              _finishGame();
            } else if ((snakeInitialY + snakeOffsetY) > snakeMaxY ||
                snakeOffsetY < 0) {
              _finishGame();
            }

            return Stack(
              children: [
                Positioned(
                  top: screenHeight * 0.075,
                  left: screenWidth * 0.35,
                  child: ButtonTheme(
                    height: screenHeight * 0.05,
                    minWidth: screenWidth * 0.3,
                    child: RaisedButton(
                      color: Colors.cyan,
                      child: Text("Iniciar Jogo"),
                      onPressed: () => _startGame(
                          snakeMaxX - appleSize,
                          snakeMaxY - appleSize,
                          screenWidth * canvasLeftOffset,
                          screenHeight * canvasTopOffset),
                    ),
                  ),
                ),
                Positioned(
                  left: screenWidth * canvasLeftOffset,
                  top: screenHeight * canvasTopOffset,
                  child: Container(
                    height: screenHeight * 0.4,
                    width: screenWidth * 0.9,
                    color: Colors.grey,
                  ),
                ),
                Positioned(
                  left: snakeInitialX + snakeOffsetX,
                  top: snakeInitialY + snakeOffsetY,
                  child: Container(
                    height: snakeSize,
                    width: snakeWidth,
                    color: Colors.green,
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.65,
                  left: (screenWidth - screenHeight * 0.3) / 2,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.indigo,
                    ),
                    height: screenHeight * 0.3,
                    width: screenHeight * 0.3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: screenHeight * 0.1,
                          width: screenHeight * 0.1,
                          child: Material(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(screenHeight * 0.05)),
                            color: Colors.transparent,
                            child: ButtonTheme(
                              buttonColor: Colors.transparent,
                              height: screenHeight * 0.1,
                              minWidth: screenWidth * 0.1,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_upward,
                                  color: Colors.black,
                                  size: 35,
                                ),
                                color: Colors.cyan,
                                onPressed: _upwardPress,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: screenHeight * 0.1,
                              width: screenHeight * 0.1,
                              child: Material(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        screenHeight * 0.05)),
                                color: Colors.transparent,
                                child: ButtonTheme(
                                  buttonColor: Colors.transparent,
                                  height: screenHeight * 0.1,
                                  minWidth: screenWidth * 0.1,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.arrow_back,
                                      color: Colors.black,
                                      size: 35,
                                    ),
                                    color: Colors.cyan,
                                    onPressed: _leftPress,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: screenHeight * 0.1,
                              width: screenHeight * 0.1,
                              child: Material(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        screenHeight * 0.05)),
                                color: Colors.transparent,
                                child: ButtonTheme(
                                  buttonColor: Colors.transparent,
                                  height: screenHeight * 0.1,
                                  minWidth: screenWidth * 0.1,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.arrow_forward,
                                      color: Colors.black,
                                      size: 35,
                                    ),
                                    color: Colors.cyan,
                                    onPressed: _rightPress,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: screenHeight * 0.1,
                          width: screenHeight * 0.1,
                          child: Material(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(screenHeight * 0.05)),
                            color: Colors.transparent,
                            child: ButtonTheme(
                              buttonColor: Colors.transparent,
                              height: screenHeight * 0.1,
                              minWidth: screenWidth * 0.1,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_downward,
                                  color: Colors.black,
                                  size: 35,
                                ),
                                color: Colors.cyan,
                                onPressed: _downwardPress,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (appleIsVisible)
                  Positioned(
                    top: appleY,
                    left: appleX,
                    child: Container(
                      height: appleSize,
                      width: appleSize,
                      color: Colors.red,
                    ),
                  )
              ],
            );
          },
        ),
      ),
    );
  }
}
