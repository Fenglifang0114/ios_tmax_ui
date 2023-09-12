class ModifyScale {
  int? scaleId;
  String? scaleModel;
  MediaConf? mediaConf;

  ModifyScale({this.scaleId, this.scaleModel, this.mediaConf});

  ModifyScale.fromJson(Map<String, dynamic> json) {
    scaleId = json['ScaleId'];
    scaleModel = json['ScaleModel'];
    mediaConf = json['MediaConf'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScaleId'] = scaleId;
    data['ScaleModel'] = scaleModel;
    data['MediaConf'] = mediaConf;
    return data;
  }
}

ModifyScale myModifyScale = ModifyScale(scaleModel: 'TMax');

class MediaConf {
  int? type;
  String? mediaInfoJson;

  MediaConf({this.type, this.mediaInfoJson});

  MediaConf.fromJson(Map<String, dynamic> json) {
    type = json['Type'];
    mediaInfoJson = json['MediaInfoJson'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Type'] = type;
    data['MediaInfoJson'] = mediaInfoJson;
    return data;
  }
}

MediaConf myMediaConf = MediaConf();
