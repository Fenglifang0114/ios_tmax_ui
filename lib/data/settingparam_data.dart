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
  int wgtMode;

  SettingParam(
      this.id,
      this.recMode,
      this.zeroRange,
      this.stableTime,
      this.dateFormat,
      this.dateSeparator,
      this.scaleMode,
      this.scaleSn,
      this.saveMode,
      this.wgtMode);
  SettingParam.fromJson(Map<String, dynamic> json)
      : id = json['Id'] ?? 0,
        recMode = json['RecMode']?.toString() ?? "0",
        zeroRange = json['ZeroRange']?.toString() ?? "1",
        stableTime = json['StableTime']?.toString() ?? "1",
        dateFormat = json['DateFormat']?.toString() ?? "0",
        dateSeparator = json['DateSeparator']?.toString() ?? "0",
        scaleMode = json['ScaleMode'] ?? 0,
        scaleSn = json['ScaleSn']?.toString() ?? "",
        saveMode = json['SaveMode']?.toString() ?? "",
        wgtMode = json['WgtMode'] ?? 0;

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
      'WgtMode': wgtMode,
    };
  }
}

SettingParam mySettingParam =
    SettingParam(0, "0", "1", "1", "0", "0", 0, "", "", 0);

final String wgtCollectionMode = '0';
final String wgtCheckMode = '1';
final String wgtTakeInMode = '2';
final String wgtTakeOutMode = '3';
