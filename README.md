<p align="center">
  <img src="assets\icons\icon.png" alt="Fursafy Logo" width="120" />
</p>

<h1 align="center">Fursafy</h1>

<p align="center">
  <strong>Your opportunity, one tap away.</strong>
</p>

<p align="center">
  <em>Fursa kwa Vijana &mdash; Opportunities for Youth</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.29-blue?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Firebase-Firestore%20%7C%20Functions%20%7C%20FCM-orange?logo=firebase" alt="Firebase" />
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License" />
  <img src="https://img.shields.io/badge/Status-Academic%20Project-purple" alt="Status" />
  <img src="https://github.com/AshrafuHussein/fursafy/actions/workflows/flutter_ci.yml/badge.svg" alt="CI" />
</p>

---

## Project Overview

### Introduction
Fursafy is a mobile job-matching platform designed to connect Tanzanian youth aged 18 to 35 with short-term, informal employment opportunities. By providing a structured, mobile-first marketplace, Fursafy allows skilled youth to discover jobs nearby and enables local providers to hire qualified workers efficiently. The platform relies on a server-side intelligent matching engine that pairs candidates and job requirements based on geographic proximity and skill set compatibility.

### Background
Youth unemployment is a significant socio-economic challenge in Tanzania and across East Africa. Approximately 850,000 young people enter the Tanzanian labour market annually, while only 40,000 to 50,000 formal jobs are created (ILO, 2022). Consequently, a substantial proportion of youth rely on the informal economy, undertaking short-term tasks such as technical repairs, cleaning services, tutoring, construction assistance, and other skill-based work.

Despite the demand for informal services, access to these opportunities remains unstructured and heavily dependent on word of mouth, personal networks, or unmoderated social media groups. Existing platforms lack specialized features such as location-aware proximity calculations, bilateral rating reviews, and automatic skill-set matching. Fursafy addresses this gap by offering a dedicated digital matching system.

### Problem Statement
No dedicated digital platform in Tanzania currently fulfills all of the following requirements:
1. Performs skill-based matchmaking between youth and short-term job providers.
2. Implements location-aware job discovery for physical tasks.
3. Builds mutual trust through verified profiles and bilateral rating systems.
4. Delivers real-time notifications to matched candidates.

Fursafy solves these challenges concurrently using a unified mobile application.

---

## Research Objectives and Project Scope

### Research Objectives
1. Assess the challenges faced by Tanzanian youth in accessing short-term informal job opportunities.
2. Analyze the requirements of job providers in sourcing skilled workers for one-time or short-term tasks.
3. Design a digital matching platform that matches youth to jobs based on skill sets and location.
4. Implement a functional prototype allowing job posting, worker discovery, and notifications.
5. Evaluate the usability and effectiveness of the developed platform.

### Scope and Boundaries
#### In Scope
- Cross-platform mobile application for Youth (Job Seekers) and Job Providers built with Flutter (Android and iOS).
- Backend infrastructure powered by Firebase services (Auth, Firestore, Cloud Functions, FCM, Storage).
- Location-aware proximity job matching computed via a server-side Firebase Cloud Function using the Haversine formula.
- Real-time push notifications delivered via Firebase Cloud Messaging.
- Bilateral rating and review system (Youth rating Provider, and Provider rating Youth) to build trust.
- Admin management dashboard (separate view or interface) to moderate users, review listings, and check platform statistics.

#### Out of Scope
- Direct in-app payment processing or mobile money API integration (Phase 1).
- Full-time, formal corporate employment listings.
- Real-time chat or video calling (slated for Phase 2).
- Machine learning-based recommendation systems beyond rule-based and spatial calculations.

---

## User Classes and Characteristics

- **Youth (Job Seeker):** Tanzanian youth aged 18 to 35 seeking short-term physical or service-oriented work. Technical proficiency is low to medium, and they may operate on devices with low data bandwidth or intermittent connectivity.
- **Job Provider:** Individuals, households, or small to medium enterprises (SMEs) needing short-term physical, trade, or service tasks completed. Technical proficiency is low.
- **Admin:** Arusha Technical College (ATC) instructors, examiners, or platform operators managing system integrity, moderating listings, reviewing flag submissions, and exporting data reports.

