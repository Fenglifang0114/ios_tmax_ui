class SettingParam {
  String recMode;
  String zeroRange;
  String stableTimeToRec;
  String dateFormat;
  SettingParam(
      this.recMode, this.zeroRange, this.stableTimeToRec, this.dateFormat);
  SettingParam.fromJson(Map<String, dynamic> json)
      : recMode = json['RecMode'],
        zeroRange = json['ZeroRange'],
        stableTimeToRec = json['StableTimeToRec'],
        dateFormat = json['DateFormat'];

  Map<String, dynamic> toJson() {
    return {
      'RecMode': recMode,
      'ZeroRange': zeroRange,
      'StableTimeToRec': stableTimeToRec,
      'DateFormat': dateFormat,
    };
  }
}

SettingParam mySettingParam = SettingParam("", "", "", "");
