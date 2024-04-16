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

ChannelResponse mySetSerialOutputResp = ChannelResponse('', '', 0);
ChannelResponse myDownPrnFmtResp = ChannelResponse('', '', 0);
ChannelResponse mySerialPortResponse = ChannelResponse('', '', 0);
ChannelResponse mySetDynamicIpResp = ChannelResponse('', '', 0);
ChannelResponse mySetStaticIpResp = ChannelResponse('', '', 0);
ChannelResponse myConnectBTResponse = ChannelResponse('', '', 0);
ChannelResponse myRespBTData = ChannelResponse('', '', 0);
ChannelResponse myRespUpdateFirmware = ChannelResponse('', '', 0);
ChannelResponse myConnectApResponse = ChannelResponse('', '', 0);
ChannelResponse myRespCheckSerialPort = ChannelResponse('', '', 0);
ChannelResponse myRespGetBuildInfo = ChannelResponse('', '', 0);
ChannelResponse myScalePassthData = ChannelResponse('', '', 0);
ChannelResponse myOpenScalePassthData = ChannelResponse('', '', 0);
ChannelResponse myCloseScalePassthData = ChannelResponse('', '', 0);
ChannelResponse myRegWeightResp = ChannelResponse('', '', 0);
ChannelResponse myUnregWeightResp = ChannelResponse('', '', 0);
ChannelResponse myDownPluResp = ChannelResponse('', '', 0);
ChannelResponse myGetWeightErrResp = ChannelResponse('', '', 0);
ChannelResponse myGetScaleTimeResp = ChannelResponse('', '', 0);
ChannelResponse mySetScaleTimeResp = ChannelResponse('', '', 0);
ChannelResponse myRespChangeWifiMode = ChannelResponse('', '', 0);
ChannelResponse myRespGetAllEepromData = ChannelResponse('', '', 0);
ChannelResponse myRespGetOneEepromData = ChannelResponse('', '', 0);
ChannelResponse myRespModifyEepromInfo = ChannelResponse('', '', 0);
ChannelResponse myRespModifyHeaderFooter = ChannelResponse('', '', 0);
ChannelResponse myRespSetServerIp = ChannelResponse('', '', 0);

class SerialPortStatus {
  bool serialPortStatus;

  SerialPortStatus(
    this.serialPortStatus,
  );
}

SerialPortStatus mySerialPortStatus = SerialPortStatus(true);
