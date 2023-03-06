class WeightData {
  bool? isStable;
  bool? isNet;
  String? weightVal;
  String? weightUnit;

  WeightData({this.isStable, this.isNet, this.weightVal, this.weightUnit});

  WeightData.fromJson(Map<String, dynamic> json) {
    isStable = json['IsStable'];
    isNet = json['IsNet'];
    weightVal = json['WeightVal'];
    weightUnit = json['WeightUnit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IsStable'] = this.isStable;
    data['IsNet'] = this.isNet;
    data['WeightVal'] = this.weightVal;
    data['WeightUnit'] = this.weightUnit;
    return data;
  }
}

class WtData {
  String weight;
  String unit;
  String stable;
  String net;

  String tare;
  WtData(this.weight, this.unit, this.stable, this.net, this.tare);
  WtData.fromJson(Map<String, dynamic> json)
      : weight = json['weight'],
        unit = json['unit'],
        stable = json['stable'],
        net = json['net'],
        tare = json['tare'];

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'unit': unit,
      'stable': stable,
      'net': net,
      'tare': tare,
    };
  }
}

WtData myWtData = WtData("0.000", "kg", "stable", "net", "0.000");
