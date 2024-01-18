class ScreenMgr {
  bool isMainScreen;
  bool serialPortST;
  ScreenMgr(this.isMainScreen, this.serialPortST);
}

ScreenMgr myScreenMgr = ScreenMgr(true, false);
