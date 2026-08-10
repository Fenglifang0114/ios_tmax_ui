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
      : type = json['Type'] ?? 'TEXT',
        alignment = json['Alignment'] ?? 1,
        content = json['Content'] ?? '',
        defaultValue = json['DefaultValue'] ?? '',
        fontHeightRatio = json['FontHeightRatio'] ?? 1,
        fontSize = json['FontSize'] ?? 24,
        fontWidthRatio = json['FontWidthRatio'] ?? 1,
        height = json['Height'] ?? 26,
        maxLength = json['MaxLength'] ?? 10,
        rotation = json['Rotation'] ?? 0,
        style = json['Style'] ?? 0,
        tabOrder = json['TabOrder'] ?? 0,
        varName = json['VarName'] ?? '',
        width = json['Width'] ?? 50,
        xPos = (json['XPos'] as num?)?.toInt() ?? 0,
        yPos = (json['YPos'] as num?)?.toInt() ?? 0,
        barcodeName = json['barcodeName'] ?? '',
        barcodeType = json['barcodeType'] ?? '',
        hralignment = json['Hralignment'] ?? '',
        varcontent = json['Varcontent'] ?? [],
        x2Pos = (json['X2Pos'] as num?)?.toInt() ?? 0,
        y2Pos = (json['Y2Pos'] as num?)?.toInt() ?? 0,
        lineWidth = (json['LineWidth'] as num?)?.toDouble() ?? 1.0,
        qrWidth = json['QrWidth']?.toString() ?? '3',
        qrcodeName = json['qrcodeName'] ?? '',
        qrcodeType = json['qrcodeType'] ?? '',
        fontBold = json['fontBold']?.toString() ?? 'false',
        fontReverse = json['fontReverse']?.toString() ?? 'false';

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
