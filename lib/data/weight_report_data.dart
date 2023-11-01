class WeightReportData {
  WeightReportData(
    this.id,
    this.dateTime,
    this.weight,
    this.weightUnit,
    this.plu,
    this.pluName,
    this.pluRemarks,
    this.pretare,
    this.userName,
    this.userNo,
    this.userRemarks,
    this.scaleName,
  );
  final String id;
  final String dateTime;
  final String weight;
  final String weightUnit;
  final String plu;
  final String pluName;
  final String pluRemarks;
  final String pretare;
  final String scaleName;
  final String userNo;
  final String userName;
  final String userRemarks;
}

WeightReportData myWeightReportData =
    WeightReportData('', '', '', '', '', '', '', '', '', '', '', '');

class ReportFields {
  List<String> filedsList;
  ReportFields(this.filedsList);
}

ReportFields myReportFields = ReportFields([
  'Date Time',
  'PLU NO.',
  'PLU Name',
  'PLU Remarks',
  'Weight',
  'Weight Unit',
  'Pretare',
  'User NO.',
  'User Name',
  'User Remarks',
  'Scale Name'
]);
