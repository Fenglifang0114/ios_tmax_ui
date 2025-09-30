import 'package:t_max/data/darf_fma_data_from_db.dart';
import 'package:t_max/data/fma_rec_list_db_data.dart';
import 'package:t_max/data/formula_from_db_data.dart';
import 'package:t_max/data/formula_scale_data.dart';
import 'package:t_max/data/import_fma_data.dart';
import 'package:t_max/data/req_formula_data.dart';

List<CategoryTypeList> rawTypeList = [];

List<CategoryTypeList> formulaTypeList = [];

List<RawDataInfo> rawDataList = [];

List<FormulaInfoDb> formulaDataList = [];
List<FormulaInfoDb> searchFmaList = [];

List<FmaRecFromDb> fmaRecFromDbList = [];

List<DarfFmaInfo> darfFmaInfoList = []; //暂存的配方称重记录和配方明细

String getFmaTypeName(int fmaTypeId) {
  for (var item in formulaTypeList) {
    if (item.categoryId == fmaTypeId) {
      return item.categoryName;
    }
  }
  return '-';
}

String getRawTypeName(int rawTypeId) {
  for (var item in rawTypeList) {
    if (item.categoryId == rawTypeId) {
      return item.categoryName;
    }
  }
  return '-';
}

// 定义 EncryptedValue 枚举
enum EncryptedValue {
  confidential,
  public,
}

class ExportResult {
  bool isSuccess;
  String? errorMessage;
  ExportResult({required this.isSuccess, this.errorMessage});
}

class ImportFmaResult {
  bool isSuccess;
  String? errorMessage;
  List<ImportFmaInfo> importFmaInfoList;

  ImportFmaResult(
      {required this.isSuccess,
      this.errorMessage,
      required this.importFmaInfoList});
}

class ImportRawResult {
  bool isSuccess;
  String? errorMessage;
  List<List<String>> importRawList;

  ImportRawResult(
      {required this.isSuccess,
      this.errorMessage,
      required this.importRawList});
}

//定义常量的颜色

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
