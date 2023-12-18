import '../data/reqweightdata_data.dart';

class PubWeightFuncs {
  static bool weightIsZero() {
    bool res = false;
    if (myReqWeightCountine.msgBody == null) {
      res = false;
    } else if (myReqWeightCountine.msgBody!.isZero) {
      res = true;
    }
    return res;
  }
}
