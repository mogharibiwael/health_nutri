/// Pure Dart diet calculation service - unit-testable.
/// Mifflin-St Jeor BMR, TDEE, target calories, macro grams.
class DietCalculatorService {
  DietCalculatorService._();

  /// Activity factor mapping (map physical_activity strings to these)
  static const Map<String, double> activityFactors = {
    'sedentary': 1.2,
    'light': 1.3,
    'moderate': 1.5,
    'active': 1.7,
    'very_active': 1.9,
    'قليل': 1.2,
    'خفيف': 1.3,
    'متوسط': 1.5,
    'نشط': 1.7,
    'نشط جداً': 1.9,
  };

  static double _getActivityFactor(String? activity) {
    if (activity == null || activity.isEmpty) return 1.3;
    final lower = activity.toLowerCase().trim();

    // Support numeric strings directly (e.g., "1.5")
    final numeric = double.tryParse(lower);
    if (numeric != null && numeric > 0) return numeric;

    for (final e in activityFactors.entries) {
      if (lower.contains(e.key.toLowerCase())) return e.value;
    }
    return 1.3;
  }

  /// Compute age from DOB (YYYY-MM-DD or YYYY/MM/DD)
  static int? ageFromDob(String? dob) {
    if (dob == null || dob.isEmpty) return null;
    final parts = dob.split(RegExp(r'[-/]'));
    if (parts.isEmpty) return null;
    final year = int.tryParse(parts[0]);
    if (year == null) return null;
    return DateTime.now().year - year;
  }

  /// BMR Mifflin-St Jeor
  static double bmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isFemale,
  }) {
    if (weightKg <= 0 || heightCm <= 0) return 0;
    if (isFemale) {
      return 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }
    return 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
  }

  /// TDEE = BMR * activity_factor
  static double tdee({
    required double bmrValue,
    required String? physicalActivity,
  }) {
    final factor = _getActivityFactor(physicalActivity);
    return (bmrValue * factor) + (bmrValue * factor * 0.1);
  }

  /// Target calories based on goal
  static double targetCalories({
    required double tdeeValue,
    required DietGoal goal,
    double weeklyChangeKg = -0.5,
  }) {
    switch (goal) {
      case DietGoal.maintain:
        return tdeeValue;
      case DietGoal.weightLoss:
        final deficit = (-weeklyChangeKg).clamp(0.0, 2.0) * 550;
        final target = tdeeValue - deficit;
        return target.clamp(1200.0, tdeeValue);
      case DietGoal.weightGain:
        final surplus = (weeklyChangeKg > 0 ? weeklyChangeKg : 0.5) * 1100;
        return tdeeValue + surplus;
    }
  }

  /// Macro grams from target calories and preset ratios
  static MacroTargets macroTargets({
    required double targetCaloriesValue,
    double carbsRatio = 0.50,
    double proteinRatio = 0.25,
    double fatRatio = 0.25,
  }) {
    final carbs = (targetCaloriesValue * carbsRatio) / 4;
    final protein = (targetCaloriesValue * proteinRatio) / 4;
    final fat = (targetCaloriesValue * fatRatio) / 9;
    return MacroTargets(
      carbsG: carbs,
      proteinG: protein,
      fatG: fat,
      calories: targetCaloriesValue,
    );
  }

  /// Full calculation from patient inputs
  static DietTargetsResult calculate({
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isFemale,
    String? physicalActivity,
    DietGoal goal = DietGoal.weightLoss,
    double weeklyChangeKg = -0.5,
    double carbsRatio = 0.50,
    double proteinRatio = 0.25,
    double fatRatio = 0.25,
  }) {
    final bmrVal = bmr(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      isFemale: isFemale,
    );
    final tdeeVal = tdee(bmrValue: bmrVal, physicalActivity: physicalActivity);
    final targetCal = targetCalories(
      tdeeValue: tdeeVal,
      goal: goal,
      weeklyChangeKg: weeklyChangeKg,
    );
    final macros = macroTargets(
      targetCaloriesValue: targetCal,
      carbsRatio: carbsRatio,
      proteinRatio: proteinRatio,
      fatRatio: fatRatio,
    );
    return DietTargetsResult(
      bmr: bmrVal,
      tdee: tdeeVal,
      targetCalories: targetCal,
      macros: macros,
    );
  }
}

enum DietGoal { maintain, weightLoss, weightGain }

class MacroTargets {
  final double carbsG;
  final double proteinG;
  final double fatG;
  final double calories;

  MacroTargets({
    required this.carbsG,
    required this.proteinG,
    required this.fatG,
    required this.calories,
  });
}

class DietTargetsResult {
  final double bmr;
  final double tdee;
  final double targetCalories;
  final MacroTargets macros;

  DietTargetsResult({
    required this.bmr,
    required this.tdee,
    required this.targetCalories,
    required this.macros,
  });
}
