# Diet Creation Guide – Nutri Guide App

This document describes what is required to create a diet plan for a patient in the Nutri Guide app.

---

## Overview

Creating a diet plan is a **4-step wizard** that only **doctors** can use. The flow is:

1. **Diet Periods** – Define meal times (breakfast, lunch, dinner, snacks)
2. **Diet Targets** – Set calorie and macro targets (carbs, protein, fat)
3. **Diet Distribution** – Distribute daily servings across meals
4. **Create Diet** – Review and submit the plan to the API

---

## Prerequisites

### 1. Patient Profile

The patient must have these fields filled:

| Field | Required | Description |
|-------|----------|-------------|
| **Weight** | Yes | In kg |
| **Height** | Yes | In cm |
| **Birthdate** | Yes | For age calculation |
| **Gender** | Yes | Male/Female (for BMR) |
| **Physical Activity** | Optional | Activity multiplier (default 1.3) |

### 2. Macro Percentages (Patient Details)

Before creating a diet, the doctor should set macro percentages in **Patient Details** → **Protein, Fat, and Carbohydrate Ratio**:

- **Carbs:** 50–65% (default 55%)
- **Protein:** 15–25% (default 20%)
- **Fat:** 25–35% (default 25%)
- **Sum must equal 100%**

These percentages are converted to grams using **Total Calories** (BMR × activity) and saved to the patient. The diet creation wizard uses these values.

---

## Step 1: Diet Periods

**Route:** `/diet-periods`  
**Purpose:** Define when each meal/snack occurs.

### Meal Types

- Breakfast
- Lunch
- Dinner
- First Snack
- Second Snack
- Third Snack
- Extra Snack (custom name)

### Data Structure

Each period has:

```json
{
  "meal_type": "breakfast",
  "hour": 8,
  "minute": 0,
  "custom_name": "Optional name for extra snacks"
}
```

### Arguments Passed

- `patient_id`
- `patient_name`
- `doctor_id`
- `patient` (PatientModel)

---

## Step 2: Diet Targets

**Route:** `/diet-targets`  
**Purpose:** Calculate calorie and macro targets from patient data.

### Inputs

- **Goal:** Maintain / Weight Loss / Weight Gain
- **Milk Type:** Skim / Low-fat / Whole
- **Meat Type:** Very lean / Lean / Medium-fat / High-fat

### Calculations

- **BMR** (Mifflin-St Jeor) from weight, height, age, gender
- **TDEE** = BMR × activity multiplier
- **Target Calories** based on goal
- **Macros** (carbs, protein, fat grams) from patient’s macro percentages or calculator defaults
- **Exchange Plan** (daily servings: starch, fruit, vegetables, milk, meat, fat)

### Output

- `targetsResult` (BMR, TDEE, target calories, macros)
- `exchangePlan` (daily servings per group)

---

## Step 3: Diet Distribution

**Route:** `/diet-distribution`  
**Purpose:** Split daily servings across meals.

### Data

- **Distribution:** `meal_key → { starch, fruit, vegetables, milk, meat, fat }`
- **Meal keys:** From periods (e.g. `breakfast`, `lunch`, `dinner`, `firstSnack`, …)

### Default Distribution

- Main meals (breakfast, lunch, dinner): ~25%, 35%, 40% of calories
- Snacks: ~15% total

### Validation

- Sum of servings per group across all meals must match the daily exchange plan totals.

---

## Step 4: Create Diet

**Route:** `/create-diet-for-patient`  
**Purpose:** Build and send the diet plan to the API.

### API Endpoint

```
POST /api/diet-plans
```

### Request Body

```json
{
  "patient_id": 74,
  "doctor_id": 14,
  "title": "Diet plan for Patient Name",
  "daily_calories": 2200,
  "duration_days": 30,
  "start_date": "2026-03-04",
  "end_date": "2026-04-03",
  "meal_periods": [
    { "meal_type": "breakfast", "hour": 8, "minute": 0 },
    { "meal_type": "lunch", "hour": 13, "minute": 0 },
    { "meal_type": "dinner", "hour": 19, "minute": 0 }
  ],
  "meals": [
    {
      "meal_type": "breakfast",
      "name": "breakfast",
      "serving_summary": "2 starch, 1 fruit, 1 milk",
      "carbs_g": 45,
      "protein_g": 15,
      "fat_g": 8,
      "calories": 320
    }
  ],
  "doctor_notes": ["Optional note 1", "Optional note 2"]
}
```

### Meal Object

Each meal has:

- `meal_type` – breakfast, lunch, dinner, firstSnack, secondSnack, thirdSnack, extraSnack
- `name` – Display name
- `serving_summary` – Text description of servings
- `carbs_g` – Carbohydrates in grams
- `protein_g` – Protein in grams
- `fat_g` – Fat in grams
- `calories` – Calories for this meal

---

## Navigation Flow

```
Patient Details → "إنشاء حمية للمريض"
    ↓
Diet Periods (set meal times)
    ↓
Diet Targets (goal, milk, meat, calculate targets)
    ↓
Diet Distribution (distribute servings)
    ↓
Create Diet (review, submit)
    ↓
API → Success
```

---

## Entry Points

1. **From Patient Details:** Tap **"إنشاء حمية للمريض"** (Create Diet for Patient).
2. **From Diet Page:** Doctor can create a diet plan for a patient (if supported in your flow).

---

## Summary Checklist

- [ ] Patient has weight, height, birthdate, gender
- [ ] Macro percentages set in Patient Details (carbs, protein, fat, sum = 100%)
- [ ] Meal periods defined (diet-periods)
- [ ] Targets calculated (diet-targets)
- [ ] Servings distributed across meals (diet-distribution)
- [ ] Diet plan created and submitted (create-diet-for-patient)

---

## API Links (from `api_link.dart`)

| Purpose | Endpoint |
|---------|----------|
| Create diet plan | `POST /api/diet-plans` |
| Get patient macros | `GET /api/doctor/patients/{id}/macros` |
| Update patient macros | `PUT /api/doctor/patients/{id}/macros` |
| Get my diet (patient) | `GET /api/my-diet` |
| Get diet meals | `GET /api/my-diet/meals` |
