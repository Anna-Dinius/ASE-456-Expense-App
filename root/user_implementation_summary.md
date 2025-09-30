### User Profile Feature – Implementation Summary

This app now supports creating, editing, and signing in to user accounts using Firebase Auth and Firestore.

## What’s new
- Added email/password authentication.
- Created and updates user profiles in Firestore at `users/{uid}`.
- Three profile screens:
  - `ProfileCreationScreen`: sign up (name, email, password)
  - `ProfileSummaryScreen`: view profile, sign out, go to edit
  - `ProfileEditingScreen`: edit name, phone, profile image URL
- Home shows a new person icon to open the profile summary.

## New files
- `lib/service/auth_service.dart`: small wrapper for sign up/in/out and auth state stream.
- `lib/service/user_service.dart`: reads/writes `users/{uid}` in Firestore.
- `lib/view/profile_creation.dart`: sign-up form; creates user doc if missing.
- `lib/view/profile_summary.dart`: shows user info; edit + sign out.
- `lib/view/profile_editing.dart`: edit and save profile fields.
- `lib/view/sign_in.dart`: sign-in form for existing users.

## Modified files
- `pubspec.yaml`
  - Added `firebase_auth` dependency.
- `lib/main.dart`
  - Replaced hardcoded user with Firebase `currentUser.uid`.
  - Added `AuthGate` (if signed out → creation screen; if signed in → home).
  - Passed `userId` into `MyHomePage` for user-specific data.
  - Added a profile button in the app bar to open the summary screen.
- `lib/view/profile_summary.dart`
  - Shows a snackbar on sign-out and returns to the start so `AuthGate` shows sign in/up.

## Data model (Firestore)
- Collection: `users`
  - Doc id: `uid`
  - Fields used now: `id`, `name`, `email`, `phoneNumber`, `profileImageUrl`, `createdAt`, `lastUpdatedAt`
  - Subcollections: `categories`, `transactions` (unchanged; now use `userId` from auth)

## How it works (simple flow)
1. App starts → `AuthGate` checks if a user is signed in.
2. If not signed in → `ProfileCreationScreen` (with a link to `SignInScreen`).
3. After sign up/sign in → a user doc is created if missing → go to Home.
4. Tap the person icon in the Home app bar → `ProfileSummaryScreen`.
5. Tap Edit Profile → `ProfileEditingScreen` to update your info.
6. Tap the logout icon on the summary screen to sign out.


## Quick test checklist
- Sign up with a new email → profile doc appears in Firestore.
- Open profile → see name/email.
- Edit profile (name/phone/image URL) → changes saved.
- Sign out → app returns to sign in/up.
- Sign in with an existing user → lands in the app and loads that user’s data.


