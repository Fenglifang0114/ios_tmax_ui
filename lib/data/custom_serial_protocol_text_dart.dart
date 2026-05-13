import 'dart:convert';

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

OutPutList outPutListFromJson(String str) =>
    OutPutList.fromJson(json.decode(str));

String outPutListToJson(OutPutList data) => json.encode(data.toJson());

class OutPutList {
  List<FunctionData> function;
  List<Datum> data;

  OutPutList({
    required this.function,
    required this.data,
  });

  factory OutPutList.fromJson(Map<String, dynamic> json) => OutPutList(
        function: List<FunctionData>.from(
            json["function"].map((x) => FunctionData.fromJson(x))),
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "function": List<dynamic>.from(function.map((x) => x.toJson())),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Datum {
  bool isvar;
  bool? ishex;
  String? value;
  String? varname;
  int? functionid;
  int? length;

  Datum({
    required this.isvar,
    this.ishex,
    this.value,
    this.varname,
    this.functionid,
    this.length,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        isvar: json["isvar"],
        ishex: json["ishex"],
        value: json["value"],
        varname: json["varname"],
        functionid: json["functionid"],
        length: json["length"],
      );

  Map<String, dynamic> toJson() => {
        "isvar": isvar,
        "ishex": ishex,
        "value": value,
        "varname": varname,
        "functionid": functionid,
        "length": length,
      };
}

class FunctionData {
  int id;
  String type;
  int? decimal;
  String? alignment;
  String? filling;
  String description;
  String? istrue;
  String? isfalse;

  FunctionData({
    required this.id,
    required this.type,
    this.decimal,
    this.alignment,
    this.filling,
    required this.description,
    this.istrue,
    this.isfalse,
  });

  factory FunctionData.fromJson(Map<String, dynamic> json) => FunctionData(
        id: json["id"],
        type: json["type"],
        decimal: json["decimal"],
        alignment: json["alignment"],
        filling: json["filling"],
        description: json["description"],
        istrue: json["istrue"],
        isfalse: json["isfalse"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "decimal": decimal,
        "alignment": alignment,
        "filling": filling,
        "description": description,
        "istrue": istrue,
        "isfalse": isfalse,
      };
}
