# Similar App Reference – Diet Creation Flow

This document describes the diet creation flow from a similar app (reference images), to guide implementation in Nutri Guide.

---

## Overview

The similar app uses a **multi-step wizard** with granular control over food categories and portions. Key concepts:

1. **Main Categories** – Food groups (milk types, vegetables, fruits, starches, meats, fats)
2. **Portion Distribution** – Split totals into sub-categories (e.g. carbs → starch vs other carbs; protein → meat types by fat level)
3. **Meal Assignment** – Assign portions to meals (breakfast, lunch, dinner, snacks)
4. **Meal Planning** – Add specific food items per meal, then create the diet

---

## Screen 1: Main Categories & Number of Portions

**Title:** تحديد الحصص للوجبات (Determine portions for meals)

**Tabs:**
- الفئات الرئيسية (Main Categories)
- عدد الحصص (Number of Portions)
- الدهون (g) (Fats in grams)

**Table structure:**

| Main Category (الفئات الرئيسية) | Number of Servings (عدد الحصص) | Fats (g) (الدهون) |
|--------------------------------|-------------------------------|-------------------|
| حليب خالي الدسم (Skim milk)    | 0–3                           | 3.0               |
| حليب منخفض الدسم (Low-fat milk)| 0–3                           | 5.0               |
| حليب كامل الدسم (Whole milk)   | 0–6                           | 8.0               |
| الخضروات (Vegetables)          | 0                             | 0.0               |
| الفواكه (Fruits)               | 0–2                           | 0.0               |
| النشويات (Starches)            | 0–3                           | 1.0               |
| كربوهيدرات أخرى (Other carbs) | 0–2                           | 0.0               |
| اللحوم قليلة الدهون جداً (Very lean meats) | 0–2   | 1.0               |
| اللحوم قليلة الدهون (Lean meats)         | -     | -                 |
| اللحوم متوسطة الدهون (Medium-fat meats)  | -     | -                 |
| اللحوم عالية الدهون (High-fat meats)     | 0–6   | 8.0               |
| الدهون (Fats)                  | 0–23                          | 5.0               |

**Button:** حساب الناتج واظهار بقية البنات (Calculate result and show remaining data)

---

## Screen 2: Carbohydrate Distribution

**Title:** تقسيم حصص الكربوهيدرات (Carbohydrate portion distribution)

**Instruction:** Total carbohydrate portions = 10. Divide them into the following fields.

**Input fields:**
- حصص النشويات (Starch portions)
- حصص الكربوهيدرات الأخرى (Other carbohydrate portions)

**Constraint:** Starch + Other carbs = 10

**Button:** حفظ (Save)

---

## Screen 3: Protein Distribution

**Title:** تقسيم حصص اللحوم (البروتينات) (Dividing meat portions – Proteins)

**Instruction:** Total protein portions = 13. Divide them into the following fields.

**Input fields:**
- حصص اللحوم قليلة الدهون جداً (Very low-fat meat portions)
- حصص اللحوم قليلة الدهون (Low-fat meat portions)
- حصص اللحوم متوسطة الدهون (Medium-fat meat portions)
- حصص اللحوم عالية الدهون (High-fat meat portions)

**Constraint:** Sum of all four = 13

**Button:** حفظ (Save)

---

## Screen 4: Dividing Portions Over Periods

**Title:** تقسيم الحصص على الفترات (Dividing portions over periods/meals)

**Table:**
- Main Categories | Selected Portions (الحصص المختارة) | Meal column (وجبة / عدد)
- Same categories as Screen 1, with values distributed per meal

**Button:** الانتقال للخطوة الاخيرة (Go to the last step)

---

## Screen 5: Meal Planning (تحديد الوجبات)

**Title:** تحديد الوجبات (Determine meals)

**Per meal (e.g. Breakfast, Lunch):**
- Nutritional breakdown at top (e.g. Skim milk 3, Low-fat milk 3, Whole milk 6, Fruits 2, Starches 3, etc.)
- List of added food items (e.g. خبز توست ابيض - قطعة واحدة) with remove (x) option
- OR input field: ادخل الوجبات لـ وجبة الإفطار (Enter meals for Breakfast)

**Notes field:** ادخل ملاحظاتك ان وجدت (Enter your notes if any)

**General instruction:** اشرب ماء كل ثلاث ساعات (Drink water every 3 hours)

**Button:** انشاء الحمية (Create Diet)

---

## Key Differences vs Current Nutri Guide

| Feature              | Similar App                          | Current Nutri Guide                    |
|----------------------|--------------------------------------|----------------------------------------|
| Carb breakdown       | Starch vs Other carbs                | Single starch in exchange plan          |
| Protein breakdown    | 4 meat types by fat                  | Single meat type (veryLean/lean/etc.)   |
| Milk                 | 3 types with separate serving inputs | 1 type (skim/lowFat/whole)              |
| Portion input        | Per-category number inputs           | Distribution across meals only         |
| Meal items           | Add specific foods per meal          | Serving summary text only               |
| Flow                 | Categories → Distribute → Meals      | Periods → Targets → Distribution → Create |

---

## Implementation Ideas for Nutri Guide

1. **Carb distribution** – Add step to split total carbs into starch vs other carbs (e.g. breads vs fruits/sugars).
2. **Protein distribution** – Add step to split total protein into very lean / lean / medium-fat / high-fat meat portions.
3. **Milk distribution** – Allow mixing skim, low-fat, and whole milk servings (currently one type only).
4. **Meal items** – Optional: let doctor add specific food items per meal (e.g. "White toast - 1 piece") in addition to serving counts.
5. **Notes / instructions** – Support doctor_notes and general instructions (e.g. "Drink water every 3 hours").

---

## UI Notes (RTL, Overflow)

- Layout is RTL (Arabic).
- Table rows with long labels + numbers can cause `RenderFlex overflow` if not wrapped in `Expanded` or `Flexible`.
- Use `Wrap` or `SingleChildScrollView` for narrow screens.
- Consider `Table` or `DataTable` for the main categories table.
