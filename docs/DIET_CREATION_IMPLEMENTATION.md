# Diet Creation – Implementation Guide

This document describes **how the diet creation flow works** in the Nutri Guide app and **what was implemented** to enable doctors to create diet plans for patients.

---

## Overview

Creating a diet plan is an **8-step wizard** that only **doctors** can use. The flow allows doctors to:

1. Set meal times
2. Calculate nutritional targets from patient data
3. Adjust portions per food category (milk types, starches, meats, etc.)
4. Split carbohydrates (starch vs other carbs)
5. Split proteins (4 meat types by fat content)
6. Distribute portions across meals
7. Add specific meal items (e.g. "White toast - 1 piece")
8. Submit the plan to the API

---

## Full Navigation Flow

```
Patient Details → "إنشاء حمية للمريض" (Create Diet for Patient)
    ↓
Step 1: Diet Periods (/diet-periods)
    ↓
Step 2: Diet Targets (/diet-targets)
    ↓
Step 3: Portion Categories (/diet-portion-categories)
    ↓
Step 4: Carb Distribution (/diet-portion-carb)
    ↓
Step 5: Protein Distribution (/diet-portion-protein)
    ↓
Step 6: Portion Distribution by Periods (/diet-distribution)
    ↓
Step 7: Determine Meals (/diet-determine-meals)
    ↓
Step 8: Create Diet (/create-diet-for-patient)
    ↓
POST /api/diet-plans → Success
```

---

## Prerequisites

### Patient Profile (must be filled in Patient Details)

| Field | Required | Description |
|-------|----------|-------------|
| Weight | Yes | In kg |
| Height | Yes | In cm |
| Birthdate | Yes | For age calculation |
| Gender | Yes | Male/Female (for BMR) |
| Physical Activity | Optional | Activity multiplier (default 1.3) |

### Macro Percentages (Patient Details)

- **Carbs:** 50–65% (default 55%)
- **Protein:** 15–25% (default 20%)
- **Fat:** 25–35% (default 25%)
- **Sum must equal 100%**

---

## Step-by-Step Implementation

### Step 1: Diet Periods

**Route:** `/diet-periods`  
**Controller:** `DietPeriodsController`  
**Page:** `DietPeriodsPage`

**Purpose:** Define when each meal/snack occurs.

**Meal types:** Breakfast, Lunch, Dinner, First Snack, Second Snack, Third Snack, Extra Snack

**Data passed to next step:** `periods` (list of `{meal_type, hour, minute, custom_name?}`)

---

### Step 2: Diet Targets

**Route:** `/diet-targets`  
**Controller:** `DietTargetsController`  
**Page:** `DietTargetsPage`

**Purpose:** Calculate calorie and macro targets from patient data.

**Inputs:**
- **Goal:** Maintain / Weight Loss / Weight Gain
- **Milk Type:** Skim / Low-fat / Whole
- **Meat Type:** Very lean / Lean / Medium-fat / High-fat

**Calculations:**
- BMR (Mifflin-St Jeor)
- TDEE = BMR × activity
- Target calories based on goal
- Exchange plan (daily servings: starch, fruit, vegetables, milk, meat, fat)

**Data passed:** `targets`, `exchange_plan`, `periods`, `patient`, `doctor_id`, `patient_id`, `patient_name`

---

### Step 3: Portion Categories

**Route:** `/diet-portion-categories`  
**Controller:** `PortionCategoriesController`  
**Page:** `PortionCategoriesPage`  
**Model:** `PortionCategoriesPlan` (in `portion_categories_model.dart`)

**Purpose:** Let the doctor adjust portions per food category. Shows a table with:
- **Main Categories** (column 1)
- **Number of Portions** (column 2) – editable via +/- buttons
- **Fats (g)** (column 3) – fat per serving (read-only)

**Categories:**
- Skim milk, Low-fat milk, Whole milk
- Vegetables, Fruits
- Starch, Other carbohydrates
- Very lean meat, Lean meat, Medium-fat meat, High-fat meat
- Fats

**Default values:** From `DailyExchangePlan` (converted via `PortionCategoriesPlan.fromDailyExchange()`)

**Data passed:** `portion_plan`, `exchange_plan`, `periods`, `targets`, `patient`, `doctor_id`, `patient_id`, `patient_name`

---

### Step 4: Carb Distribution

**Route:** `/diet-portion-carb`  
**Controller:** `PortionCarbController`  
**Page:** `PortionCarbPage`

**Purpose:** Split total carbohydrate portions into:
- **Starch portions** (e.g. breads, grains)
- **Other carbohydrate portions** (e.g. fruits, sugars)

**Instruction shown:** "Total carbohydrate portions resulting = X - Divide them among the following fields"

**Data passed:** Updates `portion_plan.starch` and `portion_plan.otherCarbs`, then passes to Protein Distribution

---

### Step 5: Protein Distribution

**Route:** `/diet-portion-protein`  
**Controller:** `PortionProteinController`  
**Page:** `PortionProteinPage`

**Purpose:** Split total protein portions into 4 meat types by fat content:
- Very low-fat meat portions
- Low-fat meat portions
- Medium-fat meat portions
- High-fat meat portions

