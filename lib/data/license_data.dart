class LicenseData {
  String data;

  LicenseData(this.data);
  LicenseData.fromJson(Map<String, dynamic> json) : data = json['Data'];

  Map<String, dynamic> toJson() {
    return {
      'Data': data,
    };
  }
}

LicenseData myLicenseData = LicenseData(
  "",
);

class LicenseInfo {
  bool isValid;
  String pId;
  String liceseDate;
  LicenseInfo(this.isValid, this.pId, this.liceseDate);
}

LicenseInfo myLicenseInfo = LicenseInfo(
  false,
  '',
  '',
);

class CheckSerialPortOnOFF {
  bool isCheck;
  CheckSerialPortOnOFF(this.isCheck);
}

CheckSerialPortOnOFF myCheckSerialPortOnOFF = CheckSerialPortOnOFF(true);
