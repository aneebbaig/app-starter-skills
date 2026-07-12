# Bloc best practices (when the user picks bloc over Riverpod)

Only read this when the state-management answer is bloc. The clean
architecture in `architecture.md` does not change: feature-first folders, use
cases, datasource interface + impl, repository interface + impl, DI through
get_it, and `Either<Failure, T>` all stay exactly the same. Bloc replaces only
the presentation-layer state holder: where Riverpod would have a Notifier or
AsyncNotifier, bloc has a Bloc or Cubit.

Confirm current flutter_bloc APIs via Context7 before writing; the library
moves between majors.

## Packages

- `flutter_bloc` (includes `bloc`), `equatable` for value-equal states.
- Dev: `bloc_test` for unit-testing blocs, `mocktail` for mocks.
- Optional: `hydrated_bloc` when state must survive restarts (it needs a
  storage init in `main`); do not add it by default.

## Cubit vs Bloc

- Default to **Cubit** for straightforward screen state: methods mutate via
  `emit`, less boilerplate.
- Use a full **Bloc** (events + `on<Event>` handlers) when the input stream
  matters: debouncing search, throttling, event ordering, or when many UI
  entry points feed one state machine.
- Do not mix both styles inside one feature without a reason.

## States and events

- One sealed state hierarchy per bloc: `sealed class ProfileState` with
  `Initial / Loading / Loaded / Error` subclasses, or a single class with a
  status enum + copyWith. Pick one shape per app and stay consistent.
- States are immutable and value-equal (`Equatable` or records). Never mutate
  a state object; always emit a new one.
- The error state carries the `Failure` (from the domain layer), and the UI
  shows `failure.userMessage`. Raw messages stay out of the UI.
- Events are verbs in past or imperative form (`ProfileRefreshed`,
  `LoginSubmitted`), sealed the same way.

## Wiring (mirrors the Riverpod provider chain)

- The bloc's constructor takes its use cases (not repositories, not
  datasources). Register blocs in get_it as **factory** (a fresh bloc per
  screen), while use cases, repositories, and datasources stay lazy
  singletons bound to their interfaces.
- Provide with `BlocProvider(create: (_) => getIt<ProfileBloc>())` at the
  screen root. `MultiBlocProvider` only for genuinely shared subtrees; do not
  provide every bloc at app root. App-root blocs are for truly global state
  only (auth session, theme).
- Close is handled by `BlocProvider` automatically; never emit after close
  (guard long async work with `isClosed` or cancel on close).

## In the UI

- `BlocBuilder` for rendering, `BlocListener` for side effects (navigation,
  snackbars, dialogs), `BlocConsumer` only when a widget truly needs both.
  Side effects NEVER live in the builder.
- Use `buildWhen` / `listenWhen`, or `BlocSelector` for a slice, so one
  changing field does not rebuild the whole screen. Same scoping discipline
  as Riverpod's `select`.
- `context.read<T>()` inside callbacks, `context.watch<T>()` only inside
  build. Never `watch` in a callback.
- Widgets stay dumb: read state, dispatch events or call cubit methods. No
  business logic in widgets; it lives in the bloc, which delegates to use
  cases.

## Do not

- Do not call repositories or datasources from a bloc. Blocs call use cases.
- Do not pass `BuildContext` into a bloc or hold it across awaits.
- Do not create one god bloc for the whole app. One bloc/cubit per feature
  concern, same single-responsibility rule as providers.
- Do not communicate bloc-to-bloc directly. Compose at the use-case level, or
  have the UI listen to one and dispatch to the other.
- Do not throw from blocs. Use cases already return `Either<Failure, T>`;
  fold it into a state.
- Do not skip `bloc_test` coverage for non-trivial blocs: given initial
  state, when event, expect emitted states.

## Observability

Register a `BlocObserver` in `main` that logs transitions and errors in debug
builds only. Strip or silence it in release; never log payloads or tokens
(see `../../shared/hardening.md`).
