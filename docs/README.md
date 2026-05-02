# Mass Todo

## Overview
Mass Todo is a high-performance, offline-first task management application built with Flutter. It helps users manage their daily tasks, deadlines, and categories seamlessly with a premium, linear-inspired design aesthetic.

## Key Features
- **Unified Dashboard:** Bento grid stats, weekly progress tracking, and next-up task spotlight.
- **Overdue Task Alerts:** Collapsible section highlighting urgent tasks that missed their deadlines.
- **Intelligent Task Management:** Offline-first persistence, dynamic custom categories, and smart filtering (completed/pending).
- **Category Management:** Dedicated settings for custom organizational hierarchy.
- **Centralized Notifications:** Global snackbar system for consistent user feedback.

## Tech Stack
- **Framework:** Flutter (Dart 3.x)
- **State Management:** Flutter Riverpod 3.x
- **Database:** SQLite (sqflite)
- **UI System:** Material 3
- **Fonts:** Google Fonts (Outfit / Inter)

## How to Run
1. Clone the repository.
2. Navigate to the app directory: `cd app`
3. Fetch dependencies: `flutter pub get`
4. Run the app: `flutter run`
5. Build release APK: `flutter build apk --release`

## Entry Points
- `lib/main.dart`: App initialization and root widget.
- `lib/ui/main_navigation.dart`: Core navigation routing.
- `lib/ui/dashboard_screen.dart`: Main dashboard view.

## Screenshots
- Dashboard: `[docs/images/dashboard.png]`
- Overdue Section: `[docs/images/dashboard-overdue-expand.png]`
- Categories: `[docs/images/mytask-with-category-group.png]`
- Settings: `[docs/images/setting.png]`
