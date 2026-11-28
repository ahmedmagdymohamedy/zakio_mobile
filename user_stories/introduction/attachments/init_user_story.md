Epic 1: Introduction & First-Time Onboarding

Description: This epic covers the user's very first interaction with the Zakio app, from the moment the app launches to the moment they are handed off to the Authentication flow. The primary goal is to hook the parent, explain the scientific and educational value of the app (brain strengthening), and ensure a completely frictionless, visually stunning first impression.

1. User Story: Splash Screen & Intelligent Routing

As a system, I want to display a branded splash screen while checking the user's current state, so that the user has a smooth visual entry while the app decides whether to show the Introduction, the Login screen, or the Home Dashboard.

Acceptance Criteria:

The splash screen must display the Zakio logo centered on the screen with the primary brand background color.

The splash screen must remain visible for a minimum of 2 seconds to prevent jarring, rapid screen flashes.

Logic Routing:

Condition A: If the app is launched for the very first time after installation -> Route to Intro Screen 1.

Condition B: If the user has completed the intro previously but is NOT logged in -> Route to Authentication Flow.

Condition C: If the user is fully authenticated with an active session -> Route to Children List/Home Dashboard.

2. User Story: Intro Screen 1 - The Hook (Welcome & Emotion)

As a first-time parent user, I want to see an emotionally engaging welcome screen with high-quality animation, so that I immediately feel Zakio is a premium, safe, and joyful environment for my child.

Acceptance Criteria:

Display an engaging, smooth animation featuring the Zakio mascot or joyful children.

Display a clear, bold Headline (e.g., "Welcome to Zakio!").

Display a short Subtitle explaining the app's emotional value (e.g., "Where fun meets learning in a safe environment.").

Include global navigation elements (See Story 6).

3. User Story: Intro Screen 2 - The Core Value (Brain Strengthening)

As a first-time parent user, I want to see an explanation of how the app specifically strengthens my child's brain, so that I understand the scientific and educational value behind the gameplay.

Acceptance Criteria:

Display a smooth transition animation that visually represents cognitive growth (e.g., puzzle pieces coming together, or a glowing brain conceptualization).

Display a Headline focused on cognitive development (e.g., "Supercharge Their Mind").

Display a Subtitle explaining the method (e.g., "Scientifically designed games that build logic, memory, and problem-solving skills.").

Maintain global navigation elements.

4. User Story: Intro Screen 3 - Adaptive Learning & Methodology

As a first-time parent user, I want to learn that the app adapts to my child's specific intelligence level, so that I am reassured the content won't be too easy (boring) or too hard (frustrating).

Acceptance Criteria:

Display an animation representing levels, growth, or a personalized path.

Display a Headline emphasizing personalization (e.g., "Grows With Your Child").

Display a Subtitle (e.g., "Smart placement tests ensure your child always plays at the perfect difficulty level.").

Maintain global navigation elements.

5. User Story: Intro Screen 4 - Parental Control & Call to Action

As a first-time parent user, I want to know that I can track my child's progress and manage their experience, so that I feel fully in control of their digital learning journey before creating an account.

Acceptance Criteria:

Display an animation showing a parent dashboard, charts, or progress reports.

Display a Headline emphasizing parental involvement (e.g., "Track Every Milestone").

Display a Subtitle (e.g., "Get detailed insights into their cognitive growth and celebrate their wins.").

The "Next" button must transition into a prominent, primary CTA button labeled "Get Started" or "Create Account".

6. User Story: Onboarding Navigation & Gestures

As a user navigating the intro screens, I want clear, intuitive controls to swipe between pages, skip the tutorial, or proceed manually, so that I can consume the information at my own pace or bypass it if I am in a hurry.

Acceptance Criteria:

Swiping: The user must be able to swipe left and right to transition between screens seamlessly.

Pagination Indicator: Display distinct dots at the bottom of the screen indicating the total number of pages and the current active page.

Skip Button: A "Skip" button must be clearly visible in the top-right corner on Screens 1, 2, and 3. Tapping "Skip" immediately routes the user to the Authentication flow.

Next Button: A "Next" button (or arrow) must be visible on the bottom right for Screens 1, 2, and 3.

Transition Smoothness: Moving between screens must trigger the next animation fluidly without lag.

7. User Story: Analytics & Drop-off Tracking (Hidden Business Requirement)

As a Product Manager, I want the system to track user behavior during the onboarding flow behind the scenes, so that I can analyze where parents lose interest and optimize the screens for better conversion rates.

Acceptance Criteria:

The system must log an event when the user views each specific intro screen (e.g., event: intro_screen_viewed, property: screen_number).

The system must track the time spent on each screen.

The system must log an event if the user taps "Skip," recording exactly which screen they skipped from.

The system must log a success event when the user clicks "Get Started" on the final screen.

Improvisations & Suggestions:

Sound Design: Do not underestimate the power of audio. I suggest adding a very subtle, uplifting background music track that plays during the onboarding, along with soft "pop" sound effects when the user swipes between screens. (You can add an option to mute this, but having it on by default creates a premium feel).

Haptic Feedback: When the user reaches the final screen, and the "Get Started" button appears, trigger a gentle vibration (haptic feedback) on the device to physically prompt them to take action.

Pre-fetching Data: While the user is slowly reading these 4 introduction screens, use that background time to silently initialize the necessary backend connections for the upcoming Authentication flow so that when they click "Get Started," the next page loads instantly.