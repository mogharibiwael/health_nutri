/// Food Exchange groups and serving definitions (fixed macros per serving)
enum ExchangeGroup {
  starch,
  fruit,
  vegetables,
  milkSkim,
  milkLowFat,
  milkWhole,
  meatVeryLean,
  meatLean,
  meatMediumFat,
  meatHighFat,
  fat,
}

class ExchangeServingDefinition {
  final ExchangeGroup group;
  final String nameKey;
  final int carbsG;
  final int proteinG;
  final int fatG;
  final int calories;

  const ExchangeServingDefinition({
    required this.group,
    required this.nameKey,
    required this.carbsG,
    required this.proteinG,
    required this.fatG,
    required this.calories,
  });
}

/// Fixed exchange definitions per serving.
/// Values from standard food exchange table (جدول 1). See docs/EXCHANGE_TABLE_REFERENCE.md.
class ExchangeDefinitions {
  static const starch = ExchangeServingDefinition(
    group: ExchangeGroup.starch,
    nameKey: 'starch',
    carbsG: 15,
    proteinG: 3,
    fatG: 0,
    calories: 80,
  );
  static const fruit = ExchangeServingDefinition(
    group: ExchangeGroup.fruit,
    nameKey: 'fruit',
    carbsG: 15,
    proteinG: 0,
    fatG: 0,
    calories: 60,
  );
  static const vegetables = ExchangeServingDefinition(
    group: ExchangeGroup.vegetables,
    nameKey: 'vegetables',
    carbsG: 5,
    proteinG: 2,
    fatG: 0,
    calories: 25,
  );
  static const milkSkim = ExchangeServingDefinition(
    group: ExchangeGroup.milkSkim,
    nameKey: 'milkSkim',
    carbsG: 12,
    proteinG: 8,
    fatG: 0,
    calories: 90,
  );
  static const milkLowFat = ExchangeServingDefinition(
    group: ExchangeGroup.milkLowFat,
    nameKey: 'milkLowFat',
    carbsG: 12,
    proteinG: 8,
    fatG: 5,
    calories: 120,
  );
  static const milkWhole = ExchangeServingDefinition(
    group: ExchangeGroup.milkWhole,
    nameKey: 'milkWhole',
    carbsG: 12,
    proteinG: 8,
    fatG: 8,
    calories: 150,
  );
  static const meatVeryLean = ExchangeServingDefinition(
    group: ExchangeGroup.meatVeryLean,
    nameKey: 'meatVeryLean',
    carbsG: 0,
    proteinG: 7,
    fatG: 1,
    calories: 35,
  );
  static const meatLean = ExchangeServingDefinition(
    group: ExchangeGroup.meatLean,
    nameKey: 'meatLean',
    carbsG: 0,
    proteinG: 7,
    fatG: 3,
    calories: 55,
  );
  static const meatMediumFat = ExchangeServingDefinition(
    group: ExchangeGroup.meatMediumFat,
    nameKey: 'meatMediumFat',
    carbsG: 0,
    proteinG: 7,
    fatG: 5,
    calories: 75,
  );
  static const meatHighFat = ExchangeServingDefinition(
    group: ExchangeGroup.meatHighFat,
    nameKey: 'meatHighFat',
    carbsG: 0,
    proteinG: 7,
    fatG: 8,
    calories: 100,
  );
  static const fat = ExchangeServingDefinition(
    group: ExchangeGroup.fat,
    nameKey: 'fat',
    carbsG: 0,
    proteinG: 0,
    fatG: 5,
    calories: 45,
  );

  static ExchangeServingDefinition getMilk(MilkType type) {
    switch (type) {
      case MilkType.skim:
        return milkSkim;
      case MilkType.lowFat:
        return milkLowFat;
      case MilkType.whole:
        return milkWhole;
    }
  }

  static ExchangeServingDefinition getMeat(MeatType type) {
    switch (type) {
      case MeatType.veryLean:
        return meatVeryLean;
      case MeatType.lean:
        return meatLean;
      case MeatType.mediumFat:
        return meatMediumFat;
      case MeatType.highFat:
        return meatHighFat;
    }
  }
}

enum MilkType { skim, lowFat, whole }
enum MeatType { veryLean, lean, mediumFat, highFat }

/// Daily servings per exchange group
class DailyExchangePlan {
  final double starch;
  final double fruit;
  final double vegetables;
  final double milk;
  final double meat;
  final double fat;
  final MilkType milkType;
  final MeatType meatType;

  DailyExchangePlan({
    required this.starch,
    required this.fruit,
    required this.vegetables,
    required this.milk,
    required this.meat,
    required this.fat,
    this.milkType = MilkType.lowFat,
    this.meatType = MeatType.lean,
  });

  Map<String, dynamic> toJson() => {
        'starch': starch,
        'fruit': fruit,
        'vegetables': vegetables,
        'milk': milk,
        'meat': meat,
        'fat': fat,
        'milk_type': milkType.index,
        'meat_type': meatType.index,
      };

  static DailyExchangePlan fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) => (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '0') ?? 0.0;
    return DailyExchangePlan(
      starch: _toDouble(json['starch']),
      fruit: _toDouble(json['fruit']),
      vegetables: _toDouble(json['vegetables']),
      milk: _toDouble(json['milk']),
      meat: _toDouble(json['meat']),
      fat: _toDouble(json['fat']),
      milkType: MilkType.values[(json['milk_type'] as num? ?? 1).toInt()],
      meatType: MeatType.values[(json['meat_type'] as num? ?? 1).toInt()],
    );
  }

  (double carbs, double protein, double fat, double calories) computeTotals() {
    final s = ExchangeDefinitions.starch;
    final f = ExchangeDefinitions.fruit;
    final v = ExchangeDefinitions.vegetables;
    final m = ExchangeDefinitions.getMilk(milkType);
    final mt = ExchangeDefinitions.getMeat(meatType);
    final ft = ExchangeDefinitions.fat;

    final c = (starch * s.carbsG + fruit * f.carbsG + vegetables * v.carbsG +
        milk * m.carbsG + meat * mt.carbsG + fat * ft.carbsG).toDouble();
    final p = (starch * s.proteinG + fruit * f.proteinG + vegetables * v.proteinG +
        milk * m.proteinG + meat * mt.proteinG + fat * ft.proteinG).toDouble();
    final fa = (starch * s.fatG + fruit * f.fatG + vegetables * v.fatG +
        milk * m.fatG + meat * mt.fatG + fat * ft.fatG).toDouble();
    final cal = (starch * s.calories + fruit * f.calories + vegetables * v.calories +
        milk * m.calories + meat * mt.calories + fat * ft.calories).toDouble();

    return (c, p, fa, cal);
  }
}
