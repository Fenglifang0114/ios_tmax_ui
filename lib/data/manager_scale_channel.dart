import '../common/web_socket_mgr.dart';
import 'comscaleinfo_data.dart';

final manager = WebSocketScaleManager();
List<int> webChannelList = [];
String ipAddress = "127.0.0.1";
int webPort = 7878;

class GetUrl {
  static String getUrl(int scaleId) {
    String url = "ws://$ipAddress:$webPort/tmax?scaleid=$scaleId";

    return url;
  }
}

class DefScaleInfo {
  int? defScaleId;
  String? defScaleModel;
  String? defScaleSn;
  String? defScaleName;
  String? defScalePort;
  String? defScaleIp;
  String? defScaleBaud;

  DefScaleInfo(this.defScaleId);

  static void getDefScaleInfo(int scaleId) {
    if (scaleId == 1) {
      myDefScaleInfo.defScaleId = scaleId;
      myDefScaleInfo.defScaleModel = myComScaleInfo.scaleModel;
      myDefScaleInfo.defScaleSn = myComScaleInfo.scaleSn;
      myDefScaleInfo.defScalePort = myComScaleInfo.portName;
      myDefScaleInfo.defScaleBaud = myComScaleInfo.baudRate.toString();
      myDefScaleInfo.defScaleName = myComScaleInfo.scaleName;
      if (myDefScaleInfo.defScaleModel == "TMax") {
        myDefScaleInfo.defScaleModel = "";
        myDefScaleInfo.defScaleSn = "";
      }
    } else {
      myDefScaleInfo.defScaleId = scaleId;
      var tempscale = NetScaleListMgr.findScaleInfo(myNetScaleList, scaleId);
      myDefScaleInfo.defScaleModel = tempscale.scaleModel!;
      myDefScaleInfo.defScaleSn = tempscale.scaleSn!;
      myDefScaleInfo.defScalePort = tempscale.port!.toString();
      myDefScaleInfo.defScaleIp = tempscale.ip;
      myDefScaleInfo.defScaleName = tempscale.scaleName;
      if (myDefScaleInfo.defScaleModel == "TMax") {
        myDefScaleInfo.defScaleModel = "";
        myDefScaleInfo.defScaleSn = "";
      }
    }
  }
}

DefScaleInfo myDefScaleInfo = DefScaleInfo(1);
