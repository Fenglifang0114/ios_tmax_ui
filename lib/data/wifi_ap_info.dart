class WiFiAPInfo {
  String? ssid;
  String? bssid;
  String? channel;
  int? rssi;

  WiFiAPInfo({this.ssid, this.bssid, this.channel, this.rssi});

  WiFiAPInfo.fromJson(Map<String, dynamic> json) {
    ssid = json['Ssid'];
    bssid = json['Bssid'];
    channel = json['Channel'];
    rssi = json['Rssi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Ssid'] = ssid;
    data['Bssid'] = bssid;
    data['Channel'] = channel;
    data['Rssi'] = rssi;
    return data;
  }
}

WiFiAPInfo myWiFiAPInfo = WiFiAPInfo();
