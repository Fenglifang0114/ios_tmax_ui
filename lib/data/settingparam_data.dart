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
      : id = json['Id'] is int
            ? json['Id']
            : (int.tryParse(json['Id']?.toString() ?? json['id']?.toString() ?? '0') ?? 0),
        recMode = (json['RecMode'] ?? json['recMode'] ?? json['rec_mode'] ?? "manual").toString(),
        zeroRange = (json['ZeroRange'] ?? json['zeroRange'] ?? "1").toString(),
        stableTime = (json['StableTime'] ?? json['StableTimeToRec'] ?? json['stableTime'] ?? "1").toString(),
        dateFormat = (json['DateFormat'] ?? json['dateFormat'] ?? "0").toString(),
        dateSeparator = (json['DateSeparator'] ?? json['dateSeparator'] ?? "0").toString(),
        scaleMode = json['ScaleMode'] is int
            ? json['ScaleMode']
            : (int.tryParse(json['ScaleMode']?.toString() ?? json['scaleMode']?.toString() ?? '0') ?? 0),
        scaleSn = (json['ScaleSn'] ?? json['scaleSn'] ?? "").toString(),
        saveMode = (json['SaveMode'] ?? json['saveMode'] ?? "").toString(),
        wgtMode = json['WgtMode'] is int
            ? json['WgtMode']
            : (int.tryParse(json['WgtMode']?.toString() ?? json['wgtMode']?.toString() ?? json['wgt_mode']?.toString() ?? '0') ?? 0);

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
