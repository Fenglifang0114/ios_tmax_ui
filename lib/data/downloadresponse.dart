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
      : msgType = json['MsgType'],
        msgBody = json['MsgBody'],
        scaleId = json['ScaleId'];

  Map<String, dynamic> toJson() {
    return {
      'MsgType': msgType,
      'MsgBody': msgBody,
      'ScaleId': scaleId,
    };
  }
}

DownloadResponse myDownloadResponse = DownloadResponse(0, '', 0);
