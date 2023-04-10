class AddUserInfo {
  String? id;
  String? name;
  bool? isFemale;
  String? phone;
  String? remarks;

  AddUserInfo({this.id, this.name, this.isFemale, this.phone, this.remarks});

  AddUserInfo.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    name = json['Name'];
    isFemale = json['IsFemale'];
    phone = json['Phone'];
    remarks = json['Remarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['Id'] = id;
    data['Name'] = name;
    data['IsFemale'] = isFemale;
    data['Phone'] = phone;
    data['Remarks'] = remarks;
    return data;
  }
}

class UserInfoList {
  List<UserInfo>? userInfo;
  UserInfoList({this.userInfo});
  factory UserInfoList.fromJson(List<dynamic> parsedJson) {
    List<UserInfo> userList = <UserInfo>[];
    userList = parsedJson.map((i) => UserInfo.fromJson(i)).toList();
    return UserInfoList(userInfo: userList);
  }
}

UserInfoList myUserInfoList = UserInfoList();

class UserInfo {
  int? recId;
  String? id;
  String? name;
  bool? isFemale;
  String? phone;
  String? remarks;

  UserInfo(
      {this.recId,
      this.id,
      this.name,
      this.isFemale,
      this.phone,
      this.remarks});

  UserInfo.fromJson(Map<String, dynamic> json) {
    recId = json['RecId'];
    id = json['Id'];
    name = json['Name'];
    isFemale = json['IsFemale'];
    phone = json['Phone'];
    remarks = json['Remarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['RecId'] = recId;
    data['Id'] = id;
    data['Name'] = name;
    data['IsFemale'] = isFemale;
    data['Phone'] = phone;
    data['Remarks'] = remarks;
    return data;
  }
}

UserInfo myUserInfo = UserInfo();
UserInfo myCurrUserInfo = UserInfo();

class UserRecDel {
  int recId;

  UserRecDel(this.recId);
  UserRecDel.fromJson(Map<String, dynamic> json) : recId = json['RecId'];

  Map<String, dynamic> toJson() {
    return {
      'RecId': recId,
    };
  }
}

UserRecDel myUserRecDel = UserRecDel(0);
