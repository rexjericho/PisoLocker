# Firebase Firestore Setup Guide for PisoLocker

## Problem Fixed
The signup screen was throwing an error when clicking "Create Account" due to:
1. Missing Firestore security rules configuration
2. Storing plain text passwords (security issue)
3. Insufficient error handling for Firestore operations

## Changes Made

### 1. Created Firestore Security Rules (`firestore.rules`)
- Allows authenticated users to read/write their own user document
- Allows authenticated users to read locker data
- Restricts write access to lockers for admin users only

### 2. Updated `firebase.json`
- Added Firestore rules and indexes configuration

### 3. Fixed `signup_screen.dart`
- Removed storing plain text passwords (security best practice)
- Added `SetOptions(merge: true)` to prevent overwriting existing documents
- Used `FieldValue.serverTimestamp()` for consistent server timestamps
- Added better error handling with specific error messages for:
  - Permission denied errors
  - Database unavailable errors
  - Email/password not enabled in Firebase Console
- Added null check for user credential

## Steps to Complete Setup

### Step 1: Deploy Firestore Rules
Run the following command in your terminal (requires Firebase CLI):
```bash
cd /workspace/pisolocker
firebase deploy --only firestore:rules
```

If you don't have Firebase CLI installed:
```bash
npm install -g firebase-tools
firebase login
firebase deploy --only firestore:rules
```

### Step 2: Enable Email/Password Authentication in Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/project/pisolocker)
2. Navigate to **Authentication** → **Sign-in method**
3. Click on **Email/Password**
4. Toggle **Enable** to ON
5. Click **Save**

### Step 3: Create Firestore Database
1. Go to [Firebase Console](https://console.firebase.google.com/project/pisolocker)
2. Navigate to **Firestore Database**
3. Click **Create database**
4. Choose **Start in test mode** (for development) or apply the security rules manually
5. Select a location closest to your users
6. Click **Enable**

### Step 4: Apply Security Rules Manually (if not using CLI)
1. In Firebase Console, go to **Firestore Database** → **Rules**
2. Copy the content from `firestore.rules` file
3. Paste into the rules editor
4. Click **Publish**

## Testing the Fix

After completing the setup steps:
1. Run your Flutter app
2. Go to the signup screen
3. Enter valid credentials:
   - Full Name: Any name
   - Email: Valid email format
   - Password: At least 6 characters
   - Confirm Password: Must match
   - Check "I agree to Terms & Conditions"
4. Click "Create Account"
5. You should see a success message and be redirected to login

## Troubleshooting

### Error: "Permission denied"
- Make sure you've deployed the Firestore rules
- Verify Email/Password authentication is enabled in Firebase Console

### Error: "Email/password accounts are not enabled"
- Go to Firebase Console → Authentication → Sign-in method
- Enable Email/Password provider

### Error: "Database unavailable"
- Check your internet connection
- Verify Firestore database is created in Firebase Console

## Security Notes

- Passwords are NO LONGER stored in Firestore (handled by Firebase Auth)
- User data is protected by security rules
- Only users can modify their own documents
- Admin role is required to modify locker data
