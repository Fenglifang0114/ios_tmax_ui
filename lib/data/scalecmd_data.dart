class ScaleCmd {
  String? cmdMode;
  String? cmdData;

  ScaleCmd(this.cmdMode, this.cmdData);

  ScaleCmd.fromJson(Map<String, dynamic> json) {
    cmdMode = json['Req'];
    cmdData = json['ReqData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Req'] = cmdMode;
    data['ReqData'] = cmdData;
    return data;
  }
}

ScaleCmd myScaleCmd = ScaleCmd("", "");
