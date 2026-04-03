# Subscriptions API (for Chat button)

## GET /api/subscriptions

Returns the current user's (patient's) subscriptions. Used after login to show "Chat" instead of "Subscribe" for doctors the patient is already subscribed to.

**Headers:** `Authorization: Bearer {token}`

**Expected response (200):**
```json
{
  "data": [
    { "id": 1, "doctor_id": 16, "user_id": 81, ... },
    ...
  ]
}
```

The app extracts `doctor_id` from each item and caches them. If the backend uses a different structure (e.g. `subscriptions` key, or `doctorId`), the app handles `data`, `subscriptions`, and `doctor_id`/`doctorId`.

---

# Medical Tests API

## Endpoint

**Base URL:** `https://health-system-backend-l7m5.onrender.com/api`

### GET /api/medical-tests

List medical tests.

| Role   | Usage                                      | Query params              |
|--------|--------------------------------------------|---------------------------|
| Patient| Own tests                                  | `page` (optional)         |
| Doctor | Tests for a specific patient               | `page`, `user_id`         |

**Example requests:**
- Patient (own tests): `GET /api/medical-tests?page=1`
- Doctor (patient's tests): `GET /api/medical-tests?page=1&user_id=81`

**Headers:** `Authorization: Bearer {token}`

---

## Response (200 OK)

```json
{
    "current_page": 1,
    "data": [
        {
            "id": 1,
            "name": "تياي",
            "user_id": 81,
            "image": null,
            "created_at": "2026-03-09T20:25:43.000000Z",
            "updated_at": "2026-03-09T20:32:48.000000Z",
            "status": "pending",
            "user": {
                "id": 81,
                "name": "waaa",
                "email": "ww@gmail.com",
                "type": "user",
                "email_verified_at": null,
                "created_at": "2026-03-04T22:15:13.000000Z",
                "updated_at": "2026-03-04T22:15:13.000000Z",
                "phone": null,
                "role": null
            }
        }
    ],
    "first_page_url": "...",
    "from": 1,
    "last_page": 1,
    "last_page_url": "...",
    "links": [...],
    "next_page_url": null,
    "path": "...",
    "per_page": 10,
    "prev_page_url": null,
    "to": 3,
    "total": 3
}
```

### Data item fields

| Field       | Type   | Description                    |
|------------|--------|--------------------------------|
| id         | int    | Medical test ID                |
| name       | string | Test name                      |
| user_id    | int    | Patient user ID                |
| image      | string\|null | File path/URL for the test |
| created_at | string | ISO 8601 timestamp             |
| updated_at | string | ISO 8601 timestamp             |
| status     | string | e.g. "pending"                |
| user       | object | Patient info (id, name, email) |

---

## Download

**GET /api/medical-tests/{id}/download**

Returns the file bytes for the medical test.

**Headers:** `Authorization: Bearer {token}`

---

## Upload (from chat)

**POST /api/medical-tests** (multipart/form-data)

| Field     | Type   | Required | Description      |
|-----------|--------|----------|------------------|
| name      | string | yes      | Test name        |
| file      | file   | yes      | Uploaded file    |
| doctor_id | int    | yes      | Doctor ID        |
| user_id   | int    | yes      | Patient user ID  |
