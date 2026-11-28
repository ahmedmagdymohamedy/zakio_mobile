---
trigger: always_on
---

# 🚨 MANDATORY: Clean Code Standards 🚨

> Act as a **strict lead Flutter architect and code reviewer**. Check every line you write or
> change against this rule before you present it. Code that works but breaks this rule is
> **not done**.
>
> Companion rules, all mandatory: `.ai/rules/centralized_managers.md` (where shared logic
> lives), `.ai/rules/performance_and_logic.md`, `.ai/rules/caching.md`.

---

## 1. Reuse first — never repeat code (the most important rule)

Before you write ANY widget, function, extension, constant, model, style or piece of logic:

1. **Search first.** Look for something that already does it, or nearly does it: `lib/core/`
   (managers, utils, extensions, resources, validations), `lib/presentation/widgets/`,
   `lib/data/`, and the feature you are in. Search by **behavior**, not only by name: grep for
   the API it would call, the string, the color, the widget type.
2. **It exists → use it.** Never write a second one.
3. **Something close exists → extend the existing one** (a parameter, an option, a variant).
   Do not fork a copy with a small change. Keep its current callers working.
4. **It exists but is trapped in one screen or feature** (private, or inside a page folder),
   and you now need it somewhere else → **promote it.** Move it to the right shared place
   (table below), make it generic, and make **both** the old place and the new place use it.
   Delete the old copy **in the same task**. Two versions must never exist.
5. **It does not exist → write it once, in the right place.** If it may be used from more
   than one place, it goes in the shared place from the start.

**Duplication includes:**
- copy-pasted blocks with renamed variables;
- two widgets that look the same except for a color or size;
- the same string, number, duration or path typed in two places;
- the same read / parse / write logic in two cubits;
- the same validation or the same date / number formatting.

A repeated block is a bug, not a style choice.

### Where shared things go

| What | Where |
|------|-------|
| Reusable widget (button, card, input, loader, empty / error state) | `lib/presentation/widgets/` |
| Logic or a service used from more than one place | a manager — see `centralized_managers.md` |
| Pure helper function | `lib/core/utils/` |
| Extension on a type (`String`, `BuildContext`, `DateTime`, `Duration`, `Color`) | `lib/core/extensions/<type>_ext.dart` |
| Validation, regex, input formatters | `lib/core/validations/` |
| Constants (limits, counts, durations, TTLs) | `lib/core/resources/app_constants.dart` |
| Colors, fonts, assets | `app_colors.dart`, `app_fonts.dart`, `app_assets.dart` in `lib/core/resources/`; theme in `lib/app/app_theme.dart` |
| User-visible text | a key in `lib/core/resources/string_keys.dart` + the value in **every** file in `assets/translations/` |
| Navigation | `AppRouter` (`lib/core/resources/app_routes.dart`) |
| Dialogs, toasts | `DialogsManager` (`lib/core/managers/dialogs_managers.dart`) |
| Data models | `lib/data/models/` (freezed) |
| State shared by several screens | `lib/presentation/general_cubit/` |
| Widgets used by only one page | `lib/presentation/pages/<page>/widgets/` — promote to `lib/presentation/widgets/` once a second page needs it |

## 2. No hardcoding

- No magic numbers for business values (limits, counts, durations, timeouts) → `AppConstants`.
- No raw colors (`Colors.x`, `Color(0x…)`) in widgets or screens → `AppColors` or the theme.
- No font family typed inline → `AppFonts`.
- No user-visible string literal → `StringKeys` + all translation files.
- No asset path literal → `AppAssets`.
- No database path, storage key or cache key typed outside the manager that owns it.

## 3. Structure and responsibilities

- **Layers:** view → cubit → manager → data source. Widgets render state and forward events.
  Cubits hold the screen's logic and call managers. Only managers touch Firebase,
  SharedPreferences or other SDKs.
- **No business logic in widgets.** No I/O, no decisions about data, no parsing in `build`.
- **Single responsibility:** one class has one reason to change. One file holds one main
  public class, plus its small private helpers.
