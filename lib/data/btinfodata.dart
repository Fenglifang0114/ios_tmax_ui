import 'dart:convert';

List<BtInfo> btInfoFromJson(String str) =>
    List<BtInfo>.from(json.decode(str).map((x) => BtInfo.fromJson(x)));

class BtInfo {
  String? mac;
  String? name;
  int? rssi;

  BtInfo({
    this.mac,
    this.name,
    this.rssi,
  });

  factory BtInfo.fromJson(Map<String, dynamic> json) => BtInfo(
        mac: json["mac"],
        name: json["name"],
        rssi: json["rssi"],
      );

  Map<String, dynamic> toJson() => {
        "mac": mac,
        "name": name,
        "rssi": rssi,
      };
}
