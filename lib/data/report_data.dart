class ReportData {
  String firstField;
  String secondField;
  String thirdField;
  String fourthField;
  String fifthField;
  String sixthField;
  String seventhField;
  String eighthField;
  String ninthField;
  String tenthField;
  ReportData(
      this.firstField,
      this.secondField,
      this.thirdField,
      this.fourthField,
      this.fifthField,
      this.sixthField,
      this.seventhField,
      this.eighthField,
      this.ninthField,
      this.tenthField);
  ReportData.fromJson(Map<String, dynamic> json)
      : firstField = json['firstField'],
        secondField = json['secondField'],
        thirdField = json['thirdField'],
        fourthField = json['fourthField'],
        fifthField = json['fifthField'],
        sixthField = json['sixthField'],
        seventhField = json['seventhField'],
        eighthField = json['eighthField'],
        ninthField = json['ninthField'],
        tenthField = json['tenthField'];

  Map<String, dynamic> toJson() {
    return {
      'firstField': firstField,
      'secondField': secondField,
      'thirdField': thirdField,
      'fourthField': fourthField,
      'fifthField': fifthField,
      'sixthField': sixthField,
      'seventhField': seventhField,
      'eighthField': eighthField,
      'ninthField': ninthField,
      'tenthField': tenthField,
    };
  }
}

ReportData myReportData = ReportData("1", "2022-9-15", "000000", "other", "5",
    "0.5", "0", "12", "Administrator", "删除");
