class FromateItemData {
  String type;
  int xPos;
  int yPos;
  double width;
  double height;
  int fontSize;
  int fontWidthRatio;
  int fontHeightRatio;
  int style;
  int rotation;
  String varName;
  String defaultValue;
  int alignment;
  int maxLength;
  int tabOrder;
  String content;
  List<dynamic> varcontent;
  String barcodeName;
  String barcodeType;
  String hralignment;
  int x2Pos;
  int y2Pos;
  double lineWidth;
  String qrWidth;
  String qrcodeName;
  String qrcodeType;
  String fontBold;
  String fontReverse;
  FromateItemData(
      {required this.type,
      required this.xPos,
      required this.yPos,
      required this.width,
      required this.height,
      required this.fontSize,
      required this.fontWidthRatio,
      required this.fontHeightRatio,
      required this.alignment,
      required this.maxLength,
      required this.rotation,
      required this.style,
      required this.tabOrder,
      required this.varName,
      required this.content,
      required this.defaultValue,
      required this.varcontent,
      required this.barcodeName,
      required this.barcodeType,
      required this.hralignment,
      required this.x2Pos,
      required this.y2Pos,
      required this.lineWidth,
      required this.qrWidth,
      required this.qrcodeName,
      required this.qrcodeType,
      required this.fontBold,
      required this.fontReverse});

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  FromateItemData.fromJson(Map json)
      : type = json['type'],
        xPos = json['xPos'],
        yPos = json['yPos'],
        width = _toDouble(json['width']),
        height = _toDouble(json['height']),
        fontSize = json['fontSize'],
        fontWidthRatio = json['fontWidthRatio'],
        fontHeightRatio = json['fontHeightRatio'],
        alignment = json['alignment'],
        maxLength = json['maxLength'],
        rotation = json['rotation'],
        style = json['style'],
        tabOrder = json['tabOrder'],
        varName = json['varName'],
        content = json['content'],
        defaultValue = json['defaultValue'],
        varcontent = json['varcontent'],
        barcodeName = json['barcodeName'],
        barcodeType = json['barcodeType'],
        hralignment = json['hralignment'],
        x2Pos = json['x2Pos'],
        y2Pos = json['y2Pos'],
        lineWidth = json['lineWidth'],
        qrWidth = json['qrWidth'],
        qrcodeName = json['qrcodeName'],
        qrcodeType = json['qrcodeType'],
        fontBold = json['fontBold'],
        fontReverse = json['fontReverse'];
  Map toJson() => {
        'type': type,
        'xPos': xPos,
        'yPos': yPos,
        'width': width,
        'height': height,
        'fontSize': fontSize,
        'fontWidthRatio': fontWidthRatio,
        'fontHeightRatio': fontHeightRatio,
        'alignment': alignment,
        'maxLength': maxLength,
        'rotation': rotation,
        'style': style,
        'tabOrder': tabOrder,
        'varName': varName,
        'content': content,
        'defaultValue': defaultValue,
        'varcontent': varcontent,
        'barcodeName': barcodeName,
        'barcodeType': barcodeType,
        'hralignment': hralignment,
        'x2Pos': x2Pos,
        'y2Pos': y2Pos,
        'lineWidth': lineWidth,
        'qrWidth': qrWidth,
        'qrcodeName': qrcodeName,
        'qrcodeType': qrcodeType,
        'fontBold': fontBold,
        'fontReverse': fontReverse,
      };
}

class FormatContent {
  String page;
  String rotation;
  String content;
  String? printer;
  String? prtType; //lable page mode
  FormatContent(
      {required this.page,
      required this.rotation,
      required this.content,
      this.printer,
      this.prtType});
  FormatContent.fromJson(Map json)
      : content = json['content'],
        page = json['page'],
        rotation = json['rotation'],
        printer = json['printer'],
        prtType = json['prtType'];

  Map toJson() => {
        'page': page,
        'rotation': rotation,
        'content': content,
        'printer': printer,
        'prtType': prtType,
      };
}

class PageInfo {
  int pWidth;
  int pHeight;
  String rotation;
  List<FmtContent> content;

