// 9. {"MsgType":13,"MsgBody":"no response, time out","ScaleId":1}  下载后秤反馈的消息
//10.{"MsgType":14,"MsgBody":"serial port error","ScaleId":1}  串口报错后的反馈

class ChannelResponse {
  String msgBody;
  String msgType;
  int scaleId;
  ChannelResponse(
    this.msgType,
    this.msgBody,
    this.scaleId,
  );
  ChannelResponse.fromJson(Map<String, dynamic> json)
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

ChannelResponse myDownloadResponse = ChannelResponse('', '', 0);

ChannelResponse mySerialPortResponse = ChannelResponse('', '', 0);

ChannelResponse myConnectDynamicIpResponse = ChannelResponse('', '', 0);

ChannelResponse myConnectStaticIpResponse = ChannelResponse('', '', 0);

class SerialPortStatus {
  bool serialPortStatus;

  SerialPortStatus(
    this.serialPortStatus,
  );
}

SerialPortStatus mySerialPortStatus = SerialPortStatus(true);
