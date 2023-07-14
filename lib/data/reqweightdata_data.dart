class ReqWeightCountine {
  int? scaleId;
  String? msgType;
  MsgBody? msgBody;

  ReqWeightCountine({this.scaleId, this.msgType, this.msgBody});

  ReqWeightCountine.fromJson(Map<String, dynamic> json) {
    scaleId = json['ScaleId'];
    msgType = json['MsgType'];
    msgBody =
        json['MsgBody'] != null ? MsgBody.fromJson(json['MsgBody']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScaleId'] = scaleId;
    data['MsgType'] = msgType;
    if (msgBody != null) {
      data['MsgBody'] = msgBody!.toJson();
    }
    return data;
  }
}

class MsgBody {
  bool isStable;
  bool isNet;
  String weightVal;
  String weightUnit;

  MsgBody(this.isStable, this.isNet, this.weightVal, this.weightUnit);
  MsgBody.fromJson(Map<String, dynamic> json)
      : isStable = json['IsStable'],
        isNet = json['IsNet'],
        weightVal = json['WeightVal'],
        weightUnit = json['WeightUnit'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['IsStable'] = isStable;
    data['IsNet'] = isNet;
    data['WeightVal'] = weightVal;
    data['WeightUnit'] = weightUnit;
    return data;
  }
}

ReqWeightCountine myReqWeightCountine = ReqWeightCountine();
