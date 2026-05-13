import 'conninfo_data.dart';

class ConnInfoList {
  int? count;
  List<ConnInfo>? infolist; //list 是关键字，因此修改名字为infolist

  ConnInfoList(this.count, this.infolist);

  ConnInfoList.fromJson(Map<String, dynamic> json) {
    count = json['count'];
    if (json['list'] != null) {
      infolist = <ConnInfo>[];
      json['list'].forEach((v) {
        infolist!.add(ConnInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['count'] = count;
    if (infolist != null) {
      data['list'] = infolist!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

ConnInfoList myConnInfoList = ConnInfoList(0, []);
