# Backend: Add Medical File Download Endpoint

Your Flutter app needs a way to download medical files. The app tries these URLs **in order** until one returns the file:

1. **Direct URL** – `{base}/uploads/medical-files/xxx.pdf` (files in Laravel `public/uploads/`)
2. **Storage URL** – `{base}/storage/uploads/medical-files/xxx.pdf` (after `php artisan storage:link`)
3. **API download** – `GET /api/medical-files/{id}/download` (with auth)
4. **API uploads path** – `{base}/api/uploads/medical-files/xxx.pdf`
5. **API storage path** – `{base}/api/storage/uploads/medical-files/xxx.pdf`

If **none** of these work, implement option A or B below and ensure the backend serves the file at one of these URLs (or returns a full `download_url` in the API response).

---

## Option A: Serve files from `public/uploads/` (simplest)

If files are stored in `public/uploads/medical-files/`, the app will request:

`https://your-domain.com/uploads/medical-files/1772822471_0000222200.pdf`

- Ensure your web server (e.g. Nginx, or Laravel’s `public/`) serves `public/uploads/` at `/uploads/`.
- On Render/Heroku, `public/` is usually served at the app root, so the URL above should work if the file exists in `public/uploads/medical-files/`.

---

## Option B: Add a download route (recommended if files are private)

If files are in `storage/app/public/` or you want to enforce auth, add a download endpoint.

## 1. Add Route (routes/api.php)

```php
Route::get('medical-files/{id}/download', [MedicalFileController::class, 'download'])
    ->middleware('auth:sanctum'); // or your auth middleware
```

## 2. Add Download Method to Controller

If you have a `MedicalFileController`:

```php
public function download($id)
{
    $file = MedicalFile::findOrFail($id);
    $path = storage_path('app/public/' . $file->file_path);
    
    if (!file_exists($path)) {
        $path = public_path($file->file_path); // try public folder
    }
    
    if (!file_exists($path)) {
        return response()->json(['message' => 'File not found'], 404);
    }
    
    return response()->download($path, $file->file_name, [
        'Content-Type' => 'application/pdf',
    ]);
}
```

## 3. If files are in `public/uploads/`

```php
public function download($id)
{
    $file = MedicalFile::findOrFail($id);
    $path = public_path($file->file_path);
    
    if (!file_exists($path)) {
        return response()->json(['message' => 'File not found'], 404);
    }
    
    return response()->download($path, $file->file_name);
}
```

## 4. File Path Reference

Your API returns: `file_path: "uploads/medical-files/1772822471_0000222200.pdf"`

- **If in storage/app/public/**: Full path = `storage_path('app/public/uploads/medical-files/xxx.pdf')`
- **If in public/**: Full path = `public_path('uploads/medical-files/xxx.pdf')`

Choose based on where your Laravel app stores uploaded files.
