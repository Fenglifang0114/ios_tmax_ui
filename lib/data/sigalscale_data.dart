/*
单通道收到的数据格式
*/
class RevScaleData {
  int scaleId;
  int msgType;
  String msgBody;

  RevScaleData(this.scaleId, this.msgType, this.msgBody);

  RevScaleData.fromJson(Map<String, dynamic> json)
      : scaleId = json['ScaleId'],
        msgType = json['MsgType'],
        msgBody = json['MsgBody'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ScaleId'] = this.scaleId;
    data['MsgType'] = this.msgType;
    data['MsgBody'] = this.msgBody;
    return data;
  }
}

RevScaleData myRevScaleData = RevScaleData(0, 0, "");
