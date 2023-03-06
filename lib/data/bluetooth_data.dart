class Bluetoothdata {
  String name;
  String type;
  String device;
  String num;
  Bluetoothdata(this.name, this.type, this.device, this.num);
  Bluetoothdata.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        type = json['type'],
        device = json['device'],
        num = json['num'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'device': device,
      'num': num,
    };
  }
}

Bluetoothdata myBluetoothdata = Bluetoothdata("", "", "", "");
