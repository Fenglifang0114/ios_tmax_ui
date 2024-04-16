class ServerIpData {
  String? ip;
  String? netmask;
  String? gateway;
  String? serverIp;
  String? serverPort;

  ServerIpData();
  ServerIpData.fromJson(Map<String, dynamic> json)
      : ip = json['ip'],
        netmask = json['netmask'],
        gateway = json['gateway'],
        serverIp = json['serverIp'],
        serverPort = json['serverPort'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ip'] = ip;
    data['netmask'] = netmask;
    data['gateway'] = gateway;
    data['serverIp'] = serverIp;
    data['serverPort'] = serverPort;

    return data;
  }
}

ServerIpData myServerIpData = ServerIpData();
