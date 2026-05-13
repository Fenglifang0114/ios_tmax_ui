import 'package:t_max/data/ports.dart';

//获取串口列表

class SPortInfoList {
  int? count;
  List<Ports>? ports;
  SPortInfoList(this.count, this.ports);

  SPortInfoList.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['ports'] != null) {
      ports = <Ports>[];
      json['ports'].forEach((v) {
        ports!.add(Ports.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    if (ports != null) {
      data['ports'] = ports!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

SPortInfoList mySPortInfoList = SPortInfoList(0, [myPorts]);