---

## Functional Requirements (FR)

### Authentication Module
- **FR-01:** Registration with email and password or phone number OTP.
- **FR-02:** Role selection (Youth or Job Provider) enforced at registration and stored in the database.
- **FR-03:** Password reset links via email.
- **FR-04:** Persistent login state across application launches.
- **FR-05:** Sign out action which clears local state and redirects to the login screen.

### Youth Profile Module
- **FR-07:** Create and edit profiles including full name, photo, bio, location, and skills (up to 10).
- **FR-08:** Predefined taxonomy for skills to prevent arbitrary or unstructured inputs.
- **FR-09:** Capture geolocation via device GPS or manual map pin placement, saved as a Firestore GeoPoint.
- **FR-10:** Profile dashboard showing accumulated average rating and the total count of completed jobs.
- **FR-11:** Set availability status (Available, Busy, Inactive) to toggle matching inclusion.

### Job Provider Module
- **FR-12:** Create and edit provider business or personal profiles.
- **FR-13:** Post new job listings with title, description, category, skills required, location GeoPoint, pay, and deadline.
- **FR-14:** Soft delete or close active listings (updating status to closed).
- **FR-15:** View a structured list of applicants for each posted job.
- **FR-16:** Accept or reject individual applications, which triggers notification dispatches to the applicant.

### Job Discovery and Matching Module
- **FR-18:** Paginated job feed (15 items per page) showing open jobs, ordered by creation date.
- **FR-19:** Keyword search on job titles and descriptions.
- **FR-20:** Filtering by category, pay range, and maximum distance radius.
- **FR-21:** Automatic server-side matching engine running on Firestore document triggers.
- **FR-22:** Detailed job view display showing skills required, description, provider ratings, pay, and location map.

### Application Module
- **FR-24:** Apply for jobs with an optional cover message (maximum 500 characters).
- **FR-25:** Prevent duplicate applications for the same job listing.
- **FR-26:** Withdraw pending job applications.
- **FR-27:** Youth dashboard to monitor application status (Pending, Accepted, Rejected, Completed).

### Ratings and Reviews Module
- **FR-29:** Bilateral review system where both parties rate each other (1 to 5 stars + optional comment) upon task completion.
- **FR-32:** Immutable ratings database; only one review allowed per job per participant.

### Notifications Module
- **FR-33:** Notifications stored in user sub-collections (`notifications/{uid}/{notifId}`) for auditing and in-app viewing.
- **FR-34:** In-app notification center showing read/unread states and updating bottom navigation badge counts.

---

## Non-Functional Requirements (NFR)

- **Performance (NFR-01):** Job listing screens must load cached or network data within 2 seconds under 3G network conditions. The Cloud Function matching engine must process matches within 5 seconds of job creation.
- **Security (NFR-03):** All Firestore reads and writes must be gated by server-side Firebase Security Rules. Direct database writes from client side must be blocked unless authenticated and role-authorized. Passwords must never be stored in plain text or in Firestore collections.
- **Scalability (NFR-05):** Support up to 10,000 concurrent users without database or server latency degradation using Firestore horizontal sharding and auto-scaling functions.
- **Reliability (NFR-06):** Target system uptime of 99.5% with read-only offline support enabled via Hive and Firestore cache persistence.
- **Usability (NFR-07):** Adherence to ISO 9241-11 usability standards: minimum tap targets of 48x48dp, contrast ratio >= 4.5:1, and a maximum of 3 taps for youth to apply for a matched job.
- **Localisation (NFR-09):** Support full bilingual capabilities (English and Swahili) using `flutter_localizations` and ARB files.
- **Maintainability (NFR-10):** Implementation of Clean Architecture principles separating data layers, domain logic, and presentation layers using the BLoC state management pattern.

---

## System Architecture

Fursafy utilizes a decoupled four-layer architecture, ensuring that changes in external infrastructure (such as maps or SMS gateways) do not impact core business logic.

