class ModifyScale {
  int? scaleId;
  MediaConf? mediaConf;

  ModifyScale({this.scaleId, this.mediaConf});

  ModifyScale.fromJson(Map<String, dynamic> json) {
    scaleId = json['ScaleId'];
    mediaConf = json['MediaConf'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ScaleId'] = this.scaleId;
    data['MediaConf'] = this.mediaConf;
    return data;
  }
}

ModifyScale myModifyScale = ModifyScale();

class MediaConf {
  int? type;
  String? mediaInfoJson;

  MediaConf({this.type, this.mediaInfoJson});

  MediaConf.fromJson(Map<String, dynamic> json) {
    type = json['Type'];
    mediaInfoJson = json['MediaInfoJson'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Type'] = this.type;
    data['MediaInfoJson'] = this.mediaInfoJson;
    return data;
  }
}

MediaConf myMediaConf = MediaConf();
