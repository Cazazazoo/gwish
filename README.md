# 🎁 gwish

**gwish** is a native iOS app built with SwiftUI and Firebase that helps users track gift ideas, manage wishlists, and manage profiles of loved ones.

---

## Features

- Create and manage multiple personal wishlists
- Add detailed gift ideas (price, priority, link, category, occasion)
- Mark items as purchased or completed
- Support for profiles (e.g. friend, partner, sibling)
- Clean MVVM architecture for maintainability

---

## Technologies

- SwiftUI (UI)
- Firebase Firestore (Database)
- Firebase Auth (Authentication)
- Firebase Cloud Functions (Backend automation)
- MVVM Design Pattern (Architecture)

---

## Getting Started

### Prerequisites

- Xcode 15 or newer
- Swift Package Manager (SPM)
- A Firebase project with Firestore & Authentication enabled

---

### Setup Instructions

1. **Clone the repo**
   git clone https://github.com/Cazazazoo/gwish.git
   cd gwish

2. **Install Firebase SDK using SPM**
   - In Xcode: `File` → `Add Packages...`
   - Use this URL:
     https://github.com/firebase/firebase-ios-sdk
   - Add:
     - FirebaseAuth
     - FirebaseCore
     - FirebaseFirestore
     - FirebaseFunctions

3. **Add Firebase Config**
   - In Firebase Console: download your `GoogleService-Info.plist`
   - Drag it into your Xcode project (check "Copy if needed" and make sure it’s in the app target)

4. **Build and Run**
   - Open the project in Xcode
   - Select a simulator or device
   - Press `Cmd + R` or click the Run ▶️ button

---

## Project Structure

gwish/
├── App/              # App entry point
├── Models/           # Codable data models (User, Wishlist, Item, Profile)
├── ViewModels/       # ObservableObject classes that manage logic
├── Views/            # SwiftUI screens and components
├── Services/         # Firebase services (Auth, Firestore, etc.)

---

## Firebase Notes

- All user data is stored in Firestore under collections like /users, /wishlists, and /profiles
- Firestore security rules should restrict access to the logged-in user
- Firebase Authentication supports anonymous or email/password login

---

## Future Ideas

- Friend connections & shared wishlists
- Notifications for wishlist changes
- AI gift recommendations
- Enhanced profile-to-profile linking with permissions

---

## Author

Built by Connie Zhu
