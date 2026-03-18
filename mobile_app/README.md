# Insight Quest Mobile

This is the Flutter version of Insight Quest intended to support both Android and iPhone from one codebase.

## What Is Included

- `pubspec.yaml`
- `lib/main.dart`
- seeded event calendar, cities, and profile screens
- email/password auth scaffold

## First-Time Setup

Flutter was not installed in the current shell environment, so the native runner folders were not auto-generated here.

After installing Flutter on your machine:

1. Open a terminal in `/Users/jessicapinto/Documents/GitHub/AI_Hackathon_CPP/mobile_app`
2. Run `flutter create .`
3. Run `flutter pub get`

That will generate the Android and iOS platform folders around the app code already in this directory.

## Run On Android

1. Start an Android emulator or connect an Android phone
2. Run `flutter run`

## Run On iPhone

1. Open Xcode and install any required iOS simulator components
2. Start an iPhone simulator, or connect a real iPhone
3. Run `flutter run`

You can also open `ios/Runner.xcworkspace` in Xcode after `flutter create .` has generated the iOS project.

## Next Implementation Step

Replace the seeded demo data with:

- parsed CSV-backed local data
- Firebase backend data
- real attendance check-in and location unlock logic

For account sharing, see `/Users/jessicapinto/Documents/GitHub/AI_Hackathon_CPP/docs/firebase-auth-plan.md`.
