import 'package:flutter/foundation.dart';

class Product {
  final int? id;
  final String? name;
  final List<Com>? coms;

  Product({this.id, this.name, this.coms});
  factory Product.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['coms'] as List;
    if (kDebugMode) {
      print(list.runtimeType);
    }
    List<Com> comsList = list.map((i) => Com.fromJson(i)).toList();

    return Product(
        id: parsedJson['id'], name: parsedJson['name'], coms: comsList);
  }
}

class Com {
  final int? imageId;
  final String? imageName;

  Com({this.imageId, this.imageName});

  factory Com.fromJson(Map<String, dynamic> parsedJson) {
    return Com(imageId: parsedJson['id'], imageName: parsedJson['imageName']);
  }
}

class ComInfo {
  String? portName;
  int? baud;
  int? dataBits;
  String? parity;
  double? stopbits;

  ComInfo(this.portName, this.baud, this.dataBits, this.parity, this.stopbits);

  ComInfo.fromJson(Map<String, dynamic> json) {
    portName = json['portName'];
    baud = json['baud'];
    dataBits = json['dataBits'];
    parity = json['parity'];
    stopbits = json['stopbits'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['portName'] = portName;
    data['baud'] = baud;
    data['dataBits'] = dataBits;
    data['parity'] = parity;
    data['stopbits'] = stopbits;
    return data;
  }
}
