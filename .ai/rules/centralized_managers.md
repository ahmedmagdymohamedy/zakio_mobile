---
trigger: always_on
---

# 🚨 MANDATORY: Centralize Shared Logic in Managers 🚨

> **Anything that may be used from more than one place lives in ONE centralized place, and
> every caller goes through it.** The result is less code, one place to change, one place to
> cache, and one place to fix a bug.
>
> When the logic already exists somewhere, follow the promotion procedure in
> `.ai/rules/clean_code.md` §1, steps 1–5: search, extend or move, point both callers at it,
> and delete the copy in the same task.

---

## When something must be centralized

Centralize it when **any** of these is true:

- It is used — or may be used — from **two or more** screens, cubits or widgets.
- It talks to anything outside the Dart code:
  - Firebase (Realtime Database, and later Firestore, Auth, Remote Config, Storage);
  - SharedPreferences;
  - an HTTP API;
  - a platform plugin (notifications, permissions, device info).
- It holds **app-wide state** or a resource that must exist **once**: a database instance, a
  listener, a cache, the current session.
- It is a **cross-cutting concern**: navigation, dialogs and toasts, logging, error mapping,
  connectivity, formatting.

## Where managers live

| Kind | Location | Existing |
|------|----------|----------|
| Device and app services (local storage, dialogs, logging, notifications, permissions) | `lib/core/managers/` | `SharedPreferencesManager`, `DialogsManager` |
| Firebase and backend access | `lib/data/firebase/managers/` | `RtdbManager`; empty placeholders `firestore_manager.dart`, `remote_config_manager.dart`, `sql_connect_manager.dart` |
| Navigation | `lib/core/resources/app_routes.dart` | `AppRouter` |
| App-wide state shared by several screens | `lib/presentation/general_cubit/` | `AppDataCubit` |
| Stateless pure helpers | `lib/core/utils/`, `lib/core/extensions/` | — |

### Two kinds of data manager

- **Source managers** own one connection or SDK. They hold the instance and its setup —
  `RtdbManager` owns the Realtime Database instance, `SharedPreferencesManager` owns local
  storage.
- **Domain managers** own one business domain, for example a `ChildrenManager`. A domain
  manager has:
  - the domain's paths and keys;
  - reads and writes;
  - parsing into models;
  - its cache (`.ai/rules/caching.md`);
  - its error mapping.

  It uses the source managers and never re-opens the SDK itself.

## How a manager is shaped

Follow the project's existing style:

- **A static API on a class with private state**, like `SharedPreferencesManager.getToken()`.
- **Async setup goes in an `init()`** that is called once from `AppInitialization.init()`,
  inside its existing `Future.wait`.
- **It owns its keys, paths and constants privately**, like `_tokenKey`. Callers never see a
  raw key or path.
- **It returns typed models, never raw maps or SDK snapshots.** JSON is parsed in exactly one
  place (`Model.fromJson`).
- **It owns its errors.** Catch SDK exceptions inside, log them once, and hand callers a clear
  result or failure — not an SDK exception.
- **It owns listener lifecycle.**
  - At most one live listener per path.
  - It exposes a `Stream` to callers.
  - It cancels the listener when nobody needs it, and on sign-out.
- **No `BuildContext` in data managers.** Only the UI services — `AppRouter`, `DialogsManager`
  — touch UI, through `appContext`.
- **One manager, one responsibility.** Split it by domain before it nears 500 lines.

## Rules for callers

- **Widgets never call a data manager directly.** They go through their cubit.
  - Exception: the UI services `AppRouter` and `DialogsManager` may be called from widgets
    and cubits.
- **Cubits call managers.** They never use an SDK entry point directly:
  - `FirebaseDatabase.instance`, `FirebaseDatabase.instanceFor(...)`;
  - `SharedPreferences.getInstance()`;
  - `FirebaseAuth.instance`;
  - an HTTP client.
- **SDK imports stay inside managers.** `package:firebase_database`,
  `package:shared_preferences`, `package:cloud_firestore`, `package:firebase_auth`,
  `package:firebase_remote_config` and HTTP packages may be imported only under:
  - `lib/data/firebase/managers/`;
  - `lib/core/managers/`;
  - `lib/app/app_initialization.dart` (Firebase setup);
  - `lib/firebase_options.dart` (generated).

  Check it:
  `grep -rn "^import 'package:\(firebase_\|cloud_firestore\|shared_preferences\|http\|dio\)" lib`
  — every hit must be in one of those places.
- **Shared screen state goes through a general cubit** in `lib/presentation/general_cubit/`.
  Never pass state from screen to screen by hand, and never keep a copy in each screen.

## Before you add a new manager

1. **Check that no existing manager already owns this source or domain.** If one does, extend
   it. Do not add a second.
2. **Fill the existing placeholder** if one fits (for example `firestore_manager.dart`),
   instead of creating a new file.
3. **Name it `<Domain>Manager`** in `<domain>_manager.dart`, in the right folder from the table.
4. **If it needs setup**, add its `init()` to `AppInitialization.init()`.

---

## Self-check before saying "done"

- Did I write logic that another screen or cubit already has, or will need? → It belongs in a
  manager or a shared place, and both callers use it.
- Does any widget or cubit touch an SDK, a raw path or a raw storage key? → Move it into the
  owning manager.
- Did the SDK-import grep come back clean?
- Did I open a second listener, instance or cache for something a manager already owns?
