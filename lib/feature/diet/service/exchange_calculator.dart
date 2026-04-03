import '../model/exchange_model.dart';

/// Converts macro targets (carbs, protein, fat grams) to daily exchange servings.
class ExchangeCalculator {
  /// Default: vegetables 3, fruit 2, milk 1-2
  static DailyExchangePlan fromMacros({
    required double targetCarbsG,
    required double targetProteinG,
    required double targetFatG,
    int vegetablesMin = 3,
    int fruitMin = 2,
    int milkServings = 1,
    MilkType milkType = MilkType.lowFat,
    MeatType meatType = MeatType.lean,
  }) {
    final milk = ExchangeDefinitions.getMilk(milkType);
    final meat = ExchangeDefinitions.getMeat(meatType);
    final veg = ExchangeDefinitions.vegetables;
    final fru = ExchangeDefinitions.fruit;
    final fatDef = ExchangeDefinitions.fat;

    double vegS = vegetablesMin.toDouble();
    double fruS = fruitMin.toDouble();
    double milkS = milkServings.toDouble().clamp(1.0, 2.0);

    double carbsUsed = (vegS * veg.carbsG + fruS * fru.carbsG + milkS * milk.carbsG);
    double proteinUsed = (vegS * veg.proteinG + fruS * fru.proteinG + milkS * milk.proteinG);
    double fatUsed = (vegS * veg.fatG + fruS * fru.fatG + milkS * milk.fatG);

    double proteinRemaining = (targetProteinG - proteinUsed).clamp(0.0, 999.0);
    double meatS = (proteinRemaining / meat.proteinG);

    proteinUsed += (meatS * meat.proteinG);
    fatUsed += (meatS * meat.fatG);

    double fatRemaining = (targetFatG - fatUsed).clamp(0.0, 999.0);
    double fatS = (fatRemaining / fatDef.fatG);

    fatUsed += (fatS * fatDef.fatG);

    double carbsRemaining = (targetCarbsG - carbsUsed).clamp(0.0, 999.0);
    double starchS = (carbsRemaining / ExchangeDefinitions.starch.carbsG);

    return DailyExchangePlan(
      starch: starchS,
      fruit: fruS,
      vegetables: vegS,
      milk: milkS,
      meat: meatS,
      fat: fatS,
      milkType: milkType,
      meatType: meatType,
    );
  }
}
