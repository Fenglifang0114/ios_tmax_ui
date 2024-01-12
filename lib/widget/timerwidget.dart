import 'package:flutter/material.dart';

import '../../data/common.dart';
import '../../data/theme_base.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends ClockBaseState<TimerWidget> {
  @override
  void initState() {
    super.initState();
    startClock();
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: [
        // const TextSpan(
        // text: " Current time:",
        //     style: TextStyle(
        //         // height: 1.5,
        //         )),
        TextSpan(
            text:
                "${now.year}-${pad0(now.month)}-${pad0(now.day)} ${pad0(now.hour)}:${pad0(now.minute)}:${pad0(now.second)}",
            style: const TextStyle(
              fontSize: 30.0,
              color: Colors.blue,
              height: 1.5,
            ))
      ]),
    );
  }
}
