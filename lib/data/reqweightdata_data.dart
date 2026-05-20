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
      try {
        msgBody = MsgBody.fromJson(jsonDecode(json['MsgBody']));
      } catch (e) {
        msgBody = null;
      }
    } else {
      msgBody =
          json['MsgBody'] != null ? MsgBody.fromJson(json['MsgBody']) : null;
    }
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
      : isZero = json['IsZero'] ?? false,
        isStable = json['IsStable'] ?? false,
        isNet = json['IsNet'] ?? false,
        weightVal = json['WeightVal']?.toString() ?? '',
        weightUnit = json['WeightUnit']?.toString() ?? '';

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
ReqWeightCountine myWgtCnt1 = ReqWeightCountine();
ReqWeightCountine myWgtCnt2 = ReqWeightCountine();
ReqWeightCountine myWgtCnt3 = ReqWeightCountine();
ReqWeightCountine myWgtCnt4 = ReqWeightCountine();

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
