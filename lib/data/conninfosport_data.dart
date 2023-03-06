class ConnInfoSport {
  String? portName;
  int? baud;
  int? dataBits;
  String? parity;
  int? stopbits;

  ConnInfoSport(
      this.portName, this.baud, this.dataBits, this.parity, this.stopbits);

  ConnInfoSport.fromJson(Map<String, dynamic> json) {
    portName = json['portName'];
    baud = json['baud'];
    dataBits = json['dataBits'];
    parity = json['parity'];
    stopbits = json['stopbits'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['portName'] = portName;
    data['baud'] = baud;
    data['dataBits'] = dataBits;
    data['parity'] = parity;
    data['stopbits'] = stopbits;
    return data;
  }
}

ConnInfoSport myConnInfoSport = ConnInfoSport("", 0, 0, " ", 0);
