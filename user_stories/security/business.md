# Security
_Keeps families' data, Zakio's online services and the bill safe from abuse — without adding any step for parents or children._

## Overview
Zakio holds data about families and children and runs on online services that are paid for by use. Security is the set of protections that make sure only the genuine app and the right people can reach that data and those services. Every security capability of the app is documented here. Today it has one part: **genuine-app protection** — the online services can tell the real Zakio app on a real phone apart from scripts, copied credentials or modified apps, and refuse the rest.

## Who it's for
- **Parents and children** — their data is protected; nothing changes in how they use the app.
- **The owner** — protection against data abuse, fraud and unexpected cost.
- **The development team** — test builds on the team's own devices keep working.

## User stories

### US-01: Only the genuine app reaches our services
**As the** owner, **I want** our online services to accept requests only from the genuine Zakio app on a genuine device, **so that** our data and our bill are protected from abuse.
**Acceptance criteria:**
- The Android and iPhone apps prove they are genuine on every request to the online services.
- Once protection is switched on for a service, requests without that proof (scripts, copied credentials, modified apps) are refused.
- Protection is switched on per service, by the owner, only after real users are seen passing the check.

### US-02: Invisible to families
**As a** parent or child, **I want** the protection to work without any extra step, **so that** using Zakio stays simple.
**Acceptance criteria:**
- No screen, prompt or wait is added by the protection.
- A device's proof is reused for 12 hours before it is renewed, in the background.
- If the check cannot be prepared, the app still opens.

### US-03: Test builds keep working
**As a** developer, **I want** test builds on our own devices to pass the check, **so that** we can keep building and testing once protection is on.
**Acceptance criteria:**
- Test builds use a test mode that the owner approves once per test device.
- A test device that was not approved is refused once protection is on.

## Business rules & constraints
- **Mobile only:** Android and iPhone. The website is an information page only and does not use the online services; desktop apps are not shipped.
- **12-hour proof** (owner's cost choice): fewer checks cost less; a stolen proof stays usable for at most 12 hours.
- **Android has a daily check allowance** (10,000 checks a day on the standard level). It must be raised before the number of daily Android users approaches it (exact headroom to confirm with real usage).
- **Switching protection on refuses every request without a proof** — including older app versions released before this protection and test devices that were not approved.
- **Store listings:** "Zakio - Kids Brain Games" on the Megz Games Google Play account and on the Ahmed Magdy App Store account (both created 2026-11-28, English (US) as the main language, free).

## Success metrics
- Share of verified requests per online service, close to 100% before protection is switched on.
- No support reports of families unable to connect because of a security check.
- No unexpected usage spikes on the bill.

## Dependencies & relationships
- Every feature that uses Zakio's online services.
- The store listings on Google Play and the App Store.

## Out of scope / non-goals
- Protecting the website (it is an information page only).
- Desktop apps.
- Automatically retrying when a single device's check fails — added with the first feature that needs it.

## Not built yet
- Genuine-app protection is not switched on for any online service yet — it waits for real users passing the check.
- The team's test devices are not approved yet.

## Sources
- No attachments — built from the owner's requests in chat (2026-11-28).
