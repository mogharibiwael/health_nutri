/// One saved calculation from GET /api/calculations/history.
class CalculationModel {
  final int id;
  final double? bmi;
  final double? bmr;
  final double? calories;
  final double? protein;
  final double? fat;
  final double? carbs;
  final String? bmiStatus;
  final String? createdAt;

  CalculationModel({
    required this.id,
    this.bmi,
    this.bmr,
    this.calories,
    this.protein,
    this.fat,
    this.carbs,
    this.bmiStatus,
    this.createdAt,
  });

  factory CalculationModel.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return CalculationModel(
      id: toInt(json["id"]) ?? 0,
      // Backend keys (as provided): BMI, BMR, calories, protin, fat, carbo
      bmi: toDouble(json["BMI"] ?? json["bmi"]),
      bmr: toDouble(json["BMR"] ?? json["bmr"]),
      calories: toDouble(json["calories"] ?? json["total_calories"] ?? json["total_kcal"]),
      protein: toDouble(json["protin"] ?? json["protein"] ?? (json["macros"] is Map ? (json["macros"] as Map)["protein_g"] : null)),
      fat: toDouble(json["fat"] ?? (json["macros"] is Map ? (json["macros"] as Map)["fat_g"] : null)),
      carbs: toDouble(json["carbo"] ?? json["carbs"] ?? (json["macros"] is Map ? (json["macros"] as Map)["carbs_g"] : null)),
      bmiStatus: json["bmi_status"]?.toString() ?? json["bmiStatus"]?.toString(),
      createdAt: json["created_at"]?.toString(),
    );
  }
}
