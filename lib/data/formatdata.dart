class FromateItemData {
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

  FromateItemData({
    required this.type,
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
    required this.fontReverse,
  });
  FromateItemData.fromJson(Map json)
      : type = json['type'],
        xPos = json['xPos'],
        yPos = json['yPos'],
        width = json['width'],
        height = json['height'],
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
