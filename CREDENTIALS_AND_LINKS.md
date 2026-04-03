# Credentials & Links

## Web app (reference)
- **URL:** https://healthsystemfront-nhmq.onrender.com/
- **Title:** مشروع التغذية العلاجية (Therapeutic Nutrition Project)

## Default login (admin)
- **Email:** `admin@example.com`
- **Password:** `password`

*(If the web app shows different defaults, e.g. admin@gmail.com / password, use the one that works on your backend.)*

## API base (this app)
- **Base URL:** configured in `lib/core/constant/api_link.dart`  
  (e.g. `https://health-system-backend-l7m5.onrender.com/api`)

## Developer API guide
- **Local file:** `developer_api_guide.md` (see Downloads or project docs)
- **Endpoints added in app:**
  - `POST /api/calculations/nutrition` – BMI, BMR, TEF, TDEE, macros (body: weight, height, age, gender, activity_level, goal, save)
  - `GET /api/references/nutrition-manuals` – nutrition references for doctors
  - `POST /api/diet-plans` – with optional `doctor_notes` (array) and `meals` (array)
  - `POST /api/meals` – meal with serving, carbo, protin, fat
