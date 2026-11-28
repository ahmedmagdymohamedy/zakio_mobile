# Release
_Ships every new version of Zakio to the store testers of both Google Play and the App Store in one step, the same way every time._

## Overview
A new version of the app has to reach testers on Android and iPhone quickly and without mistakes, because each store permanently reserves a version number the moment it is uploaded. Release is the one repeatable process that prepares both store versions, protects the shipped code from being copied, keeps the keys needed to read future crash reports, and delivers the builds to the testing tracks of both stores.

## Who it's for
- **The owner** — decides when a version ships and what number it carries.
- **The development team** — runs one step instead of two store-specific procedures.
- **Testers** — receive the same version on Android and iPhone.

## User stories

### US-01: One step ships both stores
**As the** owner, **I want** one step that delivers the new version to Google Play's internal testers and to TestFlight, **so that** both platforms get the same version with no manual store work.
**Acceptance criteria:**
- One run delivers Android first, then iPhone.
- If the iPhone half fails, the Android half stays delivered and the iPhone half can be re-run alone.
- Before anything is built, every missing requirement is listed at once and nothing is sent.

### US-02: Version numbers are never wasted
**As the** owner, **I want** the version number set only by me, **so that** no store version number is used up by mistake.
**Acceptance criteria:**
- The release never changes the version number by itself.
- Both stores receive exactly the version the owner set.

### US-03: Shipped code is protected and crashes stay readable
**As the** owner, **I want** the shipped app's code scrambled while every crash report stays readable to the team, **so that** the app is hard to copy and problems are still fixed fast.
**Acceptance criteria:**
- Every store version is built with scrambled code.
- The keys to read that version's crash reports reach the crash-reporting service before the store upload; if they cannot be sent, the version is not shipped.
- The keys are also kept by the team for every version.

## Business rules & constraints
- **Store records:** "Zakio - Kids Brain Games" on Google Play (Megz Games account) and on the App Store (Ahmed Magdy account), English (US) as the main language, free. Created 2026-11-28.
- **Testing tracks only:** releases go to Google Play internal testing and TestFlight. Public release is a separate, deliberate step.
- **Version numbers are permanent** in both stores once uploaded.
- **Apple's tool deadline:** from April 2027, iPhone versions must be prepared with Apple's newer tools.

## Success metrics
- Every release reaches both stores' testers in one run.
- No version number wasted by mistake.
- Every store version has readable crash reports.

## Dependencies & relationships
- **Monitoring** — receives each version's crash-report keys.
- **Security** — store copies are signed by Google Play; that signature is registered for genuine-app protection.

## Out of scope / non-goals
- Public (production) release and store listing content (texts, screenshots, ratings).
- Inviting testers.
- The website.

## Not built yet
- Testers are not invited yet on either store.
- Store listings (description, screenshots, content rating, privacy details) are not filled in.

## Sources
- No attachments — built from the owner's requests in chat (2026-11-28).
