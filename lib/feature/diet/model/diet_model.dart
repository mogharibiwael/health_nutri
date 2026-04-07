class DietModel {
  final int id;
  final int? patientId;
  final int? doctorId;
  final String? doctorName;
  final String? patientName;
  final String title;
  final int dailyCalories;
  final int durationDays;
  final String startDate;
  final String endDate;
  final String? notes;
  final List<DietMealModel> meals;
  final String? createdAt;
  final bool isDietPlan;

  DietModel({
    required this.id,
    this.patientId,
    this.doctorId,
    this.doctorName,
    this.patientName,
    required this.title,
    required this.dailyCalories,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    this.notes,
    this.meals = const [],
    this.createdAt,
    this.isDietPlan = false,
  });

  factory DietModel.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    String? _extractDoctorName(Map<String, dynamic> json) {
      if (json["doctor"] is Map) {
        final d = json["doctor"] as Map;
        return (d["name"] ?? d["fullname"] ?? d["full_name"])?.toString();
      }
      return (json["doctor_name"] ?? json["fullname"] ?? json["full_name"])?.toString();
    }

    String? _extractPatientName(Map<String, dynamic> json) {
      if (json["patient"] is Map) {
        final p = json["patient"] as Map;
        return (p["name"] ?? p["fullname"] ?? p["full_name"])?.toString();
      }
      return (json["patient_name"] ?? json["fullname"] ?? json["full_name"])?.toString();
    }

    List<DietMealModel> mealsList = [];
    if (json["meals"] is List) {
      mealsList = (json["meals"] as List)
          .map((e) => DietMealModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    int? patientId = json["patient_id"] != null ? _toInt(json["patient_id"]) : null;
    int? doctorId = json["doctor_id"] != null ? _toInt(json["doctor_id"]) : null;
    if (patientId == null && json["patient"] is Map) {
      patientId = _toInt((json["patient"] as Map)["id"]);
    }
    if (doctorId == null && json["doctor"] is Map) {
      doctorId = _toInt((json["doctor"] as Map)["id"]);
    }

    String _formatDate(String? raw) {
      if (raw == null || raw.isEmpty) return "";
      if (raw.contains("T")) return raw.split("T").first;
      return raw;
    }

    return DietModel(
      id: _toInt(json["id"]),
      patientId: patientId,
      doctorId: doctorId,
      doctorName: _extractDoctorName(json),
      patientName: _extractPatientName(json),
      title: (json["title"] ?? "").toString(),
      dailyCalories: _toInt(json["daily_calories"] ?? 0),
      durationDays: _toInt(json["duration_days"] ?? 0),
      startDate: _formatDate(json["start_date"]?.toString()),
      endDate: _formatDate(json["end_date"]?.toString()),
      notes: json["notes"]?.toString() ?? json["description"]?.toString(),
      meals: mealsList,
      createdAt: json["created_at"]?.toString(),
      isDietPlan: json.containsKey("daily_calories") || json.containsKey("duration_days") || json.containsKey("meals"),
    );
  }
}

class DietMealModel {
  final int id;
  final int dayNumber;
  final String mealType; // breakfast, lunch, dinner, snack
  final String mealName;
  final int calories;
  final String? servingSummary;
  final String? description; // diet-plans API: describtion
  final int? carbsG;
  final int? proteinG;
  final int? fatG;
  final String? mealTime; // e.g. "08:00"

  DietMealModel({
    required this.id,
    required this.dayNumber,
    required this.mealType,
    required this.mealName,
    required this.calories,
    this.servingSummary,
    this.description,
    this.carbsG,
    this.proteinG,
    this.fatG,
    this.mealTime,
  });

  factory DietMealModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    // Support both /diets and /diet-plans API formats
    // diet-plans: category=Breakfast/Lunch/Dinner/Snack, meal_type=drink/side/main
    final category = json["category"]?.toString();
    final mealTypeRaw = (json["meal_type"] ?? category ?? "").toString();
    final mealType = _categoryToMealType(category) ?? mealTypeRaw;
    final mealName = (json["meal_name"] ?? json["name"] ?? "").toString();
    final calories = toInt(json["calories"] ?? json["energy"] ?? 0);
    final servingSummary = json["serving_summary"]?.toString() ?? json["serving"]?.toString();
    final description = json["describtion"]?.toString() ?? json["description"]?.toString();

    return DietMealModel(
      id: toInt(json["id"] ?? 0),
      dayNumber: toInt(json["day_number"] ?? 0),
      mealType: mealType.isNotEmpty ? mealType : "snack",
      mealName: mealName.isNotEmpty ? mealName : (json["name"] ?? "").toString(),
      calories: calories,
      servingSummary: servingSummary,
      description: description,
      carbsG: json["carbs_g"] != null ? toInt(json["carbs_g"]) : (json["carbo"] != null ? toInt(json["carbo"]) : null),
      proteinG: json["protein_g"] != null ? toInt(json["protein_g"]) : (json["protin"] != null ? toInt(json["protin"]) : null),
      fatG: json["fat_g"] != null ? toInt(json["fat_g"]) : (json["fat"] != null ? toInt(json["fat"]) : null),
      mealTime: json["meal_time"]?.toString(),
    );
  }

  static String? _categoryToMealType(String? category) {
    if (category == null || category.isEmpty) return null;
    final c = category.toLowerCase();
    if (c == "breakfast") return "breakfast";
    if (c == "lunch") return "lunch";
    if (c == "dinner") return "dinner";
    if (c.contains("snack")) return "snack";
    return c;
  }

  String get mealTypeDisplay {
    switch (mealType.toLowerCase()) {
      case "breakfast":
        return "Breakfast";
      case "lunch":
        return "Lunch";
      case "dinner":
        return "Dinner";
      case "firstsnack":
        return "First Snack";
      case "secondsnack":
        return "Second Snack";
      case "thirdsnack":
        return "Third Snack";
      case "extrasnack":
      case "snack":
        return "Snack";
      default:
        return mealType.isNotEmpty ? mealType : "Snack";
    }
  }
}
