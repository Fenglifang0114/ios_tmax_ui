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

  DownLoadPluFile({this.scaleModel, this.filePath});

  DownLoadPluFile.fromJson(Map<String, dynamic> json) {
    scaleModel = json['ScaleModel'];
    filePath = json['FilePath'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScaleModel'] = scaleModel;
    data['FilePath'] = filePath;
    return data;
  }
}

DownLoadPluFile myDownLoadPluFile = DownLoadPluFile();
