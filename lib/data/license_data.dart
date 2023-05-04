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
