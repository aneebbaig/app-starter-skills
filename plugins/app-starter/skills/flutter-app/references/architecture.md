# Flutter clean architecture

Feature-first clean architecture, matching the owner's shipped apps. Strict
layering: `data -> domain <- presentation`.

```
lib/
  app/            App widget, root screen (bottom nav), splash
  core/
    config/       env wrapper (dart-define-from-file), typed config
    constants/    routes, colors, typography, dimensions
    di/           get_it + injectable setup, root providers
    errors/       Failure sealed class + userMessage / debugMessage
    llm/          BYOK: provider presets, config, shared REST decode (if applicable)
    network/      ApiClient (Dio) + AuthInterceptor (backend apps)
    router/       go_router or onGenerateRoute
    storage/      secure storage + shared_preferences wrapper
    theme/        AppTheme
    usecases/     UseCase<Output, Params> base classes
    utils/        extensions, logger, helpers
    widgets/      shared UI, toasts routed through a global messenger key
  features/
    <feature>/
      data/         datasources (abstract + impl), mappers, repositories
      domain/       entities, repository interfaces, use cases (each a Provider)
      presentation/ providers (Notifier / AsyncNotifier), screens, widgets
```

## Error model (Either / Failure)

Every use case returns `Future<Either<Failure, T>>`. Never throw across layers.

```dart
sealed class Failure {
  const factory Failure.database(String msg) = DatabaseFailure;
  const factory Failure.network(String msg) = NetworkFailure;
  const factory Failure.parse(String msg) = ParseFailure;
  const factory Failure.permission(String msg) = PermissionFailure;
  const factory Failure.auth(String msg) = AuthFailure;
  const factory Failure.rateLimited(String msg) = RateLimitedFailure;
  const factory Failure.validation(String msg) = ValidationFailure; // shown verbatim
  const factory Failure.unknown(String msg) = UnknownFailure;       // raw hidden from UI
}
// failure.userMessage -> safe display copy. failure.debugMessage -> raw, logs only.
```

## Riverpod patterns

- Provider chain: use-case provider reads the repository provider, which reads the
  datasource provider; a presentation `AsyncNotifierProvider` calls the use case.
- Use `ref.read` (not `ref.watch`) inside notifier methods. Use `ref.listen` for
  side effects like navigation. Never `addPostFrameCallback` in `build`.
- With codegen, run build_runner after any `@riverpod`, `@injectable`, or Drift
  table change:
  `fvm dart run build_runner build --delete-conflicting-outputs`.

## Two app shapes

- BYOK LLM app: no backend. Each user supplies their own key, stored in
  `flutter_secure_storage` per provider. LLM providers reached over plain REST
  (`http`); add a provider by adding one enum entry. No server secrets.
- Backend-backed app: `ApiClient` (Dio) with module-scoped path prefixes and an
  `AuthInterceptor` that attaches the Bearer token and refreshes on 401. No API
  keys in the client; all sensitive calls go through the authenticated backend.

## Environment

Use `--dart-define-from-file=.env` (KEY=VALUE). Env files are NOT pubspec assets
(security). Gitignore them. Provide `.env.example`.
