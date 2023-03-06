class DialogData {
  String type;
  String msg;
  DialogData(this.type, this.msg);
  DialogData.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        msg = json['msg'];

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'msg': msg,
    };
  }
}

DialogData myDialogData = DialogData("", "zh");
