# AI Agent Rules - Mass Todo App

You are an expert Flutter developer helping with the development of the "Mass Todo" application.

## Project Overview
Mass Todo is an offline-first todo application built with Flutter. It focuses on performance, clean UI, and robust local data persistence.

## Tech Stack
- **Framework**: Flutter
- **State Management**: Riverpod (`flutter_riverpod`)
- **Database**: SQLite (`sqflite`)
- **Key Libraries**:
    - `path_provider` for file system access
    - `google_fonts` for typography
    - `uuid` for unique ID generation
    - `intl` for localization and date formatting

## Architecture & Directory Structure
The project follows a modular structure under `lib/`:
- `database/`: Database initialization and schema management (SQLite).
- `models/`: Data models and JSON serialization.
- `repositories/`: Data access layer, interfacing between the database and the rest of the app.
- `providers/`: Riverpod providers for state management and dependency injection.
- `ui/`: UI components, screens, and themes.

## Coding Rules & Best Practices

### 1. State Management (Riverpod)
- Prefer `ConsumerWidget` for stateless widgets and `ConsumerStatefulWidget` for stateful ones.
- Keep logic inside `StateNotifier` or `Notifier` classes within the `providers/` directory.
- Avoid passing `WidgetRef` deep into the widget tree; use providers instead.

### 2. UI & Theming
- Use `AppTheme` defined in `lib/ui/app_theme.dart` for consistent styling.
- Utilize `google_fonts` as configured in the theme.
- Ensure all UI components are responsive and follow Material Design principles.

### 3. Data Persistence
- Always use the `repositories/` layer for database operations.
- Ensure all database operations are asynchronous and handle errors gracefully.
- Follow the offline-first principle: UI should react to data changes in the local database.

### 4. General Dart/Flutter
- Use `const` constructors whenever possible for performance.
- Follow the official [Dart Style Guide](https://dart.dev/guides/language/analysis-options).
- Keep widgets small and focused on a single responsibility.

## Development Workflow
- When adding a new feature:
    1. Define the model in `models/`.
    2. Add necessary database migrations/queries in `database/`.
    3. Implement data access in `repositories/`.
    4. Create Riverpod providers in `providers/`.
    5. Build the UI in `ui/`.
