// /*
// RespData 是服务器反馈给客户端的数据
// */

// // CMD_TARE                 TCmd = iota // without parameters
// // 	CMD_ZERO                             // without parameters
// // 	CMD_READ_WEIGHT                      // response will be a json string of WtContPerc struct
// // 	CMD_SEND_WEIGHT_CONTINUE             // without parameters
// // 	CMD_STOP_SEND_WEIGHT                 // without parameters
// // 	CMD_READ_CONFIG                      // response will be a json string of ScaleConfig struct
// // 	CMD_REBOOT                           // without parameters
// // 	CMD_INSERT                           // parameter will be a json string of Rec struct
// // 	CMD_DELETE                           // parameter will be scale's id string
// // 	CMD_GET_LIST                         // response will be a json string of RecList struct
// // 	CMD_CHANGE_SCALE_CONN                // parameter will be a json string of ScaleConn struct
// // 	CMD_GET_COM_PORT_LIST                // response will be a json string of ComList struct

const int cmdTare = 1;
const int cmdZero = 2;
const int cmdReadWeight = 3;
const int cmdSendWeightContinu = 4;
const int cmdStopSendWeight = 5;
const int cmdReadConfig = 6;
const int cmdReboot = 7;
const int cmdInsert = 8;
const int cmdDelete = 9;
const int cmdGetList = 10;
const int cmdChangeScaleConn = 11;
const int cmdGetComPortList = 12;

class RespData {
  int? respCmd;
  Object? respJsonData;

  RespData(this.respCmd, this.respJsonData);

  RespData.fromJson(Map<String, dynamic> json) {
    respCmd = json['respCmd'];
    respJsonData = json['respJsonData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['respCmd'] = respCmd;
    data['respJsonData'] = respJsonData;
    return data;
  }
}

RespData myRespData = RespData(0, {});

// var hostData = Data.fromJson(json.decode("json字符串"));
// if (hostData.code == 0) {
//   var data = hostData.data as user;
// }else{
//   var data = hostData.data as String;
// }

class MessageError {
  String? messagedata;

  MessageError(this.messagedata);

  MessageError.fromJson(Map<String, dynamic> json) {
    messagedata = json['MsgBody'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['MsgBody'] = messagedata;

    return data;
  }
}

MessageError myMessageError = MessageError('');
MessageError myGetIpError = MessageError('');
MessageError myGetApInfoError = MessageError('');

MessageError myRespGetIpMode = MessageError('');
MessageError myGetWifiListError = MessageError('');
