import '../common/web_socket_mgr.dart';

final manager = WebSocketScaleManager();
int defaultScaleId = 1;
String defaultScaleModel = "TMax";
String defaultScaleSn = "Sn";
String defscaleMedia = "";
String defScaleInfo = "";
List<int> webChannelList = [];
String ipAddress = "127.0.0.1";
int webPort = 7878;

class GetUrl {
  static String getUrl(int scaleId) {
    String url = "ws://" +
        ipAddress +
        ":" +
        webPort.toString() +
        "/tmax?scaleid=" +
        scaleId.toString();

    return url;
  }
}
