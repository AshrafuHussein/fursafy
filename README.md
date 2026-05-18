# 🟢 Fursafy

**Fursa kwa Vijana — Opportunities for Youth**

A mobile job-matching platform connecting Tanzanian youth (18–35) to short-term informal job opportunities. Built with Flutter and Firebase, Fursafy bridges the gap between skilled youth and local job providers through intelligent skills-based matching and real-time notifications.

---

## 📱 Screenshots

> *Coming soon — UI screens are designed in [Stitch (Antigravity)](https://stitch.withgoogle.com/) and are being translated to Flutter.*

---

## 🎯 Problem Statement

Each year, approximately **850,000 young people** enter the Tanzanian labour market, while only **40,000–50,000** formal employment opportunities are created (ILO, 2022). A large proportion of youth rely on the informal economy — technical repairs, cleaning, tutoring, construction, and other skill-based tasks — but access to these opportunities remains unstructured, relying on personal networks and word of mouth.

**Fursafy** solves this by providing a structured, mobile-first platform where:
- **Youth** can discover, filter, and apply for nearby jobs
- **Job Providers** can post opportunities and find matched workers
- **A Matching Engine** automatically connects jobs to qualified youth based on skills, location, and ratings

---

## ✨ Key Features

### For Youth (Workers)
- 📋 Browse paginated job feed with category filters
- 🔍 Search and filter jobs by keyword, category, distance, and pay range
- 📍 Location-based job discovery (within configurable radius)
- 📝 Apply for jobs with optional cover message
- 📊 Track application status (Pending → Accepted / Rejected)
- ⭐ Rate job providers after completion
- 👤 Build a professional profile with skills and ratings

### For Job Providers
- ➕ Post job listings with skills, location, pay, and deadline
- 👥 View and manage applicants per job
- ✅ Accept or reject applications (with push notifications)
- ⭐ Rate workers after job completion
- 📈 Dashboard with active jobs and applicant stats

### Platform-Wide
- 🔔 Real-time push notifications (FCM) for matches, applications, and status changes
- 🤖 **Matching Engine** — Cloud Function that automatically matches new jobs to qualified youth
- 🌍 Bilingual UI: **Swahili** 🇹🇿 + **English** 🇬🇧
- 📶 Offline-first: cached job listings for low-connectivity areas
- 🔒 Role-based security with Firestore Security Rules
- 🛡️ Admin panel for user management and job moderation (Phase 2)

---

## 🏗️ Architecture

Fursafy follows a **four-layer architecture** with **feature-first Clean Architecture** in the Flutter layer:

```
┌─────────────────────────────────────────────────┐
│              PRESENTATION LAYER                 │
│    Flutter Screens · BLoC State Management      │
│    GoRouter Navigation · Stitch Design System   │
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
│  Google Maps API · Play Store / App Store        │
│  GitHub CI/CD · Crashlytics                     │
└─────────────────────────────────────────────────┘
```

### Flutter Project Structure

```
lib/
├── main.dart                     # App entry point, Firebase init
├── app/
│   ├── app.dart                  # MaterialApp.router
│   ├── router.dart               # GoRouter routes (24 screens)
│   └── theme.dart                # Design system tokens
├── core/
│   ├── constants/                # Firestore paths, app constants
│   ├── firebase/                 # Firebase service, FCM handler
│   ├── error/                    # AppException, Failure classes
│   ├── utils/                    # Haversine, validators, formatters
│   └── widgets/                  # Shared: AppButton, AppCard, SkillChip
├── features/
│   ├── auth/                     # Login, Register, OTP, Splash
│   ├── jobs/                     # Job Feed, Detail, Post, Edit, Search
│   ├── applications/             # Apply, My Applications, Applicants
│   ├── profile/                  # Youth Profile, Provider Profile, Edit
│   ├── notifications/            # Notifications list + badge
│   └── ratings/                  # Rate Worker / Provider modal
├── l10n/
│   ├── app_en.arb                # English strings
│   └── app_sw.arb                # Swahili strings
└── functions/                    # Firebase Cloud Functions (TypeScript)
    ├── src/
    │   ├── index.ts              # Function exports
    │   ├── matchingEngine.ts     # Skills + proximity matching
    │   ├── updateRatingAverage.ts
    │   └── sendStatusNotification.ts
    └── package.json
```

Each feature follows **Clean Architecture** with three layers:
- **`data/`** — Repositories, data sources, models (Firestore ↔ Entity mapping)
- **`domain/`** — Entities, abstract repository interfaces
- **`presentation/`** — BLoC (Events, States), Screens, Widgets

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| Frontend | **Flutter** (Dart) | Cross-platform mobile (Android + iOS) |
| State Management | **BLoC** (`flutter_bloc`) | Predictable state management |
| Navigation | **GoRouter** | Declarative routing with deep linking |
| Auth | **Firebase Auth** | Email/password + phone authentication |
| Database | **Cloud Firestore** | Real-time NoSQL database |
| Storage | **Firebase Storage** | Profile images and attachments |
| Backend Logic | **Cloud Functions** (Node.js 20) | Matching engine, triggers |
| Push Notifications | **Firebase FCM** | Real-time push delivery |
| Maps | **Google Maps SDK** | Job location display + proximity |
| Analytics | **Firebase Analytics** | Usage tracking |
| Crash Reporting | **Firebase Crashlytics** | Production monitoring |
| Config | **Firebase Remote Config** | Feature flags, match radius |
| Localization | **flutter_localizations** | Swahili + English |
| Local Cache | **Hive** | Offline-first caching |

---

## 🎨 Design System

The UI follows the **"Digital Curator"** design philosophy — an editorial, gallery-like experience that feels sophisticated and premium.

| Token | Value | Usage |
|---|---|---|
| Primary | `#00694c` | Core brand, primary actions |
| Primary Container | `#008560` | Hero gradients |
| Secondary | `#855400` | Amber energy accents |
| Secondary Container | `#fcaa33` | Youth-focused CTAs |
| Surface | `#faf9f4` | Warm paper background |
| Headline Font | Plus Jakarta Sans | Authority, editorial voice |
| Body Font | Manrope | Functional clarity |
| Roundness | 8dp default | Soft professionalism |

**Design Rules:**
- ❌ No 1px borders — use surface tier shifts for boundaries
- ❌ No divider lines — use whitespace and background changes
- ✅ Glassmorphism for floating elements (bottom nav, FAB)
- ✅ Ambient shadows (large blur, ultra-low opacity, tinted)
- ✅ Editorial typography with high-contrast scale

---

## 🗄️ Database Schema

Six core Firestore collections:

| Collection | Description |
|---|---|
| `users` | All user accounts with role, status, FCM token |
| `youth_profiles` | Youth-specific data: skills, location, ratings |
| `jobs` | Job listings with skills required, pay, location |
| `applications` | Job applications with status tracking |
| `ratings` | Mutual ratings (youth ↔ provider) per job |
| `notifications/{uid}` | Per-user notification documents |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.11.5`
- Dart SDK `^3.11.5`
- Android Studio / VS Code with Flutter extensions
- Firebase CLI (`npm install -g firebase-tools`)
- A Firebase project (Blaze plan for Cloud Functions)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/fursafy.git
cd fursafy

# Install Flutter dependencies
flutter pub get

# Run on Android emulator
flutter run
```

### Firebase Setup

1. Place your `google-services.json` in `android/app/`
2. Place your `GoogleService-Info.plist` in `ios/Runner/` (if building for iOS)
3. Deploy Firestore security rules:
   ```bash
   firebase deploy --only firestore:rules
   ```
4. Deploy Cloud Functions:
   ```bash
   cd functions && npm install && cd ..
   firebase deploy --only functions
   ```

---

## 🧪 Testing

```bash
# Run static analysis
flutter analyze

# Run unit and widget tests
flutter test

# Run on emulator
flutter run

# Test with Firebase Emulator Suite
firebase emulators:start
```

---

## 🤖 Matching Engine

The core intelligence of Fursafy — a Firebase Cloud Function that triggers on every new job post:

1. **Extract** job skills and location from the new document
2. **Query** youth profiles where skills `array-contains-any` job requirements
3. **Filter** by Haversine distance (default: 10km radius, configurable via Remote Config)
4. **Rank** candidates by: matching skills count → distance → rating average
5. **Notify** matched youth via FCM push + in-app notification

---

## 🗺️ Roadmap

- [x] SRS Document (40 pages)
- [x] Design Document (11 deliverables)
- [x] UI Design in Stitch MCP (40+ screens)
- [ ] **Phase 1:** Project scaffolding & architecture
- [ ] **Phase 1:** Firebase configuration & security rules
- [ ] **Phase 1:** Auth feature (7 screens)
- [ ] **Phase 1:** Jobs feature (12 screens)
- [ ] **Phase 1:** Applications feature (6 screens)
- [ ] **Phase 1:** Profile feature (3 screens)
- [ ] **Phase 1:** Notifications feature (1 screen)
- [ ] **Phase 1:** Ratings feature (2 screens)
- [ ] **Phase 1:** Cloud Functions (matching engine)
- [ ] **Phase 1:** Localization (Swahili + English)
- [ ] **Phase 2:** Admin Panel (Flutter web — 8 screens)
- [ ] **Phase 2:** Google Maps integration (with API key)
- [ ] **Phase 2:** CI/CD Pipeline (GitHub Actions)
- [ ] **Phase 2:** Play Store deployment

---

## 👤 Author

**Ashrafu Hussein** — Ordinary Diploma in Computer Science, Arusha Technical College (2025/2026)

---

## 📄 License

This project is developed as an academic project for Arusha Technical College.

---

## 🙏 Acknowledgements

- [Flutter](https://flutter.dev/) — Cross-platform framework
- [Firebase](https://firebase.google.com/) — Backend-as-a-Service
- [BLoC](https://bloclibrary.dev/) — State management
- International Labour Organization (ILO) — Youth employment data
