# nutri_guide

A nutrition-clinic Flutter application with two roles: **Patient** and **Doctor** (same codebase, role-based UI). Uses GetX architecture.

## Diet Calculation System

### Overview

The diet creation flow is automated: the doctor selects a patient, sets meal times, and the system auto-calculates targets and exchange servings. The patient sees their diet plan and meals without manual calculation.

### Calculation Flow

1. **BMR** (Mifflin-St Jeor):
   - Male: `BMR = 10×kg + 6.25×cm - 5×age + 5`
   - Female: `BMR = 10×kg + 6.25×cm - 5×age - 161`

2. **TDEE** = BMR × activity factor:
   - sedentary: 1.2 | light: 1.375 | moderate: 1.55 | active: 1.725 | very_active: 1.9

3. **Target calories** by goal:
   - maintain: TDEE
   - weight_loss: TDEE - 500 (clamped to safe minimum)
   - weight_gain: TDEE + 300–500

4. **Macros** (default 50% carbs, 25% protein, 25% fat):
   - carbs_g = (calories×0.50)/4
   - protein_g = (calories×0.25)/4
   - fat_g = (calories×0.25)/9

5. **Exchange servings** (Food Exchange model):
   - Vegetables: min 3/day | Fruit: 2/day | Milk: 1–2/day
   - Meat from protein target | Fat from fat target | Starch from remaining carbs

6. **Meal distribution** (default):
   - Breakfast 25% | Lunch 35% | Dinner 25% | Snacks 15%

### Adjusting Presets

- **Activity factors**: `lib/core/service/diet_calculator_service.dart` → `activityFactors`
- **Macro ratios**: `DietCalculatorService.macroTargets()` (default 50/25/25)
- **Exchange defaults**: `lib/feature/diet/service/exchange_calculator.dart` → `vegetablesMin`, `fruitMin`, `milkServings`
- **Distribution ratios**: `lib/feature/diet/controller/diet_distribution_controller.dart` → `_getCalorieRatios()`

### Key Files

- `lib/core/service/diet_calculator_service.dart` – BMR, TDEE, macros
- `lib/feature/diet/model/exchange_model.dart` – Exchange groups and serving definitions
- `lib/feature/diet/service/exchange_calculator.dart` – Macro → exchange servings
- `lib/feature/diet/service/diet_payload_builder.dart` – Build API payload (meals, meal_periods)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
