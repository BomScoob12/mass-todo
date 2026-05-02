# Technical Decisions

- **Offline-First with SQLite:** Chosen to ensure high performance and reliability without internet dependency. `sqflite` is the standard for complex local data handling in Flutter.
- **Riverpod for State Management:** Selected for its robust compile-time safety, seamless async handling, and strict separation of logic compared to standard Provider or Bloc for this scale.
- **Modern Notifier Pattern:** Refactored state logic to use Riverpod 3.x Notifier patterns, resolving type-bound mismatches and ensuring stable UI rebuilds.
- **Material 3 Design System:** Embraced Flutter's latest Material 3 components (`surfaceContainerHighest`, `withValues`) for a consistent, modern, and accessible premium UI.
- **Repository Pattern:** Implemented to decouple Riverpod state logic from direct SQLite queries, making the app easier to maintain and test if the data source changes in the future.
- **Typedefs for Relationships:** Used lightweight Dart records (`typedef`) instead of heavy relationship classes (e.g., `TaskWithCategory`) to improve code efficiency and maintainability.
