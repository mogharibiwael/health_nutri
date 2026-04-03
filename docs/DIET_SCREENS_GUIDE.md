# Diet Screens – Client Guide

This document explains how the diet creation and viewing screens work in the Nutri Guide app, for both **Doctors** and **Patients**.

---

## Overview

The app has two roles:

- **Doctor**: Creates diet plans for patients using an automated wizard.
- **Patient**: Views their assigned diet plan and meals (no manual calculation).

The system uses the patient’s profile (age, weight, height, activity level) to calculate daily calories and food exchanges automatically.

---

## Doctor Flow – Creating a Diet Plan

The doctor goes through **4 steps** to create a diet for a patient.

### Step 1: Patient Details → Create Diet Plan

- Doctor opens a patient from the patients list.
- On the patient details screen, they tap **"Create Diet Plan"**.
- This starts the diet creation wizard.

### Step 2: Diet Periods (Meal Times)

**Screen:** Diet Periods  
**Purpose:** Set meal and snack times for the patient.

- Default meals: Breakfast, Lunch, Dinner, First Snack, Second Snack, Third Snack.
- Doctor can add extra snacks.
- For each meal, the doctor sets the time (e.g. Breakfast 08:00, Lunch 13:00).
- Doctor taps **"Next Step"** to continue.

### Step 3: Diet Targets (Auto-Calculated)

**Screen:** Diet Targets  
**Purpose:** Show calculated nutrition targets and let the doctor adjust them.

The system uses the patient’s profile to calculate:

| Item | Description |
|------|-------------|
| **BMR** | Basal Metabolic Rate (calories at rest) |
| **TDEE** | Total Daily Energy Expenditure (calories per day) |
| **Target Calories** | Based on goal (maintain / lose / gain weight) |
| **Macros** | Carbs, protein, fat in grams |

The doctor can:

- Choose **goal**: Maintain weight, Weight loss, Weight gain.
- Choose **milk type**: Skim, Low-fat, Whole.
- Choose **meat type**: Very lean, Lean, Medium-fat, High-fat.
- See **daily exchange servings** (starch, fruit, vegetables, milk, meat, fat).

Doctor taps **"Next Step"** to continue.

### Step 4: Meal Distribution

**Screen:** Meal Distribution  
**Purpose:** Distribute daily servings across meals.

- A table shows each food group (starch, fruit, vegetables, milk, meat, fat).
- For each group, servings are split across meals (breakfast, lunch, dinner, snacks).
- Default split: Breakfast 25%, Lunch 35%, Dinner 25%, Snacks 15%.
- Doctor taps **"Next Step"** to finalize.

### Step 5: Create & Save

**Screen:** Create Diet for Patient  
**Purpose:** Review and save the diet plan.

- Shows patient name, meal times, target calories, and macros.
- Doctor can edit title, dates, and duration.
- Doctor taps **"Create"** to save.
- The diet is sent to the backend and the patient can see it.

---

## Patient Flow – Viewing the Diet

### My Diet Screen

- Patient opens **"My Diet"** from the home menu.
- If a diet is assigned, they see:
  - Diet title
  - Doctor name
  - Daily calories
  - Duration and dates
  - Notes (if any)
- Patient taps **"View Meals"** to see the meal plan.

### Diet Meals Screen

- Shows meals grouped by day.
- For each meal:
  - Meal type (Breakfast, Lunch, Dinner, Snack)
  - Meal name
  - Serving summary (e.g. "2 starch, 1 fruit, 2 vegetables")
  - Calories and macros (C, P, F)

---

## How the Calculations Work

### 1. BMR (Basal Metabolic Rate)

Formula (Mifflin-St Jeor):

- **Male:** BMR = 10×weight(kg) + 6.25×height(cm) − 5×age + 5  
- **Female:** BMR = 10×weight(kg) + 6.25×height(cm) − 5×age − 161  

### 2. TDEE (Total Daily Energy Expenditure)

TDEE = BMR × activity factor

| Activity Level | Factor |
|----------------|--------|
| Sedentary | 1.2 |
| Light | 1.375 |
| Moderate | 1.55 |
| Active | 1.725 |
| Very Active | 1.9 |

### 3. Target Calories

| Goal | Calculation |
|------|-------------|
| Maintain | TDEE |
| Weight Loss | TDEE − 500 (approx.) |
| Weight Gain | TDEE + 300 to 500 |

### 4. Macros (Default 50% Carbs, 25% Protein, 25% Fat)

- Carbs (g) = (calories × 0.50) ÷ 4  
- Protein (g) = (calories × 0.25) ÷ 4  
- Fat (g) = (calories × 0.25) ÷ 9  

### 5. Food Exchange Servings

Each food group has fixed servings per day:

| Group | Default Servings | Example |
|-------|------------------|--------|
| Vegetables | Min 3 | Non-starchy vegetables |
| Fruit | 2 | Fruits |
| Milk | 1–2 | Skim / Low-fat / Whole |
| Meat | From protein target | Very lean / Lean / Medium / High fat |
| Starch | From remaining carbs | Bread, rice, grains |
| Fat | From fat target | Oils, nuts |

### 6. Meal Distribution

Daily servings are split across meals:

- Breakfast: 25%
- Lunch: 35%
- Dinner: 25%
- Snacks: 15% (shared among all snacks)

---

## Screen Summary

| Screen | Purpose | Who Uses It |
|--------|---------|-------------|
| Patient Details | Patient info and “Create Diet Plan” button | Doctor |
| Diet Periods | Set meal times | Doctor |
| Diet Targets | View and adjust calculated targets | Doctor |
| Diet Distribution | Distribute servings across meals | Doctor |
| Create Diet for Patient | Final review and save | Doctor |
| My Diet | View current diet plan | Patient |
| Diet Meals | View meals and servings | Patient |

---

## Data Flow

```
Patient Profile (age, weight, height, activity)
    ↓
Diet Calculator Service (BMR, TDEE, macros)
    ↓
Exchange Calculator (daily servings per group)
    ↓
Diet Distribution (servings per meal)
    ↓
Diet Payload Builder (meals + meal_periods)
    ↓
API POST /diet-plans (save to backend)
    ↓
Patient sees diet in "My Diet" and "Diet Meals"
```

---

## Technical Files (for Reference)

| File | Purpose |
|------|---------|
| `diet_calculator_service.dart` | BMR, TDEE, target calories, macros |
| `exchange_model.dart` | Food exchange groups and serving definitions |
| `exchange_calculator.dart` | Converts macros to daily exchange servings |
| `diet_payload_builder.dart` | Builds API payload (meals, meal_periods) |
| `diet_periods_page.dart` | Meal times screen |
| `diet_targets_page.dart` | Targets and exchange screen |
| `diet_distribution_page.dart` | Meal distribution screen |
| `create_diet_for_patient_page.dart` | Final create screen |
| `diet_page.dart` | Patient "My Diet" screen |
| `diet_meals_page.dart` | Patient "Diet Meals" screen |

---

## Requirements

- Patient must have a complete profile (date of birth, height, weight, physical activity).
- Doctor must be logged in and have access to the patient.
- Patient must be subscribed to the doctor for the doctor to create a diet for them.

---

*Last updated: February 2026*
