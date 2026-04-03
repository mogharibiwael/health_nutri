import 'exchange_model.dart';

/// Extended portion plan matching reference app: main categories with portions + fat per serving.
/// Used for "تحديد الحصص للوجبات" (Determine portions for meals) table.
class PortionCategoriesPlan {
  double milkSkim;
  double milkLowFat;
  double milkWhole;
  double vegetables;
  double fruit;
  double starch;
  double otherCarbs;
  double meatVeryLean;
  double meatLean;
  double meatMediumFat;
  double meatHighFat;
  double fat;

  PortionCategoriesPlan({
    this.milkSkim = 0,
    this.milkLowFat = 0,
    this.milkWhole = 0,
    this.vegetables = 0,
    this.fruit = 0,
    this.starch = 0,
    this.otherCarbs = 0,
    this.meatVeryLean = 0,
    this.meatLean = 0,
    this.meatMediumFat = 0,
    this.meatHighFat = 0,
    this.fat = 0,
  });

   double get totalMilk => milkSkim + milkLowFat + milkWhole;
  double get totalStarch => starch + otherCarbs;
  double get totalMeat => meatVeryLean + meatLean + meatMediumFat + meatHighFat;

  double get totalProtein {
    final sum = (milkSkim * ExchangeDefinitions.milkSkim.proteinG) +
        (milkLowFat * ExchangeDefinitions.milkLowFat.proteinG) +
        (milkWhole * ExchangeDefinitions.milkWhole.proteinG) +
        (vegetables * ExchangeDefinitions.vegetables.proteinG) +
        (fruit * ExchangeDefinitions.fruit.proteinG) +
        (starch * ExchangeDefinitions.starch.proteinG) +
        (otherCarbs * ExchangeDefinitions.starch.proteinG) +
        (meatVeryLean * ExchangeDefinitions.meatVeryLean.proteinG) +
        (meatLean * ExchangeDefinitions.meatLean.proteinG) +
        (meatMediumFat * ExchangeDefinitions.meatMediumFat.proteinG) +
        (meatHighFat * ExchangeDefinitions.meatHighFat.proteinG) +
        (fat * ExchangeDefinitions.fat.proteinG);
    return sum.toDouble();
  }

  double get totalCarbs {
    final sum = (milkSkim * ExchangeDefinitions.milkSkim.carbsG) +
        (milkLowFat * ExchangeDefinitions.milkLowFat.carbsG) +
        (milkWhole * ExchangeDefinitions.milkWhole.carbsG) +
        (vegetables * ExchangeDefinitions.vegetables.carbsG) +
        (fruit * ExchangeDefinitions.fruit.carbsG) +
        (starch * ExchangeDefinitions.starch.carbsG) +
        (otherCarbs * ExchangeDefinitions.starch.carbsG) +
        (meatVeryLean * ExchangeDefinitions.meatVeryLean.carbsG) +
        (meatLean * ExchangeDefinitions.meatLean.carbsG) +
        (meatMediumFat * ExchangeDefinitions.meatMediumFat.carbsG) +
        (meatHighFat * ExchangeDefinitions.meatHighFat.carbsG) +
        (fat * ExchangeDefinitions.fat.carbsG);
    return sum.toDouble();
  }

  double get totalFat {
    final sum = (milkSkim * ExchangeDefinitions.milkSkim.fatG) +
        (milkLowFat * ExchangeDefinitions.milkLowFat.fatG) +
        (milkWhole * ExchangeDefinitions.milkWhole.fatG) +
        (vegetables * ExchangeDefinitions.vegetables.fatG) +
        (fruit * ExchangeDefinitions.fruit.fatG) +
        (starch * ExchangeDefinitions.starch.fatG) +
        (otherCarbs * ExchangeDefinitions.starch.fatG) +
        (meatVeryLean * ExchangeDefinitions.meatVeryLean.fatG) +
        (meatLean * ExchangeDefinitions.meatLean.fatG) +
        (meatMediumFat * ExchangeDefinitions.meatMediumFat.fatG) +
        (meatHighFat * ExchangeDefinitions.meatHighFat.fatG) +
        (fat * ExchangeDefinitions.fat.fatG);
    return sum.toDouble();
  }

  double get totalCalories {
    final sum = (milkSkim * ExchangeDefinitions.milkSkim.calories) +
        (milkLowFat * ExchangeDefinitions.milkLowFat.calories) +
        (milkWhole * ExchangeDefinitions.milkWhole.calories) +
        (vegetables * ExchangeDefinitions.vegetables.calories) +
        (fruit * ExchangeDefinitions.fruit.calories) +
        (starch * ExchangeDefinitions.starch.calories) +
        (otherCarbs * ExchangeDefinitions.starch.calories) +
        (meatVeryLean * ExchangeDefinitions.meatVeryLean.calories) +
        (meatLean * ExchangeDefinitions.meatLean.calories) +
        (meatMediumFat * ExchangeDefinitions.meatMediumFat.calories) +
        (meatHighFat * ExchangeDefinitions.meatHighFat.calories) +
        (fat * ExchangeDefinitions.fat.calories);
    return sum.toDouble();
  }

