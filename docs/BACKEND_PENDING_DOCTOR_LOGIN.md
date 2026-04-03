# Allow doctors to login before admin approval

The app sends **`allow_pending_doctor: true`** in the login request body so that the backend can return a token for doctors whose account is not yet approved.

## Current behavior (backend)

When a doctor with `application_status != "approved"` logs in, the backend returns for example:

- **403** or **401** with body: `{"message": "حسابك بانتظار الموافقة من قبل الإدارة"}`  
- **No token** is returned, so the app cannot create a session.

## Required change (backend)

When the login request includes **`allow_pending_doctor: true`** and the user is a **doctor** with **pending** (or similar) status:

1. Return **200** (success).
2. Return the **same token** you would issue for an approved doctor (or a token with the same permissions you want pending doctors to have).
3. Return the **user** object (including nested `doctor` with `application_status`, etc.).

Example response:

```json
{
  "token": "eyJ0eXAiOiJKV1Q...",
  "user": {
    "id": 80,
    "name": "...",
    "email": "...",
    "type": "doctor",
    "doctor": {
      "id": 16,
      "application_status": "pending",
      "is_verified": false,
      ...
    }
  }
}
```

The app will:

- Create a session and let the doctor in.
- Show the **shared home** (ads, step counter, BMI, spiritual nutrition, etc.).
- **Not** show “My clinic” until `application_status === "approved"` (or `is_verified === true`).

So the backend only needs to **allow** login (return token + user) when `allow_pending_doctor === true` and the user is a pending doctor; the app already handles the rest.
