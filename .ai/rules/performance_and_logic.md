---
trigger: always_on
---

# 🚨 MANDATORY: Performance and Correct Logic 🚨

> Zakio is used by parents and children on ordinary phones. **Every screen must feel instant,
> never freeze, and never show a wrong or half-finished state.** Check every change against
> this rule. Slow code or code that breaks on an edge case is **not done**.
>
> Companion rules: `.ai/rules/clean_code.md`, `.ai/rules/centralized_managers.md`,
> `.ai/rules/caching.md`.

---

## Part A — Performance

### Rebuilds

- **`const` everywhere it is possible:** constructors, widgets, values.
- **Rebuild only what changed.**
  - Scope a `BlocBuilder` to the **smallest subtree** that uses the state.
  - Use `buildWhen`, `BlocSelector` or `context.select` so a widget rebuilds only when the
    fields it shows change.
- **Side effects go in `BlocListener`** (or `listenWhen`), never in `builder`: navigation,
  dialogs, toasts.
- **Split big trees into widget classes** so each part rebuilds on its own.

### `build` must be pure and cheap

- **No I/O in `build`**: no reads, no writes, no SDK calls.
- **No heavy work in `build`**: no sorting or filtering of large lists, no parsing. The cubit
  emits ready-to-render state.
- **Don't create objects that should live longer** inside `build` (controllers, formatters,
  streams). Create them once in state or in the cubit.

### Lists, images, animations

- **Long or unknown-length lists** use `ListView.builder`, `GridView.builder` or slivers —
  never a `Column` of mapped items. Give items stable `Key`s when they can reorder.
- **Size images for their slot**, using `cacheWidth` / `cacheHeight` for large images. Keep
  asset files compressed.
- **Precache images** needed on the first frame (splash, intro) so they don't pop in.
- **Animations:**
  - dispose their controllers;
  - pass static parts as `child` to `AnimatedBuilder`;
  - wrap expensive continuous animations in a `RepaintBoundary`.

### Async work and startup

- **Never block the UI isolate.** Heavy CPU work (large JSON, image processing) runs in
  `Isolate.run` / `compute`.
- **Run independent async work in parallel** with `Future.wait`, as `AppInitialization.init()`
  already does — not one after another.
- **Keep startup lean.** `AppInitialization.init()` sets up only what the first frame needs;
  everything else is deferred. Never wait on the network before the first frame without a
  timeout.

### Network and Firebase

- **Read only what you need:**
  - the narrowest path;
  - queries on indexed fields;
  - `limitToFirst` / `limitToLast` for lists.

  Never listen at the database root or on a big parent node.
- **No listener per list item.** Use one listener on the list's path, owned by its manager.
- **Batch related writes** (multi-path updates).
- **Debounce input-driven calls** (search, typing).
- **Serve repeated reads from the cache** — see `.ai/rules/caching.md`.

### Memory and lifecycle

- **Dispose everything you create** in `dispose()`: `TextEditingController`, `FocusNode`,
  `AnimationController`, `ScrollController`, `StreamSubscription`, `Timer`.
- **Cubits cancel their subscriptions and timers** in `close()`.
- **After an `await`:**
  - in a cubit, check `isClosed` before `emit`;
  - in a `State`, check `mounted` before using `context`.

### Measure, don't guess

When performance is in question, profile in **profile mode** with Flutter DevTools. Don't
micro-optimize code that is not measured as slow at the cost of clarity.

---

## Part B — Correct logic

### Every state is handled

- **Every screen that loads data handles all of its states**:
  - loading;
  - success;
  - empty;
  - error;
  - offline, where the screen needs the network.

  Each state is shown in the UI. No endless spinner, no blank screen, no silent failure.
- **The user story is the requirement.** The acceptance criteria in the feature's
  `business.md` (see `.ai/rules/user_stories_sync.md`) are met exactly — they are not
  suggestions.

### Errors and logging

- **Never swallow an error** (`catch (_) {}`, or an empty `onError`).
- **Every I/O call is guarded**:
  - catch at the manager boundary;
  - map the error to a clear result;
  - log it once;
  - give the user a friendly, translated message through `DialogsManager`.
- **Set a timeout** on every network call that a screen waits for.
- **Log through ONE central logger** in `lib/core/managers/`, built on the `logger` package
  already in `pubspec.yaml`.
  - Create it once, when it is first needed.
  - Never use `print` / `debugPrint` in committed code.
- **Never log secrets or personal data**: tokens, passwords, emails, or anything about a child.

### Races and double actions

- **Guard against double taps.** An action that is running disables its button
  (`AppButton.isLoading`) or ignores repeats.
- **The latest request wins.** When a newer request starts, cancel or ignore the response of
  the older one.
- **Writes are idempotent.**
  - A retry must not create duplicates: use deterministic ids/keys.
  - Use transactions for counters and other read-modify-write updates.

### One source of truth

- Every piece of state has **one owner** (a manager or a cubit).
- Never keep two copies that can disagree. Derive what you show from the owner.

### Edge cases to consider on every change

- First launch vs returning user; signed out vs signed in.
- Empty data, a single item, a very long list.
- Very long text, in **Arabic (RTL) and English**.
- Slow network, no network, network lost mid-action.
- App killed or backgrounded mid-flow, then reopened.
- The back button or gesture in the middle of a flow.

### Testable logic

- Keep pure logic free of `BuildContext` and of static SDK access so it can be unit-tested.
  Pure logic means routing decisions, validations, formatting, cache rules.
- Add a unit test under `test/` when you write non-trivial logic of this kind.

---

## Self-check before saying "done"

- Does any widget rebuild more than it needs to? Is there any I/O or heavy work in `build`?
- Did I dispose every controller, subscription and timer? Is `emit` guarded after `await`?
- Are loading, empty, error and offline all handled and shown?
- Can a double tap, a retry or a slow response break the result?
- Is every error caught, logged once (without personal data), and shown in a friendly way?
- Did I go through the edge-case list for this change?
