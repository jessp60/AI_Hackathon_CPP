# Data Integration Plan

## What You Uploaded

### `data_event_calendar.csv`
Purpose:
- real scheduled Insight Association event dates by region

Columns:
- `IA Event Date`
- `Region`
- `Nearby Universities`
- `Suggested Lecture Window`
- `Course Alignment`

App use:
- primary seed data for the in-app event calendar
- basis for city unlock regions
- event reward opportunities by metro area

Notes:
- this is the most important file for the MVP calendar
- it still needs enrichment for exact venue, start time, end time, event title, and attendance verification settings

### `data_cpp_events_contacts.csv`
Purpose:
- catalog of Cal Poly Pomona programs, competitions, and event opportunities

Columns include:
- event/program name
- category
- recurrence
- host/unit
- volunteer roles
- audience
- public URL
- published contacts

App use:
- secondary content source for opportunity listings
- sponsor/partner/event pipeline
- future “missions” or “career opportunities” tab

Notes:
- this is not the same as a dated calendar feed
- best used for opportunity discovery, partnerships, and future event sourcing

### `data_cpp_course_schedule.csv`
Purpose:
- class schedule and guest lecture fit data

Columns include:
- instructor
- course
- section
- title
- days/times
- enrollment cap
- mode
- guest lecture fit

App use:
- outreach planning for aligning Insight events with courses
- admin dashboard insights
- future recommendation engine for which students should see which events

Notes:
- this is more useful for organizer/admin tooling than the student-facing MVP

### `data_speaker_profiles.csv`
Purpose:
- Insight leadership and speaker profile data by metro region

Columns include:
- name
- board role
- metro region
- company
- title
- expertise tags

App use:
- speaker cards on event detail pages
- mentor or NPC-style profile cards
- regional content for city unlock screens

Notes:
- this is strong flavor content for making each city feel distinct

## Best MVP Mapping

### Student-Facing Calendar
Use:
- `data_event_calendar.csv`

Why:
- it contains actual dated events by region

### Opportunity / Career / Partner Tab
Use:
- `data_cpp_events_contacts.csv`

Why:
- it is a curated opportunity inventory, not a schedule

### City Unlock System
Use:
- `data_event_calendar.csv`
- `data_speaker_profiles.csv`

Why:
- event regions define unlockable places
- speaker profiles help each region feel alive and specific

### Admin / Outreach Features
Use:
- `data_cpp_course_schedule.csv`

Why:
- helps coordinate guest lectures and campus targeting

## Recommended Firestore Collections

### `events`
Seed initially from:
- `data_event_calendar.csv`

Suggested fields:
- `id`
- `title`
- `date`
- `region`
- `citySlug`
- `nearbyUniversities`
- `suggestedLectureWindow`
- `courseAlignment`
- `venueName`
- `address`
- `latitude`
- `longitude`
- `rewardXp`
- `rewardCoins`
- `attendanceMethod`
- `status`

### `regions`
Seed initially from:
- unique regions in `data_event_calendar.csv`
- unique metro regions in `data_speaker_profiles.csv`

Suggested fields:
- `id`
- `name`
- `state`
- `heroCity`
- `latitude`
- `longitude`
- `speakerCount`
- `eventCount`
- `badgeName`
- `unlockDescription`

### `speakers`
Seed initially from:
- `data_speaker_profiles.csv`

Suggested fields:
- `id`
- `name`
- `boardRole`
- `metroRegion`
- `company`
- `title`
- `expertiseTags`
- `photoUrl`
- `bio`

### `opportunities`
Seed initially from:
- `data_cpp_events_contacts.csv`

Suggested fields:
- `id`
- `name`
- `category`
- `recurrence`
- `hostUnit`
- `volunteerRoles`
- `primaryAudience`
- `publicUrl`
- `contactName`
- `contactValue`

### `courses`
Seed initially from:
- `data_cpp_course_schedule.csv`

Suggested fields:
- `id`
- `instructor`
- `courseCode`
- `section`
- `title`
- `days`
- `startTime`
- `endTime`
- `mode`
- `guestLectureFit`

## Region and City Design

The uploaded data already suggests a strong region-based unlock system.

### Clear unlockable regions from the event calendar
- Portland
- San Diego
- Los Angeles
- San Francisco
- Seattle
- Ventura / Thousand Oaks
- Orange County / Long Beach

### Regional speaker coverage also supports
- Los Angeles — West
- Los Angeles — North
- Los Angeles — East
- Los Angeles — Long Beach

Recommendation:
- use a two-level map model
- level 1: unlock metro regions
- level 2: optionally add sub-regions later for Los Angeles variants

For MVP, keep it simple:
- one unlock per metro region
- one badge per region
- one featured speaker card per region

## Data Gaps To Fill Before Shipping

The CSVs are strong, but the app still needs a few fields that are not here yet:

- exact event start and end times
- exact venue names and addresses
- latitude/longitude for map pins and location unlock checks
- event descriptions and images
- event ownership/admin IDs
- attendance verification method per event

## Recommended Import Priority

1. Import `data_event_calendar.csv` into `events`
2. Create `regions` from the unique event regions
3. Import `data_speaker_profiles.csv` into `speakers`
4. Link one or more speakers to each region
5. Import `data_cpp_events_contacts.csv` into `opportunities`
6. Hold `data_cpp_course_schedule.csv` for admin features

## Product Recommendation

For the first playable demo, the best experience is:

- event calendar from `data_event_calendar.csv`
- avatar XP rewards on verified attendance
- map screen with unlockable metro regions
- each unlocked region reveals a badge plus featured speakers

That will feel like a real branded experience very quickly, using the data you already have.
