import 'package:flutter/material.dart';
import 'package:t_max/data/fma_rec_list_db_data.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/req_formula_data.dart';

List<CategoryTypeList> rawTypeList = [];

List<CategoryTypeList> formulaTypeList = [];

List<RawDataInfo> rawDataList = [];

List<FormulaInfoDb> formulaDataList = [];

List<FmaRecFromDb> fmaRecFromDbList = [];

//定义常量的颜色

Color bgColor = const Color(0xFFEFEFEF); //灰色
Color clickColor = const Color(0xFFECECEC); //浅灰色
Color lineColor = const Color(0xFFEEEEEE); //深灰色
Color greenColor = const Color(0xFF1EAF81); //绿色
Color redColor = const Color(0xFFFB4545); //红色
Color wgtBgColor = const Color(0xFFF4F4F4); //背景色

String noStr = 'no'; //无
String lowStr = 'low'; //低
String highStr = 'high'; //高
String okStr = 'ok'; //正常
String yesStr = 'yes'; //有

String pctStr = 'pct'; //百分比
String wgtStr = 'wgt'; //重量

String pctStrShow = '%'; //百分比
String wgtStrShow = 'g'; //重量

String showErrorStr = '± '; //误差显示格式

//重量或者百分比
enum FormulaMode {
  wgt,
  pct,
}

//重量单位
enum FormulaWgtUnit {
  kg,
  g,
  lb,
}
