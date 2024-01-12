class OlUlErrInfo {
  int olCnt;
  int olTime;
  int ulCnt;
  int ulTime;
  OlUlErrInfo(this.olCnt, this.olTime, this.ulCnt, this.ulTime);
  OlUlErrInfo.fromJson(Map<String, dynamic> json)
      : olCnt = json['OlCnt'],
        olTime = json['OlTime'],
        ulCnt = json['UlCnt'],
        ulTime = json['UlTime'];
  Map<String, dynamic> toJson() {
    return {
      'OlCnt': olCnt,
      'OlTime': olTime,
      'UlCnt': ulCnt,
      'UlTime': ulTime,
    };
  }
}

OlUlErrInfo myOlUlErrInfo = OlUlErrInfo(0, 0, 0, 0);
