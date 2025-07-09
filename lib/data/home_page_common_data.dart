//主界面公用的常量
import 'dart:typed_data';

import 'package:t_max/data/home_page_common_data.dart' as transparent_image;

const leftBarWidth = 240.0; //左侧菜单宽度
const leftBarLittleWidth = 74.0; //左侧菜单宽度收缩后的宽度
const leftBarIconHeight = 78.0; //左侧菜单图标部分高度
const leftBarHeight = 52.0; //左侧菜单高度
const topBarHeight = 56.0; //顶部菜单高度
const iconAppSize = 36.0; //顶部菜单大小
const iconMenuSize = 22.0; //顶部菜单大小
const leftAppNameWidth = 170.0; //左侧菜单应用名称宽度
const pageTopTitleHeight = 56.0; //页面顶部标题高度
const topLinePadding = 2.0; //顶部操作栏间距高度
const regularPadding = 14.0; //常规边距
const dialogTitleheight = 54.0; //对话框标题高度
const smallPadding = 8.0; //小边距
const largePadding = 20.0; //大边距
const bottomBtnHeight = 68.0; //底部按钮高度
const inputHeight = 48.0; //输入框高度
const btnHeight = 48.0; //按钮高度
const inputWidth = 300.0; //输入框宽度
const textContentHeight = 42.0; //文本控件高度
const scaleItemHeight = 62.0; //秤列表项高度
const scaleInnerItemHeight = 38.0; //秤列表项里图标占用的控件宽度
const topIconSize = 20.0; //顶部菜单图标大小
const scaleListWidth = 290.0; //下拉秤的列表宽度
const wifiListWidth = 255.0; //下拉秤的列表宽度
const headWidthPadding = 500.0; //头部菜单间隔宽度
const wgtIconSize = 24.0; //顶部菜单图标大小

const appScaleListWidth = 234.0; //app里面下拉秤的列表宽度

String appIconPath = 'assets/images/app.png';
String logoIconPath = 'assets/images/logo.png';

// Duration for home page elements to fade in.
const Duration entranceAnimationDuration = Duration(milliseconds: 200);

// The desktop top padding for a page's first header (e.g. Gallery, Settings)
const double firstHeaderDesktopTopPadding = 5.0;

// A transparent image used to avoid loading images when they are not needed.
final Uint8List kTransparentImage = transparent_image.kTransparentImage;

//全局变量

String defualtSelectPage = '/multiScaleManagement'; //当前选中的页面ID

// 存储用户选择要添加的付费菜单 ID
Set<int> selectedConfigPaidMenuIds = {};

enum PageId { home, config, apps, appsSetting, systemSetting }

//免费的Config菜单Id
Set<int> freeConfigMenuIds = {
  MenuId.multiScaleManagement.index,
  MenuId.setSystemTimePage.index,
  MenuId.btSettingPage.index,
  MenuId.wifiSettingPage.index,
  MenuId.updateFirmwarePage.index,
  MenuId.calibrationPage.index,
  MenuId.pluEditPage.index,
  MenuId.downReciptPage.index,
  MenuId.downloadLabelPage.index,
};

//付费的Config菜单Id
Set<int> paidConfigMenuIds = {
  MenuId.labelDesignPage.index,
  MenuId.receiptDesignPage.index,
  MenuId.serialOutputDesignPage.index,
  MenuId.basicDataCollectionPage.index,
  MenuId.parameterSettingPage.index,
};

// 存储用户选择要添加的付费菜单 ID
Set<int> selectedAppsPaidMenuIds = {
  MenuId.weightModePage.index,
  MenuId.retailReportPage.index,
};

//免费的appId
Set<int> freeAppMenuIds = {
  MenuId.weightModePage.index,
  MenuId.retailReportPage.index,
};

//零售的appId
Set<int> retailAppMenuIds = {
  MenuId.labelDesignPage.index,
  MenuId.receiptDesignPage.index,
};

//零售的appId
Set<int> industrialAppMenuIds = {
  MenuId.weightDataCollectionPage.index,
  MenuId.checkWeighersPage.index,
  MenuId.takeInPage.index,
  MenuId.takeOutPage.index,
  MenuId.formulationScalePage.index,
  MenuId.flowRatePage.index,
};

//如何定义一个枚举类型 比如  home  = 1  config = 2  apps = 3  appsSetting = 4  systemSetting = 5
// ... 已有代码 ...

enum MenuId {
  multiScaleManagement,
  setSystemTimePage,
  btSettingPage,
  wifiSettingPage,
  updateFirmwarePage,
  labelDesignPage,
  receiptDesignPage,
  serialOutputDesignPage,
  basicDataCollectionPage,
  parameterSettingPage,
  weightModePage,
  pluEditPage,
  downloadLabelPage,
  downReciptPage,
  retailReportPage,
  headerFooterPage,
  weightDataCollectionPage,
  checkWeighersPage,
  takeInPage,
  takeOutPage,
  formulationScalePage,
  flowRatePage,
  calibrationPage;
}
