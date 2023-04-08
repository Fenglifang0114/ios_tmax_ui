// 9. {"MsgType":13,"MsgBody":"no response, time out","ScaleId":1}  下载后秤反馈的消息

class DownloadResponse {
  String msgBody;
  int msgType;
  int scaleId;
  DownloadResponse(
    this.msgType,
    this.msgBody,
    this.scaleId,
  );
  DownloadResponse.fromJson(Map<String, dynamic> json)
      : msgType = json['name'],
        msgBody = json['type'],
        scaleId = json['device'];

  Map<String, dynamic> toJson() {
    return {
      'name': msgType,
      'type': msgBody,
      'device': scaleId,
      'num': num,
    };
  }
}

DownloadResponse myDownloadResponse = DownloadResponse(0, '', 0);
