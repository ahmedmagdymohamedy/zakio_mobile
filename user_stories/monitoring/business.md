# Monitoring
_Tells the team, automatically, whenever the app breaks for a family — with enough detail to fix it fast._

## Overview
Parents and children rarely report problems; they just stop using the app. Monitoring records every crash in the released app on Android and iPhone, in a form the team can read even though the shipped code is scrambled, so problems are found and fixed before they cost families or ratings. Every monitoring capability of the app is documented here. Today it has one part: **crash reporting**.

## Who it's for
- **Parents and children** — problems get fixed without them having to report anything.
- **The owner and the development team** — see what broke, on which version and device, and how often.

## User stories

### US-01: Every crash is reported automatically
**As the** owner, **I want** every crash of the released app recorded automatically, **so that** I know about problems before families complain or leave.
**Acceptance criteria:**
- Any unexpected error in a store version of the app is recorded, on Android and iPhone.
- Each report shows the app version and the device.
- The family sees no extra screen or prompt.

### US-02: Reports stay readable
**As a** developer, **I want** every crash report to point to the exact place in our code, **so that** I can fix it quickly even though the shipped code is scrambled.
**Acceptance criteria:**
- Every store version's reading keys are sent to the crash-reporting service before that version ships (see Release).
- A version whose keys could not be sent is not shipped.

### US-03: Test builds stay out of the numbers
**As the** owner, **I want** crashes from the team's own test builds left out, **so that** the crash numbers reflect real families only.
**Acceptance criteria:**
- Development builds record nothing.

## Business rules & constraints
- **Mobile only:** Android and iPhone; the website and desktop builds are not monitored.
- **No personal information** about parents or children is added to crash reports.

## Success metrics
- Share of users who never hit a crash, per version.
- Time from the first report of a crash to its fix.

## Dependencies & relationships
- **Release** — sends each version's reading keys before shipping.
- **Security** — starts first at app start; monitoring follows.

## Out of scope / non-goals
- Usage analytics and performance measurement (future monitoring parts).
- Reporting errors the app survives, as their own category.

## Not built yet
- Splitting survivable errors from real crashes (sweetgathering found this matters once real traffic arrives).

## Sources
- No attachments — built from the owner's requests in chat (2026-11-28).
