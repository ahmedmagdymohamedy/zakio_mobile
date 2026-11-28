---
trigger: always_on
---

# 🚨 MANDATORY: Firebase Cost Minimization 🚨

> Zakio's backend is Firebase:
> - **SQL Connect** (Data Connect on Cloud SQL);
> - **Cloud Firestore**;
> - **Realtime Database**;
> - **Remote Config**;
> - **Hosting**.
>
> **Every one of them bills** — per operation, per document, per byte downloaded, per fetch or
> per GB served — for every user, on every device, on every launch. One careless listener, or
> one fetch on every screen open, becomes a large recurring bill.
>
> **The owner's decision (2026-11-27): caching is our main cost tool.** Users may feel a small
> effect: a change made on the backend may take a while to reach them — minutes to a day,
> depending on the data. That is accepted.
>
> Pick the cheapest option that keeps the business correct. Spend a billed call only when
> nothing cheaper works.
>
> How to cache: `.ai/rules/caching.md`. Where Firebase calls live:
> `.ai/rules/centralized_managers.md`.

---

## 1. The priority ladder — cheapest first

Satisfy every data need at the **lowest** step that works:

1. **Already on the device (free).** The value is in a cubit, in a manager's memory, in a
   stream that is already open, or can be derived from data you hold. Fetching it again is a
   bug.
2. **The on-device cache (free).** The manager's cache, or the SDK's offline cache, while it is
   within its TTL.
3. **A tiny check before a big fetch.** Read one small version stamp / `updatedAt`, and fetch
   the dataset only when it has changed.
4. **A billed fetch — the last resort.** Only on a cache miss or an expired TTL. It must be
   deduplicated, written back to the cache, and use the fewest operations possible.

Under **Data & state** in the feature's `technical.md`, record which step each backend read
uses and its TTL.

## 2. Freshness defaults — the owner accepts a delay

| Data | Default |
|------|---------|
| Content and settings the team changes from the backend (lessons, catalogs, texts, app settings) | Long TTL (hours to days) or a version stamp. **No live listener.** |
| The user's own data (profile, children) | Cache + write-through: the user's own writes update the cache, so there is no re-read. Refresh after the TTL, on resume. A live listener only if the user story needs instant sync between devices. |
| Data that several users change together and that must show live | One live listener on the smallest path, only while the screen is open. |
| Decisions that must be right now (access, payments, permissions) | Check at the source at the moment of the decision. What is displayed may still come from the cache. |

**A live listener needs a reason in the user story.** "It feels nicer" is not a reason.

---

## 3. Tricks per service

### Cloud Firestore — billed per document read, write and delete

Index-entry reads, storage and network egress are billed too.

- **Every query costs at least one read**, even when it returns nothing. Don't query to check
  whether something is there when a cache or a stamp can tell you.
- **How listeners are billed:**
  - the first result bills every document in it;
  - after that, one read per document that is added or changed;
  - with offline persistence, a listener disconnected for **more than 30 minutes** is billed as
    a brand-new query when it reconnects;
  - without persistence, every reconnect is billed that way.

  So don't keep listeners on background screens, and never detach and re-attach on rebuilds.
- **`offset` bills every skipped document.** Paginate with cursors (`startAfter`), and always
  use `limit()`.
- **Count with `count()`** — never by downloading the documents.
- **Shape data for the screen.** A list screen should cost about one read: a summary document,
  or list documents that already hold what the list shows. Never one read per item. Move
  large, rarely shown fields into a separate document.
- **Security rules that call `get()` / `exists()` add reads** to every request they guard.
  Keep them off hot paths.
- **Read from the local cache** (`GetOptions(source: Source.cache)`) when cached data is good
  enough — that read never reaches the server.
- **Writes:**
  - batch related writes;
  - never write per keystroke or per tick;
  - never rewrite fields that did not change.

### Realtime Database — billed by data downloaded and stored

- **Cost is bytes.** `get()` or listen on the **narrowest path**. Never use a parent node that
  holds lists the screen does not show. Keep the tree flat and the nodes small.
