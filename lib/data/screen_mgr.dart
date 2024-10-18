class ScreenMgr {
  bool isMainScreen;

  String wifiOrBt;
  ScreenMgr(this.isMainScreen, this.wifiOrBt);
}

ScreenMgr myScreenMgr = ScreenMgr(true, 'bt wifi');
