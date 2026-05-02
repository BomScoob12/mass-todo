# Known Issues

- **Background Sync:** The app is strictly offline-first. There is no cloud synchronization or remote backup mechanism implemented.
- **Platform Specifics:** Desktop build files (`windows`, `linux`) contain default Flutter boilerplate and TODOs that have not been customized, as the primary target is mobile.
- **Race Conditions:** While recent fixes addressed task completion state syncing, rapid successive operations in the task detail drawer might still require optimistic UI updates to completely prevent perceived lag or state overriding.
- **Testing Coverage:** Automated unit and widget tests are minimal and need expansion to cover edge cases in provider logic and database constraints.
