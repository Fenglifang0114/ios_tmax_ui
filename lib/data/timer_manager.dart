import 'dart:async';

import '../functions/methods.dart';

class TimerManager {
  static final TimerManager _instance = TimerManager._internal();
  factory TimerManager() => _instance;

  Timer? _cntScaleTimer;
  bool _isCntScaleTiming = false;

  bool get isCntScaleTiming => _isCntScaleTiming;

  void startCntScaleTimer(int time) {
    if (_cntScaleTimer != null) {
      _cntScaleTimer!.cancel();
    }

    _isCntScaleTiming = true;
    _cntScaleTimer = Timer(Duration(seconds: time), () {
      PublicFunctions.checkSerialPort();
      startCntScaleTimer(5);
    });
  }

  void stopCntScaleTimer() {
    _cntScaleTimer?.cancel();
    _isCntScaleTiming = false;
  }

  TimerManager._internal();
}

TimerManager cntScaleTimerMgr = TimerManager();
