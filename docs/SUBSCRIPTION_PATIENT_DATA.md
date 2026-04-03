# Subscription & Profile Data in Patient Details

Patient info comes from two sources:
1. **Subscription form** (when subscribing): `full_name`, `phone`, `date_of_birth`, `height_cm`, `weight_kg`, `gender`, `activity`
2. **Patient profile** (edit after subscribe): PUT `/patients/profile` with `height`, `current_weight`, `date_of_birth`, `gender`, `physical_activity`, `medical_history`

This data must appear in the doctor's patient details for BMI, BMR, and calorie calculations.

## Backend Requirements

1. **Store subscription data** when creating a subscription (POST /api/subscriptions):
   - Save `height_cm`, `weight_kg`, `date_of_birth`, `gender`, `activity` to the patient record or subscription record.

2. **Store profile updates** when patient edits (PUT /api/patients/profile):
   - Save `height`, `current_weight`, `date_of_birth`, `gender`, `physical_activity`, `medical_history` to the patient's profile.
   - This data must be returned when the doctor fetches patients.

3. **Return in patient APIs** using one of these formats:

   **Option A – Flat fields in patient object:**
   ```json
   {
     "id": 1,
     "fullname": "John",
     "height_cm": 170,
     "weight_kg": 75,
     "date_of_birth": "1990-01-01",
     "gender": "male",
     "activity": "light",
     "phone_number": "..."
   }
   ```

   **Option B – Nested subscription:**
   ```json
   {
     "id": 1,
     "fullname": "John",
     "subscription": {
       "height_cm": 170,
       "weight_kg": 75,
       "date_of_birth": "1990-01-01",
       "gender": "male",
       "activity": "light"
     }
   }
   ```

   **Option C – Standard patient fields:**
   ```json
   {
     "id": 1,
     "fullname": "John",
     "height": 170,
     "weight": 75,
     "birthdate": "1990-01-01",
     "gender": "male",
     "physical_activity": "1.375"
   }
   ```

   **Option D – Profile from PUT /patients/profile (current_weight):**
   ```json
   {
     "id": 1,
     "fullname": "John",
     "profile": {
       "height": 170,
       "current_weight": 75,
       "date_of_birth": "1990-01-01",
       "gender": "male",
       "physical_activity": "active"
     }
   }
   ```

3. **Activity values** (subscription sends string, app uses multiplier):
   - `sedentary` → 1.2
   - `light` → 1.375
   - `moderate` → 1.55
   - `active` → 1.725

4. **GET /api/doctor/patients/{id}** (optional): If the list endpoint does not include full subscription data, the app will call this endpoint to fetch a single patient with subscription info.

## App Behavior

- `PatientModel.fromJson` supports all field variants above.
- When opening patient details, if height/weight/birthdate/activity are missing, the app calls `GET /doctor/patients/{id}` to load them.
- Calculations (BMI, BMR, TDEE) use this data when available.
