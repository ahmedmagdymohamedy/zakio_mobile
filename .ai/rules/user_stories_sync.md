---
trigger: always_on
---

# 🚨 MANDATORY: Read the User Story First, Keep It In Sync After 🚨

> **This rule is NON-NEGOTIABLE and applies to EVERY task that touches a feature** —
> code, a fix, a plan, or a question about how something works.
>
> **The owner never writes or edits the three story files (`business.md`, `technical.md`,
> `backlog.md`). You do.** They stay accurate only because every agent, on every task, keeps
> them accurate. If they drift from the app, that is the agent's failure, not the owner's.
>
> **A task is NOT DONE — do not report it as complete — until every touched feature's
> `backlog.md` has a new dated line, and `business.md` / `technical.md` match what was built.**
> Finished code with stale story files is an unfinished task.

The folder `user_stories/` is the product backlog: one subfolder per business feature, plus a
`README.md` index that maps every feature to its folder. The exact shape of the three story
files is defined in `.ai/templates/user_story_files.md` — follow it whenever you write them.

---

## The folder and who owns what

```
user_stories/
├── README.md                 ← index of every feature        (agent keeps it in sync)
└── <feature>/                ← e.g. introduction
    ├── business.md           ← AGENT-owned
    ├── technical.md          ← AGENT-owned
    ├── backlog.md            ← AGENT-owned
    └── attachments/          ← OWNER-owned — READ ONLY
```

| Path | Owner | What the agent may do |
|------|-------|------------------------|
| `business.md`, `technical.md`, `backlog.md` | Agent | Read before every task; write after every task. The owner never edits them, and you never ask the owner to. |
| `attachments/**` | Owner | **Read only, and only when starting a new user story or when the owner points to something new** (see BEFORE, step 5). Never create, edit, rename, move, reformat or delete anything inside — not to fix a typo, not to "bring it up to date" after a decision. The only exception is when the owner, in the current task, explicitly asks you to write there. |
| `README.md` | Agent | Add or update a feature's row when a feature is added, renamed, or its one-line description changes. |

**What `attachments/` holds:** the inputs the owner brings when a user story starts, or when
something new comes up — the initial user story they wrote or got from the BA, UI designs
(images, exports, Figma links), API contracts (JSON / YAML / OpenAPI / Postman), PDFs, notes.
Once an input has been built, **the three story files carry the current truth**, and they are
what every task reads. The attachments carry where it started.

---

## BEFORE any task — collect deep knowledge first

Do all of this before writing code, a plan, or an answer. Reading only the README row is not
reading the story.

1. **Identify every feature the task touches.** If it touches more than one, all of them are in
   scope — read each one.
2. **Open `user_stories/README.md`** to find the folder(s). If no folder fits, ask the owner
   whether this is a new feature or which feature it belongs to. Do not guess.
3. **Read `business.md`, `technical.md` and `backlog.md` in full — on EVERY task.** They are
   the source of truth for the feature as it is now. The backlog holds the recent decisions
   and the deviations from the original inputs.
