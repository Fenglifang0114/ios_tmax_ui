class ReceiptItemData {
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

  ReceiptItemData(
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
  ReceiptItemData.fromJson(Map<String, dynamic> json)
      : type = json['type'] ?? json['Type'] ?? 'TEXT',
        alignment = (json['alignment'] ?? json['Alignment']) as int? ?? 1,
        content = json['content'] ?? json['Content'] ?? '',
        defaultValue = json['defaultValue'] ?? json['DefaultValue'] ?? '',
        fontHeightRatio = (json['fontHeightRatio'] ?? json['FontHeightRatio']) as int? ?? 1,
        fontSize = (json['fontSize'] ?? json['FontSize']) as int? ?? 24,
        fontWidthRatio = (json['fontWidthRatio'] ?? json['FontWidthRatio']) as int? ?? 1,
        height = (json['height'] ?? json['Height']) as int? ?? 26,
        maxLength = (json['maxLength'] ?? json['MaxLength']) as int? ?? 10,
        rotation = (json['rotation'] ?? json['Rotation']) as int? ?? 0,
        style = (json['style'] ?? json['Style']) as int? ?? 0,
        tabOrder = (json['tabOrder'] ?? json['TabOrder']) as int? ?? 0,
        varName = json['varName'] ?? json['VarName'] ?? '',
        width = (json['width'] ?? json['Width']) as int? ?? 50,
        xPos = (json['xPos'] ?? json['XPos'] as num?)?.toInt() ?? 0,
        yPos = (json['yPos'] ?? json['YPos'] as num?)?.toInt() ?? 0,
        barcodeName = json['barcodeName'] ?? json['BarcodeName'] ?? '',
        barcodeType = json['barcodeType'] ?? json['BarcodeType'] ?? '',
        hralignment = json['hralignment'] ?? json['Hralignment'] ?? '',
        varcontent = json['varcontent'] ?? json['Varcontent'] ?? [],
        x2Pos = (json['x2Pos'] ?? json['X2Pos'] as num?)?.toInt() ?? 0,
        y2Pos = (json['y2Pos'] ?? json['Y2Pos'] as num?)?.toInt() ?? 0,
        lineWidth = (json['lineWidth'] ?? json['LineWidth'] as num?)?.toDouble() ?? 1.0,
        qrWidth = (json['qrWidth'] ?? json['QrWidth'])?.toString() ?? '3',
        qrcodeName = json['qrcodeName'] ?? json['QrcodeName'] ?? '',
        qrcodeType = json['qrcodeType'] ?? json['QrcodeType'] ?? '',
        fontBold = (json['fontBold'] ?? json['FontBold'])?.toString() ?? 'false',
        fontReverse = (json['fontReverse'] ?? json['FontReverse'])?.toString() ?? 'false';

  Map<String, dynamic> toJson() {
    return {
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
}

ReceiptItemData myReceiptItemData = ReceiptItemData(
    'TEXT',
    0,
    0,
    50,
    26,
    24,
    1,
    1,
    1,
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
    100,
    0,
    2,
    '3',
    '--',
    'Qrcode',
    'false',
    'false');
