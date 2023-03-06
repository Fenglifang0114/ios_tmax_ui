class ComInfoList {
  List<String>? msgBody;

  ComInfoList(this.msgBody);

  ComInfoList.fromJson(Map<String, dynamic> json) {
    msgBody = json['MsgBody'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['MsgBody'] = msgBody;
    return data;
  }
}

ComInfoList myComInfoList = ComInfoList([]);
