class BasicErrInfo {
  int forcedShutdownCnt;
  int powerOnCnt;
  int runningTime;
  int caliCnt;
  int calSwitchCnt;
  int err4Cnt;
  int err19Cnt;
  int olTime;
  int ulTime;
  int wgtCnt;
  BasicErrInfo(
      this.forcedShutdownCnt,
      this.powerOnCnt,
      this.ulTime,
      this.runningTime,
      this.calSwitchCnt,
      this.caliCnt,
      this.err19Cnt,
      this.err4Cnt,
      this.olTime,
      this.wgtCnt);
  BasicErrInfo.fromJson(Map<String, dynamic> json)
      : forcedShutdownCnt = json['ForcedShutdownCnt'],
        powerOnCnt = json['PowerOnCnt'],
        runningTime = json['RunningTime'],
        caliCnt = json['CaliCnt'],
        calSwitchCnt = json['CalSwitchCnt'],
        err4Cnt = json['Err4Cnt'],
        err19Cnt = json['Err19Cnt'],
        olTime = json['OlTime'],
        ulTime = json['UlTime'],
        wgtCnt = json['WgtCnt'];
}

BasicErrInfo myBasicErrInfo = BasicErrInfo(0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
