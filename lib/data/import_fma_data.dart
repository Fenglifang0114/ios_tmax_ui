//表格中导入配方数据
// To parse this JSON data, do
//

import 'dart:convert';

String importFmaInfoToJson(FmaImportFmt data) => json.encode(data.toJson());

class FmaImportFmt {
  String? createBy;
  List<ImportFmaInfo>? fmaInfo;

  FmaImportFmt({
    this.createBy,
    this.fmaInfo,
  });

  factory FmaImportFmt.fromJson(Map<String, dynamic> json) => FmaImportFmt(
        createBy: json["CreateBy"],
        fmaInfo: json["FmaInfo"] == null
            ? []
            : List<ImportFmaInfo>.from(
                json["FmaInfo"]!.map((x) => ImportFmaInfo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "CreateBy": createBy,
        "FmaInfo": fmaInfo == null
            ? []
            : List<dynamic>.from(fmaInfo!.map((x) => x.toJson())),
      };
}

class ImportFmaInfo {
  String? formulaId;
  String? formulaName;
  String? mode;
  String? weightUnit;
  String? category;
  bool? isConfidential;
  bool? needContainer;
  List<Ingredient>? ingredients;
  String? notes;

  ImportFmaInfo({
    this.formulaId,
    this.formulaName,
    this.mode,
    this.weightUnit,
    this.category,
    this.isConfidential,
    this.needContainer,
    this.ingredients,
    this.notes,
  });

  factory ImportFmaInfo.fromJson(Map<String, dynamic> json) => ImportFmaInfo(
        formulaId: json["FormulaId"],
        formulaName: json["FormulaName"],
        mode: json["Mode"],
        weightUnit: json["WeightUnit"],
        category: json["Category"],
        isConfidential: json["IsConfidential"],
        needContainer: json["NeedContainer"],
        ingredients: json["Ingredients"] == null
            ? []
            : List<Ingredient>.from(
                json["Ingredients"]!.map((x) => Ingredient.fromJson(x))),
        notes: json["Notes"],
      );

  Map<String, dynamic> toJson() => {
        "FormulaId": formulaId,
        "FormulaName": formulaName,
        "Mode": mode,
        "WeightUnit": weightUnit,
        "Category": category,
        "IsConfidential": isConfidential,
        "NeedContainer": needContainer,
        "Ingredients": ingredients == null
            ? []
            : List<dynamic>.from(ingredients!.map((x) => x.toJson())),
        "Notes": notes,
      };
}

class Ingredient {
  int? ingredientNo;
  String? ingredientId;
  String? ingredientName;
  double? weightOrPercent;
  double? allowError;

  Ingredient({
    this.ingredientNo,
    this.ingredientId,
    this.ingredientName,
    this.weightOrPercent,
    this.allowError,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        ingredientNo: json["IngredientNo"],
        ingredientId: json["IngredientId"],
        ingredientName: json["IngredientName"],
        weightOrPercent: json["WeightOrPercent"]?.toDouble(),
        allowError: json["AllowError"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "IngredientNo": ingredientNo,
        "IngredientId": ingredientId,
        "IngredientName": ingredientName,
        "WeightOrPercent": weightOrPercent,
        "AllowError": allowError,
      };
}
// List<ImportFmaInfo> myImportFmaInfo = [];
