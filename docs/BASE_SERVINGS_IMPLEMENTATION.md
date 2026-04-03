# Base Servings Step – Implementation Summary

This document describes what was implemented and fixed for the **Base Servings** step in the diet creation flow.

---

## Flow Position

```
Patient Details  →  Diet Periods  →  Diet Targets  →  Base Servings  →  Portion Categories  →  …  →  Create Diet for Patient
```

Base Servings sits **after Diet Targets** and **before Portion Categories**. Targets (BMR/TDEE, calories, macros) come from Diet Targets; Base Servings lets the doctor define how much carbs, protein, and fat come from **Fruits**, **Vegetables**, and **Milk** only.

---

## What Was Implemented

### 1. Manual Macro Input (Replacing Automatic Exchange Calculation)

**Before:** The app calculated macro contribution automatically from fixed exchange values × number of servings (e.g. fruit = 15 g carbs per serving).

**After:** For each of the three base groups (Fruits, Vegetables, Milk), the doctor can:
- Set **number of servings** (+/− stepper)
- Manually enter **Carbohydrates (g)**
- Manually enter **Protein (g)**
- Manually enter **Fat (g)**

Values are **editable** and **independent** of the exchange table. On first load, they are **pre-filled** from the exchange plan (e.g. fruit servings × 15 g carbs) so the starting state is valid.

---

### 2. Calculation Logic

- **Per-group contribution**  
  For each group, the contribution is the entered carbs, protein, and fat.  
  **Calories** for that group = `(carbs × 4) + (protein × 4) + (fat × 9)` kcal.

- **Total contribution**  
  - Total Carbs = fruitCarbs + vegetableCarbs + milkCarbs  
  - Total Protein = fruitProtein + vegetableProtein + milkProtein  
  - Total Fat = fruitFat + vegetableFat + milkFat  
  - Total Calories = (totalCarbs × 4) + (totalProtein × 4) + (totalFat × 9)

- **Remaining requirements**  
  - remainingCarbs = targetCarbs − totalCarbs  
  - remainingProtein = targetProtein − totalProtein  
  - remainingFat = targetFat − totalFat  
  - remainingCalories = targetCalories − totalCalories  

  Remaining values are **clamped to ≥ 0** (never shown as negative).

---

### 3. UI Structure

The Base Servings screen includes:

1. **Three group cards** (Fruits, Vegetables, Milk). Each card has:
   - Group title
   - **Servings** (+/−)
   - **Carbohydrates (g)** – numeric text field
   - **Protein (g)** – numeric text field
   - **Fat (g)** – numeric text field

2. **Read-only contribution sections**
   - Fruits contribution (carbs, protein, fat, calories)
   - Vegetables contribution
   - Milk contribution
   - **Total contribution**
   - **Remaining requirements** (vs patient targets)

3. **Warning banner**  
   Shown when base group totals **exceed** patient targets (e.g. "Base group totals exceed patient targets. Remaining values may be zero. You can still proceed.").

4. **Next Step** button  
   Navigates to Portion Categories with the same arguments as before (`base_servings`, `base_contribution`, `remaining_macros`, etc.).

---

### 4. Validation and Behavior

- **Numeric only:** Macro fields use a numeric keyboard and `FilteringTextInputFormatter` so only digits and one decimal are allowed.
- **Non-negative:** All macro values are clamped to ≥ 0 (negative or invalid input becomes 0).
- **Auto-recalculation:** Totals and remaining values update whenever any serving or macro value changes (`GetBuilder` + `update()`).
- **Exceeding targets:** If base contribution exceeds patient targets, remaining is shown as 0 and the warning banner is shown; the doctor can still proceed to the next step.

---

### 5. Files Touched

| File | Changes |
|------|--------|
| `lib/feature/diet/controller/base_servings_controller.dart` | Manual macro fields (fruit/vegetable/milk carbs, protein, fat); pre-fill from exchange; `caloriesFromMacros()`; contribution/remaining getters; `hasExceedsTargetsWarning`; **fix:** restored missing `if (patientId == null \|\| doctorId == null)` in `goToPortionCategories()`. |
| `lib/feature/diet/view/base_servings_page.dart` | Three `_GroupCard` widgets with servings + macro inputs; `_MacroInputField` (stateful, syncs when not focused); contribution/total/remaining sections; warning banner. |
| `lib/core/localization/en.dart` | `baseServingsDesc`, `baseServingsExceedsTargetWarning`. |
| `lib/core/localization/ar.dart` | Same keys in Arabic. |

---

### 6. Controller Fix (Error Resolved)

**Problem:** In `goToPortionCategories()`, the first validation block was broken: the condition `if (patientId == null || doctorId == null)` was missing, so the method started with `Get.snackbar(...); return; }`, leaving invalid structure and a stray `}`.

**Fix:** Restored the full guard:

```dart
if (patientId == null || doctorId == null) {
  Get.snackbar("error".tr, "fillFields".tr);
  return;
}
if (exchangePlan == null || targets == null) {
  Get.snackbar("error".tr, "fillPatientProfile".tr);
  return;
}
// ... build args and navigate
```

Navigation to Portion Categories and the rest of the flow now work as intended.

---

## RTL / Arabic

- The screen uses `Directionality` and existing locale (e.g. `Get.locale`) so it remains RTL-friendly and works with Arabic translations.

---

*Last updated: March 2026*
