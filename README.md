# TaskFlow | Clean Architecture To-Do App

TaskFlow is a premium, production-ready productivity application built with **Flutter**, following the strict principles of **Clean Architecture**.

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-3.27.0-blue)
![Architecture](https://img.shields.io/badge/Architecture-Clean--Layers-orange)

## ✨ Features

- **Modern UI**: Sleek, responsive design using Google Fonts (Poppins) and custom themes.
- **Clean Architecture**: Separated into Domain, Data, and Presentation layers for maximum testability and maintainability.
- **BLoC State Management**: Robust and predictable state handling.
- **Advanced Task Management**: 
  - Priority levels (Low, Medium, High)
  - Categories (Work, Personal, Shopping, etc.)
  - Pinned tasks for quick access.
  - Date & Time scheduling.
- **Smart Notifications**: Background reminders that persist even after device reboots.
- **Productivity Tools**:
  - **Focus Mode**: Integrated Pomodoro timer.
  - **Analytics**: Visual charts for productivity tracking.
  - **Calendar**: Integrated view for date-based planning.

## 🏗️ Technical Stack

- **Framework**: Flutter
- **Persistence**: SQLite (via `sqflite`)
- **State Management**: flutter_bloc
- **Notifications**: flutter_local_notifications & flutter_timezone
- **Animations**: flutter_animate
- **Charts**: fl_chart
- **CI/CD**: GitHub Actions (Automated Check, Test, and Build)

## 🚀 CI/CD Pipeline

The project includes a fully automated **GitHub Actions** workflow located in `.github/workflows/flutter_ci.yml`.

Every push or pull request to the `main` or `dev` branches triggers:
1. **Linting**: Ensures code consistency.
2. **Formatting**: Automatic validation of code structure.
3. **Testing**: Runs all unit and widget tests.
4. **Build**: Generates a release APK and uploads it as a build artifact.

## 🛠️ Getting Started

1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter run` to launch on your device/emulator.

**Note for Android Notifications**: On Android 12+, ensure you grant the "Alarms & Reminders" permission for scheduled tasks to function correctly.
