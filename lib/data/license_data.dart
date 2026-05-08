const String tConfigLic = "T-Config";
const String redeLic = "rede";
const String wedaLic = "weda";
const String chweLic = "chwe";
const String inweLic = "inwe";
const String taouLic = "taou";
const String faspLic = "fasp";
const String foscLic = "fosc";
const String ladeLic = "lade";

class LicenseData {
  List<LicenseInfo> licList;

  LicenseData(this.licList);
  factory LicenseData.fromJson(List<dynamic> parsedJson) {
    List<LicenseInfo> licList = <LicenseInfo>[];
    licList = parsedJson.map((i) => LicenseInfo.fromJson(i)).toList();

    return LicenseData(licList);
  }
}

LicenseData myLicenseData = LicenseData([]);

class LicenseInfo {
  bool isValid;
  String pId;
  String liceseDate;
  String moduleName;
  LicenseInfo(bool valid, this.pId, this.liceseDate, this.moduleName)
      : isValid = true;
  LicenseInfo.fromJson(Map<String, dynamic> json)
      : pId = json['Id'],
        moduleName = json['ModuleName'],
        isValid = true,
        liceseDate = json['ValidDate'];
}

String myConfigCode = ''; //高级配置中的配置代码

LicenseInfo myLicenseInfo = LicenseInfo(true, '', '', '');
LicenseInfo myTConLicInfo = LicenseInfo(true, '', '', '');
LicenseInfo myRedeLicInfo = LicenseInfo(true, '', '', ''); //receipt_design
LicenseInfo myWedaLicInfo =
    LicenseInfo(true, '', '', ''); //weight Data collection
LicenseInfo myChweLicInfo = LicenseInfo(true, '', '', ''); //check weighing
LicenseInfo myInWeLicInfo = LicenseInfo(true, '', '', ''); //Increment weighing
LicenseInfo myTaouLicInfo = LicenseInfo(true, '', '', ''); //take out scale
LicenseInfo myFaSpInfo = LicenseInfo(true, '', '', ''); //fateSpeed scale
LicenseInfo myFoScLicInfo = LicenseInfo(true, '', '', ''); //formula scale
LicenseInfo myLadeLicInfo = LicenseInfo(true, '', '', ''); //label design

class LicenseSetting {
  void setLicInfo() {
    if (myLicenseData.licList.isNotEmpty) {
      for (var item in myLicenseData.licList) {
        if (item.moduleName.contains("T-Config*")) {
          myTConLicInfo.isValid = item.isValid;
          myTConLicInfo.pId = item.pId;
          myTConLicInfo.liceseDate = item.liceseDate;
          myConfigCode = item.moduleName.replaceAll("T-Config*", "");
          myLicenseInfo = myTConLicInfo;
          continue;
        }

        switch (item.moduleName) {
          case tConfigLic:
            myTConLicInfo = item;
            myLicenseInfo = item;
            break;
          case redeLic:
            myRedeLicInfo = item;
            myLicenseInfo = item;
            break;
          case wedaLic:
            myWedaLicInfo = item;
            myLicenseInfo = item;
            break;
          case chweLic:
            myChweLicInfo = item;
            myLicenseInfo = item;
            break;
          case inweLic:
            myInWeLicInfo = item;
            myLicenseInfo = item;
            break;
          case taouLic:
            myTaouLicInfo = item;
            myLicenseInfo = item;
            break;
          case faspLic:
            myFaSpInfo = item;
            myLicenseInfo = item;
            break;
          case foscLic:
            myFoScLicInfo = item;
            myLicenseInfo = item;
            break;
          case ladeLic:
            myLadeLicInfo = item;
            myLicenseInfo = item;
            break;
          default:
            break;
        }
      }
    }
  }
}

void initLicInfo() {}
