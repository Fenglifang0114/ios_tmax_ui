class UserData {
  String userName;
  String password;
  String newPassword;
  String computerid;
  String license;
  String newlicense;
  UserData(this.userName, this.password, this.newPassword, this.computerid,
      this.license, this.newlicense);
  UserData.fromJson(Map<String, dynamic> json)
      : userName = json['userName'],
        password = json['password'],
        newPassword = json['newPassword'],
        computerid = json['computerid'],
        license = json['license'],
        newlicense = json['newlicense'];

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'password': password,
      'newPassword': newPassword,
      'computerid': computerid,
      'license': license,
      'newlicense': newlicense,
    };
  }
}

UserData myUserData = UserData("Administrator", "2", "3", "4", "5", "6");