```
+-------------------------------------------------------------+
|                     PRESENTATION LAYER                      |
|       Flutter UI Widgets - BLoC State Management            |
|       GoRouter Declarative Navigation - Theme System        |
+-------------------------------------------------------------+
|                     APPLICATION LAYER                       |
|   Authentication Service - Matching Engine Core Interface   |
|   Notification Service - Application & Rating Handlers      |
+-------------------------------------------------------------+
|                        DATA LAYER                           |
|   Cloud Firestore - Firebase Auth Client - Cloud Storage    |
|   FCM Handler - Remote Config Service - Local Hive Cache    |
+-------------------------------------------------------------+
|                  INFRASTRUCTURE LAYER                       |
|   Google Maps API - Africa's Talking SMS Gateway            |
|   GitHub CI/CD Actions - Firebase App Distribution          |
+-------------------------------------------------------------+
```

### Folder Structure
The mobile client follows a feature-first Clean Architecture pattern:

```
lib/
├── main.dart                       # Application entry point & Firebase initialization
├── app/
│   ├── app.dart                    # MaterialApp.router configuration
│   ├── router.dart                 # Declarative GoRouter route mapping (24 screens)
│   └── theme.dart                  # Central design tokens and color schemes
├── core/
│   ├── config/                     # Environment config keys and runtime variables
│   ├── constants/                  # Firestore collection paths and application constants
│   ├── error/                      # Central exception and failure classes
│   ├── location/                   # App-wide location provider and LocationBloc
│   ├── services/                   # Application services (Notification, Firebase)
│   ├── utils/                      # Haversine utilities, validators, and formatters
│   └── widgets/                    # Shared UI widgets (AppButton, AppCard, SkillChip)
├── features/
│   ├── auth/                       # Splash, Onboarding, Login, Registration, OTP, Passwords
│   │   ├── data/                   # AuthRepository, AuthDataSource implementations
│   │   ├── domain/                 # AuthRepository interface, User entity
│   │   └── presentation/           # Authentication screens and AuthBloc
│   ├── jobs/                       # Job Feed, Posting, Editing, Search and Map Views
│   │   ├── data/                   # JobRepository, JobDataSource implementations
│   │   ├── domain/                 # JobEntity, JobRepository interface
│   │   └── presentation/           # Job screens and JobFeedBloc
│   ├── applications/               # Job Applications (Apply, My Applications, Candidates)
│   ├── profile/                    # User Profiles (Youth, Provider, Public Profiles)
│   ├── notifications/              # Notification center and notification lists
│   └── ratings/                    # Bilateral rating and review submission
└── l10n/
    ├── app_en.arb                  # English translation strings
    └── app_sw.arb                  # Swahili translation strings
```

---

## Matching Engine

The Fursafy Matching Engine runs server-side as a Node.js 20 Cloud Function (Firebase Functions v2), triggering on the creation of a document in the `jobs` collection.

### Matching Steps
1. **Extract Parameters:** Read the created job listing's required skills (`skillsRequired` array) and its location (`GeoPoint`).
2. **Query Candidates:** Fetch youth profiles from `youth_profiles` where `availabilityStatus == 'available'` and the user's `skills` array contains at least one of the job's required skills.
3. **Distance Filtering:** Calculate the distance between the candidate's home location and the job location using the Haversine formula. Filter out candidates located further than the configured radius (default: 10 km, loaded dynamically from Firebase Remote Config).
4. **Scoring and Ranking:** Rank candidates based on a compound priority score calculated as follows:
   
   $$\text{Score} = (\text{Matching Skill Count} \times 3) + \left(\frac{1}{\text{Distance in km}} \times 2\right) + (\text{Rating Average} \times 1)$$
   
5. **Notification Dispatch:** Cap matches at the top 50 candidates. For each candidate, create a notification document in the database and issue a high-priority push notification payload via Firebase Cloud Messaging (FCM).

### Implementation Scaffold (`functions/src/matchingEngine.ts`)

