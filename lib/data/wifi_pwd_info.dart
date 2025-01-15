// To parse this JSON data, do
//
//     final wifiPwdInfoList = wifiPwdInfoListFromJson(jsonString);
//wifi 密码解析
import 'dart:convert';

List<WifiPwdInfoList> wifiPwdInfoListFromJson(String str) =>
    List<WifiPwdInfoList>.from(
        json.decode(str).map((x) => WifiPwdInfoList.fromJson(x)));

class WifiPwdInfoList {
  int id;
  String ssid;
  String pwd;
  DateTime? createdAt;

  WifiPwdInfoList({
    required this.id,
    required this.ssid,
    required this.pwd,
    this.createdAt,
  });

  factory WifiPwdInfoList.fromJson(Map<String, dynamic> json) =>
      WifiPwdInfoList(
        id: json["Id"],
        ssid: json["Ssid"],
        pwd: json["Pwd"],
        createdAt: DateTime.parse(json["CreatedAt"]),
      );
}

List<WifiPwdInfoList> myWifiPwdInfoList = [];
