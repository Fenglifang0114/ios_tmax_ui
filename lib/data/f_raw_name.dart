import 'package:t_max/data/formula_common.dart';
import 'package:t_max/data/formula_scale_data.dart';

RawDataInfo getRawData(String rawId) {
  for (var item in rawDataList) {
    if (item.rawMaterial.materialId == rawId) {
      return item;
    }
  }
  return rawDataList.first;
}

String getRawCategoryName(String rawId) {
  int categoryId = 0;
  for (var item in rawDataList) {
    if (item.rawMaterial.materialId == rawId) {
      categoryId = item.rawMaterial.categoryId;
    }
  }
  for (var item in rawTypeList) {
    if (item.categoryId == categoryId) {
      return item.categoryName;
    }
  }
  return "-";
}

String getRawName(String rawId) {
  for (var item in rawDataList) {
    if (item.rawMaterial.materialId == rawId) {
      return item.rawMaterial.materialName;
    }
  }
  return "";
}