```typescript
import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const MATCH_RADIUS_KM = 10;
const MAX_MATCHES = 50;

export const matchingEngine = functions.firestore.onDocumentCreated(
  'jobs/{jobId}',
  async (event) => {
    const job = event.data?.data();
    if (!job || job.status !== 'open') return;

    const { skillsRequired, location } = job;
    const jobId = event.params.jobId;

    // Fetch youth with matching availability and skills
    const snap = await db.collection('youth_profiles')
      .where('availabilityStatus', '==', 'available')
      .where('skills', 'array-contains-any', skillsRequired.slice(0, 10))
      .get();

    const candidates = snap.docs
      .map(d => ({ ...d.data(), uid: d.id } as any))
      .filter(y => haversineKm(location, y.location) <= MATCH_RADIUS_KM)
      .map(y => ({
        ...y,
        score: calcScore(y, location, skillsRequired)
      }))
      .sort((a, b) => b.score - a.score)
      .slice(0, MAX_MATCHES);

    const batch = db.batch();
    for (const youth of candidates) {
      const notifRef = db.collection('notifications')
        .doc(youth.uid)
        .collection('notifs')
        .doc();

      batch.set(notifRef, {
        type: 'job_match',
        jobId: jobId,
        message: `New job match: ${job.title} - TSh ${job.payAmount}`,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
    }
    await batch.commit();

    // Multicast push notifications
    const tokens = candidates.map(y => y.fcmToken).filter(Boolean);
    if (tokens.length > 0) {
      await admin.messaging().sendEachForMulticast({
        tokens,
        notification: {
          title: 'New Job Match!',
          body: job.title
        },
        data: {
          jobId: jobId,
          type: 'job_match'
        }
      });
    }
  }
);

function haversineKm(p1: admin.firestore.GeoPoint, p2: admin.firestore.GeoPoint): number {
  const R = 6371;
  const dLat = (p2.latitude - p1.latitude) * Math.PI / 180;
  const dLon = (p2.longitude - p1.longitude) * Math.PI / 180;
  const a = Math.sin(dLat / 2) ** 2 +
            Math.cos(p1.latitude * Math.PI / 180) *
            Math.cos(p2.latitude * Math.PI / 180) *
            Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function calcScore(youth: any, jobLoc: admin.firestore.GeoPoint, reqSkills: string[]): number {
  const matchSkills = youth.skills.filter((s: string) => reqSkills.includes(s)).length;
  const distance = haversineKm(youth.location, jobLoc) || 0.1; // Prevent division by zero
  const rating = youth.ratingAvg || 0.0;
  return (matchSkills * 3) + (1 / distance * 2) + (rating * 1);
}
```

---

## Database Schema

Fursafy uses six core root collections in Cloud Firestore:

### 1. Collection: `users`
- **Path:** `users/{uid}`
- **Description:** Central directory document for authentication and role validation.
- **Fields:**
  - `uid` (String, Required): Firebase Auth UID.
  - `fullName` (String, Required): User's display name.
  - `email` (String, Required): Login email address.
  - `phone` (String, Optional): Verification phone number.
  - `role` (String, Required): Enum value (`youth` | `provider` | `admin`).
  - `photoURL` (String, Optional): Profile picture storage URL.
  - `location` (GeoPoint, Required): Registration location coords.
  - `status` (String, Required): Enum value (`active` | `suspended` | `inactive`).
  - `fcmToken` (String, Optional): Current FCM device registration token.
  - `createdAt` (Timestamp, Required): Server timestamp.
  - `updatedAt` (Timestamp, Required): Server timestamp.

### 2. Collection: `jobs`
- **Path:** `jobs/{jobId}`
- **Description:** Contains individual job posting details.
- **Fields:**
  - `jobId` (String, Required): Auto-generated Firestore document ID.
  - `providerId` (String, Required): Publisher's `uid`.
  - `title` (String, Required): Short job title (maximum 80 characters).
  - `description` (String, Required): Job specifications (maximum 1000 characters).
  - `category` (String, Required): Category taxonomy string.
  - `skillsRequired` (Array of Strings, Required): Maximum 5 skills required.
  - `location` (GeoPoint, Required): Precise geographic job site location.
  - `locationLabel` (String, Required): Human-readable address.
  - `payAmount` (Number, Required): Tanzanian Shillings (TSh) pay amount.
  - `payType` (String, Required): Enum value (`fixed` | `hourly` | `negotiable`).
  - `deadline` (Timestamp, Required): Expiration time of application.
  - `status` (String, Required): Enum value (`open` | `filled` | `closed` | `cancelled`).
  - `applicantCount` (Number, Required): Total applicant counter.
  - `createdAt` (Timestamp, Required): Server timestamp.
  - `updatedAt` (Timestamp, Required): Server timestamp.

