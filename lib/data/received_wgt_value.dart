//接收到的重量值

class ReceiveWgtInfo {
  String? weightVal;
  String? weightUnit;
  bool? isStable;
  bool? isZero;
  bool? isNet;

  ReceiveWgtInfo({
    this.weightVal,
    this.weightUnit,
    this.isStable,
    this.isZero,
    this.isNet,
  });
}
