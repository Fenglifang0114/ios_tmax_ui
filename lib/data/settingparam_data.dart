class SettingParam {
  String recMode;
  String zeroRange;
  String stableTimeToRec;
  String dateFormat;
  String dateSeparator;
  String scaleMode;

  SettingParam(this.recMode, this.zeroRange, this.stableTimeToRec,
      this.dateFormat, this.dateSeparator, this.scaleMode);
  SettingParam.fromJson(Map<String, dynamic> json)
      : recMode = json['RecMode'],
        zeroRange = json['ZeroRange'],
        stableTimeToRec = json['StableTimeToRec'],
        dateFormat = json['DateFormat'],
        dateSeparator = json['DateSeparator'],
        scaleMode = json['ScaleMode'];

  Map<String, dynamic> toJson() {
    return {
      'RecMode': recMode,
      'ZeroRange': zeroRange,
      'StableTimeToRec': stableTimeToRec,
      'DateFormat': dateFormat,
      'DateSeparator': dateSeparator,
      'ScaleMode': scaleMode,
    };
  }
}

SettingParam mySettingParam = SettingParam("", "", "", "", "", "");
