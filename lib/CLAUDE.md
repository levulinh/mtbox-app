# Flutter App Architecture

## State Management: Riverpod
- Use `@riverpod` annotation for providers
- Providers live in `lib/providers/` (create this dir when first needed)
- UI reads state via `ref.watch()`; mutations via `ref.read().notifier`

## Navigation: go_router
- All routes defined in `lib/router.dart` (create when first needed)
- Use named routes

## Local Storage: Hive
- Models that need persistence go in `lib/models/` and extend `HiveObject`
- Adapters generated via `build_runner`

## Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Private members: `_leadingUnderscore`

## Folder Structure
- `lib/models/` — Dart data classes (Hive models)
- `lib/screens/` — Full-page widgets (one file per screen)
- `lib/widgets/` — Reusable UI components
- `lib/services/` — Business logic, data access
- `lib/providers/` — Riverpod providers (create when needed)

## Code Rules
- No business logic in widgets — delegate to services/providers
- Keep widgets small; extract to lib/widgets/ when > ~80 lines
- Always handle null safety explicitly
- Run `flutter analyze` before every commit — fix all warnings
