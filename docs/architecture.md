# Architecture

## Project Structure
- `/lib/database/`: SQLite database initialization and configuration (`database_helper.dart`).
- `/lib/models/`: Data models and typed records (`task_model.dart`).
- `/lib/providers/`: Riverpod state providers and async notifiers (`task_provider.dart`, `category_provider.dart`).
- `/lib/repositories/`: Data access layer bridging state and SQLite (`task_repository.dart`, `category_repository.dart`).
- `/lib/ui/`: UI components, screens, and widgets organized by feature (e.g., dashboard, my_tasks, widgets).

## Architecture Pattern
The project uses a **Feature-based layered architecture**:
- **UI Layer:** Flutter widgets listening to Riverpod providers for reactive updates.
- **State Layer:** Riverpod Notifiers acting as the single source of truth for UI state.
- **Repository Layer:** Abstracted data access, handling CRUD operations.
- **Data Layer:** SQLite local database.

## State Management
**Flutter Riverpod 3.x** is used for state management. It utilizes modern `Notifier` and `AsyncNotifier` patterns to handle reactive UI updates, asynchronous database queries, and data caching efficiently.

## Data Flow
UI (Widget) ➔ Triggers Action on Riverpod Provider ➔ Provider calls Repository ➔ Repository executes SQLite Query ➔ Database returns Data ➔ Provider updates State ➔ UI reacts and rebuilds.
