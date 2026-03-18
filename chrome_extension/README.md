# Insight Quest Chrome Extension

This Chrome extension shows today's Insight Association events in a popup and can send same-day notifications.

## What It Includes

- `manifest.json`: Manifest V3 extension config
- `popup.html`, `popup.css`, `popup.js`: popup UI
- `background.js`: reminder and notification logic
- `events.js`: local seeded event feed
- Firebase email/password auth in the popup
- `firebase-config.js`: Firebase auth endpoints/config

## Load In Chrome

1. Open `chrome://extensions`
2. Turn on Developer mode
3. Click `Load unpacked`
4. Select `/Users/jessicapinto/Documents/GitHub/AI_Hackathon_CPP/chrome_extension`

## Test Notifications

1. Click the extension icon
2. Press `Test Today's Notification`
3. Allow notifications if Chrome asks

## Test Account Login

1. Make sure Email/Password auth is enabled in Firebase Console
2. Load the extension in `chrome://extensions`
3. Create an account or sign in with the same email/password you use in the app
4. Reopen the popup to confirm the session is still active

## How Notifications Work

- the extension checks once on install
- it also runs an hourly alarm
- it stores `lastNotificationDate` in `chrome.storage.local`
- it only auto-notifies once per day

## Data Source

The current event feed is local and seeded from `data_event_calendar.csv`.

Next recommended upgrade:

- replace `events.js` with a JSON feed or Firebase-backed sync
- let the extension share event data with the mobile app/backend
- sync profile, badges, and saved events from Firestore after login
