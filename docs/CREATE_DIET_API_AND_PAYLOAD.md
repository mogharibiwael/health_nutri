# Create Diet API and Payload

This document describes the **create diet plan** API used by the app and the exact **payload** sent.

---

## API endpoint

| Method | URL | Auth |
|--------|-----|------|
| **POST** | `{baseUrl}/diet-plans` | Bearer token (doctor) |

**Example:**  
`POST https://health-system-backend-l7m5.onrender.com/api/diet-plans`

Defined in code: `ApiLinks.dietPlans` → `"$baseUrl/diet-plans"`  
Used in: `lib/feature/diet/data/diet_data.dart` → `createDiet(body: body, token: token)` and `createDietPlan(...)`.

---

## Payload (request body)

The body is **JSON**. All fields below are sent when creating a plan from the wizard.

### Top-level fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `patient_id` | int | Yes | Patient ID |
| `doctor_id` | int | Yes | Doctor ID (from doctors table) |
| `title` | string | Yes | Plan title (e.g. "Diet plan for [Patient Name]") |
| `daily_calories` | int | Yes | Target daily calories |
| `duration_days` | int | Yes | Plan duration in days |
| `start_date` | string | Yes | Start date (e.g. "2026-03-07") |
| `end_date` | string | Yes | End date (e.g. "2026-06-07") |
| `meals` | array | No | List of meal objects (see below) |
| `meal_periods` | array | No | List of meal period objects (see below) |
| `doctor_notes` | array of strings | No | Optional notes from the doctor |

### `meals` array

Each element is an object:

| Field | Type | Description |
|-------|------|-------------|
| `meal_type` | string | e.g. `"breakfast"`, `"lunch"`, `"dinner"`, `"extraSnack"` |
| `name` | string | Display name (e.g. `"breakfast"`, `"Snack 1"`, or custom name) |
| `serving_summary` | string | Text summary, e.g. `"2 starch, 1 fruit, 1 vegetables. Oatmeal; Banana"` |
| `carbs_g` | int | Carbs in grams for this meal |
| `protein_g` | int | Protein in grams |
| `fat_g` | int | Fat in grams |
| `calories` | int | Calories for this meal |

Built by: `DietPayloadBuilder.buildMeals()` from distribution, periods, exchange plan, and optional meal items.

### `meal_periods` array

Each element is an object:

| Field | Type | Description |
|-------|------|-------------|
| `meal_type` | string | e.g. `"breakfast"`, `"lunch"`, `"dinner"`, `"extraSnack"` |
| `hour` | int | Hour (0–23) |
| `minute` | int | Minute (0–59) |
| `custom_name` | string | Optional; for extra snacks |

Built by: `DietPayloadBuilder.buildMealPeriods(periods)` from the wizard’s periods (meal times).

---

## Example payload

```json
{
  "patient_id": 5,
  "doctor_id": 2,
  "title": "Diet plan for Ahmed",
  "daily_calories": 2000,
  "duration_days": 90,
  "start_date": "2026-03-07",
  "end_date": "2026-06-07",
  "meals": [
    {
      "meal_type": "breakfast",
      "name": "breakfast",
      "serving_summary": "2 starch, 1 fruit, 1 milk. Oatmeal; Apple",
      "carbs_g": 42,
      "protein_g": 11,
      "fat_g": 3,
      "calories": 255
    },
    {
      "meal_type": "lunch",
      "name": "lunch",
      "serving_summary": "3 starch, 2 vegetables, 2 meat, 1 fat",
      "carbs_g": 55,
      "protein_g": 24,
      "fat_g": 16,
      "calories": 460
    },
    {
      "meal_type": "dinner",
      "name": "dinner",
      "serving_summary": "2 starch, 2 vegetables, 2 meat",
      "carbs_g": 40,
      "protein_g": 22,
      "fat_g": 10,
      "calories": 358
    }
  ],
  "meal_periods": [
    { "meal_type": "breakfast", "hour": 8, "minute": 0 },
    { "meal_type": "lunch", "hour": 13, "minute": 0 },
    { "meal_type": "dinner", "hour": 19, "minute": 30 },
    { "meal_type": "extraSnack", "hour": 10, "minute": 0, "custom_name": "Morning snack" }
  ],
  "doctor_notes": ["Avoid dairy after 6 PM", "Drink 2L water daily"]
}
```

---

## Where it is built in the app

1. **Screen:** `lib/feature/diet/view/create_diet_for_patient_page.dart`  
   On “Create”, it reads form values and wizard args (distribution, periods, exchange plan, meal items, doctor notes), then calls the controller.

2. **Payload building:**  
   - `DietPayloadBuilder.buildMeals(...)` → `meals`  
   - `DietPayloadBuilder.buildMealPeriods(periods)` → `meal_periods`

3. **Data layer:** `lib/feature/diet/data/diet_data.dart`  
   - `createDietPlan(...)` builds the `body` map and calls `createDiet(body: body, token: token)`.  
   - `createDiet(...)` sends `POST` to `ApiLinks.diets` with that body and the auth token.

