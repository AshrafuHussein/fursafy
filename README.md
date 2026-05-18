<p align="center">
  <img src="assets/images/fursafy_logo.png" alt="Fursafy Logo" width="120" />
</p>

<h1 align="center">🟢 Fursafy</h1>

<p align="center">
  <strong>Your opportunity, one tap away.</strong>
</p>

<p align="center">
  <em>Fursa kwa Vijana — Opportunities for Youth</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.29-blue?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Firebase-Firestore%20%7C%20Functions%20%7C%20FCM-orange?logo=firebase" alt="Firebase" />
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License" />
  <img src="https://img.shields.io/badge/Status-Academic%20Project-purple" alt="Status" />
  <img src="https://github.com/AshrafuHussein/fursafy/actions/workflows/flutter_ci.yml/badge.svg" alt="CI" />
</p>

---

## 📖 About

**Fursafy** is a mobile job-matching platform connecting Tanzanian youth (aged 18–35) to short-term informal job opportunities. Each year, approximately **850,000 young people** enter the Tanzanian labour market while only **40,000–50,000** formal jobs are created (ILO, 2022). Fursafy bridges this gap by providing a structured, mobile-first marketplace where skilled youth can discover nearby jobs and local providers can find qualified workers — all powered by an intelligent matching engine.

Built with **Flutter** and **Firebase**, the platform supports three distinct user roles, real-time push notifications, bilingual UI (Swahili 🇹🇿 + English 🇬🇧), and offline-first caching for low-connectivity areas.

---

## ✨ Features

### 👷 Youth Workers
- Browse a paginated job feed with category and skill filters
- Search and filter jobs by keyword, category, distance, and pay range
- Discover nearby jobs within a configurable radius (Google Maps)
- Apply for jobs with optional cover messages
- Track application status (Pending → Accepted / Rejected)
- Build a professional profile with skills, experience, and ratings
- Rate job providers after job completion

### 🏢 Job Providers
- Post job listings with required skills, location, pay, and deadlines
- View and manage applicants per job posting
- Accept or reject applications (with push notification to youth)
- Rate workers after job completion
- Dashboard with active jobs and applicant statistics

### 🛡️ Admin
- User management and moderation
- Job listing oversight and approval
- Platform analytics and reporting
- Content moderation tools

### 🌐 Platform-Wide
- 🔔 **Real-time push notifications** (Firebase Cloud Messaging)
- 🤖 **Matching Engine** — Cloud Function that auto-matches new jobs to qualified youth
- 🌍 **Bilingual UI** — Swahili 🇹🇿 + English 🇬🇧
- 📶 **Offline-first** — Cached job listings for low-connectivity areas
- 🔒 **Role-based security** with Firestore Security Rules

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Frontend** | Flutter (Dart) | Cross-platform mobile (Android + iOS) |
| **State Management** | BLoC (`flutter_bloc`) | Predictable, testable state management |
| **Navigation** | GoRouter | Declarative routing with deep linking |
| **Auth** | Firebase Auth | Phone number authentication |
| **Database** | Cloud Firestore | Real-time NoSQL database |
| **Storage** | Firebase Storage | Profile images and attachments |
| **Backend Logic** | Cloud Functions (TypeScript) | Matching engine, triggers, notifications |
| **Push Notifications** | Firebase Cloud Messaging | Real-time push delivery |
| **Maps** | Google Maps SDK | Job location display + proximity search |
| **SMS/OTP** | Africa's Talking API | Phone verification services |
| **Localization** | flutter_localizations | Swahili + English |
| **Local Cache** | Hive | Offline-first data caching |
| **CI/CD** | GitHub Actions | Automated analysis and testing |
| **Crash Reporting** | Firebase Crashlytics | Production error monitoring |

---

## 🏗️ Architecture

Fursafy follows a **feature-first Clean Architecture** pattern with four layers:

```
┌─────────────────────────────────────────────────┐
│              PRESENTATION LAYER                 │
│    Flutter Screens · BLoC State Management      │
│    GoRouter Navigation · Custom Design System   │
├─────────────────────────────────────────────────┤
│              APPLICATION LAYER                  │
│  Auth Service · Matching Engine · Notification  │
│  Service · Application Handler · Rating Service │
├─────────────────────────────────────────────────┤
│                 DATA LAYER                      │
│  Firestore · Firebase Auth · Cloud Storage      │
│  FCM · Remote Config · Analytics                │
├─────────────────────────────────────────────────┤
│             INFRASTRUCTURE LAYER                │
│  Google Maps API · Africa's Talking API          │
│  GitHub CI/CD · Play Store                      │
└─────────────────────────────────────────────────┘
```

### Project Structure

