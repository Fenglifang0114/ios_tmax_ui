import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../data/common.dart';
import '../../data/theme_base.dart';

class TimerWidget extends StatefulWidget {
  late String name;
  late String title;

  TimerWidget({super.key});

  @override
  State<StatefulWidget> createState() {
    var state = _TimerWidgetState();
    state.startClock();
    return state;
  }
}

class _TimerWidgetState extends ClockBaseState<TimerWidget> {
  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: [
        const TextSpan(
            text: " Current time:",
            style: TextStyle(
                // height: 1.5,
                )),
        TextSpan(
            text:
                "${now.year}-${pad0(now.month)}-${pad0(now.day)} ${pad0(now.hour)}:${pad0(now.minute)}:${pad0(now.second)}",
            style: const TextStyle(
                // fontSize: 18.0,
                // color: Colors.white,
                // height: 1.5,
                ))
      ]),
    );
  }
}
