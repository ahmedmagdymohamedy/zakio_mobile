# Authoring standard — user story files

Every feature folder under `user_stories/` holds three agent-owned files — `business.md`,
`technical.md`, `backlog.md` — plus, when the owner has inputs, an owner-owned `attachments/`
folder that agents only read. This file defines the required shape of the three agent-owned
files. When and why they are written is defined in `.ai/rules/user_stories_sync.md`.

Ground everything in two sources: the feature's `attachments/` (the original input) and the
real implementation (read the code you built or changed). Do not invent flows, limits, copy,
names or numbers. Where a detail is uncertain, write what is verifiable and mark the rest
**"to confirm"**.

---

## File 1 — `business.md` (BUSINESS ONLY)

Strictly product/business. **No** technology names, **no** Firebase / database / cubit / package
mentions, **no** file or class names, **no** code. Sections:

```
# <Feature Name>
_one-sentence summary in italics_

## Overview
2–4 sentences: the problem it solves and the business value.

## Who it's for
The roles that touch this feature (parent, child, first-time parent, returning parent, …).

## User stories
One entry per story that is BUILT. Each:

### US-NN: <short title>
**As a** <role>, **I want** <capability>, **so that** <benefit>.
**Acceptance criteria:**
- testable, business-level bullets (3–6 each), matching what was actually built

## Business rules & constraints
Bullets: limits, gating, eligibility, timings, routing conditions, platform availability — in
business terms only.

## Success metrics
Bullets: what shows this feature works.

## Dependencies & relationships
Bullets: other features it relies on or feeds (by plain feature name).

## Out of scope / non-goals
Bullets: what this feature deliberately does NOT do.

## Not built yet
Bullets: stories or acceptance criteria from the attachments that are not implemented yet, each
with the attachment it comes from. Remove a bullet once it is built (and log that in the
backlog). Omit the section when nothing is pending.

## Sources
Bullets: every file in `attachments/` this document was written from (file name + one line on
what it holds).
```

## File 2 — `technical.md` (DEVELOPER VIEW, NO CODE)

Conceptual engineering doc. You MAY name real pages, widgets, cubits, managers, models, routes,
Firebase services and paths, SharedPreferences keys, translation keys and flavors — but **do not
paste code, snippets or pseudocode**. Sections:

```
# <Feature Name> — Technical
_one-sentence scope_

## How it works
End-to-end narrative, as you'd explain it to a new teammate.

## Key components
Bullets naming each real piece (page / widget / cubit / manager / model / service) + a one-line
role, with its location under `lib/`.

## Data & state
Where data lives and its conceptual shape: Firebase Realtime Database paths, other Firebase
services, SharedPreferences keys, in-memory cubit state. State who is the source of truth.

## Important flows
Numbered, step-by-step main lifecycle(s) / routing / state machine(s).

## API contracts
Endpoints or backend calls the feature uses, as implemented — and where they differ from a
contract in `attachments/`. Omit if the feature has none.

## Integrations & dependencies
Third-party packages and services, and the internal features/managers it relies on.

## Edge cases & failure handling
Offline, slow network, first launch vs returning, interrupted flows, validation, retries —
whatever applies.

## Security & permissions
Auth requirements, database rules, what a signed-out user can reach.

## Localization
Translation keys or copy groups the feature owns (Arabic and English).

## Platform notes
Android vs iOS (vs web/desktop) differences, and dev vs live flavor differences.

## Constraints, risks & tech debt
Known limitations and TODOs you observe.
```

## File 3 — `backlog.md` (CHANGE LOG)

Exactly this shape (replace `<Feature Name>`; the seed line uses the real date the files were
first authored):

```
# <Feature Name> — Change Backlog

> Running log of changes to this feature. Every change is one dated line, newest first.
> Format: `- YYYY-MM-DD — <what changed>` (one or two lines max).

## Changes

- YYYY-MM-DD — Initial user-story documentation authored (business + technical) while implementing <what was built>.
```

Later lines go **above** older ones. When a change deviates from an attachment, say so in the
line (what differs and why).

---

**Quality bar:** specific to Zakio and to THIS feature, deep, no generic filler, matched to the
real implementation and to the attachments.