### 3. Collection: `youth_profiles`
- **Path:** `youth_profiles/{uid}`
- **Description:** Profile extension document containing youth-specific portfolio items.
- **Fields:**
  - `uid` (String, Required): Matches parent auth `uid`.
  - `skills` (Array of Strings, Required): Predefined taxonomy tags (maximum 10).
  - `bio` (String, Optional): Summary description (maximum 300 characters).
  - `location` (GeoPoint, Required): Primary physical location.
  - `availabilityStatus` (String, Required): Enum value (`available` | `busy` | `inactive`).
  - `ratingAvg` (Number, Required): Total rating average (default: 0.0).
  - `jobsCompleted` (Number, Required): Total completed jobs counter.
  - `portfolioURLs` (Array of Strings, Optional): Links to external work or certificates.
  - `updatedAt` (Timestamp, Required): Server timestamp.

### 4. Collection: `applications`
- **Path:** `applications/{appId}`
- **Description:** Intermediary entity joining youth profiles to job listings.
- **Fields:**
  - `appId` (String, Required): Auto-generated document ID.
  - `jobId` (String, Required): Job document reference ID.
  - `youthId` (String, Required): Applicant's user `uid`.
  - `providerId` (String, Required): Job publisher's `uid` (used for security validation).
  - `coverMessage` (String, Optional): Optional cover statement (maximum 500 characters).
  - `status` (String, Required): Enum value (`pending` | `accepted` | `rejected` | `withdrawn` | `completed`).
  - `appliedAt` (Timestamp, Required): Server timestamp.
  - `updatedAt` (Timestamp, Required): Server timestamp.

### 5. Collection: `ratings`
- **Path:** `ratings/{ratingId}`
- **Description:** Contains immutable task feedback records.
- **Fields:**
  - `ratingId` (String, Required): Auto-generated rating ID.
  - `jobId` (String, Required): Reference ID of the completed job.
  - `raterId` (String, Required): UID of the user authoring the rating.
  - `rateeId` (String, Required): UID of the target user receiving the rating.
  - `raterRole` (String, Required): Role of the author (`youth` | `provider`).
  - `score` (Number, Required): Rating integer from 1 to 5.
  - `comment` (String, Optional): Text review (maximum 300 characters).
  - `createdAt` (Timestamp, Required): Server timestamp.

### 6. Sub-collection: `notifications`
- **Path:** `notifications/{uid}/notifs/{notifId}`
- **Description:** Sub-collection under each user containing localized alerts.
- **Fields:**
  - `notifId` (String, Required): Auto-generated notification ID.
  - `type` (String, Required): Enum value (`job_match` | `application_received` | `application_accepted` | `application_rejected` | `rating_received`).
  - `message` (String, Required): Human-readable notification text.
  - `jobId` (String, Optional): Reference ID for deep-linking navigation.
  - `isRead` (Boolean, Required): Default is `false`.
  - `createdAt` (Timestamp, Required): Server timestamp.

---

## Firestore Queries and Index Configurations

All composite queries executed by the application client require database indexes configured in `firestore.indexes.json`. The following indexes must be deployed:

| Collection | Query Description | Fields and Direction |
|---|---|---|
| `jobs` | Fetch open jobs ordered by creation date | `status` (ASC), `createdAt` (DESC) |
| `jobs` | Search jobs in category ordered by date | `status` (ASC), `category` (ASC), `createdAt` (DESC) |
| `applications` | Fetch applicant history for youth | `youthId` (ASC), `appliedAt` (DESC) |
| `applications` | Retrieve applications for provider listing | `jobId` (ASC), `appliedAt` (DESC) |
| `ratings` | Fetch ratings for youth or provider | `rateeId` (ASC), `createdAt` (DESC) |
| `notifications` | Retrieve user notification history | `createdAt` (DESC) |

