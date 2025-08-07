# Firebase Setup Guide

## Step 1: Get Firebase Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Click on **Project Settings** (gear icon)
4. Scroll down to **Your apps** section
5. Click on **Web app** (</> icon) to add or view web app
6. Copy the `firebaseConfig` object

## Step 2: Configure the Admin Panel

1. Open `lib/firebase-config.ts` in your admin panel
2. Replace the placeholder values with your actual Firebase configuration:

```typescript
export const firebaseConfig = {
  apiKey: "AIzaSyD...", // Your actual API key
  authDomain: "your-project.firebaseapp.com",
  databaseURL: "https://your-project-default-rtdb.firebaseio.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com", 
  messagingSenderId: "123456789",
  appId: "1:123456789:web:..."
};
```

## Step 3: Database Structure

Make sure your Firebase Realtime Database has this structure:

```json
{
  "users": {
    "user_id_1": {
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "+1234567890",
      "role": "driver",
      "status": "active",
      "joinDate": "2024-01-15",
      "profilePicture": "https://...",
      "location": {
        "lat": 40.7128,
        "lng": -74.0060,
        "address": "New York, NY"
      }
    }
  },
  "trips": {
    "trip_id_1": {
      "driverId": "user_id_1",
      "origin": "New York, NY",
      "destination": "Los Angeles, CA", 
      "status": "active", // active, completed, cancelled
      "startDate": "2024-01-20T08:00:00Z",
      "endDate": "2024-01-25T18:00:00Z",
      "distanceMiles": 2800,
      "fuelCost": 850.50,
      "vehicleId": "vehicle_1",
      "route": {
        "waypoints": [
          {
            "lat": 40.7128,
            "lng": -74.0060,
            "name": "New York, NY"
          },
          {
            "lat": 34.0522,
            "lng": -118.2437,
            "name": "Los Angeles, CA"
          }
        ]
      }
    }
  },
  "vehicles": {
    "vehicle_1": {
      "make": "Freightliner",
      "model": "Cascadia",
      "year": 2023,
      "licensePlate": "ABC123",
      "status": "active",
      "fuelEfficiency": 7.5,
      "currentLocation": {
        "lat": 40.7128,
        "lng": -74.0060
      }
    }
  },
  "bookings": {
    "booking_1": {
      "userId": "user_id_1",
      "tripId": "trip_id_1", 
      "status": "confirmed",
      "bookingDate": "2024-01-18T10:00:00Z",
      "amount": 850.50,
      "paymentStatus": "paid"
    }
  }
}
```

## Step 4: Database Rules

Set up Firebase database rules for security:

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null",
    "users": {
      "$userId": {
        ".read": "auth != null",
        ".write": "auth != null && auth.uid == $userId"
      }
    },
    "trips": {
      ".read": "auth != null",
      ".write": "auth != null"
    }
  }
}
```

## Step 5: Start the Admin Panel

1. Double-click `start-dev.bat` or run:
```bash
npm run dev
```

2. Open http://localhost:3000 in your browser

## Troubleshooting

### Firebase Connection Issues
- Verify your `firebaseConfig` values are correct
- Check that your Firebase project has Realtime Database enabled
- Ensure database rules allow read/write access

### Build Errors
- Run `npm install` to ensure all dependencies are installed
- Check for TypeScript errors with `npm run lint`

### Data Not Loading
- Verify your database structure matches the expected format
- Check browser console for JavaScript errors
- Ensure Firebase database URL ends with `.firebaseio.com`

## Quick Test Data

To quickly test the admin panel, add this sample data to your Firebase:

```json
{
  "users": {
    "test_user_1": {
      "name": "John Smith", 
      "email": "john.smith@example.com",
      "phone": "+1-555-0123",
      "role": "driver",
      "status": "active",
      "joinDate": "2024-01-15"
    }
  },
  "trips": {
    "test_trip_1": {
      "driverId": "test_user_1",
      "origin": "Dallas, TX",
      "destination": "Houston, TX",
      "status": "active",
      "startDate": "2024-01-20T08:00:00Z",
      "distanceMiles": 240,
      "fuelCost": 120.50
    }
  }
}
```