```
lib/
├── main.dart                     # App entry point, Firebase init
├── app/
│   ├── app.dart                  # MaterialApp.router
│   ├── router.dart               # GoRouter route definitions
│   └── theme.dart                # Design system tokens
├── core/
│   ├── config/                   # EnvConfig (--dart-define keys)
│   ├── constants/                # Firestore paths, app constants
│   ├── error/                    # AppException, Failure classes
│   ├── utils/                    # Haversine, validators, formatters
│   └── widgets/                  # Shared UI components
├── features/
│   ├── auth/                     # Login, Register, OTP, Splash
│   ├── jobs/                     # Job Feed, Detail, Post, Edit, Search
│   ├── applications/             # Apply, My Applications, Applicants
│   ├── profile/                  # Youth Profile, Provider Profile
│   ├── notifications/            # Notifications list + badge
│   └── ratings/                  # Rate Worker / Provider modal
└── l10n/
    ├── app_en.arb                # English strings
    └── app_sw.arb                # Swahili strings
```

Each feature uses Clean Architecture layers: **`data/`** → **`domain/`** → **`presentation/`** (BLoC).

---

## 🚀 Setup

### Prerequisites

- Flutter SDK `^3.29.0`
- Dart SDK `^3.11.5`
- Android Studio / VS Code with Flutter extensions
- Firebase CLI (`npm install -g firebase-tools`)
- A Firebase project (Blaze plan required for Cloud Functions)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/AshrafuHussein/fursafy.git
cd fursafy

# 2. Install Flutter dependencies
flutter pub get

# 3. Copy the environment template and fill in your real keys
cp .env.example .env
# Edit .env with your actual API keys — this file is git-ignored

# 4. Run the app (passing keys via --dart-define)
flutter run \
  --dart-define=FIREBASE_API_KEY=your_key \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id \
  --dart-define=FIREBASE_APP_ID=your_app_id \
  --dart-define=GOOGLE_MAPS_API_KEY=your_maps_key \
  --dart-define=AFRICAS_TALKING_API_KEY=your_at_key
```

### Firebase Setup

1. Place your `google-services.json` in `android/app/` (git-ignored)
2. Place your `GoogleService-Info.plist` in `ios/Runner/` (git-ignored)
3. Deploy Firestore security rules:
   ```bash
   firebase deploy --only firestore:rules
   ```
4. Deploy Cloud Functions:
   ```bash
   cd functions && npm install && cd ..
   firebase deploy --only functions
   ```

> **⚠️ Important:** Real API keys are **never** committed to this repository. All keys are passed at compile time via `--dart-define`. See [`.env.example`](.env.example) for the full list of required variables.

---

## 📸 Screenshots

> *Screenshots coming soon — the app is currently under active development.*

---

## 🎓 Academic Information

| Field | Details |
|---|---|
| **Project Title** | Fursafy — Mobile Job-Matching Platform for Tanzanian Youth |
| **Institution** | Arusha Technical College (ATC), Tanzania |
| **Program** | Ordinary Diploma in Computer Science |
| **Academic Year** | 2025/2026 |
| **Student** | Ashrafu Hussein Hashimu |
| **Supervisor** | Eng. Abdul Kirobo |
| **Project Type** | Final Year Project (Solo) |

> **📌 Note:** This repository is **public for academic review purposes only**. It allows the project supervisor, examiners, and academic reviewers to access and evaluate the work. **Contributions are not accepted.** See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## 🗄️ Database Schema

Six core Firestore collections:

| Collection | Description |
|---|---|
| `users` | All user accounts with role, status, FCM token |
| `youth_profiles` | Youth-specific data: skills, location, ratings |
| `jobs` | Job listings with required skills, pay, location |
| `applications` | Job applications with status tracking |
| `ratings` | Mutual ratings (youth ↔ provider) per job |
| `notifications/{uid}` | Per-user notification documents |

---

## 🤖 Matching Engine

The core intelligence of Fursafy — a Firebase Cloud Function (TypeScript) that triggers on every new job post:

1. **Extract** required skills and location from the new job document
2. **Query** youth profiles where skills `array-contains-any` job requirements
3. **Filter** by Haversine distance (default 10km, configurable via Remote Config)
4. **Rank** candidates by: matching skills count → distance → average rating
5. **Notify** matched youth via FCM push + in-app notification

---

## 🧪 Testing

```bash
# Run static analysis
flutter analyze

# Run unit and widget tests
flutter test

# Run with Firebase Emulator Suite
firebase emulators:start
```

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

Copyright © 2025/2026 **Ashrafu Hussein Hashimu**

---

## 🙏 Acknowledgements

- [Flutter](https://flutter.dev/) — Cross-platform UI framework
- [Firebase](https://firebase.google.com/) — Backend-as-a-Service
- [BLoC Library](https://bloclibrary.dev/) — State management
- International Labour Organization (ILO) — Youth employment data for Tanzania
- **Eng. Abdul Kirobo** — Project Supervisor, Arusha Technical College
