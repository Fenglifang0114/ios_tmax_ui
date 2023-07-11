class IpInfoData {
  List<Addresses>? addresses;
  String? gateway;
  List<String>? dns;
  String? mac;

  IpInfoData({this.addresses, this.gateway, this.dns, this.mac});

  IpInfoData.fromJson(Map<String, dynamic> json) {
    if (json['addresses'] != null) {
      addresses = <Addresses>[];
      json['addresses'].forEach((v) {
        addresses!.add(Addresses.fromJson(v));
      });
    }
    gateway = json['gateway'];
    dns = json['dns'].cast<String>();
    mac = json['mac'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (addresses != null) {
      data['addresses'] = addresses!.map((v) => v.toJson()).toList();
    }
    data['gateway'] = gateway;
    data['dns'] = dns;
    data['mac'] = mac;
    return data;
  }
}

class Addresses {
  String? address;
  int? mask;
  String? proto;
  String? family;

  Addresses({this.address, this.mask, this.proto, this.family});

  Addresses.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    mask = json['mask'];
    proto = json['proto'];
    family = json['family'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['mask'] = mask;
    data['proto'] = proto;
    data['family'] = family;
    return data;
  }
}

class DynamicIpInfo {
  String? id;
  String? ssid;
  String? password;

  DynamicIpInfo({this.id, this.ssid, this.password});

  DynamicIpInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ssid = json['ssid'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ssid'] = ssid;
    data['password'] = password;
    return data;
  }
}

class StaticIpInfo {
  String? id;
  String? ssid;
  String? password;
  List<StaticAddresses>? staticAddresses;
  String? gateway;
  String? dns;

  StaticIpInfo(
      {this.id,
      this.ssid,
      this.password,
      this.staticAddresses,
      this.gateway,
      this.dns});

  StaticIpInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ssid = json['ssid'];
    password = json['password'];
    if (json['addresses'] != null) {
      staticAddresses = <StaticAddresses>[];
      json['addresses'].forEach((v) {
        staticAddresses!.add(StaticAddresses.fromJson(v));
      });
    }
    gateway = json['gateway'];
    dns = json['dns'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ssid'] = ssid;
    data['password'] = password;
    if (staticAddresses != null) {
      data['addresses'] = staticAddresses!.map((v) => v.toJson()).toList();
    }
    data['gateway'] = gateway;
    data['dns'] = dns;
    return data;
  }
}

class StaticAddresses {
  String? address;
  int? mask;
  String? family;

  StaticAddresses({this.address, this.mask, this.family});

  StaticAddresses.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    mask = json['mask'];
    family = json['family'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['mask'] = mask;
    data['family'] = family;
    return data;
  }
}
