---
trigger: always_on
---

# 🚨 MANDATORY: Cache Everything — and Stay Correct When the Other Side Changes 🚨

> **Data that comes from outside the device is read through a cache.** That means Firebase,
> APIs, remote config and network images. A screen never waits on the network for data it has
> already seen.
>
> **A cache that can show wrong data is a bug.** Every cached dataset must know how it finds
> out that the data changed somewhere else — another device, the backend, an admin.
>
> Companion rules: `.ai/rules/centralized_managers.md` (the manager owns its cache),
> `.ai/rules/firebase_cost_minimization.md` (which data is worth a billed call, and the default
> freshness per type of data), `.ai/rules/performance_and_logic.md`.

---

## 1. Who owns the cache

- **The domain manager that owns the data owns its cache** (`centralized_managers.md`).
  Cubits and widgets never build their own cache, and never keep a "just in case" copy.
- **One cache per dataset.** If two screens show the same data, they read the same manager.
- **Cache keys, TTLs and schema versions live in one place:**
  - keys are private constants in the manager;
  - TTLs are in `AppConstants`.

## 2. The layers

| Layer | What | Lifetime |
|-------|------|----------|
| **L1 — memory** | The manager's in-memory value or map | This app session |
| **L2 — on device** | **One** of the two below, never both, for the same data | Across restarts |
| **Source** | Realtime Database, other Firebase services, API | Truth |

For **L2**, choose one per dataset:

- **The manager's own copy** in SharedPreferences, through `SharedPreferencesManager`. Add one
  generic JSON read/write there once — do not add a pair of methods for every dataset.
- **The Realtime Database SDK's own offline cache.** It is enabled once, in `RtdbManager`, and
  works on mobile only.

**Keeping a second persistent copy of data that the SDK already caches is forbidden.** The two
will drift apart.

**SharedPreferences is for small values.** For large or many-item data, ask the owner about a
proper local store before adding a package.

## 3. Reading — cache first, then revalidate

1. **Return L1 if it is present and fresh.**
2. **Otherwise return L2 at once if it is present**, even if stale, so the screen shows
   something immediately.
3. **If the data was stale or missing, fetch from the source in the background.** When fresh
   data arrives:
   - update L1 and L2;
   - emit to listeners;
   - change nothing on screen if the value did not change.
4. **Deduplicate in-flight requests.** At most one request per key at a time; concurrent
   callers share the same `Future`.
5. **Never crash on a bad cache.** If an entry fails to parse or its schema version is old,
   drop it and fetch again.

## 4. Writing — keep the cache in step

- **Write-through:** write to the source; when it succeeds, update L1 and L2 at once. Never
  just invalidate and force a re-read of something you already know.
- **Optimistic updates** are allowed only with a rollback: on failure, restore the old value
  and tell the user.
- **Persisted entries are an envelope:** the value, plus `savedAt` and `schemaVersion`, plus
  the source's `version` / `updatedAt` when the source has one. Bump `schemaVersion` whenever
  the model's shape changes.

## 5. Changes on the other side — every dataset declares its strategy

Pick the **cheapest** strategy that keeps the business correct. Write it down, with its TTL,
under **Data & state** in the feature's `technical.md` (`.ai/rules/user_stories_sync.md`).

| Strategy | Use when | How |
|----------|----------|-----|
| **Live listener** | The data can change elsewhere while the app is open, and the user must see it at once | One Realtime Database listener per path, owned by the manager. Each event updates L1 + L2 and is emitted to the cubits. Cancel it when nobody needs it. |
| **Version stamp** | A dataset that is large or read often but changes rarely | Keep a tiny `version` / `updatedAt` value beside it at the source. On start and resume, read only the stamp, and fetch the full dataset only when the stamp has changed. |
| **TTL + refresh on resume** | Some staleness (minutes to days) is harmless | When an entry is older than its TTL, revalidate it in the background (section 3). Choose the TTL from how sensitive the data is, not from what is convenient. |

## 6. Lifecycle events every cache must handle

- **App resumed** (`AppLifecycleState.resumed`) → revalidate expired entries and check version
  stamps.
- **Sign-out or account switch** → clear **every user-scoped** entry in L1 and L2, and cancel
  that user's listeners. The next person on the device must never see the previous user's
  data, and **never a child's data from another account**.
- **The user's own write** → update the cache immediately (section 4).
- **Pull-to-refresh or explicit retry** → bypass the TTL and go to the source.
- **Startup** → prune expired entries and entries from an old schema, in the manager's
  `init()`.

## 7. Safety and limits

- **Show stale data if you must, but never decide on it.**
  - A cached value may be **displayed**.
  - A decision that matters — access, permissions, payments, anything where stale means wrong
    — is checked against the source at the moment of the decision.
- **User-scoped keys include the user id**, so the data of two accounts on one device never
  mixes.
- **Caches are bounded.** Set a maximum entry count, or evict the least recently used entries,
  and prune them. Never store large blobs in SharedPreferences.
- **Do not cache:**
  - secrets beyond what the session needs;
  - one-time values (codes, nonces);
  - data the owner said must always be live.
- **Offline:** serve the cache, and where staleness matters, tell the user the data may be out
  of date.

---

## Self-check before saying "done"

- Does every new read of outside data go through its manager's cache, with in-flight dedup?
- Which strategy (live listener, version stamp, TTL) tells this dataset about changes made
  elsewhere? Did I write it, and its TTL, in the feature's `technical.md`?
- Do my writes update the cache? Does sign-out clear every user-scoped entry and listener?
- Is there exactly one persistent copy of this data, not both the manager's copy and the SDK's?
- Is any important decision being made on cached data alone?
