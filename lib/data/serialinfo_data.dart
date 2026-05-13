class SerialinfoData {
  List<String> name;
  SerialinfoData(this.name);
  SerialinfoData.fromJson(Map<String, dynamic> json) : name = json['name'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}

SerialinfoData mySerialinfoData = SerialinfoData([
  "COM1",
  "COM2",
]);
