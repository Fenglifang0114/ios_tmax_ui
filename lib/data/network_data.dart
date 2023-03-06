class Networkdata {
  String name;
  String type;
  String content;
  String index;
  Networkdata(this.name, this.type, this.content, this.index);
  Networkdata.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        type = json['type'],
        content = json['content'],
        index = json['index'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'content': content,
      'index': index,
    };
  }
}

Networkdata myNetworkdata = Networkdata("", "", "", "");
