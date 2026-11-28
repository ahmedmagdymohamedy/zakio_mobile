# User Stories — Product Backlog

This folder is the **business backlog** for Zakio. Each subfolder is one **business
feature** — the place where its original inputs, its user stories and acceptance criteria,
its implementation notes and its change history live.

> **Working rule:** before any task, read the affected feature's three story files in full
> (its `attachments/` only when a new user story starts or the owner points to something
> new). After the task, update `business.md` / `technical.md` if anything changed,
> and **always** add a dated line to `backlog.md`. The owner never edits these files — agents
> keep them in sync. Full rule: `.ai/rules/user_stories_sync.md`. File shapes:
> `.ai/templates/user_story_files.md`.

## How each feature folder is organized

```
<feature>/
├── business.md      ← agent-owned
├── technical.md     ← agent-owned
├── backlog.md       ← agent-owned
└── attachments/     ← owner-owned, read-only for agents
```

| Item | Owner | Purpose |
|------|-------|---------|
| `attachments/` | Owner | The inputs the owner brings when a story starts or something new comes up: the initial user story (owner or BA), UI designs, API contracts, PDFs, notes. Agents read them only when a new user story starts or the owner points to something new; they never change anything inside. |
| `business.md` | Agent | The **business/product** view of what is built: overview, roles, user stories with acceptance criteria, business rules, metrics, dependencies, non-goals, what is not built yet. **No** technology or code. |
| `technical.md` | Agent | The **developer** view: real pages, cubits, managers, data paths, flows, edge cases, security, platform notes. Conceptual prose — **no code snippets**. |
| `backlog.md` | Agent | The **change log**: one dated line per change, newest first: `- YYYY-MM-DD — <what changed>`. |

The three story files start empty and are written **while the feature is implemented**,
from the attachments plus what was actually built.

Folder names are lowercase snake_case (for example `introduction`).

## Feature index

| Folder | Feature | What it delivers (business view) | Status |
|--------|---------|----------------------------------|--------|
| `introduction` | Introduction and First-Time Onboarding | The first experience from app launch to the hand-off to sign-in: a branded splash that routes each user to the right place, and intro screens that show parents the app's educational value. | Not built yet |
| `security` | Security | Every protection for families' data, the online services and the bill. Today: genuine-app protection — only the real Zakio app on a real Android phone or iPhone can reach the online services; invisible to families. | Built — not enforced yet |
| `monitoring` | Monitoring | Every way the team learns the app broke for a family. Today: automatic crash reporting on Android and iPhone, readable despite scrambled code. | Built |
| `release` | Release | One step ships each new version to Google Play internal testers and TestFlight, with scrambled code and crash-report keys sent first. | Built — 1.0.0+1 shipped to testing |

Add a row here whenever a new feature folder is created.