---

## Security and Access Control

### Firestore Security Rules (`firestore.rules`)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {

    // Global verification helpers
    function isSignedIn() {
      return request.auth != null;
    }
    function isOwner(uid) {
      return request.auth.uid == uid;
    }
    function getRole() {
      return get(/databases/$(db)/documents/users/$(request.auth.uid)).data.role;
    }
    function isYouth() {
      return getRole() == 'youth';
    }
    function isProvider() {
      return getRole() == 'provider';
    }
    function isAdmin() {
      return getRole() == 'admin';
    }
    function isActive() {
      return get(/databases/$(db)/documents/users/$(request.auth.uid)).data.status == 'active';
    }

    // Users Collection rules
    match /users/{uid} {
      allow read: if isSignedIn();
      allow write: if isOwner(uid) || isAdmin();
    }

    // Jobs Collection rules
    match /jobs/{jobId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && isProvider() && isActive();
      allow update, delete: if isOwner(resource.data.providerId) || isAdmin();
    }

    // Applications Collection rules
    match /applications/{appId} {
      allow read: if isOwner(resource.data.youthId) || isOwner(resource.data.providerId) || isAdmin();
      allow create: if isSignedIn() && isYouth() && isActive();
      allow update: if isOwner(resource.data.youthId) || isOwner(resource.data.providerId);
    }

    // Youth Profiles rules
    match /youth_profiles/{uid} {
      allow read: if isSignedIn();
      allow write: if isOwner(uid) || isAdmin();
    }

    // User Sub-collection Notifications rules
    match /notifications/{uid}/{document=**} {
      allow read, write: if isOwner(uid);
    }

    // Ratings rules
    match /ratings/{ratingId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && isActive();
      allow update, delete: if false; // Ratings are immutable
    }
  }
}
```

### Firebase Storage Rules (`storage.rules`)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{uid}/{allFiles=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == uid
                   && request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

---

## Testing Strategy

### Testing Levels
- **Unit Tests:** Individual Dart functions, entity calculations (such as Haversine calculations in Flutter), validation models, and repository interfaces. Tested via `flutter test` with `mockito`.
- **Widget Tests:** Validation of UI widgets, loading skeletons, state updates inside BlocBuilder, and navigation parameters. Tested using `WidgetTester`.
- **Integration Tests:** End-to-end flow execution (registration to job application and review scoring) using mock Firebase triggers and emulator instances.
- **Security Rules Verification:** Local authorization verification executed using the `@firebase/rules-unit-testing` framework.

### Critical Test Cases

| Test ID | Module | Test Case Scenario | Expected Result | Pass Criteria |
|---|---|---|---|---|
| **TC-01** | Auth | Register Youth with valid email | User accounts created in Auth and user profiles written in Firestore | All collections show valid documents; role set to `youth` |
| **TC-02** | Auth | Register Provider with valid email | User account and provider document written in Firestore | Document created; role set to `provider` |
| **TC-03** | Auth | Login with incorrect password | Firebase Auth validation rejects token request | Error payload received; user remains on login screen |
| **TC-04** | Match | Post job matching available youth skills | Cloud Function triggers and evaluates profile overlap | Notification document written under target youth ID within 10s |
| **TC-05** | Match | Post job where youth location > 10 km | Candidate filtered out by distance calculations | No notification written for the candidate |
| **TC-06** | Match | Post job where youth status is `busy` | Candidate filtered out by availability filter | Youth profile skipped in evaluation |
| **TC-07** | Apply | Youth applies twice for same job listing | Firestore validate application logic blocks transaction | Error response returned; database count unchanged |
| **TC-08** | Security | Write to another user's profile | Firestore Security Rules evaluate identity check | Permission denied exception thrown |
| **TC-09** | Security | Unauthenticated job list fetch | Rules verify authentication tokens | Permission denied exception thrown |
| **TC-10** | Ratings | Provider rates youth after job completion | Ratings document written; ratings transaction updates average | Profile document average recalculates matching the rating mean |
| **TC-11** | Notif | Provider accepts job application | Notification trigger writes matching payload | FCM pushes notification; in-app entry shows status accepted |
| **TC-12** | Admin | Admin suspends active user profile | Write permission update switches status | Role checks deny database modifications to suspended user |

---

## Setup and Installation

### Prerequisites
- Flutter SDK `^3.29.0`
- Dart SDK `^3.11.5`
- Firebase CLI installed and logged in (`npm install -g firebase-tools`)
- A Firebase project with the Blaze plan enabled (required for outbound network routing in Cloud Functions)
- Google Maps API key (with Directions API, Places API, and Geocoding API enabled)

### Local Deployment
```bash
# 1. Clone the repository
git clone https://github.com/AshrafuHussein/fursafy.git
cd fursafy

