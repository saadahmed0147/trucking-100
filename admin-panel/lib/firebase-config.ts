// Firebase configuration
// Replace these values with your actual Firebase project configuration
export const firebaseConfig = {
  apiKey: "AIzaSyCmg_aClHW5OKjQ-CQNYUk3SkZ7WJ_-9Wg",
  authDomain: "trucking-100-5223c.firebaseapp.com",
  databaseURL: "https://trucking-100-5223c-default-rtdb.firebaseio.com",
  projectId: "trucking-100-5223c",
  storageBucket: "trucking-100-5223c.firebasestorage.app",
  messagingSenderId: "801099113858",
  appId: "1:801099113858:web:1ff6b7ae790350efbbdb9b",
  measurementId: "G-RYSTWB41MZ"
};

// Database paths - adjust these according to your Firebase structure
export const DB_PATHS = {
  TRIPS: 'trips',
  USERS: 'users', 
  DRIVERS: 'drivers',
  VEHICLES: 'vehicles',
  BOOKINGS: 'bookings',
  PAYMENTS: 'payments',
  ANALYTICS: 'analytics'
} as const;
