class ReqWeightCountine {
  int? scaleId;
  int? msgType;
  MsgBody? msgBody;

  ReqWeightCountine({this.scaleId, this.msgType, this.msgBody});

  ReqWeightCountine.fromJson(Map<String, dynamic> json) {
    scaleId = json['ScaleId'];
    msgType = json['MsgType'];
    msgBody =
        json['MsgBody'] != null ? new MsgBody.fromJson(json['MsgBody']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ScaleId'] = this.scaleId;
    data['MsgType'] = this.msgType;
    if (this.msgBody != null) {
      data['MsgBody'] = this.msgBody!.toJson();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IsStable'] = this.isStable;
    data['IsNet'] = this.isNet;
    data['WeightVal'] = this.weightVal;
    data['WeightUnit'] = this.weightUnit;
    return data;
  }
}

ReqWeightCountine myReqWeightCountine = ReqWeightCountine();