  PageInfo({
    required this.pWidth,
    required this.pHeight,
    required this.rotation,
    required this.content,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) => PageInfo(
        pWidth: json["pWidth"],
        pHeight: json["pHeight"],
        rotation: json["rotation"],
        content: List<FmtContent>.from(
            json["content"].map((x) => FmtContent.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "pWidth": pWidth,
        "pHeight": pHeight,
        "rotation": rotation,
        "content": List<dynamic>.from(content.map((x) => x.toJson())),
      };
}

class FmtContent {
  String type;
  int tabOrder;
  int? xPos;
  int? yPos;
  double? width;
  double? height;
  int? fontSize;
  int? fontWidthRatio;
  int? fontHeightRatio;
  int? alignment;
  int? maxLength;
  int? rotation;
  String? content;
  String? fontBold;
  String? fontReverse;
  String? varName;
  String? defaultValue;
  double? lineWidth;
  int? style;
  String? barcodeName;
  String? barcodeType;
  String? hralignment;
  List<Varcontent>? varcontent;
  int? grade;
  String? qrWidth;
  String? qrcodeName;
  String? qrcodeType;
  int? x1Pos;
  int? y1Pos;
  int? x2Pos;
  int? y2Pos;

  FmtContent({
    required this.type,
    required this.tabOrder,
    this.xPos,
    this.yPos,
    this.width,
    this.height,
    this.fontSize,
    this.fontWidthRatio,
    this.fontHeightRatio,
    this.alignment,
    this.maxLength,
    this.rotation,
    this.content,
    this.fontBold,
    this.fontReverse,
    this.varName,
    this.defaultValue,
    this.lineWidth,
    this.style,
    this.barcodeName,
    this.barcodeType,
    this.hralignment,
    this.varcontent,
    this.grade,
    this.qrWidth,
    this.qrcodeName,
    this.qrcodeType,
    this.x1Pos,
    this.y1Pos,
    this.x2Pos,
    this.y2Pos,
  });

  factory FmtContent.fromJson(Map<String, dynamic> json) => FmtContent(
        type: json["type"],
        tabOrder: json["tabOrder"],
        xPos: json["xPos"],
        yPos: json["yPos"],
        width: json["width"],
        height: json["height"],
        fontSize: json["fontSize"],
        fontWidthRatio: json["fontWidthRatio"],
        fontHeightRatio: json["fontHeightRatio"],
        alignment: json["alignment"],
        maxLength: json["maxLength"],
        rotation: json["rotation"],
        content: json["content"],
        fontBold: json["fontBold"],
        fontReverse: json["fontReverse"],
        varName: json["varName"],
        defaultValue: json["defaultValue"],
        lineWidth: json["lineWidth"],
        style: json["style"],
        barcodeName: json["barcodeName"],
        barcodeType: json["barcodeType"],
        hralignment: json["hralignment"],
        varcontent: json["varcontent"] == null
            ? []
            : List<Varcontent>.from(
                json["varcontent"]!.map((x) => Varcontent.fromJson(x))),
        grade: json["grade"],
        qrWidth: json["qrWidth"],
        qrcodeName: json["qrcodeName"],
        qrcodeType: json["qrcodeType"],
        x1Pos: json["x1Pos"],
        y1Pos: json["y1Pos"],
        x2Pos: json["x2Pos"],
        y2Pos: json["y2Pos"],
      );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonMap = {
      "type": type,
      "tabOrder": tabOrder,
      "xPos": xPos,
      "yPos": yPos,
      "width": width,
      "height": height,
      "fontSize": fontSize,
      "fontWidthRatio": fontWidthRatio,
      "fontHeightRatio": fontHeightRatio,
      "alignment": alignment,
      "maxLength": maxLength,
      "rotation": rotation,
      "content": content,
      "fontBold": fontBold,
      "fontReverse": fontReverse,
      "varName": varName,
      "defaultValue": defaultValue,
      "lineWidth": lineWidth,
      "style": style,
      "barcodeName": barcodeName,
      "barcodeType": barcodeType,
      "hralignment": hralignment,
      "varcontent": varcontent == null
          ? []
          : List<dynamic>.from(varcontent!.map((x) => x.toJson())),
      "grade": grade,
      "qrWidth": qrWidth,
      "qrcodeName": qrcodeName,
      "qrcodeType": qrcodeType,
      "x1Pos": x1Pos,
      "y1Pos": y1Pos,
      "x2Pos": x2Pos,
      "y2Pos": y2Pos,
    };

    jsonMap.removeWhere((key, value) => (value == null));

    if (type == 'BarCode' || type == 'QrCode') {
      // 如果 type 的值是 'BarCode'，保持 varcontent 不变
      jsonMap['varcontent'] = varcontent == null
          ? []
          : List<dynamic>.from(varcontent!.map((x) => x.toJson()));
    } else {
      // 如果 type 的值不是 'BarCode'，根据 varcontent 是否为空来决定是否保留 varcontent 字段
      if (varcontent is List && varcontent!.isEmpty) {
        jsonMap['varcontent'] = [];
      } else {
        jsonMap.remove('varcontent');
      }
    }

    // jsonMap.removeWhere(
    //     (key, value) => (value == null || (value is List && value.isEmpty)));

    return jsonMap;
  }
}

class Varcontent {
  String type;
  String? content;
  String? defaultvalue;
  String? alignment;
  int? maxlength;

  Varcontent({
    required this.type,
    this.content,
    this.defaultvalue,
    this.alignment,
    this.maxlength,
  });

  factory Varcontent.fromJson(Map<String, dynamic> json) => Varcontent(
        type: json["type"],
        content: json["content"],
        defaultvalue: json["defaultvalue"],
        alignment: json["alignment"],
        maxlength: json["maxlength"],
      );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> jsonMap = {
      "type": type,
      "content": content,
      "defaultvalue": defaultvalue,
      "alignment": alignment,
      "maxlength": maxlength,
    };

    jsonMap.removeWhere((key, value) => (value == null));

    return jsonMap;
  }
}
