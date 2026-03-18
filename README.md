# Insight Quest

Insight Quest is an Android game concept where students grow their avatar by attending Insight Association events and unlock new cities as they travel.

The idea combines:

- event attendance from an in-app calendar
- RPG-style avatar progression
- city exploration tied to real-world travel
- optional location features for discovery and rewards

## Core Concept

Students open the app, view upcoming Insight Association events, check in when they attend, and earn experience points (XP), items, and cosmetic upgrades for their character. As they travel to new places, they unlock cities on a world map and collect region-based rewards.

## Core Gameplay Loop

1. Browse the event calendar.
2. RSVP or mark interest in an event.
3. Attend the event and verify attendance.
4. Earn XP, coins, badges, or gear.
5. Level up the avatar and unlock customization.
6. Travel to a new city and unlock a new map node.
7. Discover city-specific rewards, quests, or event streak bonuses.

## MVP Features

### 1. Student Profile
- sign in with email, Google, or school account
- simple avatar selection and profile setup
- current level, XP bar, badges, and unlocked cities

### 2. Event Calendar
- monthly and list view of Insight Association events
- event details: name, date, location, host, category
- RSVP or save event

### 3. Attendance Rewards
- verified attendance gives XP and rewards
- streak bonuses for repeat attendance
- badges for milestones such as first event, five events, leadership events, and workshop streaks

### 4. Avatar Progression
- levels unlock outfits, accessories, titles, and visual effects
- optional stat themes like knowledge, leadership, networking, and exploration
- purely cosmetic progression is safest for MVP

### 5. City Unlock System
- unlock a city the first time the user is detected there
- city map shows visited and locked locations
- each city can grant a badge, postcard, or themed cosmetic

### 6. Location Features
- request location permission only when needed
- detect city-level presence rather than precise movement for privacy
- geofencing or periodic city checks can support unlocks

## Recommended Tech Stack

For this concept, a regular Android app is a better fit than a heavy game engine because the product depends on calendars, accounts, notifications, maps, and location services.

- Android client: Kotlin + Jetpack Compose
- Architecture: MVVM + Repository pattern
- Backend: Firebase
- Auth: Firebase Authentication
- Database: Firestore
- Media/assets: Firebase Storage
- Notifications: Firebase Cloud Messaging
- Maps/location: Google Maps SDK + Fused Location Provider + Geofencing

## Attendance Verification Options

Choose one or combine them:

- QR code check-in at events
- organizer approval after attendance
- geofence check-in near event venue during event time
- one-time event code shown at the venue

Best MVP choice:

- QR code or event code

That is simpler and more trustworthy than passive location alone.

## Location Design Recommendation

Use location for discovery, not constant tracking.

- store city name and coarse coordinates
- unlock a city only after the user opts in
- avoid background tracking unless clearly necessary
- explain why location is requested: unlock cities and local event rewards

This keeps the app more privacy-friendly and easier to approve in the Play Store.

## Suggested Data Model

### User
- id
- name
- school
- level
- xp
- coins
- currentAvatarId
- unlockedCities[]
- badges[]
- attendedEventIds[]

### Event
- id
- title
- description
- startTime
- endTime
- venueName
- latitude
- longitude
- city
- rewardXp
- rewardCoins
- attendanceMethod

### Attendance
- id
- userId
- eventId
- checkedInAt
- verificationType

### CityUnlock
- id
- userId
- cityName
- unlockedAt
- latitude
- longitude

## MVP User Story Set

- As a student, I can see upcoming Insight Association events in a calendar.
- As a student, I can check in to an event and earn XP.
- As a student, I can level up my avatar and equip unlocked cosmetics.
- As a student, I can unlock a city when I visit a new place.
- As a student, I can see my progress, badges, and visited cities.

## Phase 2 Ideas

- teams or guilds by campus
- friend lists and leaderboards
- city quests and regional collections
- event mini-games
- sponsor rewards
- AR photo moments in unlocked cities

## Build Order

1. Authentication and student profile
2. Event calendar and event detail screens
3. Attendance check-in flow
4. XP, levels, and avatar inventory
5. City unlock flow with location permission
6. Map/progress screen
7. Notifications and streak reminders

## What To Build First

If we start implementation next, the best first milestone is:

`Android app with sign-in, event calendar, QR/event-code check-in, XP leveling, and a simple city unlock screen.`

That gives you a real demo quickly and leaves room to add richer game visuals later.

## Current Data Sources In This Repo

The uploaded CSV files already give us a useful foundation:

- `data_event_calendar.csv`: scheduled Insight Association regional event dates and regions
- `data_cpp_events_contacts.csv`: campus programs and opportunity/contact inventory
- `data_cpp_course_schedule.csv`: course alignment data for outreach and targeting
- `data_speaker_profiles.csv`: speaker and board profiles by metro region

See `docs/data-integration.md` for how these map into the app.

## test code
## testing again