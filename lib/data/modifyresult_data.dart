class ModifyAck {
  bool? isAck;
  String? ackData;

  ModifyAck({this.isAck, this.ackData});

  factory ModifyAck.fromJson(Map<String, dynamic> json) {
    return ModifyAck(
      isAck: json['IsAck'],
      ackData: json['AckData'],
    );
  }
}

ModifyAck myModifyAck = ModifyAck();