- **Small functions:** one function does one thing. If you are tempted to label its "steps"
  with comments, split it into functions.
- **Split UI into widget classes** (`StatelessWidget` / `StatefulWidget`), not `_buildX()`
  methods that return widgets.
- **Immutability:** freezed models and states, `final` fields, `const` constructors wherever
  possible.
- **Keep it simple (KISS / YAGNI):** no speculative layers, interfaces, options or parameters
  that nothing uses yet. This limits *speculation*. It never overrides section 1: code that
  may be used from more than one place still goes in a shared place.
- **Follow the existing patterns** before inventing new ones:
  - a page is `lib/presentation/pages/<page>/view/` + `cubit/` + `cubit/state/`;
  - a cubit exposes `static get(BuildContext context)`;
  - models and states use freezed;
  - managers are static classes, set up in `AppInitialization.init()`.

## 4. File size — 500 lines max

- **No hand-written file may exceed 500 lines.** Generated files do not count: `*.g.dart`,
  `*.freezed.dart`, `firebase_options.dart`, generated locale keys.
- If a change would push a file past 500 lines, **split it first** by responsibility:
  - widgets into their own files;
  - helpers into utils or extensions;
  - logic into the cubit or a manager.

  Then make the change.
- **The only exception:** a file that is **one cohesive, flat thing** where splitting would
  scatter a single concept and make it harder to read — for example a long list of constants
  or keys, or the theme. It must still be clean, and **you must tell the owner which file is
  over 500 lines and why it stays whole.** A file that mixes responsibilities never qualifies.
- Check with `wc -l` on every file you created or grew.

## 5. Naming

- Descriptive, full words. No unclear abbreviations (`btn`, `usr`, `tmp`, `data2`).
- Dart conventions:
  - `UpperCamelCase` for types;
  - `lowerCamelCase` for members;
  - `snake_case` for files and folders;
  - the file name is its main class in snake_case.
- Booleans read as questions: `isLoading`, `hasChildren`, `canContinue`.
- Functions are verbs: `loadChildren()`, `markIntroSeen()`.
- Name things by their business meaning, not by their type (`introSeen`, not `flag`).
- Spell names correctly.

## 6. Types, safety and async style

- No `dynamic` except at a JSON boundary; parse into a model right there.
- Do not use `!` on a value that can actually be null at that point — handle the null.
- Async methods return `Future<void>`, never `async` void.
- No fire-and-forget futures unless deliberate: wrap them in `unawaited(...)` with a comment
  saying why.

## 7. Dead code, comments, formatting, packages

- **No dead code.** In the same task, remove what you made unused: imports, variables,
  parameters, files, and commented-out code.
- **Comments explain *why*, not *what*.** Give public managers and shared widgets a short `///`
  doc. When you change code, update or delete the comments it made wrong.
- **Format** changed files with `dart format`. It follows `analysis_options.yaml` (page width
  300, trailing commas preserved). Use trailing commas in multi-line widget trees.
- **`flutter analyze`** must report no new issues in the files you touched. Never silence a
  lint with `// ignore` without a written reason.
- **Never edit generated files** (`*.g.dart`, `*.freezed.dart`). Change the source and run
  `dart run build_runner build --delete-conflicting-outputs`.
- **No new package without telling the owner why.** Prefer what `pubspec.yaml` already has.

---

## Self-check before saying "done"

- Did I **search** for an existing widget, function or manager before writing a new one?
- Is any logic, widget, constant or string now in **two places**? → Centralize it, point both
  callers at it, delete the copy.
- Is anything I wrote used, or likely to be used, from more than one place, but not in a
  shared place?
- Is any file over 500 lines? If I kept one, did I tell the owner why?
- Any hardcoded string, color, number, path or key?
- Any business logic or SDK call in a widget?
- Did I remove dead code, unused imports and stale comments? Do format and analyze come out
  clean?
