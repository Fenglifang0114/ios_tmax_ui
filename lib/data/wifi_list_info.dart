class WifiListInfo {
  List<WifiInfo>? wifidatalist;

  WifiListInfo({this.wifidatalist});

  factory WifiListInfo.fromJson(List<dynamic> parsedJson) {
    List<WifiInfo> wifidatalist = <WifiInfo>[];
    wifidatalist = parsedJson.map((i) => WifiInfo.fromJson(i)).toList();

    return WifiListInfo(wifidatalist: wifidatalist);
  }
}

WifiListInfo myWifiListInfo = WifiListInfo(wifidatalist: []);

class WifiInfo {
  int? seqno;
  String? ssid;
  int? rssi;
  String? mac;
  String? enccryptType;

  WifiInfo({this.seqno, this.ssid, this.rssi, this.mac, this.enccryptType});

  WifiInfo.fromJson(Map<String, dynamic> json) {
    seqno = json['seqno'];
    ssid = json['ssid'];
    rssi = json['rssi'];
    mac = json['mac'];
    enccryptType = json['enccryptType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['seqno'] = seqno;
    data['ssid'] = ssid;
    data['rssi'] = rssi;
    data['mac'] = mac;
    data['enccryptType'] = enccryptType;
    return data;
  }
}

WifiInfo myWifiInfo = WifiInfo();
