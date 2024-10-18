import 'dart:async';
import 'package:t_max/data/manager_scale_channel.dart';

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
      PublicFunctions.checkSerialPort(myDefScaleInfo.defScaleId!); //只管串口
      startCntScaleTimer(10);
    });
  }

  void stopCntScaleTimer() {
    _cntScaleTimer?.cancel();
    _isCntScaleTiming = false;
  }

  Timer? _portTimer;

  void startPortOffTimer(int time, Function setStateCallback) {
    if (_portTimer != null) {
      _portTimer!.cancel();
    }

    _portTimer = Timer(Duration(seconds: time), () {
      setStateCallback();
      startPortOffTimer(2, setStateCallback);
    });
  }

  void stopPortOffTimer() {
    _portTimer?.cancel();
  }

  TimerManager._internal();
}

TimerManager cntScaleTimerMgr = TimerManager();
