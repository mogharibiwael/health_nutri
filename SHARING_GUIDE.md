# 📋 Guide for Developer (XSMARTTV Project)

Welcome! This is a Flutter-based health management system with two roles: **Patient** and **Doctor**.

## 🛠 Prerequisites

Before you start, make sure you have:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- [Visual Studio Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio).
- Dart and Flutter extensions installed in your IDE.

## 🚀 Getting Started

Follow these steps to run the project locally:

1.  **Clone/Extract the project**: Ensure all files are in a single directory.
2.  **Install dependencies**: Run the following command in the project root:
    ```bash
    flutter pub get
    ```
3.  **Run the application**:
    ```bash
    flutter run
    ```

## 🌐 API Configuration

The project is currently configured to connect to a **live remote backend**:
- **Base URL**: `https://health-system-backend-l7m5.onrender.com/api`
- **Location**: `lib/core/constant/api_link.dart`

If you want to run your own backend, you will need the Laravel API project and update the `baseUrl` in that file.

## 🏗 Project Architecture

- **Framework**: Flutter
- **State Management**: GetX
- **Structure**: Feature-based organization in the `lib/` directory.
    - `lib/core/`: Common services, constants, and utilities.
    - `lib/features/`: UI and logic for specific application features.

## 📦 Sharing Tip

Since `flutter clean` was executed, the project size is small. You can simply zip the folder and send it!

Happy coding! 🚀
