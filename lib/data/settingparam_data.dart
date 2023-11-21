class SettingParam {
  int id;
  String recMode;
  String zeroRange;
  String stableTime;
  String dateFormat;
  String dateSeparator;
  int scaleMode;
  String scaleSn;
  String saveMode;

  SettingParam(
      this.id,
      this.recMode,
      this.zeroRange,
      this.stableTime,
      this.dateFormat,
      this.dateSeparator,
      this.scaleMode,
      this.scaleSn,
      this.saveMode);
  SettingParam.fromJson(Map<String, dynamic> json)
      : id = json['Id'],
        recMode = json['RecMode'],
        zeroRange = json['ZeroRange'],
        stableTime = json['StableTime'],
        dateFormat = json['DateFormat'],
        dateSeparator = json['DateSeparator'],
        scaleMode = json['ScaleMode'],
        scaleSn = json['ScaleSn'],
        saveMode = json['SaveMode'];

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'RecMode': recMode,
      'ZeroRange': zeroRange,
      'StableTime': stableTime,
      'DateFormat': dateFormat,
      'DateSeparator': dateSeparator,
      'ScaleMode': scaleMode,
      'ScaleSn': scaleSn,
      'SaveMode': saveMode,
    };
  }
}

SettingParam mySettingParam = SettingParam(0, "", "", "", "", "", 0, "", "");
SettingParam myModeSettingNormal =
    SettingParam(0, "", "", "", "", "", 0, "", "");
SettingParam myModeSettingCheck =
    SettingParam(0, "", "", "", "", "", 0, "", "");
SettingParam myModeSettingTakeIn =
    SettingParam(0, "", "", "", "", "", 0, "", "");
SettingParam myModeSettingTakeOut =
    SettingParam(0, "", "", "", "", "", 0, "", "");
