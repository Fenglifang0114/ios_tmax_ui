class ScreenMgr {
  bool isMainScreen;
  bool serialPortST;
  String wifiOrBt;
  ScreenMgr(this.isMainScreen, this.serialPortST, this.wifiOrBt);
}

ScreenMgr myScreenMgr = ScreenMgr(true, false, 'off');
