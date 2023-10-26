class WeightReportData {
  WeightReportData(
    this.id,
    this.dateTime,
    this.weight,
    this.weightUnit,
    this.pLU,
    this.pluName,
    this.pluRemarks,
    this.pretare,
    this.userName,
    this.userRemarks,
    this.scaleName,
  );
  final String id;
  final String dateTime;
  final String weight;
  final String weightUnit;
  final String pLU;
  final String pluName;
  final String pluRemarks;
  final String pretare;
  final String scaleName;
  final String userName;
  final String userRemarks;
}

WeightReportData myWeightReportData =
    WeightReportData('', '', '', '', '', '', '', '', '', '', '');
