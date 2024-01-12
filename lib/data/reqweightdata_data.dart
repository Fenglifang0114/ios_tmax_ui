import 'dart:convert';

class ReqWeightCountine {
  int? scaleId;
  String? msgType;
  MsgBody? msgBody;

  ReqWeightCountine({this.scaleId, this.msgType, this.msgBody});

  ReqWeightCountine.fromJson(Map<String, dynamic> json) {
    scaleId = json['ScaleId'];
    msgType = json['MsgType'];
    if (json['MsgBody'] is String) {
      msgBody = MsgBody.fromJson(jsonDecode(json['MsgBody']));
    } else {
      msgBody =
          json['MsgBody'] != null ? MsgBody.fromJson(json['MsgBody']) : null;
    }
    // msgBody =
    //     json['MsgBody'] != null ? MsgBody.fromJson(json['MsgBody']) : null;
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
  bool isZero;
  bool isStable;
  bool isNet;
  String weightVal;
  String weightUnit;

  MsgBody(
      this.isZero, this.isStable, this.isNet, this.weightVal, this.weightUnit);
  MsgBody.fromJson(Map<String, dynamic> json)
      : isZero = json['IsZero'],
        isStable = json['IsStable'],
        isNet = json['IsNet'],
        weightVal = json['WeightVal'],
        weightUnit = json['WeightUnit'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['IsZero'] = isZero;
    data['IsStable'] = isStable;
    data['IsNet'] = isNet;
    data['WeightVal'] = weightVal;
    data['WeightUnit'] = weightUnit;
    return data;
  }
}

ReqWeightCountine myReqWeightCountine = ReqWeightCountine();

// class ReqWeightCountine {
//   bool isZero;
//   bool isStable;
//   bool isNet;
//   String weightVal;
//   String weightUnit;

//   ReqWeightCountine(
//       this.isZero, this.isStable, this.isNet, this.weightVal, this.weightUnit);
//   ReqWeightCountine.fromJson(Map<String, dynamic> json)
//       : isZero = json['IsZero'],
//         isStable = json['IsStable'],
//         isNet = json['IsNet'],
//         weightVal = json['WeightVal'],
//         weightUnit = json['WeightUnit'];

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['IsZero'] = isZero;
//     data['IsStable'] = isStable;
//     data['IsNet'] = isNet;
//     data['WeightVal'] = weightVal;
//     data['WeightUnit'] = weightUnit;
//     return data;
//   }
// }

// ReqWeightCountine myReqWeightCountine = ReqWeightCountine();