**Instruction shown:** "Total protein portions resulting = X - Divide them among the following fields"

**Data passed:** Updates `portion_plan` meat fields, then passes to Distribution

---

### Step 6: Portion Distribution by Periods

**Route:** `/diet-distribution`  
**Controller:** `DietDistributionController`  
**Page:** `DietDistributionPage`

**Purpose:** Distribute daily servings across meal periods (breakfast, lunch, dinner, snacks).

**Table:** Main Categories | Total Daily | Per-meal columns (breakfast, lunch, dinner, etc.)

**Logic:** Default ratios (e.g. breakfast 25%, lunch 35%, dinner 40%, snacks 15%) with balancing to match totals.

**Data passed:** `distribution` (mealKey → {starch, fruit, vegetables, milk, meat, fat}), `portion_plan`, `exchange_plan`, `periods`, `targets`, etc.

---

### Step 7: Determine Meals

**Route:** `/diet-determine-meals`  
**Controller:** `DetermineMealsController`  
**Page:** `DetermineMealsPage`

**Purpose:** Let the doctor add **specific meal items** per meal (e.g. "خبز توست ابيض - قطعة واحدة" / "White toast - 1 piece").

**Per meal:**
- Shows dietary breakdown (e.g. "Starch: 3, Fruit: 2, Milk: 3")
- Input field to add meal items
- Chips for added items (removable with ×)

**Notes field:** "Enter your notes if any" (e.g. "Drink water every 3 hours")

**Data passed:** `meal_items` (Map<mealKey, List<String>>), `doctor_notes`, `distribution`, `exchange_plan`, `periods`, etc.

---

### Step 8: Create Diet

**Route:** `/create-diet-for-patient`  
**Controller:** `DietController`  
**Page:** `CreateDietForPatientPage`

**Purpose:** Build the API payload and submit.

**Payload builder:** `DietPayloadBuilder.buildMeals()` – converts distribution + exchange plan + meal items into `meals` array.

**API:** `POST /api/diet-plans`

**Request body includes:**
- `patient_id`, `doctor_id`, `title`
- `daily_calories`, `duration_days`, `start_date`, `end_date`
- `meal_periods` – meal times
- `meals` – each with `meal_type`, `name`, `serving_summary`, `carbs_g`, `protein_g`, `fat_g`, `calories`
- `doctor_notes` – optional notes from Determine Meals step

---

## Key Files

| Purpose | File |
|--------|------|
| Portion model | `lib/feature/diet/model/portion_categories_model.dart` |
| Portion categories controller | `lib/feature/diet/controller/portion_categories_controller.dart` |
| Carb distribution controller | `lib/feature/diet/controller/portion_carb_controller.dart` |
| Protein distribution controller | `lib/feature/diet/controller/portion_protein_controller.dart` |
| Determine meals controller | `lib/feature/diet/controller/determine_meals_controller.dart` |
| Portion categories page | `lib/feature/diet/view/portion_categories_page.dart` |
| Carb distribution page | `lib/feature/diet/view/portion_carb_page.dart` |
| Protein distribution page | `lib/feature/diet/view/portion_protein_page.dart` |
| Determine meals page | `lib/feature/diet/view/determine_meals_page.dart` |
| Payload builder | `lib/feature/diet/service/diet_payload_builder.dart` |
| Routes | `lib/core/routes/route.dart`, `lib/core/routes/app_route.dart` |
| Bindings | `lib/core/routes/binding.dart` |
| Localization | `lib/core/localization/en.dart`, `lib/core/localization/ar.dart` |

---

## Routes (AppRoute constants)

```dart
dietPeriods           = "/diet-periods"
dietTargets           = "/diet-targets"
dietPortionCategories = "/diet-portion-categories"
dietPortionCarb       = "/diet-portion-carb"
dietPortionProtein    = "/diet-portion-protein"
dietDistribution      = "/diet-distribution"
dietDetermineMeals     = "/diet-determine-meals"
createDietForPatient   = "/create-diet-for-patient"
```

---

## Doctor ID Fix (Backend Requirement)

The API expects `doctor_id` from the **doctors** table, not `user_id` from the **users** table.

**Implementation:**
- `MyServices.doctorId` – reads `user["doctor_id"]` or `user["doctor"]["id"]` from session
- If not in session, `GET /api/doctor/profile` is called to fetch the doctor record
- `patient_details_controller.openCreateDiet()` uses `myServices.doctorId` instead of `myServices.userId`

**Backend must either:**
1. Return `doctor_id` or `doctor.id` in the login response for doctors, or
2. Provide `GET /api/doctor/profile` to fetch the current doctor's record

---

## Summary Checklist

- [ ] Patient has weight, height, birthdate, gender
- [ ] Macro percentages set in Patient Details (sum = 100%)
- [ ] Meal periods defined (Step 1)
- [ ] Targets calculated (Step 2)
- [ ] Portions adjusted per category (Step 3)
- [ ] Carbs split into starch + other (Step 4)
- [ ] Proteins split into 4 meat types (Step 5)
- [ ] Servings distributed across meals (Step 6)
- [ ] Specific meal items added (Step 7)
- [ ] Diet plan created and submitted (Step 8)
