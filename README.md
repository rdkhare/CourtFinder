# CourtFinder 🏀

CourtFinder is an iOS app that helps basketball enthusiasts find nearby courts in real-time, save their favorite spots, and connect with other players.

## Features

### 🗺️ Court Discovery
- **Real-time Court Location**: Find basketball courts near your current location
- **Interactive Map**: View courts on an interactive Google Map with custom markers
- **List View**: Switch between map and list views to browse courts easily
- **Search**: Search courts by name or address
- **Court Details**: View court information including:
  - Distance from your location
  - Ratings and reviews
  - Open/closed status
  - Court type information

### ❤️ Favorites System
- **Save Favorite Courts**: Mark courts as favorites for quick access
- **Offline Availability**: View your favorite courts even when you're not near them
- **Synced Storage**: Favorites are synced with your account across devices

### 👤 User Profiles
- **Secure Authentication**: Login with email or Google Sign-In
- **Profile Management**: Customize your profile with a photo and personal details
- **Settings**: Manage app preferences and account information

### 👥 Groups (Coming Soon)
- Connect with other players and organize games
- Join existing groups in your area
- Schedule meetups at your favorite courts

## Technologies

CourtFinder is built with modern technologies:

- **Swift & SwiftUI**: Modern, declarative UI framework
- **Firebase Authentication**: Secure user authentication
- **Firestore**: Real-time database for storing user data and favorite courts
- **Google Maps SDK**: Interactive maps and location services
- **Google Places API**: Comprehensive basketball court data
- **Core Location**: Precise user location tracking
- **Async/Await**: Modern concurrency for smooth performance

## Getting Started

### Prerequisites
- Xcode 14.0+
- iOS 16.0+
- CocoaPods (for dependency management)
- Google Maps API key
- Firebase account and configuration

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/CourtFinder.git
cd CourtFinder
```

2. Create a `GoogleService-Info.plist` file from your Firebase console and add it to the project

3. Add your Google Maps API key to the Info.plist file under the key `GMSApiKey`

4. Open the `.xcodeproj` file:
```bash
open CourtFinder.xcodeproj
```

5. Build and run the app in Xcode

## Architecture

CourtFinder follows MVVM (Model-View-ViewModel) architecture:

- **Models**: Represent data structures (Court, User)
- **Views**: SwiftUI views for different screens
- **ViewModels**: Handle business logic and state management
- **Services**: Provide API access and data processing

## Privacy & Security

- User data is securely stored in Firebase
- Location data is only accessed with explicit user permission
- API keys are securely managed to prevent exposure

## Future Improvements
- Additional Sports
- Chat functionality for groups
- Court check-ins and status updates
- User ratings and reviews for courts
- Advanced filtering options
- Dark mode support
- iPad optimization

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

Developed with ❤️ by Rajat Khare