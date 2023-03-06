class ConnInfoBt {
  String? btAddr;

  ConnInfoBt(this.btAddr);

  ConnInfoBt.fromJson(Map<String, dynamic> json) {
    btAddr = json['btAddr'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['btAddr'] = btAddr;
    return data;
  }
}

ConnInfoBt myConnInfoBt = ConnInfoBt("");
