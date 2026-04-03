# Diet Creation Flow – Every Screen Explained

This document describes **every screen** the doctor sees **after pressing "Create Diet"** (or "Create Diet Plan") on a patient’s details screen: what each screen does and why it was implemented that way.

---

## Flow Overview

After the doctor taps **Create Diet** on the patient details screen, the app opens a **wizard** of several steps. Data is passed forward via route arguments so the final API payload can be built from one place.

```
Patient Details  →  Diet Periods  →  Diet Targets  →  Portion Categories  →  Diet Distribution  →  Determine Meals  →  Create Diet for Patient  →  API + back to Patient Details
```

---

## 1. Diet Periods (Meal Times)

**Route:** `dietPeriods`  
**File:** `lib/feature/diet/view/diet_periods_page.dart`  
**Controller:** `DietPeriodsController`

### What it does

- Shows the **patient name** at the top (from the patient you selected).
- Lists **meals and snacks** with a **time** for each: Breakfast, Lunch, Dinner, First Snack, Second Snack, Third Snack.
- Each row has a **time picker**: tap the time to change it (e.g. Breakfast 08:00, Lunch 13:00).
- Doctor can **add extra snacks** ("Add Snack"); extra snacks can have a **custom name** and can be **removed**.
- **Next Step** sends: `patient_id`, `patient_name`, `doctor_id`, `patient`, and **periods** (each period = `meal_type`, `hour`, `minute`, optional `custom_name`) to the next screen.

### Why it’s there

- The plan is built **per meal period**. The backend and the patient’s view need to know **when** each meal/snack is (e.g. for reminders or ordering).
- Starting with periods ensures the rest of the wizard (targets, distribution, final create) always has a fixed list of meals (breakfast, lunch, dinner, snacks) to attach servings and optional meal items to.

---

## 2. Diet Targets (Calculated Goals)

**Route:** `dietTargets`  
**File:** `lib/feature/diet/view/diet_targets_page.dart`  
**Controller:** `DietTargetsController`

### What it does

- Shows **patient name** and a warning if profile is incomplete (e.g. missing height/weight).
- Uses the **patient’s profile** (weight, height, age, gender, physical activity) to compute and display:
  - **BMR** (Basal Metabolic Rate)
  - **TDEE** (Total Daily Energy Expenditure)
  - **Target calories**
  - **Macros**: carbs, protein, fat (grams)
- Lets the doctor choose:
  - **Goal:** Maintain / Weight loss / Weight gain (recalculates targets).
  - **Milk type:** Skim / Low-fat / Whole (affects exchange plan).
  - **Meat type:** Very lean / Lean / Medium-fat / High-fat (affects exchange plan).
- Shows **daily exchange servings** (starch, fruit, vegetables, milk, meat, fat) from the internal exchange calculator.
- **Next Step** goes directly to **Portion Categories** with: `patient_id`, `patient_name`, `doctor_id`, `patient`, `periods`, `targets` (BMR, TDEE, calories, macros), `exchange_plan`, `exchange_plan_json`.

### Why it’s there

- Targets must be **consistent with the patient’s data** (BMR/TDEE from height, weight, age, activity).
- Goal and milk/meat type drive **how many servings** of each exchange group the patient gets. Doing this here keeps the rest of the flow (portion categories, distribution, create) aligned with one calculated plan.

---

## 3. Portion Categories (Main Categories)

**Route:** `dietPortionCategories`  
**File:** `lib/feature/diet/view/portion_categories_page.dart`  
**Controller:** `PortionCategoriesController`

### What it does

- Shows a **table** of **main categories** and **number of portions** per day:
  - Milk: Skim, Low-fat, Whole  
  - Vegetables, Fruit, Starch, Other carbs  
  - Meat: Very lean, Lean, Medium-fat, High-fat  
  - Fat  
- Each row has **+ / −** to adjust the portion count; a third column shows **fat per serving** (for reference).
- Values are **pre-filled** from the exchange plan coming from Diet Targets.
- **Proceed to next step** sends the same context plus **portion_plan** (and derived `exchange_plan`) to **Diet Distribution**.

