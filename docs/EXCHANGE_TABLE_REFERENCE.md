# Exchange Table Reference – Constant Values for Diet

This document maps the **standard nutritional values per serving** (from the official food exchange table) to the constants used in the Nutri Guide app. These values are **fixed** for diet calculations.

**Source:** جدول 1 – كميات العناصر الغذائية الكبرى (بالغرام) والطاقة (كيلوسعر) في البديل الواحد من كل قائمة  
*(Table 1 – Quantities of major nutrients (grams) and energy (kcal) per one serving from each list)*

---

## Caloric Density (Reference)

| Macronutrient | kcal per gram |
|---------------|---------------|
| Carbohydrates | 4 |
| Protein       | 4 |
| Fat           | 9 |

---

## Exchange Table – Per Serving

### Carbohydrates Group (مجموعة الكربوهيدرات)

| Category | Carbs (g) | Protein (g) | Fat (g) | Calories (kcal) | App Constant |
|----------|-----------|-------------|---------|-----------------|--------------|
| **Starches** (النشويات) | 15 | 3 | 0–1 | 80 | `ExchangeDefinitions.starch` |
| **Fruits** (الفواكه) | 15 | 0 | 0 | 60 | `ExchangeDefinitions.fruit` |
| **Other Carbohydrates** (الكربوهيدرات الأخرى) | 15 | variable | variable | variable | Treated like starch/fruit |
| **Non-starchy Vegetables** (الخضروات غير النشوية) | 5 | 2 | 0 | 25 | `ExchangeDefinitions.vegetables` |

### Milk (الحليب)

| Category | Carbs (g) | Protein (g) | Fat (g) | Calories (kcal) | App Constant |
|----------|-----------|-------------|---------|-----------------|--------------|
| **Skim / Low-fat** (خالي / قليل الدسم) | 12 | 8 | 3 | 90 | `ExchangeDefinitions.milkSkim` |
| **Reduced-fat** (مخفض الدسم) | 12 | 8 | 5 | 120 | `ExchangeDefinitions.milkLowFat` |
| **Whole** (كامل الدسم) | 12 | 8 | 8 | 150 | `ExchangeDefinitions.milkWhole` |

### Meat and Alternatives (مجموعة اللحوم وبدائلها)

| Category | Carbs (g) | Protein (g) | Fat (g) | Calories (kcal) | App Constant |
|----------|-----------|-------------|---------|-----------------|--------------|
| **Very Low-fat** (قليلة الدهون جداً) | 0 | 7 | 0–1 | 35 | `ExchangeDefinitions.meatVeryLean` |
| **Low-fat** (قليلة الدهون) | 0 | 7 | 3 | 55 | `ExchangeDefinitions.meatLean` |
| **Medium-fat** (متوسطة الدهون) | 0 | 7 | 5 | 75 | `ExchangeDefinitions.meatMediumFat` |
| **High-fat** (عالية الدهون) | 0 | 7 | 8 | 100 | `ExchangeDefinitions.meatHighFat` |

### Fats Group (مجموعة الدهون)

| Category | Carbs (g) | Protein (g) | Fat (g) | Calories (kcal) | App Constant |
|----------|-----------|-------------|---------|-----------------|--------------|
| **Fats** (الدهون) | 0 | 0 | 5 | 45 | `ExchangeDefinitions.fat` |

---

## App Implementation

The constants are defined in **`lib/feature/diet/model/exchange_model.dart`** in the `ExchangeDefinitions` class:

```dart
// Example – Starch
static const starch = ExchangeServingDefinition(
  carbsG: 15,
  proteinG: 3,
  fatG: 1,      // 0–1 range, using 1
  calories: 80,
);

// Example – Meat (7g protein per serving)
static const meatVeryLean = ExchangeServingDefinition(
  carbsG: 0,
  proteinG: 7,
  fatG: 1,      // 0–1 range
  calories: 35,
);
```

---

## Usage in Diet Creation

1. **Exchange calculator** – Converts target macros (carbs, protein, fat grams) into daily serving counts using these constants.
2. **Portion categories** – The "Fats (g)" column in the portion table uses `fatG` from each definition.
3. **Meal macros** – When building the diet payload, each meal’s carbs, protein, fat, and calories are computed as:  
   `servings × (carbsG, proteinG, fatG, calories)` per group.

---

## Notes

- **0–1 ranges:** For starch fat and very-lean meat fat, the table specifies 0–1 g. The app uses 1 g for calculations.
- **Other carbohydrates:** The table lists variable values; the app treats them similarly to starch (15g carbs) for simplicity.
- **Vegetables:** The table shows 25 kcal for non-starchy vegetables; the app uses 5g carbs, 2g protein, 0g fat (≈25 kcal).
