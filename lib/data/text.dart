class TextData {
  String type;
  int xPos;
  int yPos;
  int width;
  int height;
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

  TextData(
      this.type,
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
      this.style,
      this.tabOrder,
      this.varName,
      this.content,
      this.defaultValue,
      this.varcontent,
      this.barcodeName,
      this.barcodeType,
      this.hralignment,
      this.x2Pos,
      this.y2Pos,
      this.lineWidth,
      this.qrWidth,
      this.qrcodeName,
      this.qrcodeType,
      this.fontBold,
      this.fontReverse);
  TextData.fromJson(Map<String, dynamic> json)
      : type = json['Type'],
        alignment = json['Alignment'],
        content = json['Content'],
        defaultValue = json['DefaultValue'],
        fontHeightRatio = json['FontHeightRatio'],
        fontSize = json['FontSize'],
        fontWidthRatio = json['FontWidthRatio'],
        height = json['Height'],
        maxLength = json['MaxLength'],
        rotation = json['Rotation'],
        style = json['Style'],
        tabOrder = json['TabOrder'],
        varName = json['VarName'],
        width = json['Width'],
        xPos = json['XPos'],
        yPos = json['YPos'],
        barcodeName = json['barcodeName'],
        barcodeType = json['barcodeType'],
        hralignment = json['Hralignment'],
        varcontent = json['Varcontent'],
        x2Pos = json['X2Pos'],
        y2Pos = json['Y2Pos'],
        lineWidth = json['LineWidth'],
        qrWidth = json['QrWidth'],
        qrcodeName = json['qrcodeName'],
        qrcodeType = json['qrcodeType'],
        fontBold = json['fontBold'],
        fontReverse = json['fontReverse'];

  Map<String, dynamic> toJson() {
    return {
      'XPos': xPos,
      'YPos': yPos,
      'Width': width,
      'VarName': varName,
      'TabOrder': tabOrder,
      'Style': style,
      'Rotation': rotation,
      'MaxLength': maxLength,
      'Height': height,
      'FontWidthRatio': fontWidthRatio,
      'FontSize': fontSize,
      'FontHeightRatio': fontHeightRatio,
      'DefaultValue': defaultValue,
      'Content': content,
      'Alignment': alignment,
      'Type': type,
      'Varcontent': varcontent,
      'Hralignment': hralignment,
      'QrWidth': qrWidth,
      'QrcodeType': qrcodeType,
      'FontBold': fontBold,
      'FontReverse': fontReverse,
    };
  }
}

TextData myTextData = TextData(
    'TEXT',
    0,
    0,
    50,
    30,
    23,
    1,
    1,
    0,
    20,
    0,
    0,
    1,
    '',
    '',
    '',
    [],
    '--',
    '',
    '',
    0,
    100,
    2,
    '3',
    '--',
    'Qrcode',
    'false',
    'false');

// class TextDateList {
//   List<TextData>? textData;

//   TextDateList({this.textData});

//   TextDateList.fromJson(Map<String, dynamic> json) {
//     if (json['textData'] != null) {
//       textData = <TextData>[];
//       json['textData'].forEach((v) {
//         textData!.add(TextData.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (textData != null) {
//       data['textData'] = textData!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// TextDateList myTextDateList = TextDateList(textData: []);
