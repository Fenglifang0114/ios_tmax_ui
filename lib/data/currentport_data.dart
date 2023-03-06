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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DevPath'] = this.devPath;
    data['Baud'] = this.baud;
    data['DataBits'] = this.dataBits;
    data['StopBits'] = this.stopBits;
    data['Parity'] = this.parity;
    return data;
  }
}

CurrentPort myCurrentPort = CurrentPort();
CurrentPort tempCurrentPort = CurrentPort();
