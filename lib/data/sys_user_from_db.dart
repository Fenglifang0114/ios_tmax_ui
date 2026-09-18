// To parse this JSON data, do
//
//     final sysUserDetailFromDb = sysUserDetailFromDbFromJson(jsonString);

import 'dart:convert';
import 'package:flutter/foundation.dart';

SysUserDetailFromDb sysUserDetailFromDbFromJson(String str) {
  try {
    if (str.trim().isEmpty) return SysUserDetailFromDb();
    final decoded = json.decode(str);
    if (decoded is Map<String, dynamic>) {
      return SysUserDetailFromDb.fromJson(decoded);
    } else if (decoded is Map) {
      return SysUserDetailFromDb.fromJson(Map<String, dynamic>.from(decoded));
    }
  } catch (e) {
    debugPrint("sysUserDetailFromDbFromJson error: $e");
  }
  return SysUserDetailFromDb();
}

String sysUserDetailFromDbToJson(SysUserDetailFromDb data) =>
    json.encode(data.toJson());

class SysUserDetailFromDb {
  int? userId;
  String? userName;
  String? nickName;
  String? password;
  String? email;
  String? phone;
  bool? isEnabled;
  int? roleId;
  String? roleName;
  int? initialPageId;
  bool? isChanged;
  List<int>? pageIdList;

  SysUserDetailFromDb({
    this.userId,
    this.userName,
    this.nickName,
    this.password,
    this.email,
    this.phone,
    this.isEnabled,
    this.roleId,
    this.roleName,
    this.initialPageId,
    this.isChanged,
    this.pageIdList,
  });

  factory SysUserDetailFromDb.fromJson(Map<String, dynamic> json) =>
      SysUserDetailFromDb(
        userId: json["userId"] is int ? json["userId"] : int.tryParse(json["userId"]?.toString() ?? ''),
        userName: json["userName"]?.toString(),
        nickName: json["nickName"]?.toString(),
        password: json["password"]?.toString(),
        email: json["email"]?.toString(),
        phone: json["phone"]?.toString(),
        isEnabled: json["isEnabled"] == true || json["isEnabled"] == 1 || json["isEnabled"] == "true",
        roleId: json["roleId"] is int ? json["roleId"] : int.tryParse(json["roleId"]?.toString() ?? ''),
        roleName: json["roleName"]?.toString(),
        initialPageId: json["initialPageId"] is int ? json["initialPageId"] : int.tryParse(json["initialPageId"]?.toString() ?? ''),
        isChanged: json["isChanged"] == true || json["isChanged"] == 1 || json["isChanged"] == "true",
        pageIdList: json["pageIdList"] == null
            ? []
            : (json["pageIdList"] is List
                ? List<int>.from(json["pageIdList"].map((x) => x is int ? x : int.tryParse(x?.toString() ?? '') ?? 0))
                : []),
      );

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "userName": userName,
        "nickName": nickName,
        "password": password,
        "email": email,
        "phone": phone,
        "isEnabled": isEnabled,
        "roleId": roleId,
        "roleName": roleName,
        "initialPageId": initialPageId,
        "isChanged": isChanged,
        "pageIdList": pageIdList == null
            ? []
            : List<dynamic>.from(pageIdList!.map((x) => x)),
      };
}

//全部的系统用户
List<SysUserFromDb> sysUserFromDbFromJson(String str) {
  try {
    if (str.trim().isEmpty) return [];
    final decoded = json.decode(str);
    if (decoded is List) {
      return decoded.map((x) {
        if (x is Map<String, dynamic>) {
          return SysUserFromDb.fromJson(x);
        } else if (x is Map) {
          return SysUserFromDb.fromJson(Map<String, dynamic>.from(x));
        }
        return SysUserFromDb();
      }).toList();
    }
  } catch (e) {
    debugPrint("sysUserFromDbFromJson parse error: $e");
  }
  return [];
}

String sysUserFromDbToJson(List<SysUserFromDb> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

DateTime? _safeParseDateTime(dynamic val) {
  if (val == null) return null;
  String str = val.toString().trim();
  if (str.isEmpty || str == "0001-01-01T00:00:00Z" || str.startsWith("0001-01-01")) return null;
  try {
    return DateTime.tryParse(str)?.toLocal();
  } catch (_) {
    return null;
  }
}

class SysUserFromDb {
  int? userId;
  String? userName;
  String? nickName;

  int? roleId;
  String? password;
  bool? isEnabled;
  String? email;
  String? phone;
  int? initialPageId;
  String? remark;
  DateTime? createdTime;
  DateTime? updatedTime;
  int? createdBy;
  int? updatedBy;
  bool? isChanged;

  SysUserFromDb({
    this.userId,
    this.userName,
    this.nickName,
    this.roleId,
    this.password,
    this.isEnabled,
    this.email,
    this.phone,
    this.initialPageId,
    this.remark,
    this.createdTime,
    this.updatedTime,
    this.createdBy,
    this.updatedBy,
    this.isChanged,
  });

  factory SysUserFromDb.fromJson(Map<String, dynamic> json) => SysUserFromDb(
        userId: json["UserId"] is int ? json["UserId"] : int.tryParse(json["UserId"]?.toString() ?? ''),
        userName: json["UserName"]?.toString(),
        nickName: json["NickName"]?.toString(),
        roleId: json["RoleId"] is int ? json["RoleId"] : int.tryParse(json["RoleId"]?.toString() ?? ''),
        password: json["Password"]?.toString(),
        isEnabled: json["IsEnabled"] == true || json["IsEnabled"] == 1 || json["IsEnabled"] == "true",
        email: json["Email"]?.toString(),
        phone: json["Phone"]?.toString(),
        initialPageId: json["InitialPageId"] is int ? json["InitialPageId"] : int.tryParse(json["InitialPageId"]?.toString() ?? ''),
        remark: json["Remark"]?.toString(),
        createdTime: _safeParseDateTime(json["CreatedTime"]),
        updatedTime: _safeParseDateTime(json["UpdatedTime"]),
        createdBy: json["CreatedBy"] is int ? json["CreatedBy"] : int.tryParse(json["CreatedBy"]?.toString() ?? ''),
        updatedBy: json["UpdatedBy"] is int ? json["UpdatedBy"] : int.tryParse(json["UpdatedBy"]?.toString() ?? ''),
        isChanged: json["IsChanged"] == true || json["IsChanged"] == 1 || json["IsChanged"] == "true",
      );

  Map<String, dynamic> toJson() => {
        "UserId": userId,
        "UserName": userName,
        "NickName": nickName,
        "RoleId": roleId,
        "Password": password,
        "IsEnabled": isEnabled,
        "Email": email,
        "Phone": phone,
        "InitialPageId": initialPageId,
        "Remark": remark,
        "CreatedTime": createdTime?.toIso8601String(),
        "UpdatedTime": updatedTime?.toIso8601String(),
        "CreatedBy": createdBy,
        "UpdatedBy": updatedBy,
        "IsChanged": isChanged,
      };
}
