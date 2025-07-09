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
