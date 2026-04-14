# Taskora | Clean Architecture To-Do App

Taskora is a premium, production-ready productivity application built with **Flutter**, following the strict principles of **Clean Architecture**.

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-3.29.x-blue)
![Architecture](https://img.shields.io/badge/Architecture-Clean--Layers-orange)

## ✨ Features

- **Premium UI & UX**: Sleek, responsive design using Google Fonts (Outfit) and custom theme support with an OLED-friendly Dark Mode.
- **Micro-Animations**: High-quality staggered animations using `flutter_animate` for a fluid feel.
- **Clean Architecture**: Perfectly separated into Domain, Data, and Presentation layers for maximum testability.
- **BLoC State Management**: Robust and predictable state handling.
- **Advanced Task Management**: 
  - Priority levels (Low, Medium, High) with color coding.
  - Categories (Work, Personal, Shopping, etc.) with custom icons.
  - Pinned tasks for quick access.
  - Date & Time scheduling with full editing support.
- **Smart Notifications**: Background reminders that persist even after device reboots using AlarmClock precision.
- **Productivity Tools**:
  - **Focus Mode**: Integrated deep work timer.
  - **Analytics**: Visual charts Tracking your progress and productivity score.
  - **Custom Profiles**: Personalized onboarding with name, age, gender, and profile picture.

## 🏗️ Technical Stack

- **Framework**: Flutter
- **Persistence**: SQLite (via `sqflite`)
- **State Management**: flutter_bloc
- **Notifications**: flutter_local_notifications & flutter_timezone
- **Animations**: flutter_animate
- **Charts**: fl_chart
- **Theming**: ValueNotifier-based Global Theme Controller
- **CI/CD**: GitHub Actions (Automated Analysis, Testing, and Build)

## 🚀 CI/CD Pipeline

The project includes a fully automated **GitHub Actions** workflow located in `.github/workflows/ci_cd.yml`.

Every push or pull request to the `main` or `develop` branches triggers:
1. **Static Analysis**: `flutter analyze` ensuring code quality.
2. **Testing**: Runs unit and widget tests.
3. **Automated Build**: 
   - Generates a **Debug APK** on every update.
   - Generates a **Release APK** (Obfuscated & Optimized) on pushes to `main`.
   - Uploads build artifacts for easy download.

## 🛠️ Getting Started

1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter run` to launch on your device/emulator.

**Note for Android Notifications**: On Android 12+, Taskora uses exact alarms for precision. Ensure you grant the necessary permissions if prompted.
