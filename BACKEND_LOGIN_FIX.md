# Allow Login Without Email Verification (Backend Fix)

Your Laravel backend returns `{"message":"Your email address is not verified."}` and blocks login. To allow unverified users to log in, update your backend as follows.

## Option 1: Login Controller

Find your login controller (e.g. `app/Http/Controllers/Auth/LoginController.php` or `AuthController.php`) and **remove or comment out** the email verification check:

```php
// REMOVE or comment out this block:
if (!$user->hasVerifiedEmail()) {
    return response()->json(['message' => 'Your email address is not verified.'], 403);
}
```

The login should proceed to create the token and return it for all valid credentials.

## Option 2: If using a custom middleware

If you have middleware that checks `hasVerifiedEmail()` before issuing tokens, either:
- Remove that middleware from the login route, or
- Modify it to allow unverified users for the login flow

## Option 3: User model (if blocking at model level)

If your `User` model implements `MustVerifyEmail` and your auth system enforces it globally, you may need to remove the interface:

```php
// Change from:
class User extends Authenticatable implements MustVerifyEmail

// To:
class User extends Authenticatable
```

**Note:** Removing `MustVerifyEmail` means Laravel won't enforce verification anywhere. If you only want to allow login but still require verification for some features, use Option 1 instead.

---

After the backend change, the login response should include:
```json
{
  "token": "your-sanctum-token-here",
  "user": { ... }
}
```

The Flutter app is already set up to accept this and log the user in.
