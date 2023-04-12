class CurrentPort {
  String? devPath;
  int? baud;
  int? dataBits;
  int? stopBits;
  int? parity;

  CurrentPort(
      {this.devPath, this.baud, this.dataBits, this.stopBits, this.parity});

  CurrentPort.fromJson(Map<String, dynamic> json) {
    devPath = json['DevPath'];
    baud = json['Baud'];
    dataBits = json['DataBits'];
    stopBits = json['StopBits'];
    parity = json['Parity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DevPath'] = devPath;
    data['Baud'] = baud;
    data['DataBits'] = dataBits;
    data['StopBits'] = stopBits;
    data['Parity'] = parity;
    return data;
  }
}

CurrentPort myCurrentPort = CurrentPort();
CurrentPort tempCurrentPort = CurrentPort();
