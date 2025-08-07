# Fuel Route Admin Panel

A comprehensive admin dashboard for managing your Flutter fuel route trucking app, built with Next.js 14, TypeScript, and Firebase.

## 🚀 Features

- **Dashboard**: Real-time analytics and trip monitoring
- **User Management**: View and manage registered users
- **Trip Management**: Track active, completed, and upcoming trips
- **Analytics**: Revenue, fuel consumption, and performance metrics
- **Payment Management**: Transaction history and payment processing
- **POI Management**: Points of Interest along routes
- **Settings**: System configuration and preferences

## 🛠 Tech Stack

- **Next.js 14** - React framework with App Router
- **TypeScript** - Type-safe development
- **Tailwind CSS** - Utility-first styling
- **Shadcn/ui** - Modern UI components
- **Firebase** - Real-time database and authentication
- **Recharts** - Data visualization
- **React Hook Form** - Form management with validation

## 📦 Installation

1. Install dependencies:
```bash
npm install
```

2. Configure Firebase:
   - Open `lib/firebase-config.ts`
   - Replace the placeholder values with your actual Firebase project configuration:

```typescript
export const firebaseConfig = {
  apiKey: "your-actual-api-key",
  authDomain: "your-project.firebaseapp.com",
  databaseURL: "https://your-project-default-rtdb.firebaseio.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "your-app-id"
};
```

3. Start the development server:
```bash
npm run dev
```

4. Open [http://localhost:3000](http://localhost:3000) in your browser

## 🔧 Firebase Setup

### 1. Database Structure
Make sure your Firebase Realtime Database has the following structure:

```json
{
  "users": {
    "userId1": {
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "+1234567890",
      "role": "driver",
      "status": "active",
      "joinDate": "2024-01-15"
    }
  },
  "trips": {
    "tripId1": {
      "driverId": "userId1",
      "origin": "New York, NY",
      "destination": "Los Angeles, CA",
      "status": "active",
      "startDate": "2024-01-20",
      "endDate": "2024-01-25",
      "distanceMiles": 2800,
      "fuelCost": 850.50,
      "vehicleId": "vehicle1"
    }
  }
}
```

### 2. Database Rules
Set up Firebase database rules for security:

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

## 📱 Real-time Features

The admin panel automatically syncs with your Firebase database:

- **Live Dashboard**: Statistics update in real-time
- **Trip Monitoring**: Active trip status changes instantly
- **User Activity**: Real-time user registration and activity tracking
- **Revenue Tracking**: Live payment and revenue updates

## 🎨 Customization

### Styling
- Modify `tailwind.config.ts` for theme customization
- Update component styles in `components/ui/`
- Dark mode support is built-in

### Components
- Add new UI components in `components/ui/`
- Create custom dashboard widgets in `components/dashboard/`
- Extend data visualization in `components/charts/`

## 📊 Data Management

### Fetching Data
```typescript
import { FirebaseService } from '@/lib/firebase'

// Get all trips
const trips = await FirebaseService.getTrips()

// Subscribe to real-time updates
const unsubscribe = FirebaseService.subscribeToTrips((trips) => {
  console.log('Updated trips:', trips)
})
```

### Statistics
The dashboard automatically calculates:
- Total revenue and fuel costs
- Active vs completed trips
- Average trip distance
- User growth metrics

## 🔐 Security

- Firebase authentication required for all operations
- Database rules protect sensitive data
- Type-safe API calls with TypeScript
- Input validation with Zod schemas

## 🚀 Deployment

### Vercel (Recommended)
1. Push your code to GitHub
2. Connect your repository to Vercel
3. Add environment variables:
   - `NEXT_PUBLIC_FIREBASE_API_KEY`
   - `NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN`
   - `NEXT_PUBLIC_FIREBASE_DATABASE_URL`
   - `NEXT_PUBLIC_FIREBASE_PROJECT_ID`
   - `NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET`
   - `NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID`
   - `NEXT_PUBLIC_FIREBASE_APP_ID`

### Other Platforms
The app can be deployed to any Node.js hosting platform:
- Netlify
- Railway
- DigitalOcean App Platform
- AWS Amplify

## 📋 Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is for internal use with the Fuel Route trucking application.

## 🐛 Troubleshooting

### Common Issues

1. **Firebase Connection Error**
   - Check your `firebase-config.ts` file
   - Verify Firebase project settings
   - Ensure database rules allow read/write access

2. **Build Errors**
   - Run `npm install` to ensure all dependencies are installed
   - Check TypeScript errors with `npm run lint`

3. **Real-time Updates Not Working**
   - Verify Firebase database URL is correct
   - Check browser console for JavaScript errors
   - Ensure proper database permissions

### Getting Help

If you encounter issues:
1. Check the browser console for errors
2. Verify Firebase configuration
3. Review the component documentation
4. Check database structure matches expected format

---

Built with ❤️ for efficient fleet management and route optimization.
