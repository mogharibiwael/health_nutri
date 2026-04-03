$ErrorActionPreference = 'Stop'
$sourceDir = (Get-Location).Path
$tempDir = "$env:TEMP\health_system_app_build"

Write-Host "Cleaning up previous temp directory..."
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction Ignore
}

Write-Host "Copying project to $tempDir (this avoids the Unicode path bug)..."
New-Item -ItemType Directory -Path $tempDir | Out-Null

robocopy "$sourceDir" "$tempDir" /E /XD ".git" ".dart_tool" "build" ".idea" "android\.gradle" "android\app\build" > $null

Set-Location $tempDir

Write-Host "Running flutter clean..."
flutter clean

Write-Host "Building APK..."
flutter build apk --target-platform android-arm64 --release

$apkSource = "$tempDir\build\app\outputs\flutter-apk\app-release.apk"
$apkDestDir = "$sourceDir\build\app\outputs\flutter-apk"

if (Test-Path $apkSource) {
    Write-Host "Build succeeded! Copying APK back to project directory..."
    if (-not (Test-Path $apkDestDir)) {
        New-Item -ItemType Directory -Path $apkDestDir -Force | Out-Null
    }
    Copy-Item $apkSource "$apkDestDir\app-release.apk" -Force
    Write-Host "APK successfully placed at: $apkDestDir\app-release.apk"
} else {
    Write-Host "APK build failed."
    exit 1
}
