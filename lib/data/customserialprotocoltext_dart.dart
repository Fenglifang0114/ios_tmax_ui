class SerialProtocolText {
  String type;
  String varName;
  String isTrue;
  String isFalse;
  String filling;
  int decimal;
  String default5;
  String alignment;
  int maxLength;
  int tabOrder;
  String content;
  bool isSelect;

  SerialProtocolText(
    this.type,
    this.content,
    this.varName,
    this.alignment,
    this.maxLength,
    this.tabOrder,
    this.isTrue,
    this.isFalse,
    this.filling,
    this.decimal,
    this.default5,
    this.isSelect,
  );
  SerialProtocolText.fromJson(Map<String, dynamic> json)
      : type = json['Type'],
        alignment = json['Alignment'],
        content = json['Content'],
        isTrue = json['isTrue'],
        isFalse = json['isFalse'],
        filling = json['Default3'],
        decimal = json['decimal'],
        default5 = json['Default5'],
        maxLength = json['MaxLength'],
        tabOrder = json['TabOrder'],
        varName = json['VarName'],
        isSelect = json['IsSelect'];

  Map<String, dynamic> toJson() {
    return {
      'VarName': varName,
      'TabOrder': tabOrder,
      'MaxLength': maxLength,
      'isTrue': isTrue,
      'isFalse': isFalse,
      'Default3': filling,
      'Default4': decimal,
      'Default5': default5,
      'Content': content,
      'Alignment': alignment,
      'Type': type,
      'IsSelect': isSelect,
    };
  }
}

SerialProtocolText mySerialProtocolText =
    SerialProtocolText('TEXT', '', '', '', 7, 0, '', '', '', 0, '', false);