# 2. Retrieve Flutter package dependencies
flutter pub get

# 3. Create environment files from template
cp .env.example .env
# Edit .env with your Google Maps and Firebase project credentials

# 4. Execute the application passing definitions
flutter run \
  --dart-define=FIREBASE_API_KEY=your_key \
  --dart-define=FIREBASE_PROJECT_ID=your_project_id \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=your_sender_id \
  --dart-define=FIREBASE_APP_ID=your_app_id \
  --dart-define=GOOGLE_MAPS_API_KEY=your_maps_key \
  --dart-define=AFRICAS_TALKING_API_KEY=your_at_key
```

### Backend Deployment
```bash
# Deploy Firestore security rules
firebase deploy --only firestore:rules

# Install backend dependencies and deploy Cloud Functions
cd functions
npm install
cd ..
firebase deploy --only functions
```

---

## Deployment and CI/CD

### Environments
- **Development (`fursafy-dev`):** Utilized for active local development; tested against the Firebase Emulator Suite.
- **Staging (`fursafy-staging`):** Integration environment used for Supervisor evaluations, manual testing, and QA.
- **Production (`fursafy-prod`):** Final release environment matching academic requirements.

### CI/CD Pipeline (`.github/workflows/flutter_ci.yml`)
The workflow automatically checks code changes on push or pull requests to the `main` branch:
1. Installs Flutter SDK and retrieves packages.
2. Runs static analysis (`flutter analyze`) to check for code issues.
3. Runs unit and widget tests (`flutter test`).
4. Builds the release application bundle (`flutter build appbundle --release`).
5. Publishes artifacts to Firebase App Distribution for tester distribution.
6. Deploys Cloud Functions to production automatically upon successful testing.

---

## Academic Information

- **Project Title:** Fursafy &mdash; Mobile Job-Matching Platform for Tanzanian Youth
- **Institution:** Arusha Technical College (ATC), Tanzania
- **Department:** Department of Computer Science & Information Technology
- **Program:** Ordinary Diploma in Computer Science
- **Academic Year:** 2025/2026
- **Student:** Ashrafu Hussein Hashimu (Admission No. 23050502001)
- **Supervisor:** Eng. Abdul Kirobo
- **Project Type:** Final Year Project (Solo)

---

## Glossary

- **Antigravity:** A UI generation platform producing production-ready Flutter widget code from design prompts.
- **FCM:** Firebase Cloud Messaging &mdash; Firebase utility delivering push notification payloads to Android and iOS devices.
- **Firestore:** Cloud Firestore &mdash; Serverless NoSQL real-time document-oriented database.
- **Haversine Distance:** A mathematical formula calculating the shortest distance between two points on the surface of a sphere using latitude and longitude coordinates.
- **Matching Engine:** Serverless Firebase Cloud Function matching youth profiles to job listings based on skills and proximity.
- **Stitch MCP:** Model Context Protocol server connecting AI coding agents to external design and code generation platforms.
- **SUS:** System Usability Scale &mdash; Standardized ten-item scale questionnaire measuring system usability from 0 to 100.