  /// Fat grams per serving (from ExchangeDefinitions)
  static double fatPerServing(String key) {
    final d = definition(key);
    return d?.fatG.toDouble() ?? 0;
  }

  /// Carbs, protein, fat, calories per serving. otherCarbs uses starch-like values.
  static ExchangeServingDefinition? definition(String key) {
    switch (key) {
      case 'milkSkim':
        return ExchangeDefinitions.milkSkim;
      case 'milkLowFat':
        return ExchangeDefinitions.milkLowFat;
      case 'milkWhole':
        return ExchangeDefinitions.milkWhole;
      case 'vegetables':
        return ExchangeDefinitions.vegetables;
      case 'fruit':
        return ExchangeDefinitions.fruit;
      case 'starch':
        return ExchangeDefinitions.starch;
      case 'otherCarbs':
        return ExchangeDefinitions.starch; // same as starch for display
      case 'meatVeryLean':
        return ExchangeDefinitions.meatVeryLean;
      case 'meatLean':
        return ExchangeDefinitions.meatLean;
      case 'meatMediumFat':
        return ExchangeDefinitions.meatMediumFat;
      case 'meatHighFat':
        return ExchangeDefinitions.meatHighFat;
      case 'fat':
        return ExchangeDefinitions.fat;
      default:
        return null;
    }
  }

  /// Convert from DailyExchangePlan (single milk/meat type) to PortionCategoriesPlan
  static PortionCategoriesPlan fromDailyExchange(DailyExchangePlan plan) {
    final p = PortionCategoriesPlan(
      vegetables: plan.vegetables,
      fruit: plan.fruit,
      fat: plan.fat,
    );
    switch (plan.milkType) {
      case MilkType.skim:
        p.milkSkim = plan.milk;
        break;
      case MilkType.lowFat:
        p.milkLowFat = plan.milk;
        break;
      case MilkType.whole:
        p.milkWhole = plan.milk;
        break;
    }
    switch (plan.meatType) {
      case MeatType.veryLean:
        p.meatVeryLean = plan.meat;
        break;
      case MeatType.lean:
        p.meatLean = plan.meat;
        break;
      case MeatType.mediumFat:
        p.meatMediumFat = plan.meat;
        break;
      case MeatType.highFat:
        p.meatHighFat = plan.meat;
        break;
    }
    p.starch = plan.starch;
    p.otherCarbs = 0;
    return p;
  }

  /// Convert to DailyExchangePlan (uses first non-zero milk/meat for type)
  DailyExchangePlan toDailyExchange() {
    MilkType milkType = MilkType.lowFat;
    if (milkSkim > 0) milkType = MilkType.skim;
    else if (milkLowFat > 0) milkType = MilkType.lowFat;
    else if (milkWhole > 0) milkType = MilkType.whole;

    MeatType meatType = MeatType.lean;
    if (meatVeryLean > 0) meatType = MeatType.veryLean;
    else if (meatLean > 0) meatType = MeatType.lean;
    else if (meatMediumFat > 0) meatType = MeatType.mediumFat;
    else if (meatHighFat > 0) meatType = MeatType.highFat;

    final milk = totalMilk;
    final meat = totalMeat;
    final starchTotal = starch + otherCarbs;

    return DailyExchangePlan(
      starch: starchTotal,
      fruit: fruit,
      vegetables: vegetables,
      milk: milk,
      meat: meat,
      fat: fat,
      milkType: milkType,
      meatType: meatType,
    );
  }

  Map<String, double> toGroupMap() => {
        'milkSkim': milkSkim,
        'milkLowFat': milkLowFat,
        'milkWhole': milkWhole,
        'vegetables': vegetables,
        'fruit': fruit,
        'starch': starch,
        'otherCarbs': otherCarbs,
        'meatVeryLean': meatVeryLean,
        'meatLean': meatLean,
        'meatMediumFat': meatMediumFat,
        'meatHighFat': meatHighFat,
        'fat': fat,
      };

  static const List<String> categoryKeys = [
    'milkSkim',
    'milkLowFat',
    'milkWhole',
    'vegetables',
    'fruit',
    'starch',
    'otherCarbs',
    'meatVeryLean',
    'meatLean',
    'meatMediumFat',
    'meatHighFat',
    'fat',
  ];
}
