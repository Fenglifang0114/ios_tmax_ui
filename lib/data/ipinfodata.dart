class IpInfoData {
  String? iP;
  String? gateway;
  String? netmask;

  IpInfoData({this.iP, this.gateway, this.netmask});

  IpInfoData.fromJson(Map<String, dynamic> json) {
    iP = json['IP'];
    gateway = json['Gateway'];
    netmask = json['Netmask'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['IP'] = iP;
    data['Gateway'] = gateway;
    data['Netmask'] = netmask;
    return data;
  }
}

// class IpInfoData {
//   List<Addresses>? address;
//   String? gateway;
//   List<String>? dns;
//   String? mac;

//   IpInfoData({this.address, this.gateway, this.dns, this.mac});

//   IpInfoData.fromJson(Map<String, dynamic> json) {
//     if (json['address'] != null) {
//       address = <Addresses>[];
//       json['address'].forEach((v) {
//         address!.add(Addresses.fromJson(v));
//       });
//     }
//     gateway = json['gateway'];
//     dns = json['dns'].cast<String>();
//     mac = json['mac'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     if (address != null) {
//       data['address'] = address!.map((v) => v.toJson()).toList();
//     }
//     data['gateway'] = gateway;
//     data['dns'] = dns;
//     data['mac'] = mac;
//     return data;
//   }
// }

IpInfoData myIpInfoData = IpInfoData();

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
  int? seqno;
  String? ssid;
  String? password;

  DynamicIpInfo({this.seqno, this.ssid, this.password});

  DynamicIpInfo.fromJson(Map<String, dynamic> json) {
    seqno = json['seqno'];
    ssid = json['ssid'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['seqno'] = seqno;
    data['ssid'] = ssid;
    data['password'] = password;
    return data;
  }
}

DynamicIpInfo myDynamicIpInfo = DynamicIpInfo();

class StaticIpInfo {
  int? seqno;
  String? ssid;
  String? password;
  List<StaticAddresses>? addresses;
  String? gateway;
  String? dns;

  StaticIpInfo(
      {this.seqno,
      this.ssid,
      this.password,
      this.addresses,
      this.gateway,
      this.dns});

  StaticIpInfo.fromJson(Map<String, dynamic> json) {
    seqno = json['seqno'];
    ssid = json['ssid'];
    password = json['password'];
    if (json['addresses'] != null) {
      addresses = <StaticAddresses>[];
      json['addresses'].forEach((v) {
        addresses!.add(StaticAddresses.fromJson(v));
      });
    }
    gateway = json['gateway'];
    dns = json['dns'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['seqno'] = seqno;
    data['ssid'] = ssid;
    data['password'] = password;
    if (addresses != null) {
      data['addresses'] = addresses!.map((v) => v.toJson()).toList();
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

StaticAddresses myStaticAddresses = StaticAddresses();
StaticIpInfo myStaticIpInfo = StaticIpInfo();

ConnectApInfo myConnectApInfo = ConnectApInfo();

class ConnectApInfo {
  String? ssid;
  String? password;
  String? bssid;

  ConnectApInfo({this.ssid, this.password, this.bssid});

  ConnectApInfo.fromJson(Map<String, dynamic> json) {
    ssid = json['ssid'];
    password = json['password'];
    bssid = json['bssid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ssid'] = ssid;
    data['password'] = password;
    data['bssid'] = bssid;
    return data;
  }
}
