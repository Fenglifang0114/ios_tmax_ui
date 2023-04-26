class SerialProtocolText {
  String type;
  String varName;
  String default1;
  String default2;
  String default3;
  String default4;
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
    this.default1,
    this.default2,
    this.default3,
    this.default4,
    this.default5,
    this.isSelect,
  );
  SerialProtocolText.fromJson(Map<String, dynamic> json)
      : type = json['Type'],
        alignment = json['Alignment'],
        content = json['Content'],
        default1 = json['Default1'],
        default2 = json['Default2'],
        default3 = json['Default3'],
        default4 = json['Default4'],
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
      'Default1': default1,
      'Default2': default2,
      'Default3': default3,
      'Default4': default4,
      'Default5': default5,
      'Content': content,
      'Alignment': alignment,
      'Type': type,
      'IsSelect': isSelect,
    };
  }
}

SerialProtocolText mySerialProtocolText =
    SerialProtocolText('TEXT', '', '', '', 7, 0, '', '', '', '', '', false);
