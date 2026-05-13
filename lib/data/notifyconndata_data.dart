class NotifyConnData {
  int? connId;
  String? status;

  NotifyConnData(this.connId, this.status);

  NotifyConnData.fromJson(Map<String, dynamic> json) {
    connId = json['connId'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['connId'] = connId;
    data['status'] = status;
    return data;
  }
}

NotifyConnData myNotifyConnData = NotifyConnData(1, "");