- **Every query needs a matching `.indexOn` in the database rules.** Without one, the SDK warns
  that it is "using an unspecified index", downloads the whole node and filters it on the
  device.
- **Use `get()` for data that doesn't need live updates.** Listeners only per section 2, and
  cancelled when the screen goes away.
- **Offline persistence** (`setPersistenceEnabled`, mobile only) avoids re-downloading after a
  restart. It is enabled once, in `RtdbManager`.
- **`keepSynced(true)` keeps downloading changes even when nothing shows them.** Use it only for
  small, essential paths.
- **Never store blobs** (images, audio, big JSON) in the Realtime Database.

### SQL Connect (Data Connect + Cloud SQL) — billed per operation, plus the Cloud SQL instance

- **Every query or mutation is one billed operation**: free up to a monthly quota, then charged
  per million operations. **There is no per-row fee.** So one operation that returns
  everything the screen needs, related data included, beats several small ones.
- **Select only the fields the screen shows** (egress above the free quota is billed). Always
  limit lists, and paginate.
- **Cache every result**, keyed by the operation and its variables (`caching.md`). Never run
  operations on a timer or per keystroke.
- **Combine related mutations** into one operation where the schema allows it.
- **The Cloud SQL instance is billed for running time and size, whatever the traffic.** Any
  change to the instance is the owner's decision, never made from code.

### Remote Config — fetches are free up to a daily quota per project, then billed

- **Use it for app-wide settings and flags** that are the same for everyone and change rarely.
- **Set `minimumFetchInterval` explicitly**: hours in live, short only in dev.
  - At launch, `activate()` the last fetched values so the app starts at once.
  - Fetch in the background, at most once per interval.
- **No real-time Remote Config listener by default** — the owner accepts the delay. Add one
  only if the owner asks for instant config changes.
- **No user-specific or large data** in Remote Config.

### Firebase Hosting — billed by storage and data transferred

- **Cache headers in `firebase.json`:**
  - a long `Cache-Control` only for files that are content-hashed or versioned;
  - `no-cache` for every file that keeps its name between releases.

  In a Flutter web build that means most files — `index.html`, `flutter_bootstrap.js`,
  `main.dart.js`, `flutter_service_worker.js`, `version.json`, `assets/`. Browsers revalidate
  those cheaply (a 304 when nothing changed) and still receive new releases.
- **Keep the web build small:**
  - compressed images (WebP);
  - no unused assets listed in `pubspec.yaml` — every listed asset ships to the web;
  - no video or large media on Hosting.

### Services added later

If Cloud Functions or Cloud Storage are added, the same ladder applies:
- no function call for data the device can derive;
- never a call per keystroke;
- Storage bills per byte downloaded, so cache downloaded files and images on the device.

---

## 4. Always wrong (review-blocking)

1. A billed read in `build`, or on every screen open, for data that has not changed.
2. A Firebase call outside its manager.
3. A live listener with no reason in the user story, on a large parent node, or one per list
   item.
4. A Realtime Database query without a matching `.indexOn`.
5. A Firestore list without `limit()`, or paginated with `offset`.
6. Counting by downloading documents.
7. Polling — a timer that re-fetches. Use version stamps on resume, or a listener.
8. Writing on every keystroke, scroll or tick, or rewriting unchanged data.
9. A new billed read path without a cache.
10. App-wide settings read from a database on every launch when Remote Config fits.

## 5. Keep nothing longer than needed

Stored data is billed every month. Data created per action (attempts, events, logs, sessions)
ships with its end:
- a Firestore TTL policy on an expiry field;
- a cap (keep the last N);
- or a scheduled prune.

Write the chosen lifetime in the feature's `technical.md`.

---

## Self-check before saying "done"

- Which ladder step does each new backend read use, and why didn't a cheaper one work? Is that
  written in `technical.md`?
- Did I add a live listener? Is its reason in the user story? Is it on the smallest path, and
  is it cancelled?
- Are lists limited and cursor-paginated? Are RTDB queries indexed? Are counts done with
  `count()`?
- How many reads or operations does one screen open cost? Does any of them repeat on every open
  without a change?
- Are writes batched, and made only when something changed?
