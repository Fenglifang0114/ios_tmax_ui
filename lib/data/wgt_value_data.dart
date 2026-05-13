//存储重量值

const double kgToLb = 2.2046226218;

// 定义一个 WeightInfo 类来存储重量和单位
class WeightInfo {
  String weight;
  String unit;
  bool stable;

  WeightInfo({required this.weight, required this.unit, required this.stable});
}

//加法秤和减法秤用到的 共用的增量

Map<int, WeightInfo> scaleWeightMapCommon =
    {}; // 存储每台秤的最新称重数据，键为秤的 ID，值为包含重量和单位的对象

// 单位换算方法
double convertUnit(double weight, String fromUnit, String toUnit) {
  // 简单示例，仅支持 kg 和 g 的换算，可根据实际情况扩展
  if (fromUnit == toUnit) {
    return weight;
  }
  if (fromUnit == 'kg' && toUnit == 'g') {
    return weight * 1000;
  }
  if (fromUnit == 'g' && toUnit == 'kg') {
    return weight / 1000;
  }
  if (fromUnit == 'g' && toUnit == 'lb') {
    return weight * kgToLb / 1000;
  }
  if (fromUnit == 'kg' && toUnit == 'lb') {
    return weight * kgToLb;
  }
  if (fromUnit == 'lb' && toUnit == 'g') {
    return weight / kgToLb / 1000;
  }
  if (fromUnit == 'lb' && toUnit == 'kg') {
    return weight / kgToLb;
  }
  // 默认不转换
  return weight;
}
