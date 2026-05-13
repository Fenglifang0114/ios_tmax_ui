import 'dart:convert';

PakInfo pakInfoFromJson(String str) => PakInfo.fromJson(json.decode(str));
String pakInfoToJson(PakInfo data) => json.encode(data.toJson());

List<PakInfo> myDetailPakList = [];

class PakInfo {
  int pakCount;
  int pagId;
  String msgBody;

  PakInfo({
    required this.pakCount,
    required this.pagId,
    required this.msgBody,
  });

  factory PakInfo.fromJson(Map<String, dynamic> json) => PakInfo(
        pakCount: json["PakCount"],
        pagId: json["PagId"],
        msgBody: json["MsgBody"],
      );

  Map<String, dynamic> toJson() => {
        "PakCount": pakCount,
        "PagId": pagId,
        "MsgBody": msgBody,
      };
}

class RevPakInfo {
  StringBuffer msgBody;

  RevPakInfo({
    required this.msgBody,
  });
}

RevPakInfo myDetailRevPak = RevPakInfo(msgBody: StringBuffer());
