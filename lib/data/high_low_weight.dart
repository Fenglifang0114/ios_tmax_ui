class HighLowWeight {
  double highValue;
  double lowValue;
  HighLowWeight(this.highValue, this.lowValue);
}

HighLowWeight myHighLowWeight = HighLowWeight(0.0, 0.0);

class CheckWeightSet {
  int scaleId;
  double highValue1;
  double lowValue1;
  double highValue2;
  double lowValue2;
  CheckWeightSet(this.scaleId, this.highValue1, this.lowValue1, this.highValue2,
      this.lowValue2);
}

List<CheckWeightSet> myCheckWeightSetList = [];

class CheckWeightFunc {
  CheckWeightSet findScaleId(
      List<CheckWeightSet> myCheckWeightSetList, int scaleId) {
    return myCheckWeightSetList.firstWhere(
        (element) => element.scaleId == scaleId,
        orElse: () => CheckWeightSet(scaleId, 0, 0, 0, 0));
  }

  void updateHighLow(
      List<CheckWeightSet> myCheckWeightSetList, CheckWeightSet updateHighLow) {
    var tempInfo = myCheckWeightSetList.firstWhere(
        (element) => element.scaleId == updateHighLow.scaleId,
        orElse: () => CheckWeightSet(0, 0, 0, 0, 0));
    if (tempInfo.scaleId == 0) {
      myCheckWeightSetList.add(updateHighLow);
    } else {
      myCheckWeightSetList.remove(tempInfo);
      myCheckWeightSetList.add(updateHighLow);
    }
  }
}
