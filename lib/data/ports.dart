class Ports {
  String? portName;
  String? description;

  Ports(this.portName, this.description);

  Ports.fromJson(Map<String, dynamic> json) {
    portName = json['portName'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['portName'] = portName;
    data['description'] = description;
    return data;
  }
}

Ports myPorts = Ports("", "");
