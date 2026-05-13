class ConnInfoNet {
  String? ipAddr;

  ConnInfoNet(this.ipAddr);

  ConnInfoNet.fromJson(Map<String, dynamic> json) {
    ipAddr = json['ipAddr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ipAddr'] = ipAddr;
    return data;
  }
}

ConnInfoNet myConnInfoNet = ConnInfoNet("");
