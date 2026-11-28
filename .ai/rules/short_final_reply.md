---
trigger: always_on
---

# Short final reply

> Canonical source: `.ai/rules/short_final_reply.md` (owner, 2026-11-27, taken from sweetgathering).

When a task the owner asked for is finished, the reply is **one or two lines at most**:
what was done, and anything the owner must still do. No recap of files, steps, tests
or reasoning, no headings, no lists.

## When a longer reply is allowed

Only when one of these is true:

- The owner **asked a question** that needs an explanation.
- There is a **concern about the task** the owner must know or decide: something not
  done or skipped, a failing test, a risk, a deviation from what was asked, a file kept
  over 500 lines, a step left for them.
- **Anything else** that the owner cannot act on correctly without an explanation.

Even then the reply stays **summarized**: explain only that point, in the fewest
words that answer it, then stop.

## What does not change

- Being honest: a failure, a skipped step or an unfinished change is always said — in
  the one or two lines when it fits, otherwise as the exception above.
- The other rules (user stories sync, clean code, centralized managers, performance and
  logic, caching, Firebase cost minimization) still run in full; they just aren't narrated in
  the reply.
