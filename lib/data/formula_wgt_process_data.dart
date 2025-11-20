//称重配方过程中使用的数据
class FormulaWgtProcessData {
  int? no;
  String? rawId; //原料编号
  String? rawName; //原料名称
  String? fmaMode; //配方模式
  double? targetWgt; //目标重量
  double? targetPct; //目标百分比
  double? currentWgt; //当前重量
  double? minWgt; //最小重量
  double? maxWgt; //最大重量
  double? errorWgt; //误差重量
  double? errorPct; //误差百分比
  double? currentErrorWgt; //实际误差重量
  double? currentErrorPct; //实际误差百分比
  String? isOK; //是否OK
  int? scaleId; //秤号
  String? scaleName; //秤名
  String? scaleModel; //秤型
  String? scaleSn; //秤序列号
  String? checkCode; //校验码

  FormulaWgtProcessData({
    this.no,
    this.rawId,
    this.rawName,
    this.fmaMode,
    this.targetWgt,
    this.targetPct,
    this.currentWgt,
    this.minWgt,
    this.maxWgt,
    this.errorWgt,
    this.errorPct,
    this.currentErrorWgt,
    this.currentErrorPct,
    this.isOK,
    this.scaleId,
    this.scaleName,
    this.scaleModel,
    this.scaleSn,
    this.checkCode,
  });
}
