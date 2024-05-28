class DownLoadPrtFmt {
  String? scaleModel;
  String? printerModel;
  List<String>? filePaths;

  DownLoadPrtFmt({this.scaleModel, this.printerModel, this.filePaths});

  DownLoadPrtFmt.fromJson(Map<String, dynamic> json) {
    scaleModel = json['ScaleModel'];
    printerModel = json['PrinterModel'];
    filePaths = json['FilePaths'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScaleModel'] = scaleModel;
    data['PrinterModel'] = printerModel;
    data['FilePaths'] = filePaths;
    return data;
  }
}

DownLoadPrtFmt myDownLoadPrtFmt = DownLoadPrtFmt();

class DownLoadSetOutputFmt {
  List<String>? filePath;

  DownLoadSetOutputFmt({this.filePath});

  DownLoadSetOutputFmt.fromJson(Map<String, dynamic> json) {
    filePath = json['FilePath'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['FilePath'] = filePath;
    return data;
  }
}

DownLoadSetOutputFmt myDownLoadSetOutputFmt = DownLoadSetOutputFmt();

class DownLoadPluFile {
  String? scaleModel;
  String? filePath;
  int? nameMaxLen;

  DownLoadPluFile({this.scaleModel, this.filePath, this.nameMaxLen});

  DownLoadPluFile.fromJson(Map<String, dynamic> json) {
    scaleModel = json['ScaleModel'];
    filePath = json['FilePath'].cast<String>();
    nameMaxLen = json['NameMaxLen'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScaleModel'] = scaleModel;
    data['FilePath'] = filePath;
    data['NameMaxLen'] = nameMaxLen;

    return data;
  }
}

DownLoadPluFile myDownLoadPluFile = DownLoadPluFile();

class DelPlu {
  String? scaleModel;
  List<String>? pluId;

  DelPlu({this.scaleModel, this.pluId});

  DelPlu.fromJson(Map<String, dynamic> json) {
    scaleModel = json['ScaleModel'];
    pluId = json['PluId'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScaleModel'] = scaleModel;
    data['PluId'] = pluId;
    return data;
  }
}

DelPlu myDelPlu = DelPlu();

class DefaultPrtFmt {
  String? scaleModel;
  String? printerModel;
  String? filePath;

  DefaultPrtFmt({this.scaleModel, this.printerModel, this.filePath});

  DefaultPrtFmt.fromJson(Map<String, dynamic> json) {
    scaleModel = json['ScaleModel'];
    printerModel = json['PrinterModel'];
    filePath = json['FilePath'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScaleModel'] = scaleModel;
    data['PrinterModel'] = printerModel;
    data['FilePath'] = filePath;
    return data;
  }
}

DefaultPrtFmt myDefaultPrtFmt = DefaultPrtFmt();
