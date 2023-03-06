// DevPath  string // device path of Com port, e.g. COM3
// 	Baud     int
// 	DataBits int // value: 7,8,9
// 	StopBits float32 // value should be 1, 1.5, 2.0
// 	Parity   int

// class ComInfo {
//   String? portName;
//   int? baud;
//   int? dataBits;
//   String? parity;
//   double? stopbits;

//   ComInfo(this.portName, this.baud, this.dataBits, this.parity, this.stopbits);

//   ComInfo.fromJson(Map<String, dynamic> json) {
//     portName = json['portName'];
//     baud = json['baud'];
//     dataBits = json['dataBits'];
//     parity = json['parity'];
//     stopbits = json['stopbits'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['portName'] = portName;
//     data['baud'] = baud;
//     data['dataBits'] = dataBits;
//     data['parity'] = parity;
//     data['stopbits'] = stopbits;
//     return data;
//   }
// }