4. **Read the code that implements the feature today.**
5. **Read `attachments/` ONLY in these two cases** — otherwise leave it alone:
   - **Starting a new user story.** The feature's story files are still empty because nothing
     has been built yet. List `attachments/` and read every file in it.
   - **The owner points to something new.** They mention a new or changed input ("I added the
     designs", "check the new API contract", "see the attachment"). Read that input in full,
     and anything it references.

   When you do read an attachment, read it completely — do not skim:
   - Markdown / text → read the whole file.
   - Images / UI designs → open and look at each one: layout, copy, states, colors, spacing.
   - PDFs → every page.
   - API contracts → endpoints, request/response shapes, error cases, auth.
   - Links (Figma, docs) → open them with the tools available.
   - **A file or link you cannot open → tell the owner which one.** Never carry on as if it
     said nothing.
6. **Reconcile before you build.** Know which stories and acceptance criteria this task covers,
   what is already built, and where the sources disagree. Resolve disagreements with the
   precedence below. If it is still unclear, ask the owner **before** writing code.

### Precedence when sources disagree

1. **The owner's instruction in the current task** — always wins.
2. **`business.md` / `technical.md`** — the current, agreed truth, including decisions made
   after the attachments were written.
3. **`attachments/`** — the original input.

- If a new input the owner pointed to disagrees with the story files, and their instruction
  does not already say which one wins, ask whether it replaces what the story files say.
- If the code disagrees with the story files, one of them is wrong. Tell the owner which, and
  do not silently "fix" either one.

---

## AFTER the task — the DEFINITION OF DONE

Run these as the last required steps, before you tell the owner the work is complete:

1. **ALWAYS add a dated line to every touched feature's `backlog.md`**, at the top of the
   `## Changes` list (newest first): `- YYYY-MM-DD — <what changed>`, one or two lines, today's
   real date. **No change is too small to log.**
2. **Update `business.md` / `technical.md`** whenever the task changed behavior, scope, flows,
   rules, acceptance criteria, data, routes or configuration. Add, edit or remove content so
   they describe the feature **as it is now**. History belongs in `backlog.md`, not here.
3. **First implementation of a feature (the story files are still empty):** author
   `business.md` and `technical.md` in full per the template. Ground them in the attachments
   **and** in what you actually built. Seed `backlog.md` per the template. Any story from the
   attachments that is not built yet goes under **Not built yet** in `business.md`. Never
   present it as done.
4. **Building something different from an attachment** (the owner decided otherwise, or a
   technical limit forced it): `business.md` / `technical.md` describe what was built, and the
   `backlog.md` line states what differs from the attachment and why. The attachment stays
   exactly as it is.
5. **A brand-new feature:** create `user_stories/<feature>/` with the three files (folder name
   in lowercase snake_case, like `introduction`) and add its row to `user_stories/README.md`.
   Do **not** create `attachments/` — that folder is the owner's to add when they have inputs.
   Anything the owner gave you in chat goes into `business.md`, not into attachments.
6. **Self-check that step 1 happened** for every touched feature. In the final reply, name
   the updated story folder(s) in a few words, inside the one or two lines that
   `.ai/rules/short_final_reply.md` allows — no file list.

---

## Never

- Never edit anything inside `attachments/` unless the owner explicitly asks in that task.
- Never ask the owner to update `business.md`, `technical.md`, `backlog.md` or the README —
  keeping them in sync is your job.
- Never write the story files ahead of implementation from the attachments alone. They
  describe what is built and are written **while implementing**. The only exception is the
  owner explicitly asking for documentation-only work.
- Never invent flows, limits, copy, names or numbers that are not in the attachments, the code
  or the owner's words. Write what you can verify and mark the rest **"to confirm"**.
- Never put technology in `business.md` or code snippets in `technical.md`.
- Never report a task done while a touched feature has no new `backlog.md` line.

## The only exception

If the task changed **no** behavior (a pure refactor, formatting, a rename, or an internal-only
change that alters nothing documented), you do not need to edit `business.md` /
`technical.md`. Add a `backlog.md` line anyway if the owner asked for it to be logged. **The
BEFORE steps still apply.** When in doubt whether a change is behavioral, log it: a spurious
backlog line is cheap, and a missing one is the failure this rule exists to prevent.

## Self-check before saying "done"

- Did I read `business.md`, `technical.md` and `backlog.md` in full for **every** touched
  feature before starting?
- Was this a new user story, or did the owner point to something new? → Did I read every
  relevant file in `attachments/`? If neither was true → I did not need to read them.
- Did my change alter what a parent or child sees, taps, waits for, or is routed to? → It is
  behavioral → update `business.md` / `technical.md` + `backlog.md`.
- Did I add, remove or change a persisted value, a route, a timer, a threshold, a flag or a
  data path? → Behavioral → update `technical.md` + `backlog.md`.
- Did I touch more than one feature? → Update **each** one's folder.
- Does every touched feature have a dated `backlog.md` line from today?
- Is everything inside `attachments/` exactly as I found it?
