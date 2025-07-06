
# 📓 Flutter Note-Taking App

A simple and secure cross-platform note-taking app built with **Flutter**, using **Firebase** for backend services, and **BLoC** for scalable state management.

---

## 🚀 Features

- ✅ Email/password authentication via Firebase
- ✅ Create, read, update, and delete (CRUD) notes
- ✅ Note tagging: Work, School, Personal, etc.
- ✅ Firestore real-time sync
- ✅ User logout + confirmation dialog
- ✅ BLoC state management
- ✅ Clean Architecture (Domain, Data, Presentation layers)
- ✅ Dart analyzer passes with 0 warnings
- ✅ Fully responsive Material UI

---

## 🧠 Architecture

This app follows **Clean Architecture**:
```
lib/
├── domain/          # Entities & repository contracts
├── data/            # Firebase & local data sources
├── presentation/    # Screens, widgets, BLoC, UI logic
└── main.dart        # App entrypoint
```

State management is handled using the **BLoC pattern**, separating UI from business logic.

---

## 🔐 Firebase Setup

1. Enable **Authentication → Email/Password** in Firebase Console  
2. Enable **Firestore Database** in test mode  
3. Add your `google-services.json` to `android/app/`  
4. Use the **FlutterFire CLI** to initialize Firebase:
   ```bash
   flutterfire configure
   ```

---

## 🛠️ Installation & Run

1. Clone the repo  
   ```bash
   git clone https://github.com/fadhuweb/note_app.git
   ```

2. Get dependencies  
   ```bash
   flutter pub get
   ```

3. Run on emulator or physical device  
   ```bash
   flutter run
   ```

> **Minimum SDK:** Android 6.0 (API 23)  
> **Flutter Version:** 3.32.5



## 📂 Folder Overview

```
lib/
├── data/
│   └── firebase_note_repository.dart
├── domain/
│   ├── models/
│   └── repositories/
├── presentation/
│   ├── blocs/
│   └── screens/
└── main.dart
```

---

## 🧪 Testing

To run unit or widget tests:

```bash
flutter test
```



## 🧑‍💻 Author

**Fadhlullah Abdulazeez**  


