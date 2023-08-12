import 'package:flutter/widgets.dart';

class Positions {
  double x;
  double y;
  double x1;
  double y1;
  Key key;
  Positions(this.x, this.y, this.x1, this.y1, this.key);
}

Positions myPositions = Positions(0.0, 0.0, 0.0, 0.0, Key(''));

class PositionsList {
  List<Positions> positionsList;
  PositionsList(this.positionsList);
}

PositionsList myPositionsList = PositionsList([]);
