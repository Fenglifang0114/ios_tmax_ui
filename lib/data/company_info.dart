class CompanyInfo {
  String? companyName;
  String? tel;
  String? email;
  String? address;
  String? website;

  CompanyInfo(
      this.companyName, this.tel, this.email, this.address, this.website);

  CompanyInfo.fromJson(Map<String, dynamic> json) {
    companyName = json['Company'];
    tel = json['Tel'];
    email = json['Email'];
    address = json['Address'];
    website = json['Website'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Company'] = companyName;
    data['Tel'] = tel;
    data['Email'] = email;
    data['Address'] = address;
    data['Website'] = website;
    return data;
  }
}

CompanyInfo myCompanyInfo = CompanyInfo('', '', '', '', '');
