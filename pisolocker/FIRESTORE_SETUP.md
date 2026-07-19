# Firestore Database Setup Guide for PisoLocker

This guide will help you set up the Firestore database collections for your PisoLocker app.

## Collections Overview

Your app uses two main collections:

1. **`users`** - Stores user profile information
2. **`lockers`** - Stores locker information and rental status

---

## 1. Users Collection

### Structure
Each user document should have the following fields:

```javascript
{
  uid: "user_uid_from_firebase_auth",  // Document ID
  fullName: "Juan Dela Cruz",
  email: "juan@example.com",
  phoneNumber: "+639171234567",
  studentId: "2024-00001",              // Optional
  creditScore: 100,                     // Default: 100
  profilePicUrl: "",                    // Empty by default
  createdAt: Timestamp,                 // Server timestamp
  updatedAt: Timestamp                  // Server timestamp
}
```

### Security Rules (already configured)
Users can only read/write their own data:
```
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

---

## 2. Lockers Collection

### Structure
Each locker document should have these fields:

```javascript
{
  // Auto-generated Document ID (e.g., "locker_001")
  
  name: "Locker 1",                              // String
  location: "Ground Floor - Near Entrance",      // String
  status: "Available",                           // String: "Available", "Occupied", or "Maintenance"
  currentBalance: 0.0,                           // Number (in Piso)
  remainingTimeMinutes: 0,                       // Number
  rentedBy: null,                                // String (user UID) or null
  rentalEndTime: null                            // Timestamp or null
}
```

### Status Values
- **`"Available"`** - Locker is free to rent
- **`"Occupied"`** - Locker is currently rented
- **`"Maintenance"`** - Locker is under maintenance, cannot be rented

### Sample Documents

#### Available Locker
```javascript
{
  name: "Locker 1",
  location: "Ground Floor - Near Entrance",
  status: "Available",
  currentBalance: 0.0,
  remainingTimeMinutes: 0,
  rentedBy: null,
  rentalEndTime: null
}
```

#### Occupied Locker
```javascript
{
  name: "Locker 2",
  location: "Ground Floor - Near Entrance",
  status: "Occupied",
  currentBalance: 5.0,
  remainingTimeMinutes: 100,
  rentedBy: "user_uid_12345",
  rentalEndTime: Timestamp(2024-01-15 14:30:00)
}
```

#### Under Maintenance
```javascript
{
  name: "Locker 3",
  location: "First Floor - Hallway A",
  status: "Maintenance",
  currentBalance: 0.0,
  remainingTimeMinutes: 0,
  rentedBy: null,
  rentalEndTime: null
}
```

---

## Initial Setup Steps

### Option 1: Automatic (Recommended)
The app will automatically create 5 default lockers when you first access the locker screen. No manual setup needed!

Default lockers created:
- Locker 1: Ground Floor - Near Entrance
- Locker 2: Ground Floor - Near Entrance
- Locker 3: First Floor - Hallway A
- Locker 4: First Floor - Hallway A
- Locker 5: Second Floor - Near Elevator

### Option 2: Manual Setup via Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Firestore Database**
4. Click **Start collection**
5. Collection ID: `lockers`
6. Add documents with the structure shown above

---

## Firestore Security Rules for Lockers

Add these rules to your `firestore.rules` file:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection - users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Lockers collection - authenticated users can read all lockers
    // Only server/admin can write (through Cloud Functions or admin SDK)
    match /lockers/{lockerId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;  // Update this for production with admin checks
    }
  }
}
```

### Deploy Rules
```bash
firebase deploy --only firestore:rules
```

---

## How the App Uses Lockers

### Renting a Locker
1. User selects an available locker
2. App updates Firestore:
   - `status` → "Occupied"
   - `rentedBy` → user's UID
   - `rentalEndTime` → current time + rental duration
   - `remainingTimeMinutes` → duration in minutes
   - `currentBalance` → coins inserted

### Adding Time (Inserting Coins)
1. User inserts coins via the app
2. App updates:
   - `remainingTimeMinutes` → increases
   - `currentBalance` → increases
   - `rentalEndTime` → extended

### Releasing a Locker
When rental ends or user manually ends session:
- `status` → "Available"
- `rentedBy` → deleted
- `rentalEndTime` → deleted
- `remainingTimeMinutes` → reset to 0
- `currentBalance` → reset to 0

---

## Testing Your Setup

1. **Run the app** and navigate to the Locker screen
2. You should see 5 lockers listed with their locations
3. All lockers should show "Available" status initially
4. Try renting a locker - it should update to "Occupied" in real-time
5. Check Firebase Console → Firestore to see the updated data

---

## Troubleshooting

### Lockers not showing up?
- Check if you're logged in (authentication required)
- Verify Firestore is enabled in your Firebase project
- Check console logs for error messages

### Permission denied errors?
- Make sure Firestore security rules are deployed
- Verify user is authenticated

### Need to reset all lockers?
You can delete all locker documents and the app will recreate them on next launch, or run this in Firebase Console's data tab:

```javascript
// Delete all lockers and they'll be recreated automatically
```

---

## Next Steps

After setting up lockers, you can:
1. Test the rental flow
2. Implement admin features to set maintenance mode
3. Add notifications for expiring rentals
4. Track rental history in a separate `rentals` collection

For questions or issues, check the app logs or Firebase Console logs.
