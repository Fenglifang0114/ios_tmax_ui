// 日志数据模型
//模块：系统，功能模块：登录，操作类型：登录
//模块：系统，功能模块：登出，操作类型：登出
//模块：系统，功能模块：修改密码，操作类型：修改密码

//模块：系统，功能模块：账户管理，操作类型：新增
//模块：系统，功能模块：账户管理，操作类型：删除
//模块：系统，功能模块：账户管理，操作类型：修改

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:t_max/data/language.dart';
import 'package:t_max/dialog/custom_dialog_tip.dart';

SysLogFormDb sysLogFormDbFromJson(String str) =>
    SysLogFormDb.fromJson(json.decode(str));

class SysLogFormDb {
  int? total;
  List<SysLog>? logs;

  SysLogFormDb({
    this.total,
    this.logs,
  });

  factory SysLogFormDb.fromJson(Map<String, dynamic> json) => SysLogFormDb(
        total: json["Total"],
        logs: json["Logs"] == null
            ? []
            : List<SysLog>.from(json["Logs"]!.map((x) => SysLog.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Total": total,
        "Logs": logs == null
            ? []
            : List<dynamic>.from(logs!.map((x) => x.toJson())),
      };
}

class SysLog {
  int? recId;
  String? operator;
  int? roleId;
  String? module;
  String? funcName;
  String? operationType;
  String? operation;
  String? result;
  String? remarks;
  DateTime? createTime;

  SysLog({
    this.recId,
    this.operator,
    this.roleId,
    this.module,
    this.funcName,
    this.operationType,
    this.operation,
    this.result,
    this.remarks,
    this.createTime,
  });

  factory SysLog.fromJson(Map<String, dynamic> json) => SysLog(
        recId: json["RecId"],
        operator: json["Operator"],
        roleId: json["RoleId"],
        module: json["Module"],
        funcName: json["FuncName"],
        operationType: json["OperationType"],
        operation: json["Operation"],
        result: json["Result"],
        remarks: json["Remarks"],
        createTime: json["CreateTime"] == null
            ? null
            : DateTime.parse(json["CreateTime"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "Operator": operator,
        "RoleId": roleId,
        "Module": module,
        "FuncName": funcName,
        "OperationType": operationType,
        "Operation": operation,
        "Result": result,
        "Remarks": remarks,
        "CreateTime": createTime?.toIso8601String(),
      };
}

//标定日志

CalLogFormDb calLogFormDbFromJson(String str) =>
    CalLogFormDb.fromJson(json.decode(str));

class CalLogFormDb {
  int? total;
  List<CalLog>? logs;

  CalLogFormDb({
    this.total,
    this.logs,
  });

  factory CalLogFormDb.fromJson(Map<String, dynamic> json) => CalLogFormDb(
        total: json["Total"],
        logs: json["Logs"] == null
            ? []
            : List<CalLog>.from(json["Logs"]!.map((x) => CalLog.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Total": total,
        "Logs": logs == null
            ? []
            : List<dynamic>.from(logs!.map((x) => x.toJson())),
      };
}

class CalLog {
  int? recId;
  String? operator;
  int? roleId;
  int? scaleId;
  String? scaleName;
  String? modelName;
  String? sn;
  String? type;
  String? mode;
  String? unit;
  String? calValue;
  String? before;
  String? after;
  String? calError;
  String? calResult;
  String? remarks;
  DateTime? createTime;

  CalLog({
    this.recId,
    this.operator,
    this.roleId,
    this.scaleId,
    this.scaleName,
    this.modelName,
    this.sn,
    this.type,
    this.mode,
    this.unit,
    this.calValue,
    this.before,
    this.after,
    this.calError,
    this.calResult,
    this.remarks,
    this.createTime,
  });

  factory CalLog.fromJson(Map<String, dynamic> json) => CalLog(
        recId: json["RecId"],
        operator: json["Operator"],
        roleId: json["RoleId"],
        scaleId: json["ScaleId"],
        scaleName: json["ScaleName"],
        modelName: json["ModelName"],
        sn: json["Sn"],
        type: json["Type"],
        mode: json["Mode"],
        unit: json["Unit"],
        calValue: json["Value"],
        before: json["Before"],
        after: json["After"],
        calError: json["Error"],
        calResult: json["Result"],
        remarks: json["Remarks"],
        createTime: json["CreateTime"] == null
            ? null
            : DateTime.parse(json["CreateTime"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "Operator": operator,
        "RoleId": roleId,
        "ScaleId": scaleId,
        "ScaleName": scaleName,
        "ModelName": modelName,
        "Sn": sn,
        "Type": type,
        "Mode": mode,
        "Unit": unit,
        "Value": calValue,
        "Before": before,
        "After": after,
        "Error": calError,
        "Result": calResult,
        "Remarks": remarks,
        "CreateTime": createTime?.toIso8601String(),
      };
}

//称重记录

WgtLogFormDb wgtLogFormDbFromJson(String str) =>
    WgtLogFormDb.fromJson(json.decode(str));

class WgtLogFormDb {
  int? total;
  List<ScaleWgtInfo>? logs;

  WgtLogFormDb({
    this.total,
    this.logs,
  });

  factory WgtLogFormDb.fromJson(Map<String, dynamic> json) => WgtLogFormDb(
        total: json["Total"],
        logs: json["Logs"] == null
            ? []
            : List<ScaleWgtInfo>.from(
                json["Logs"]!.map((x) => ScaleWgtInfo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Total": total,
        "Logs": logs == null
            ? []
            : List<dynamic>.from(logs!.map((x) => x.toJson())),
      };
}

class ScaleWgtInfo {
  int? recId;
  String? operator;
  int? roleId;
  String? module;
  String? scaleName;
  String? modelName;
  String? sn;
  String? weight;
  String? unit;
  String? remarks;
  DateTime? createTime;

  ScaleWgtInfo({
    this.recId,
    this.operator,
    this.roleId,
    this.module,
    this.scaleName,
    this.modelName,
    this.sn,
    this.weight,
    this.unit,
    this.remarks,
    this.createTime,
  });

  factory ScaleWgtInfo.fromJson(Map<String, dynamic> json) => ScaleWgtInfo(
        recId: json["RecId"],
        operator: json["Operator"],
        roleId: json["RoleId"],
        module: json["Module"],
        scaleName: json["ScaleName"],
        modelName: json["ModelName"],
        sn: json["Sn"],
        weight: json["Weight"],
        unit: json["Unit"],
        remarks: json["Remarks"],
        createTime: json["CreateTime"] == null
            ? null
            : DateTime.parse(json["CreateTime"]).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        "RecId": recId,
        "Operator": operator,
        "RoleId": roleId,
        "Module": module,
        "ScaleName": scaleName,
        "ModelName": modelName,
        "Sn": sn,
        "Weight": weight,
        "Unit": unit,
        "Remarks": remarks,
        "CreateTime": createTime?.toIso8601String(),
      };
}

String reqGetLogToJson(ReqGetLog data) => json.encode(data.toJson());

class ReqGetLog {
  int? page;
  int? pageSize;
  String? fieldName;
  String? direction;
  Search? search;

  ReqGetLog({
    this.page,
    this.pageSize,
    this.fieldName,
    this.direction,
    this.search,
  });

  Map<String, dynamic> toJson() => {
        "page": page,
        "pageSize": pageSize,
        "fieldName": fieldName,
        "direction": direction,
        "search": search?.toJson(),
      };
}

class Search {
  String? searchOperator;
  String? module;
  int? roleId;
  String? startTime;
  String? endTime;

  Search({
    this.searchOperator,
    this.module,
    this.roleId,
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() => {
        "operator": searchOperator,
        "module": module,
        "roleId": roleId,
        "startTime": startTime,
        "endTime": endTime,
      };
}

String reqDelLogsToJson(ReqDelLogs data) => json.encode(data.toJson());

class ReqDelLogs {
  List<int>? recId;

  ReqDelLogs({
    this.recId,
  });

  Map<String, dynamic> toJson() => {
        "RecId": recId == null ? [] : List<dynamic>.from(recId!.map((x) => x)),
      };
}

class SysLogTranslator {
  static Map<String, String> _sysLogLanguageMap = {};

  static void updateLanguageMap() {
    _sysLogLanguageMap = {
      "3": localizedStrings.operator,
      "2": localizedStrings.admin,
      "1": localizedStrings.superAdmin,

      //主模块
      "system": localizedStrings.systemOperation,
      "syslog": localizedStrings.systemRecords,
      "callog": localizedStrings.calibrationRecords,
      "scalelog": localizedStrings.weighingRecords,
      "scale_manage": localizedStrings.menuMultiScaleManagement,
      "plu_manage": localizedStrings.menuPluManagement,
      "user_manage": localizedStrings.userManagement,
      "formula_manage": localizedStrings.menuFormula,
      "device_time": localizedStrings.menuDeviceTime,
      "device_bt": localizedStrings.menuBluetoothSetting,
      "update_firmware": localizedStrings.menuFirmwareUpdate,
      "down_label_fmt": localizedStrings.menuLabelFormatDownload,
      "down_receipt_fmt": localizedStrings.menuReceiptFormatDownload,

      //子模块
      "log_del": localizedStrings.deleteLog,
      "log_export": localizedStrings.opExport,
      "log_clear": localizedStrings.fClearBtn,
      "user_update_pswd": localizedStrings.titleChangePassword,

      "user_enabled": localizedStrings.enableOrDisable,
      "formula_add": localizedStrings.addFormula,
      "formula_del": localizedStrings.deleteFormula,
      "formula_update": localizedStrings.modifyFormula,
      "formula_type_add": localizedStrings.addFormulaCategory,
      "formula_type_del": localizedStrings.deleteFormulaCategory,
      "formula_type_update": localizedStrings.modifyFormulaCategory,
      "formula_type_clear_unused": localizedStrings.clearUnusedFormulaCategory,
      "raw_type_add": localizedStrings.addIngredientCategory,
      "raw_type_del": localizedStrings.deleteIngredientCategory,
      "raw_type_update": localizedStrings.modifyIngredientCategory,
      "raw_type_clear_unused": localizedStrings.clearUnusedIngredientCategory,
      "raw_add": localizedStrings.addIngredient,
      "raw_del": localizedStrings.deleteIngredient,
      "raw_update": localizedStrings.modifyIngredient,
      "fma_wgt_rec_add": localizedStrings.addFormulaWeighingRecord,
      "fma_wgt_rec_del": localizedStrings.deleteFormulaWeighingRecord,
      "fma_draft_add": localizedStrings.addTemporaryWeighingRecord,
      "fma_draft_del": localizedStrings.deleteTemporaryWeighingRecord,
      "fma_draft_update": localizedStrings.modifyTemporaryWeighingRecord,
      "device_time_set": localizedStrings.setTime,
      "bt_set_name": localizedStrings.setName,
      "bt_set_power": localizedStrings.setPower,
      "fma_wgt_rec_upload": localizedStrings.uploadFmaWgtRecord,

      //操作结果
      "ok": localizedStrings.success,
      "fail": localizedStrings.failure,

      //操作
      "login": localizedStrings.login,
      "logout": localizedStrings.logout,
      "delete": localizedStrings.delete,
      "add": localizedStrings.gBtnAdd,
      "clear": localizedStrings.fClearBtn,
      "update": localizedStrings.opUpdate,
      "enabled": localizedStrings.opEnable,
      "query": localizedStrings.opQuery,
      "issue": localizedStrings.opIssue,
      "import": localizedStrings.opImport,
      "export": localizedStrings.opExport,
      "setting": localizedStrings.opSetting,
      "upload": localizedStrings.opUpload,
    };
  }

  static String getTranslation(String key) {
    if (_sysLogLanguageMap.isEmpty) {
      updateLanguageMap();
    }

    return _sysLogLanguageMap[key] ?? key;
  }

  static Map<String, String> getLanguageMap() {
    return _sysLogLanguageMap;
  }
}

// 使用时替换原来的 getSysLogTrans 函数
String getSysLogTrans(String key) {
  return SysLogTranslator.getTranslation(key);
}

class ReqExportLog {
  final String filePath;
  final String fieldName;
  final String direction;
  final Search search;
  final Map<String, String> translation; // 使用 dynamic 类型

  ReqExportLog({
    required this.filePath,
    this.fieldName = '',
    this.direction = '',
    required this.search,
    this.translation = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'FilePath': filePath,
      'FieldName': fieldName,
      'Direction': direction,
      'Search': search.toJson(),
      'Translation': translation, // 直接使用，不需要转换
    };
  }
}

class WgtLogTranslator {
  static Map<String, String> _wgtLogLanguageMap = {};

  static void updateLanguageMap() {
    _wgtLogLanguageMap = {
      "wgt_col": localizedStrings.menuWeighingDataCollection,
      "check_wgt": localizedStrings.menuCheckWeighing,
      "take_in": localizedStrings.menuIncrementWeighing,
      "take_out": localizedStrings.menuTakeOutScale,
      "3": localizedStrings.operator,
      "2": localizedStrings.admin,
      "1": localizedStrings.superAdmin,
    };
  }

  static String getTranslation(String key) {
    if (_wgtLogLanguageMap.isEmpty) {
      updateLanguageMap();
    }

    return _wgtLogLanguageMap[key] ?? key;
  }

  static Map<String, String> getLanguageMap() {
    return _wgtLogLanguageMap;
  }
}

// 使用时替换原来的 getSysLogTrans 函数
String getWgtLogTrans(String key) {
  return WgtLogTranslator.getTranslation(key);
}

void showDeleteDialog(Function()? onDelete, String msg, BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // 点击对话框外部不关闭对话框
    builder: (BuildContext context) {
      return ShowDeleteTipDialog(
        title: localizedStrings.fTipTitle,
        msg: msg,
      );
    },
  ).then((value) {
    if (value) {
      onDelete?.call();
    }
  });
}

class CalLogTranslator {
  static Map<String, String> _calLogLanguageMap = {};

  static void updateLanguageMap() {
    _calLogLanguageMap = {
      "3": localizedStrings.operator,
      "2": localizedStrings.admin,
      "1": localizedStrings.superAdmin,
      "single": localizedStrings.singlePoint,
      "multi": localizedStrings.multiPoint,
      "ok": localizedStrings.success,
      "fail": localizedStrings.failure,
    };
  }

  static String getTranslation(String key) {
    if (_calLogLanguageMap.isEmpty) {
      updateLanguageMap();
    }

    return _calLogLanguageMap[key] ?? key;
  }

  static Map<String, String> getLanguageMap() {
    return _calLogLanguageMap;
  }
}

// 使用时替换原来的 getSysLogTrans 函数
String getCalLogTrans(String key) {
  return CalLogTranslator.getTranslation(key);
}