### Why it’s there

- Diet Targets only output **totals** (e.g. total starch, total meat). Here the doctor can **refine** how those totals are split (e.g. more skim milk vs whole milk, or starch vs other carbs). That gives a single, detailed **portion plan** used later for distribution and for building the API payload.

---

## 4. Diet Distribution (Servings per Meal)

**Route:** `dietDistribution`  
**File:** `lib/feature/diet/view/diet_distribution_page.dart`  
**Controller:** `DietDistributionController`

### What it does

- Shows a **table**:
  - **Rows:** Food groups (starch, fruit, vegetables, milk, meat, fat).
  - **Columns:** "Group", "Total daily", then **one column per meal/snack** (from the periods you set in step 1).
- Doctor **distributes** the daily servings among those meals (e.g. 1 starch at breakfast, 2 at lunch).
- **Next** sends the same context plus `meal_distribution` (a list of meal/item servings) to **Determine Meals**.

### Why it’s there

- The "Portion Plan" was just daily totals. This step maps those totals to **specific times of day**. This is the core of "what to eat when".

---

## 5. Determine Meals (Menu Items & Notes)

**Route:** `dietDetermineMeals`  
**File:** `lib/feature/diet/view/determine_meals_page.dart`  
**Controller:** `DetermineMealsController`

### What it does

- For each meal (Breakfast, Lunch, etc.), the doctor can type **optional meal item text** (e.g. "Oatmeal with nuts").
- Includes a **global notes** field for the entire diet plan.
- **Next** sends the final context plus `meal_items` and `notes` to the final summary screen.

### Why it’s there

- Portions like "1 starch, 1 milk" are technical. This step allows the doctor to provide **actual meal examples** and **patient-specific advice**, making the plan human-readable and useful.

---

## 6. Create Diet for Patient (Final Review & Submission)

**Route:** `createDietForPatient`  
**File:** `lib/feature/diet/view/create_diet_for_patient_page.dart`  
**Controller:** `DietController`

### What it does

- Shows a **final summary** of the whole plan.
- Let’s the doctor set:
  - **Plan title** (e.g. "Initial Weight Loss Plan")
  - **Start Date** and **End Date**
- **Create** button:
   - Builds the full JSON payload using `DietPayloadBuilder`.
   - Sends **API POST request** to `/doctor/diets/create-diet-for-patient`.
   - **Back** to Patient Details on success.

### Why it’s there

- Final confirmation. It handles the actual **database insertion** through the backend, linking all the wizard data (periods, portions, distribution, meals) into one persistent record for that patient.

---

## Summary Table

| Screen Name | Core Purpose |
| :--- | :--- |
| **Diet Periods** | List of meal/snack times (and names). Needed so every later step and the API know *which* meals exist. |
| **Diet Targets** | BMR, TDEE, target calories, macros, goal, milk/meat type → daily exchange plan. |
| **Portion Categories** | Fine-tune daily portions per sub-category (milk types, meat types, starch vs other carbs, etc.). |
| **Diet Distribution** | Turn daily portions into per-meal servings (table). Feeds the payload builder. |
| **Determine Meals** | Optional meal items and doctor notes. |
| **Create Diet for Patient** | Review, set title/dates, and send one API request to create the diet plan. |

---

## Files Legend

| Screen Name | View File (lib/feature/diet/view/) | Controller File (lib/feature/diet/controller/) |
| :--- | :--- | :--- |
| Diet Periods | `diet_periods_page.dart` | `DietPeriodsController` |
| Diet Targets | `diet_targets_page.dart` | `DietTargetsController` |
| Portion Categories | `portion_categories_page.dart` | `PortionCategoriesController` |
| Diet Distribution | `diet_distribution_page.dart` | `DietDistributionController` |
| Determine Meals | `determine_meals_page.dart` | `DetermineMealsController` |
| Create Diet for Patient | `create_diet_for_patient_page.dart` | `DietController` |
