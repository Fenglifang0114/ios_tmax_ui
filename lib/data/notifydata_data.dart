const int notifyTypeConn = 1;

class NotifyData {
  int? notifyType;
  Object? data;

  NotifyData(this.notifyType, this.data);

  NotifyData.fromJson(Map<String, dynamic> json) {
    notifyType = json['notifyType'];
    if (notifyType == notifyTypeConn) {
      data = json['data'] != null ? NotifyData.fromJson(json['data']) : null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['notifyType'] = notifyType;
    if (this.data != null) {
      if (notifyType == notifyTypeConn) {
        data['data'] = (data as NotifyData).toJson();
      }
    }
    return data;
  }
}

NotifyData myNotifyData = NotifyData(0, {});
