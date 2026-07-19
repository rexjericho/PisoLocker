# Firebase Setup Guide for PisoLocker

## Prerequisites
- Firebase project created at [console.firebase.google.com](https://console.firebase.google.com)
- Flutter app connected to Firebase (firebase_core configured)

## Step 1: Enable Authentication
1. Go to Firebase Console → **Authentication** → **Sign-in method**
2. Enable **Email/Password** provider
3. Save changes

## Step 2: Create Firestore Database
1. Go to Firebase Console → **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (we'll update rules next)
4. Select a location closest to your users
5. Click **Enable**

## Step 3: Deploy Security Rules
You need to update the Firestore security rules to allow the app to work properly.

### Option A: Using Firebase CLI (Recommended)
```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project (if not done)
firebase init firestore

# Deploy the rules
firebase deploy --only firestore:rules
```

### Option B: Manual Copy-Paste
1. Go to Firebase Console → **Firestore Database** → **Rules** tab
2. Delete existing rules
3. Copy the contents of `firestore.rules` from this project
4. Paste into the console editor
5. Click **Publish**

## Step 4: Verify Configuration
1. Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are in place
2. Run the app
3. Sign up a new user
4. Check Firestore Console → **Data** tab to see if `users` collection is created

## Troubleshooting

### "Permission Denied" Errors
- Verify you deployed the security rules correctly
- Ensure the user is authenticated before accessing Firestore
- Check that the rules match your collection structure

### "FirebaseException" on Startup
- Verify `Firebase.initializeApp()` is called before any Firebase service usage
- Check that your `firebase_options.dart` is correctly generated

## Collections Structure

### users
- Document ID: User's UID
- Fields: `email`, `fullName`, `phoneNumber`, `createdAt`, `profilePicture` (optional)

### lockers
- Document ID: Auto-generated or custom locker code
- Fields: `lockerCode`, `location`, `status`, `rentedBy`, `rentalEndTime`, `createdAt`