4. **Controller:** `lib/feature/diet/controller/diet_controller.dart`  
   - `createDietPlan(...)` calls `dietData.createDietPlan(...)` and handles success/errors.

---

## Postman request

Use this to test the create diet API in Postman.

### Request

| Setting | Value |
|---------|-------|
| **Method** | POST |
| **URL** | `https://health-system-backend-l7m5.onrender.com/api/diet-plans` |

### Headers

| Key | Value |
|-----|-------|
| `Content-Type` | `application/json` |
| `Accept` | `application/json` |
| `Authorization` | `Bearer YOUR_DOCTOR_TOKEN` |

Replace `YOUR_DOCTOR_TOKEN` with the doctor's auth token (from login).

### Body (raw JSON)

Use **Body** → **raw** → **JSON** and paste:

```json
{
  "patient_id": 81,
  "doctor_id": 16,
  "title": "Diet plan for waaa",
  "daily_calories": 1684,
  "duration_days": 30,
  "start_date": "2026-03-09",
  "end_date": "2026-04-08",
  "meals": [
    {
      "meal_type": "breakfast",
      "name": "breakfast",
      "serving_summary": "2 starch, 1 fruit, 1 milk",
      "carbs_g": 42,
      "protein_g": 11,
      "fat_g": 3,
      "calories": 255
    },
    {
      "meal_type": "lunch",
      "name": "lunch",
      "serving_summary": "3 starch, 2 vegetables, 2 meat, 1 fat",
      "carbs_g": 55,
      "protein_g": 24,
      "fat_g": 16,
      "calories": 460
    },
    {
      "meal_type": "dinner",
      "name": "dinner",
      "serving_summary": "2 starch, 2 vegetables, 2 meat",
      "carbs_g": 40,
      "protein_g": 22,
      "fat_g": 10,
      "calories": 358
    }
  ],
  "meal_periods": [
    { "meal_type": "breakfast", "hour": 8, "minute": 0 },
    { "meal_type": "lunch", "hour": 13, "minute": 0 },
    { "meal_type": "dinner", "hour": 19, "minute": 30 }
  ],
  "doctor_notes": ["Drink 2L water daily"]
}
```

**Replace values:**
- `patient_id`: 81 (use the patient id from `GET /api/patients/81` response)
- `doctor_id`: 16 (use the doctor id from your login/session)
- `title`: Your plan title
- `daily_calories`, `duration_days`, `start_date`, `end_date`: Adjust as needed
- `meals`, `meal_periods`, `doctor_notes`: Optional; can be omitted or simplified

### Minimal body (required fields only)

```json
{
  "patient_id": 81,
  "doctor_id": 16,
  "title": "Diet plan for waaa",
  "daily_calories": 1684,
  "duration_days": 30,
  "start_date": "2026-03-09",
  "end_date": "2026-04-08"
}
```

### Getting the token

1. Log in as a doctor: `POST /api/login` with `email`, `password`, `type: "doctor"`.
2. Copy the `token` from the response.
3. Use it in the `Authorization` header: `Bearer <token>`.

---

## Backend expectations

Your backend should:

- Accept **POST** on `/api/diet-plans`.
- Expect **JSON** body with the fields above.
- Use **Bearer token** for authorization (doctor).
- Return on success: e.g. `200` or `201` with a JSON response (e.g. `{"message": "...", "data": { ... } }`).
- Return on validation error: e.g. `422` with `{"errors": { "field": ["message"] } }`; the app shows the first error message.

---

## Troubleshooting: "The selected patient id is invalid"

If the backend returns this error when creating a diet:

1. **Patient from GET /api/patients/{id}** – The app fetches patient details from `GET /api/patients/{id}` (e.g. `/api/patients/81`). The response `data` includes `id`, `user_id`, `name`, `date_of_birth`, `current_weight`, `height`, `medical_history`, `physical_activity`. The `id` from this response is saved and sent as `patient_id` when creating the diet.

2. **Check the debug output** – The app prints:
   - `[CreateDiet] patient.id=X patient.userId=Y -> sending patient_id=Z`
   - `[DietData] POST diet-plans body: patient_id=X, doctor_id=Y`
   - Use these values to confirm what is being sent.

2. **Confirm what the backend expects** – The backend may expect:
   - `patient_id` = `patients.id` (patient record) – this is what the app sends by default.
   - `patient_id` = `users.id` (patient’s user account) – if so, the backend team should either change their validation or document this.

3. **Verify the doctor’s patients API** – `GET /api/doctor/patients` must return items with `id` and `user_id`. The app uses `id` as `patient_id`. If the backend uses a different structure (e.g. pivot ids), the API response needs to include the correct patient identifier.

4. **Backend validation** – Ensure the backend’s `patient_id` validation matches the ID type you send (e.g. `exists:patients,id` vs `exists:users,id`).

5. **Try user_id** – If the backend expects the patient’s user account id, set `_useUserIdForPatientId = true` in `create_diet_for_patient_page.dart` (line ~18). This sends `patient.userId` instead of `patient.id`.

---

*Last updated: March 2026*
