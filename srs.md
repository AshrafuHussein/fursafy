Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

1.  Introduction & Project Overview ......................................................................................................... 3

2.  Overall System Description .................................................................................................................. 5

3.  Functional Requirements (FR) ............................................................................................................. 7

4.  Non-Functional Requirements (NFR)................................................................................................ 11

5.  System Architecture ............................................................................................................................ 13

6.  Data Models & Firestore Schema ...................................................................................................... 16

7.  Business Logic & Algorithms ............................................................................................................ 19

8.  UI/UX Specification & Screen Inventory ........................................................................................... 21

9.  Stitch MCP + Antigravity Integration Guide .................................................................................... 26

10.  Firebase Configuration & Setup ...................................................................................................... 28

11.  Flutter Project Structure ................................................................................................................... 30

12.  API & Integration Specifications ..................................................................................................... 32

13.  Security & Access Control ............................................................................................................... 34

14.  Testing Strategy & Test Cases ........................................................................................................ 36

15.  Deployment & CI/CD .......................................................................................................................... 39

16.  Development Constraints & Assumptions .................................................................................... 40

17.  Glossary ............................................................................................................................................... 41

18.  References .......................................................................................................................................... 42

Ordinary Diploma in Computer Science | Arusha Technical College

Page 1 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

1. INTRODUCTION & PROJECT OVERVIEW

1.1 Purpose of This Document

This Software Requirements Specification (SRS) is the authoritative reference document for the design,
development,  testing,  and  deployment of Fursafy  —  a mobile digital platform that connects youth to
short-term informal job opportunities in Tanzania. This document is written to be consumed directly by
an AI coding agent (such as Claude Code or any autonomous development agent) and must be followed
precisely.

Every section  of this  SRS  is structured to  give  an  AI  agent complete,  unambiguous instructions.  No
assumptions should be made that are not stated here. When a specification is incomplete or ambiguous,
the agent must flag it for human review before proceeding.

AI AGENT INSTRUCTION: Read this entire SRS before writing a single line of code. Build a mental
map of: (1) all screens, (2) all Firestore collections, (3) all Cloud Functions, and (4) the Stitch MCP
+ Antigravity UI pipeline. Only then begin scaffolding.

1.2 Project Overview

App Name

Tagline

Platform

Backend

UI Generation

Target Users

Geography

Language

Offline Support

Fursafy

Fursa kwa Vijana — Opportunities for Youth

Android (primary), iOS (secondary) — Flutter cross-platform

Firebase (Firestore, Auth, Cloud Functions, FCM, Storage, Analytics)

Antigravity (via Stitch MCP connector)

Youth (18–35) seeking short-term work in Tanzania; Job Providers
(individuals/SMEs); Admin

Urban Tanzania — Arusha, Dar es Salaam, Moshi (Phase 1)

Swahili + English bilingual UI

Read-only offline mode (cached listings); FCM for connectivity
restoration

Monetisation

Free for Phase 1 prototype; Premium tier planned post-launch

1.3 Background

Youth  unemployment  remains  a  persistent  socio-economic  challenge  in  Tanzania  and  across  East
Africa. Each year, approximately 850,000 young people enter the Tanzanian labour market, while only
40,000–50,000 formal employment opportunities are created (ILO, 2022). A large proportion of youth
rely  on  the  informal  economy,  engaging  in  short-term  or  one-time  jobs  such  as  technical  repairs,
cleaning services, tutoring, construction assistance, and other skill-based tasks.

Despite  the  availability  of  such  informal  job  opportunities,  access  remains  unstructured,  relying  on
personal  networks,  word  of  mouth,  or  informal  social  media  groups.  Existing  platforms  (DayWaka,

Ordinary Diploma in Computer Science | Arusha Technical College

Page 2 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

Mchongoo)  serve  the  general  population  but  do  not  provide  skill-based  matching,  structured  youth
profiles, or trust-building mechanisms tailored to the informal sector. Fursafy addresses this gap.

1.4 Problem Statement

There is no dedicated digital platform in Tanzania that: (1) enables skill-based matching between youth
and short-term job providers; (2) provides location-aware job discovery for informal, physical tasks; (3)
builds trust through verified profiles and a ratings system; or (4) delivers real-time job notifications to
matched youth. Fursafy is designed to solve all four problems simultaneously.

1.5 Research Objectives

1.  To assess the challenges faced by youth in accessing short-term informal job opportunities.
2.  To analyse the needs of job providers in sourcing skilled workers for one-time or short-term

tasks.

3.  To design a digital platform that enables skill-based job matching between youth and job

providers.

4.  To implement a prototype system that allows job posting and worker discovery.
5.  To evaluate the usability and effectiveness of the developed platform.

1.6 Scope & Boundaries

IN SCOPE for this SRS and the AI agent build:

•  Youth and Job Provider mobile app (Flutter — Android & iOS)
•  Firebase backend: Auth, Firestore, Cloud Functions, FCM, Storage
•  Skill-based + location-based job matching (Cloud Function)
•  Real-time push notifications (FCM)
•  Ratings and reviews system (bilateral)
•  Admin dashboard (Flutter web or separate admin app)
•  UI generation via Antigravity connected through Stitch MCP

OUT OF SCOPE (do not implement):

In-app payment processing or mobile money integration

•
•  Full-time or formal employment listings
•  Video calling or real-time chat (Phase 2)
•  ML-based recommendation beyond rule-based matching (Phase 2)

Ordinary Diploma in Computer Science | Arusha Technical College

Page 3 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

2. OVERALL SYSTEM DESCRIPTION

2.1 System Perspective

Fursafy  is  a  standalone  mobile  application  backed  by  Firebase  BaaS  (Backend-as-a-Service).  It
operates in a client–server architecture: the Flutter app is the client, Firebase services are the server.
A Firebase Cloud Function acts as the Matching Engine,  running server-side logic on every new job
post.

Figure 2.1 – Fursafy Four-Layer System Architecture

2.2 User Classes & Characteristics

User Class

Description

Youth (Job
Seeker)

Aged 18–35, urban Tanzania,
smartphone user, may have low
data bandwidth

Technical
Level

Low to Medium

Job Provider

Individual or SME needing short-
term physical/service tasks done

Low

Primary Actions

Register, build skill profile,
browse/apply for jobs, receive
matches, rate providers

Register, post jobs, view
applicants, select worker, rate
youth

Admin

ATC or Platform operator; manages
system integrity

High

Manage users, moderate listings,
view analytics, export reports

Ordinary Diploma in Computer Science | Arusha Technical College

Page 4 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

User Class

Description

Technical
Level

Primary Actions

System
(Firebase)

Automated backend actor: Matching
Engine, Notification Service

N/A —
automated

Trigger matching on new job,
send FCM push, update
denormalised data

2.3 Operating Environment

•  Client: Android 6.0+ (API 23+), iOS 13+ — Flutter 3.x
•  Backend: Firebase (Google Cloud infrastructure, multi-region)
•  Network: 3G/4G mobile data, WiFi; offline read-only mode for cached data
•
•  Version control: Git + GitHub
•  UI generation: Antigravity platform connected via Stitch MCP

IDE: Android Studio / VS Code with Flutter & Dart plugins

2.4 Design & Implementation Constraints

•  All UI components must be generated by Antigravity via Stitch MCP from the HiFi mockup

specifications in Section 8.

•  All Firebase Security Rules must be enforced — no client-side data access without rule

validation.

•  The app must be bilingual (Swahili + English). All user-facing strings must use Flutter's

localisation framework (flutter_localizations).

•  Firestore queries must stay within free Spark tier limits during academic prototype phase.
•  No third-party payment SDK may be added in this version.

2.5 Assumptions & Dependencies

•  Students have access to a Firebase project with Blaze plan enabled (required for Cloud

Functions outbound network calls).

•  Stitch MCP connector is available and authenticated against the Antigravity account.
•  Google Maps API key is provisioned and restricted to the app's package name.
•  Users have Android 6.0+ devices with internet access.
•  Flutter SDK 3.19+ and Dart 3.x are installed in the development environment.

Ordinary Diploma in Computer Science | Arusha Technical College

Page 5 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

3. FUNCTIONAL REQUIREMENTS (FR)
AI AGENT: Every FR below must be implemented. FRs are grouped by module. Each FR has an
ID,  priority  (P1=must-have,  P2=should-have,  P3=nice-to-have),  and  acceptance  criteria.  Do  not
skip any P1 requirement.

3.1 Authentication Module

ID

Requirement

Priority

Acceptance Criteria

FR-
01

FR-
02

FR-
03

FR-
04

FR-
05

FR-
06

Youth and Job Providers can register with
email + password OR phone number (OTP)

Users can log in with email/password or
phone OTP

Forgot Password — email reset link

Persistent login — user stays logged in
across app restarts

User can log out from profile screen

Role selection at registration (Youth / Job
Provider)

P1

P1

P1

P1

P1

P1

User record created in Firebase Auth AND
users/{uid} Firestore doc; role field set
correctly

Firebase Auth token issued; user
redirected to role-appropriate home screen

Firebase Auth sendPasswordResetEmail
fires; user receives email

FirebaseAuth.instance.authStateChanges()
persists session

Firebase signOut() called; all local state
cleared; app navigates to login

role field in Firestore users doc is 'youth' or
'provider'; routing differs

3.2 Youth Profile Module

ID

FR-07

FR-08

FR-09

FR-10

FR-11

Requirement

Priority

Acceptance Criteria

Youth can create and edit their profile: full
name, photo, bio, skills (multi-select),
location

Skills are selected from a predefined
taxonomy (see Appendix A)

Location is captured as a GeoPoint (lat/lng)
via device GPS or manual map pin

Profile displays accumulated rating
average and jobs completed count

Youth can set availability status: Available /
Busy / Inactive

P1

P1

P1

P1

P2

youth_profiles/{uid} doc created/updated in
Firestore; photo uploaded to Firebase
Storage

Skill chips rendered from skills_taxonomy
collection; user can multi-select up to 10

GeoPoint stored in youth_profiles.location;
Google Maps picker used

Computed from ratings collection; shown as
star rating widget

status field in youth_profiles; affects matching
engine inclusion

3.3 Job Provider Module

ID

FR-12

Requirement

Job Provider can create and edit their
business/personal profile

Priority

P1

Acceptance Criteria

providers/{uid} doc in Firestore with name, photo,
contact, location, rating

Ordinary Diploma in Computer Science | Arusha Technical College

Page 6 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

ID

Requirement

Priority

Acceptance Criteria

FR-13

Job Provider can post a new job listing  P1

FR-14

FR-15

FR-16

FR-17

Job post includes: title, description,
skills_required[], location (GeoPoint),
pay_amount, pay_type, deadline,
category

Job Provider can edit or close/delete
their job listing

Job Provider can view list of
applicants for each job

Job Provider can accept or reject
individual applications

P1

P1

P1

P1

jobs/{jobId} doc created with all required fields
(see Section 6.2)

All fields validated before Firestore write; location
requires map pin

jobs/{jobId} updated with status='closed'; soft
delete only

Query applications where job_id==jobId; show
youth profile summary

applications/{appId}.status updated to 'accepted'
or 'rejected'; FCM notification sent to youth

3.4 Job Discovery & Matching Module

Requirement

Priority

Acceptance Criteria

ID

FR-18

FR-19

FR-20

Youth can browse all open job listings
in a paginated card feed

Youth can search jobs by keyword
(title/description full-text)

Youth can filter jobs by: category, max
distance, pay range

FR-21  Matching Engine — Cloud Function
triggers on new job post

FR-22  Matched youth receive FCM push

notification with job title and pay

FR-23

Youth can view full job detail screen

P1

3.5 Application Module

P1

P1

P2

P1

P1

Firestore query jobs where status=='open',
ordered by created_at desc, paginated 15/page

Client-side Firestore query using >= and <= on
title field OR Algolia integration (P2)

Filter applied as Firestore compound query;
distance filter computed client-side from
GeoPoints

See Section 7.1 for full algorithm specification

FCM message delivered within 10 seconds of job
post creation

Job title, description, skills chips, location map
snippet, provider info, pay, deadline shown

ID

Requirement

Priority

Acceptance Criteria

FR-24  Youth can apply for a job with an
optional cover message

FR-25  Youth cannot apply for the same job

twice

FR-26  Youth can withdraw a pending

application

P1

P1

P2

applications/{appId} doc created;
status='pending'; job provider notified via FCM

Check existing application before write; show
'Already Applied' state on button

applications/{appId}.status updated to
'withdrawn'

FR-27  Youth can view all their applications with

P1

status badges

Query applications where youth_id==uid;
display Pending/Accepted/Rejected badges

FR-28

Job Provider receives in-app and push
notification on new application

P1

FCM notification to provider's device token;
notification stored in notifications/{uid}

Ordinary Diploma in Computer Science | Arusha Technical College

Page 7 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

3.6 Ratings & Reviews Module

ID

Requirement

Priority

Acceptance Criteria

FR-29  After job completion, Job Provider

P1

can rate youth (1–5 stars +
comment)

ratings/{ratingId} doc created;
youth_profiles.rating_avg updated via Cloud
Function

FR-30  After job completion, Youth can rate
Job Provider (1–5 stars + comment)

P1

ratings/{ratingId} doc created; providers.rating_avg
updated

FR-31  Ratings are displayed on both youth

P1

and provider profiles

Star widget + numeric average + recent review list
shown on profile screens

FR-32  A user can only rate once per job

P1

Firestore rule: check existing rating for this job_id +
rater_id combination

3.7 Notifications Module

ID

Requirement

Priority

Acceptance Criteria

FR-33  All FCM notifications are

P1

stored in
notifications/{uid}/{notifId}
Firestore docs

FR-34

In-app Notifications screen
shows all notifications with
read/unread state

FR-35  Notification types: job_match,
application_received,
application_accepted,
application_rejected,
rating_received

P1

P1

3.8 Admin Module

Each notification has: type, message, job_id (ref),
is_read, created_at

Unread count badge on bottom nav; tap marks as read
(is_read=true)

type field used to determine icon and navigation target on
tap

ID

Requirement

Priority

Acceptance Criteria

FR-36  Admin can view list of all users with

P1

filter by role

Admin Flutter web app queries users collection; role
filter dropdown

FR-37  Admin can suspend or reactivate a

P1

user account

users/{uid}.status='suspended'; Firestore rule denies
suspended users write access

FR-38  Admin can view all job listings and

P1

remove inappropriate ones

Admin query jobs collection; delete/close action
available

FR-39  Admin can view platform analytics:
total users, total jobs, total
applications, match rate

P2

Aggregated from Firestore or Firebase Analytics
dashboard

Ordinary Diploma in Computer Science | Arusha Technical College

Page 8 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

4. NON-FUNCTIONAL REQUIREMENTS (NFR)
AI AGENT: NFRs are enforced at architecture level, not just code comments. Firebase Security
Rules enforce NFR-03. Firestore indexes enforce NFR-01. Flutter's flutter_localizations enforces
NFR-09.

ID

Category

Requirement

Measure / Implementation

NFR-
01

NFR-
02

NFR-
03

NFR-
04

NFR-
05

NFR-
06

NFR-
07

NFR-
08

NFR-
09

NFR-
10

NFR-
11

NFR-
12

Performance

Job listing screen loads within 2
seconds on 3G

Performance

Matching Cloud Function executes
within 5 seconds

Security

All Firestore reads/writes governed
by Security Rules

Security

Passwords never stored in Firestore

Scalability

Support 10,000 concurrent users
without degradation

Reliability

99.5% uptime

Usability

ISO 9241-11 compliant — effective,
efficient, satisfying

Firestore pagination (15 docs/page);
Firestore composite indexes on jobs(status,
created_at); Flutter ListView.builder for lazy
rendering

Firestore array-contains-any query (max 10
skills); Haversine distance computed in
Node.js; FCM batch send

Firebase Security Rules enforce: (1)
authenticated access only, (2) role-based
access, (3) owner-only profile writes — see
Section 13

Firebase Auth manages credentials;
Firestore only stores uid-referenced profile
data

Firebase auto-scales; Firestore horizontal
sharding; Cloud Functions auto-scale on
demand

Firebase SLA 99.95%; offline read cache
via Firestore persistence
(enablePersistence: true)

Minimum tap target 48×48dp; text contrast
≥4.5:1; max 3 taps to apply for job; user
testing with 5+ youth

Portability

Localisation

Single codebase for Android and
iOS

Flutter; all platform-specific code in
platform channels only if unavoidable

Bilingual UI: Swahili (sw) + English
(en)

flutter_localizations; ARB files for both
locales; locale detection from device
settings

Maintainability

Clean Architecture pattern

Accessibility

Support screen readers

Data Privacy

User location only used for matching
— never shared

Feature-first folder structure; Repository
pattern for Firestore; Provider/Riverpod for
state

Semantics() widgets on all interactive
elements; meaningful content descriptions

GeoPoint stored in Firestore; not exposed
in public job listings; Security Rules block
direct location reads by other users

Ordinary Diploma in Computer Science | Arusha Technical College

Page 9 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

5. SYSTEM ARCHITECTURE

5.1 Architecture Overview

Fursafy  follows  a  four-layer  architecture:  Presentation  (Flutter),  Application  Logic  (Firebase  Cloud
Functions), Data (Firebase Services), and External/Infrastructure. All layers are decoupled through well-
defined interfaces — Flutter talks to Firebase SDK, Cloud Functions talk to Firestore and FCM, external
APIs (Google Maps, SMS) are called from Cloud Functions only.

Figure 5.1 – Four-Layer System Architecture

5.2 Layer Specifications

Layer 1 — Presentation (Flutter App)

•  Framework: Flutter 3.x, Dart 3.x
•  State Management: Riverpod 2.x (AsyncNotifier, StreamProvider)
•  Navigation: GoRouter 12.x (declarative, deep-link ready)
•  UI Components: Generated by Antigravity via Stitch MCP (see Section 9)
•
•  Maps: google_maps_flutter package
•  HTTP: Dio (for any REST calls; prefer Firebase SDK over REST)

Local Storage: Hive (user preferences, offline cache)

Layer 2 — Application Logic (Cloud Functions)

•  Runtime: Node.js 20 (Firebase Cloud Functions v2)

Ordinary Diploma in Computer Science | Arusha Technical College

Page 10 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

•  Trigger: Firestore onCreate on jobs/{jobId}
•  Functions: matchingEngine(), updateRatingAverage(), sendStatusNotification()
•  Packages: firebase-admin, geofire-common (Haversine), firebase-functions

Layer 3 — Data (Firebase Services)

•  Firestore: Primary database — all collections defined in Section 6
•  Firebase Auth: Email/password + phone OTP; custom claims for role
•  Cloud Storage: Profile images (users/{uid}/avatar.jpg), job images
•  Firebase FCM: Push notification delivery to registered device tokens
•  Remote Config: Feature flags (e.g., enable_premium_tier: false)
•  Firebase Analytics: Custom events (job_posted, job_applied, match_triggered)

Layer 4 — External / Infrastructure

•  Google Maps Platform: Places API (location search), Maps SDK (map display), Geocoding API
•  SMS Gateway (optional fallback): Africa's Talking SMS API for OTP on low-end devices
•  GitHub Actions: CI/CD pipeline — lint → test → build → deploy Cloud Functions
•  Firebase App Distribution: Beta distribution to test users
•  Crashlytics: Production crash monitoring

5.3 Data Flow — Job Posting to Youth Notification

Figure 5.2 – DFD Level 0: System data flows

Ordinary Diploma in Computer Science | Arusha Technical College

Page 11 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

Figure 5.3 – DFD Level 1: Internal process decomposition

5.4 Sequence — Youth Applies for a Job

Ordinary Diploma in Computer Science | Arusha Technical College

Page 12 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

Figure 5.4 – Sequence diagram: apply flow (12 steps)

Ordinary Diploma in Computer Science | Arusha Technical College

Page 13 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

6. DATA MODELS & FIRESTORE SCHEMA
AI AGENT: Create ALL collections and documents in Firestore exactly as specified. Field names
are  camelCase.  Use  server  timestamps  (FieldValue.serverTimestamp())  for  all  created_at  /
updated_at fields. GeoPoints use Firebase GeoPoint type — never store lat/lng as separate strings.

Figure 6.1 – Entity Relationship Diagram

6.1 Collection: users

Path: users/{uid}

Description: Base document created on registration for ALL user types

Field

Type

Required

Description

uid

fullName

email

phone

role

String

String

String

String

Enum: youth | provider
| admin

photoURL

String (Storage URL)

location

GeoPoint

Yes

Yes

Yes

No

Yes

No

Yes

Firebase Auth UID — matches document ID

Display name

Login email

Phone number including country code (+255...)

Determines routing and Security Rules

Profile photo — uploaded to Firebase Storage

Captured at registration; updated on profile edit

Ordinary Diploma in Computer Science | Arusha Technical College

Page 14 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

Field

Type

Required

Description

status

Enum: active |
suspended | inactive

Yes

Default: active

fcmToken

String

createdAt

Timestamp

updatedAt

Timestamp

Yes

Yes

Yes

Updated on each app launch; used for push
notifications

FieldValue.serverTimestamp()

FieldValue.serverTimestamp()

6.2 Collection: jobs

Path: jobs/{jobId}

Description: Job listings posted by providers; triggers Matching Engine on create

Field

Type

Required

Description

jobId

String (auto)

providerId

String (uid ref)

title

description

category

String

String

Enum

skillsRequired

Array<String>

location

GeoPoint

locationLabel

String

payAmount

Number

payType

Enum: fixed | hourly |
negotiable

deadline

Timestamp

status

Enum: open | closed
| completed |
cancelled

applicantCount

Number

createdAt

Timestamp

Yes

Yes

Yes

Yes

Yes

Yes

Yes

Yes

Yes

Yes

Yes

Yes

Yes

Yes

Firestore auto-generated document ID

Job provider's Firebase Auth UID

Short job title (max 80 chars)

Full job description (max 1000 chars)

technical_repair | cleaning | tutoring | construction |
delivery | other

Max 5 skills from taxonomy; used by Matching Engine

Job site location; shown on map

Human-readable address (e.g., 'Arusha CBD, Sokoine
Road')

Payment amount in Tanzanian Shillings (TSh)

Payment structure

Application deadline

Default: open

Denormalised counter; incremented by Cloud Function

FieldValue.serverTimestamp() — triggers Matching
Engine

updatedAt

Timestamp

Yes

FieldValue.serverTimestamp()

6.3 Collection: youth_profiles

Path: youth_profiles/{uid}

Description: Extended profile for youth users; queried by Matching Engine

Ordinary Diploma in Computer Science | Arusha Technical College

Page 15 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

Field

Type

Required

Description

uid

skills

bio

location

String

Array<String>

String

GeoPoint

availabilityStatus

Enum: available |
busy | inactive

ratingAvg

Number

jobsCompleted

Number

portfolioURLs

Array<String>

updatedAt

Timestamp

Yes

Yes

No

Yes

Yes

Yes

Yes

No

Yes

Matches Firebase Auth UID and users/{uid}

Selected from taxonomy; used in Matching Engine
array-contains-any query

Short biography (max 300 chars)

Youth's current/home location for proximity matching

Only available youth are matched

Computed average from ratings collection; default
0.0

Counter incremented on job completion; default 0

Optional links to past work or certificates

FieldValue.serverTimestamp()

6.4 Collection: applications

Path: applications/{appId}

Field

Type

Required

Description

appId

jobId

youthId

String (auto)

String (ref)

String (uid ref)

providerId

String (uid ref)

coverMessage

String

status

Enum: pending |
accepted | rejected |
withdrawn

appliedAt

Timestamp

updatedAt

Timestamp

Yes

Yes

Yes

Yes

No

Yes

Yes

Yes

Firestore auto-generated

Reference to jobs/{jobId}

Applicant's Firebase Auth UID

Job provider's UID (for Security Rules)

Optional message from youth (max 500 chars)

Default: pending

FieldValue.serverTimestamp()

FieldValue.serverTimestamp()

6.5 Collection: ratings

Path: ratings/{ratingId}

Field

Type

Required

Description

ratingId

jobId

raterId

rateeId

String (auto)

String (ref)

String (uid ref)

String (uid ref)

Yes

Yes

Yes

Yes

Firestore auto-generated

The completed job this rating refers to

Who gave the rating

Who received the rating

Ordinary Diploma in Computer Science | Arusha Technical College

Page 16 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

Field

Type

Required

Description

raterRole

score

comment

createdAt

Enum: youth |
provider

Number (1–5)

String

Timestamp

Yes

Determines which profile to update

Yes

No

Yes

Integer star rating

Written review (max 300 chars)

FieldValue.serverTimestamp()

6.6 Collection: notifications

Path: notifications/{uid}/{notifId}

Note: Sub-collection under each user — enables efficient per-user queries

Field

Type

Required

Description

notifId

type

String (auto)

Enum

message

String

jobId

isRead

String (ref)

Boolean

createdAt

Timestamp

Yes

Yes

Yes

No

Yes

Yes

Firestore auto-generated

job_match | application_received |
application_accepted | application_rejected |
rating_received

Human-readable notification text

Related job (for deep-link navigation)

Default: false; updated to true on user tap

FieldValue.serverTimestamp()

6.7 Collection: skills_taxonomy

Path: skills_taxonomy/{skillId}

Description: Master list of available skills — seeded once at setup

Seed data (run once via Firebase Admin SDK or Firestore import):

{ id: 'plumbing',       label_en: 'Plumbing',          label_sw: 'Ufinyanzi wa
Maji',   category: 'technical_repair' }
{ id: 'electrical',     label_en: 'Electrical Work',   label_sw: 'Kazi ya
Umeme',        category: 'technical_repair' }
{ id: 'carpentry',      label_en: 'Carpentry',         label_sw: 'Useremala',
category: 'construction'     }
{ id: 'cleaning',       label_en: 'Cleaning',          label_sw: 'Usafi',
category: 'cleaning'         }
{ id: 'tutoring_math',  label_en: 'Maths Tutoring',    label_sw: 'Kufundisha
Hisabati',  category: 'tutoring'         }
{ id: 'it_support',     label_en: 'IT Support',        label_sw: 'Msaada wa
Teknolojia', category: 'technical_repair' }
{ id: 'driving',        label_en: 'Driving',           label_sw: 'Udereva',
category: 'delivery'         }
{ id: 'painting',       label_en: 'Painting',          label_sw: 'Upigaji
Rangi',        category: 'construction'     }
{ id: 'cooking',        label_en: 'Cooking / Catering','label_sw': 'Kupika /
Upishi',    category: 'other'            }

Ordinary Diploma in Computer Science | Arusha Technical College

Page 17 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

{ id: 'garden',         label_en: 'Gardening',         label_sw: 'Bustani',
category: 'cleaning'         }

Ordinary Diploma in Computer Science | Arusha Technical College

Page 18 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

7. BUSINESS LOGIC & ALGORITHMS
AI  AGENT:  Section  7.1  is  the  most  critical  business  logic  in  the  app.  Implement  EXACTLY  as
specified. Do not simplify or skip steps.

7.1 Matching Engine (Cloud Function)

Trigger: Firestore onCreate — fires when jobs/{jobId} is created

Runtime: Firebase Cloud Functions v2, Node.js 20

Function name: matchingEngine

Algorithm — Step by Step

6.  Read the new job document: extract skillsRequired[] (array) and location (GeoPoint).
7.  Query youth_profiles collection: WHERE skills array-contains-any skillsRequired[] AND

availabilityStatus == 'available'. This returns all potentially matching youth.

8.  For each candidate youth profile, compute Haversine distance between youth.location and

job.location. Retain only candidates within MATCH_RADIUS_KM (default: 10km; configurable
in Firebase Remote Config).

9.  Score each remaining candidate: score = (matching_skill_count × 3) + (1 / distance_km × 2) +

(ratingAvg × 1). Sort descending by score.

10.  Cap matches at MAX_MATCHES (default: 50) to prevent FCM spam.
11.  For each matched youth (in ranked order): (a) write a notifications/{youthId}/{notifId} document;

(b) send FCM push notification to youth's fcmToken via Firebase Admin SDK; (c) log
matching_triggered custom event in Firebase Analytics.

Cloud Function Code Scaffold

AI AGENT: Implement this exact function in functions/src/matchingEngine.ts

import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';
const db = admin.firestore();
const MATCH_RADIUS_KM = 10;
const MAX_MATCHES = 50;

export const matchingEngine = functions.firestore.onDocumentCreated(
  'jobs/{jobId}', async (event) => {
    const job = event.data?.data();
    if (!job || job.status !== 'open') return;
    const { skillsRequired, location } = job;
    // Step 2: Query available youth with overlapping skills
    const snap = await db.collection('youth_profiles')
      .where('availabilityStatus', '==', 'available')
      .where('skills', 'array-contains-any', skillsRequired.slice(0,10))
      .get();
    // Step 3–4: Filter by distance, score, sort
    const candidates = snap.docs
      .map(d => ({ ...d.data(), uid: d.id }))
      .filter(y => haversineKm(location, y.location) <= MATCH_RADIUS_KM)
      .map(y => ({ ...y, score: calcScore(y, location, skillsRequired) }))
      .sort((a,b) => b.score - a.score)
      .slice(0, MAX_MATCHES);

Ordinary Diploma in Computer Science | Arusha Technical College

Page 19 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

    // Step 5–6: Notify each matched youth
    const batch = db.batch();
    for (const youth of candidates) {
      const notifRef =
db.collection('notifications').doc(youth.uid).collection('notifs').doc();
      batch.set(notifRef, { type:'job_match', jobId: event.params.jobId,
        message: `New job match: ${job.title} — TSh ${job.payAmount}`,
        isRead: false, createdAt: admin.firestore.FieldValue.serverTimestamp()
});
    }
    await batch.commit();
    // FCM batch send (from fcmTokens array)
    const tokens = candidates.map(y => y.fcmToken).filter(Boolean);
    if (tokens.length > 0) await admin.messaging().sendEachForMulticast({
      tokens, notification: { title: 'New Job Match!', body: job.title },
      data: { jobId: event.params.jobId, type: 'job_match' } });
  }
);

7.2 Rating Average Update (Cloud Function)

Trigger: Firestore onCreate on ratings/{ratingId}

Logic:  Re-query  all  ratings  for  rateeId,  compute  average,  update  ratingAvg  on  youth_profiles  or
providers document

7.3 Application Status Notification (Cloud Function)

Trigger: Firestore onUpdate on applications/{appId}

Logic: If status changed to 'accepted' or 'rejected', send FCM notification to youth's fcmToken and write
to notifications/{youthId}

7.4 Haversine Distance Formula

Used in Matching Engine (step 3). Implementation in TypeScript:

function haversineKm(p1: FirebaseFirestore.GeoPoint, p2:
FirebaseFirestore.GeoPoint): number {
  const R=6371, dLat=(p2.latitude-p1.latitude)*Math.PI/180;
  const dLon=(p2.longitude-p1.longitude)*Math.PI/180;
  const a=Math.sin(dLat/2)**2 + Math.cos(p1.latitude*Math.PI/180)
    *Math.cos(p2.latitude*Math.PI/180)*Math.sin(dLon/2)**2;
  return R*2*Math.atan2(Math.sqrt(a),Math.sqrt(1-a));
}

Ordinary Diploma in Computer Science | Arusha Technical College

Page 20 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

8. UI/UX SPECIFICATION & SCREEN INVENTORY
AI AGENT: All screens listed below MUST be generated by Antigravity via Stitch MCP (Section 9).
Do not hand-code UI widgets. Use the HiFi mockup specifications below as the Antigravity prompt
for each screen.

8.1 Visual Design Tokens

Token

Value

Usage

Primary Blue

#1A73E8

Buttons, links, active states, header accents

Accent Green

#34A853

Success states, Apply button, active badges

Warning Amber

#FBBC05

Pay amount badges, warnings

Danger Red

#EA4335

Rejection states, delete actions

Background Dark

#0A1628

Screen backgrounds (dark theme)

Surface Card

#122030

Card backgrounds

Border

#1E3A5F

Card borders, dividers

Text Primary

#FFFFFF

Main text on dark backgrounds

Text Secondary

#90CAF9

Subtitles, captions on dark backgrounds

Text Muted

#546E7A

Timestamps, placeholders

Font

Arial / Roboto

Body text — use system font stack

Heading Font

Arial Bold

All headings and CTA button text

Border Radius

12dp

All cards; 20dp for full-width buttons; 8dp for chips

Bottom Nav Height

64dp

Bottom navigation bar

Card Elevation

4dp

Job listing cards, profile cards

8.2 Screen Inventory

Complete list of all app screens, their route names, and Antigravity generation instructions:

#

Screen
Name

Route

Auth
Required

Role

Antigravity Prompt Key

S01  Splash /
Loading

/splash

S02  Onboarding

/onboarding

(3 slides)

S03

Login

/login

S04  Register —
Step 1 (role
select)

/register/role

No

No

No

No

All

All

All

All

splash_screen

onboarding_slides

auth_login

register_role

Ordinary Diploma in Computer Science | Arusha Technical College

Page 21 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

#

Screen
Name

Route

Auth
Required

Role

Antigravity Prompt Key

S05  Register —

/register/details

No

All

register_details

Step 2
(details)

S06  Register —

/register/profile

No

Youth

register_profile_youth

Step 3 (skills
/ location)

S07  Home / Job
Feed

/home

S08

Job Detail

/jobs/:jobId

S09  Apply for Job
(modal)

/jobs/:jobId/apply

Yes

Youth

home_job_feed

Yes

Yes

Youth

job_detail

Youth

apply_modal

S10  My

/applications

Yes

Youth

my_applications

Applications

S11  Notifications

/notifications

S12  Youth Profile
(own)

/profile

S13  Edit Profile /
Skills

/profile/edit

Yes

Yes

All

notifications_list

Youth

youth_profile_own

Yes

Youth

profile_edit

S14  Provider
Home /
Dashboard

S15  Post New
Job

/provider/home

Yes

Provider

provider_dashboard

/provider/jobs/new

Yes

Provider

post_job_form

S16  Edit Job

/provider/jobs/:jobId/edit

Yes

Provider

edit_job_form

S17  View

/provider/jobs/:jobId/applicants  Yes

Provider

applicants_list

Applicants

S18  Youth Public
Profile

/youth/:uid

Yes

Provider

youth_public_profile

S19  Rate Worker

/rate/:jobId

Yes

Both

rating_modal

/ Provider

S20  Admin

/admin

Dashboard

Yes

Admin

admin_dashboard

S21  Admin —
User List

/admin/users

Yes

Admin

admin_user_list

S22  Admin — Job
List

/admin/jobs

S23  Search /

/search

Filter Jobs

Yes

Admin

admin_job_list

Yes

Youth

search_filter

S24  Map View
(job
locations)

/map

Yes

Youth

map_view

Ordinary Diploma in Computer Science | Arusha Technical College

Page 22 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

8.3 Key Screen Specifications

S07 — Home / Job Feed

•  Top greeting: 'Hi [name]! 👋 Discover Opportunities Near You'
•  Search bar with filter icon — routes to S23
•  Category filter chips: All | Tech | Cleaning | Construction | Tutoring | Other (horizontal scroll)
•

Job cards (ListView.builder, paginated 15): emoji icon, job title (bold), location, time posted, pay
badge (amber), Apply button (green)

•  Bottom navigation: Home | Search | Post (FAB, provider only) | Notifications (badge) | Profile
•  Empty state: illustration + 'No jobs near you yet. Check back soon!'

S08 — Job Detail

•  Header: back arrow, 'Job Details' title
Job title (large bold), location + pay + duration chips
•
•  Provider card: avatar, name, star rating, jobs done count
•  Description text (scrollable)
•  Skills chips (from skillsRequired[])
•  Primary CTA: 'Apply for This Job' (full-width green button) — disabled if already applied
•  Secondary CTA: 'Save for Later' (outline button)

Figure 8.1 – High-Fidelity Mockups: Onboarding, Job Feed, Job Detail, Profile

Ordinary Diploma in Computer Science | Arusha Technical College

Page 23 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

Figure 8.2 – Low-Fidelity Wireframes: structural layout reference

Ordinary Diploma in Computer Science | Arusha Technical College

Page 24 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

9. STITCH MCP + ANTIGRAVITY INTEGRATION
GUIDE
AI AGENT: This section defines the EXACT workflow for generating all Fursafy UI screens using
Antigravity via Stitch MCP. Follow these steps before writing any Flutter widget code. Antigravity
generates production-ready Flutter widgets — use them directly.

9.1 What is Stitch MCP + Antigravity?

Stitch MCP is  a Model Context Protocol server that connects  AI coding agents to external services.
Antigravity is a UI generation platform that takes design prompts and outputs production-ready Flutter
widget code. Together, they allow an AI agent to generate all Fursafy screens without hand-coding any
UI widgets.

9.2 Prerequisites

12.  Stitch MCP server installed and running in the agent's environment.
13.  Antigravity account provisioned and API key stored in environment variable

ANTIGRAVITY_API_KEY.

14.  Stitch MCP configured with the Antigravity connector — add to mcp_servers in agent config:
{ "name": "antigravity", "url": "https://stitch.antigravity.dev/mcp/v1" }
15.  Design tokens from Section 8.1 uploaded to Antigravity as a shared design system named

'fursafy-design-system'.

9.3 Screen Generation Workflow

Step 1 — Upload Design System
Before generating any screen, post the design tokens (Section 8.1) to Antigravity as a design system.
This ensures all generated screens use consistent colours, typography, and spacing.

// Via Stitch MCP tool call:
antigravity.createDesignSystem({
  name: 'fursafy-design-system',
  tokens: { primaryBlue:'#1A73E8', accentGreen:'#34A853', ... },
  fonts: ['Arial', 'Roboto'],
  theme: 'dark',
  borderRadius: { card:12, button:20, chip:8 }
})

Step 2 — Generate Each Screen
For each screen in the Screen Inventory (Section 8.2), call Antigravity via Stitch MCP using the screen's
Antigravity Prompt Key and the specification from Section 8.3. Example for S07 (Home / Job Feed):

antigravity.generateScreen({
  designSystem: 'fursafy-design-system',
  screenKey: 'home_job_feed',
  framework: 'flutter',
  stateManagement: 'riverpod',
  navigation: 'go_router',
  specification: {

Ordinary Diploma in Computer Science | Arusha Technical College

Page 25 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

    layout: 'scrollable_feed',
    components: ['greeting_header', 'search_bar', 'category_chips',
'job_card_list', 'bottom_nav'],
    dataBindings: { jobList: 'StreamProvider<List<Job>>', userName: 'String' },
    actions: { onApplyTap: 'navigate_to_job_detail', onSearchTap:
'navigate_to_search' }
  }
})

Step 3 — Save Generated Widget Code
Antigravity returns a Flutter widget file. Save it to the correct path in the Flutter project:

lib/features/jobs/presentation/screens/home_screen.dart  // S07
lib/features/jobs/presentation/screens/job_detail_screen.dart  // S08
lib/features/auth/presentation/screens/login_screen.dart  // S03
// ... one file per screen

Step 4 — Wire Business Logic
After UI generation, wire each screen to its Riverpod providers and Firestore repositories. Do not modify
the generated UI code directly — use controllers and providers as the boundary layer.

9.4 Antigravity Prompt Templates

Use these prompt templates for each screen category:

Auth  screens  (S03–S06):  Dark  background  (#0A1628),  centered  form  layout,  primary  blue  input
borders, full-width green CTA buttons, Fursafy logo at top.

Feed screens (S07, S10, S11): Dark background, top greeting header with Primary Blue gradient, card
list with #122030 card surface, amber pay badges, green Apply buttons.

Detail screens (S08, S18): Dark background, provider avatar card, skill chips in Primary Blue outline,
sticky bottom CTA bar with green Apply button.

Form screens (S15, S16, S13): Dark background, labelled text inputs with #1E3A5F border, skill multi-
select chips, Google Maps embed for location, full-width submit button.

Admin screens (S20–S22): Lighter dark (#122030 bg), data tables with Primary Blue headers, status
badges, chart widgets from fl_chart package.

Ordinary Diploma in Computer Science | Arusha Technical College

Page 26 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

10. FIREBASE CONFIGURATION & SETUP
AI AGENT: Follow these steps exactly before running the Flutter app. A misconfigured Firebase
project will cause all features to fail.

10.1 Firebase Project Setup

16.  Create a new Firebase project at console.firebase.google.com named 'fursafy-prod'.
17.  Enable Blaze (pay-as-you-go) plan — required for Cloud Functions HTTP outbound calls.
18.  Add Android app with package name: com.fursafy.app — download google-services.json to

android/app/.

19.  Add iOS app with bundle ID: com.fursafy.app — download GoogleService-Info.plist to

ios/Runner/.

10.2 Services to Enable

Service

Console Location

Configuration

Firebase Auth

Authentication > Sign-in
methods

Enable: Email/Password, Phone

Cloud Firestore

Firestore Database

Create in production mode; region: europe-west1 (closest to
Tanzania)

Firebase Storage

Storage

Enable; set rules (see Section 13.3)

Cloud Functions

Functions

Enable; runtime Node.js 20

Firebase FCM

Project Settings >
Cloud Messaging

Note the Server Key for Admin SDK

Google Analytics

Analytics

Enable; link to Firebase project

Crashlytics

Crashlytics

Enable after first app run

Remote Config

Remote Config

Create parameter: match_radius_km = 10

10.3 Required Flutter Packages

Add to pubspec.yaml:

dependencies:
  flutter: sdk: flutter
  firebase_core: ^3.x.x
  firebase_auth: ^5.x.x
  cloud_firestore: ^5.x.x
  firebase_storage: ^12.x.x
  firebase_messaging: ^15.x.x
  firebase_analytics: ^11.x.x
  firebase_crashlytics: ^4.x.x
  firebase_remote_config: ^5.x.x
  google_maps_flutter: ^2.x.x
  flutter_riverpod: ^2.x.x
  riverpod_annotation: ^2.x.x
  go_router: ^14.x.x
  hive_flutter: ^1.x.x

Ordinary Diploma in Computer Science | Arusha Technical College

Page 27 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

  image_picker: ^1.x.x
  geolocator: ^13.x.x
  flutter_localizations: sdk: flutter
  intl: ^0.19.x

Ordinary Diploma in Computer Science | Arusha Technical College

Page 28 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

11. FLUTTER PROJECT STRUCTURE
feature-first  Clean  Architecture.  Each
AI  AGENT:  Use
data/domain/presentation layers. This structure is mandatory — do not use flat folder structure.

feature  has

its  own

11.1 Folder Structure

lib/
├── main.dart                          # App entry point,
Firebase.initializeApp()
├── app/
│   ├── app.dart                       # MaterialApp.router with GoRouter
│   ├── router.dart                    # All GoRouter routes (24 screens)
│   └── theme.dart                     # AppTheme with design tokens
├── core/
│   ├── firebase/                      # FirebaseService, FCM handler
│   ├── error/                         # AppException, Failure classes
│   ├── utils/                         # Haversine util, validators, formatters
│   └── widgets/                       # Shared widgets: AppButton, AppCard,
SkillChip
├── features/
│   ├── auth/
│   │   ├── data/                      # AuthRepository, FirebaseAuthDataSource
│   │   ├── domain/                    # AuthRepository interface, User entity
│   │   └── presentation/              # LoginScreen, RegisterScreen
(Antigravity generated)
│   ├── jobs/
│   │   ├── data/                      # JobRepository, FirestoreJobDataSource
│   │   ├── domain/                    # Job entity, Application entity
│   │   └── presentation/              # HomeScreen, JobDetailScreen
(Antigravity)
│   ├── profile/
│   │   ├── data/                      # ProfileRepository
│   │   ├── domain/                    # YouthProfile, ProviderProfile entities
│   │   └── presentation/              # ProfileScreen, EditProfileScreen
│   ├── notifications/
│   │   ├── data/                      # NotificationRepository
│   │   └── presentation/              # NotificationsScreen
│   ├── ratings/
│   │   └── presentation/              # RatingModal
│   └── admin/
│       └── presentation/              # AdminDashboard, UserList, JobList
├── l10n/
│   ├── app_en.arb                     # English strings
│   └── app_sw.arb                     # Swahili strings
functions/                             # Firebase Cloud Functions
├── src/
│   ├── index.ts                       # Function exports
│   ├── matchingEngine.ts              # FR-21 — full spec in Section 7.1
│   ├── updateRatingAverage.ts         # Section 7.2
│   └── sendStatusNotification.ts      # Section 7.3
└── package.json

Ordinary Diploma in Computer Science | Arusha Technical College

Page 29 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

12. API & INTEGRATION SPECIFICATIONS

12.1 Firebase Firestore Queries

All Firestore queries used in the app — agent must create corresponding composite indexes:

Screen / Feature

Collection

Query

Index Required

Home Job Feed

jobs

Search by
category

jobs

where status=='open' orderBy
createdAt desc limit 15

status ASC, createdAt
DESC

where status=='open' where
category==X orderBy createdAt
desc

status ASC, category ASC,
createdAt DESC

My Applications

applications

where youthId==uid orderBy
appliedAt desc

youthId ASC, appliedAt
DESC

Applicants for job

applications

where jobId==X orderBy appliedAt
desc

jobId ASC, appliedAt DESC

Notifications

notifications/{uid}

orderBy createdAt desc limit 50

createdAt DESC

Ratings for user

ratings

where rateeId==uid orderBy
createdAt desc

rateeId ASC, createdAt
DESC

Matching Engine

youth_profiles

where status=='available' where
skills array-contains-any []

Automatic for array queries

12.2 Google Maps Platform

API

Maps SDK for
Android/iOS

Places API
(Autocomplete)

Geocoding API

Usage

Flutter Package

Display job location map on S08; show map pins
for nearby jobs on S24

google_maps_flutter

Address search in job posting form (S15) and
profile location setup

google_maps_flutter + http

Convert address text to GeoPoint when provider
types a location

Called from Cloud Function

12.3 FCM Notification Payload

All FCM messages must include a data payload for deep-link navigation:

{
  notification: { title: 'New Job Match!', body: 'Plumber Needed — TSh 25,000'
},
  data: { type: 'job_match', jobId: 'abc123', screen: '/jobs/abc123' },
  android: { priority: 'high', notification: { sound: 'default', channelId:
'fursafy_jobs' } },
  apns: { payload: { aps: { sound: 'default', badge: 1 } } }
}

Ordinary Diploma in Computer Science | Arusha Technical College

Page 30 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

13. SECURITY & ACCESS CONTROL
AI AGENT: Deploy these Firestore Security Rules EXACTLY as written before running any app
code. Rules are the primary security layer — a bug here exposes user data.

13.1 Firestore Security Rules

rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    // Helper functions
    function isSignedIn() { return request.auth != null; }
    function isOwner(uid) { return request.auth.uid == uid; }
    function getRole() { return
get(/databases/$(db)/documents/users/$(request.auth.uid)).data.role; }
    function isYouth() { return getRole() == 'youth'; }
    function isProvider() { return getRole() == 'provider'; }
    function isAdmin() { return getRole() == 'admin'; }
    function isActive() { return
get(/databases/$(db)/documents/users/$(request.auth.uid)).data.status ==
'active'; }
    // users collection
    match /users/{uid} {
      allow read: if isSignedIn();
      allow write: if isOwner(uid) || isAdmin();
    }
    // jobs collection
    match /jobs/{jobId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && isProvider() && isActive();
      allow update, delete: if isOwner(resource.data.providerId) || isAdmin();
    }
    // applications collection
    match /applications/{appId} {
      allow read: if isOwner(resource.data.youthId) ||
isOwner(resource.data.providerId) || isAdmin();
      allow create: if isSignedIn() && isYouth() && isActive();
      allow update: if isOwner(resource.data.youthId) ||
isOwner(resource.data.providerId);
    }
    // youth_profiles collection — location is private
    match /youth_profiles/{uid} {
      allow read: if isSignedIn();
      allow write: if isOwner(uid) || isAdmin();
    }
    // notifications — private to owner
    match /notifications/{uid}/{notifId} {
      allow read, write: if isOwner(uid);
    }
    // ratings
    match /ratings/{ratingId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && isActive();
      allow update, delete: if false; // ratings are immutable
    }

Ordinary Diploma in Computer Science | Arusha Technical College

Page 31 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

  }
}

13.2 Firebase Auth Custom Claims

Set role claim on user creation via Cloud Function (onUserCreate trigger):

// Triggered when user doc is created — sets custom claim from role field
admin.auth().setCustomUserClaims(uid, { role: userData.role });

13.3 Firebase Storage Rules

rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{uid}/{allFiles=**} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == uid && request.resource.size < 5 *
1024 * 1024
                      && request.resource.contentType.matches('image/.*');
    }
  }
}

Ordinary Diploma in Computer Science | Arusha Technical College

Page 32 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

14. TESTING STRATEGY & TEST CASES
AI  AGENT:  Run  ALL  test  cases  before  marking  the  build  as  complete.  Unit  tests  run  locally.
Integration tests run against the Firebase Emulator Suite.

14.1 Testing Levels

Level

Scope

Tools

When to Run

Unit Tests

Widget Tests

Individual Dart
functions, Repository
methods, Haversine
formula

Individual Flutter
screens (rendered
against mock
providers)

flutter test + mockito

On every code change (CI)

flutter test + WidgetTester  On every UI change

Integration
Tests

Full user flows on
real/emulated device

flutter_test + Firebase
Emulator

Before each sprint release

Cloud
Function
Tests

matchingEngine,
updateRatingAverage,
sendStatusNotification

jest + firebase-functions-
test

On every Cloud Function change

Security
Rules Tests

All Firestore Security
Rules scenarios

Usability
Testing

5+ youth users using
the app on real
Android devices

Firebase Emulator +
@firebase/rules-unit-
testing

Manual observation +
SUS questionnaire

Before deploying rules

Before final submission

14.2 Critical Test Cases

TC
ID

TC-
01

TC-
02

TC-
03

TC-
04

TC-
05

TC-
06

Module

Test Case

Expected Result

Pass Criteria

Auth

Auth

Register as Youth with valid
email

Account created in Firebase
Auth + users/{uid} +
youth_profiles/{uid}

All 3 docs exist;
role='youth'

Register as Provider with
valid email

Account created +
providers/{uid}

Doc exists;
role='provider'

Auth

Login with wrong password

Error shown: 'Wrong
password'

No navigation; error
message shown

Matching

Post job with
skills=['plumbing','electrical'];
youth has skills=['plumbing']

Youth receives FCM
notification within 10s

Notification in Firestore
+ FCM delivered

Matching

Post job; youth is outside
10km radius

Youth does NOT receive
notification

Matching

Post job; youth
status='busy'

Youth not matched

No notification doc
created for out-of-range
youth

No notification for busy
youth

Ordinary Diploma in Computer Science | Arusha Technical College

Page 33 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

TC
ID

TC-
07

TC-
08

TC-
09

TC-
10

TC-
11

TC-
12

Module

Test Case

Expected Result

Pass Criteria

Application

Youth applies for same job
twice

Second apply blocked; button
shows 'Already Applied'

No duplicate application
doc

Security
Rules

Security
Rules

Ratings

Youth tries to write to
another user's profile

Unauthenticated user reads
jobs

Provider rates youth after
job completion

Notifications  Application accepted →

youth notified

Firestore permission denied

Firestore permission denied

ratings doc created;
youth_profiles.ratingAvg
updated

FCM sent +
notifications/{youthId} doc
created with
type='application_accepted'

FirebaseException with
PERMISSION_DENIED

FirebaseException with
PERMISSION_DENIED

ratingAvg = mean of all
scores for that youth

isRead=false; type
correct

Admin

Admin suspends user

users/{uid}.status='suspended';
user cannot post jobs

Firestore rule blocks
write for suspended
user

14.3 Usability Testing Protocol

Conduct usability testing with a minimum of 5 youth users from Arusha (age 18–30). Use the System
Usability Scale (SUS) questionnaire after each session. Target SUS score ≥ 68 (above average). Test
the following tasks:

20.  Create a youth account and complete your profile with 3 skills.
21.  Find a plumbing job near Arusha and apply for it.
22.  Check your application status in My Applications.
23.  Rate a job provider after a completed job.
24.  Find and read a push notification, then navigate to the related job.

Ordinary Diploma in Computer Science | Arusha Technical College

Page 34 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

15. DEPLOYMENT & CI/CD

15.1 Environments

Environment

Firebase Project

Purpose

Development

fursafy-dev

Local development with Firebase Emulator Suite

Staging

fursafy-staging

Integration testing and supervisor review

Production

fursafy-prod

Final submission and live prototype

15.2 GitHub Actions CI/CD Pipeline

# .github/workflows/ci.yml
on: [push, pull_request]
jobs:
  test:
    steps:
      - flutter pub get
      - flutter analyze
      - flutter test
      - cd functions && npm test
  deploy_functions:
    if: branch == 'main'
    steps:
      - firebase deploy --only functions
  build_android:
    if: branch == 'main'
    steps:
      - flutter build appbundle --release
      - firebase appdistribution:distribute
build/app/outputs/bundle/release/app-release.aab

15.3 Pre-Submission Checklist

•  All 24 screens generated by Antigravity and wired to business logic
•  All 3 Cloud Functions deployed and passing tests
•  Firestore Security Rules deployed and tested
•  Firebase Storage Rules deployed
•  Composite Firestore indexes created for all queries in Section 12.1
•
•  Bilingual strings complete for both en and sw ARB files
•  SUS usability score ≥ 68 from 5+ test users
•  All TC-01 through TC-12 test cases passing
•  Crashlytics enabled and first session data visible

skills_taxonomy collection seeded with all skill documents

Ordinary Diploma in Computer Science | Arusha Technical College

Page 35 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

16. DEVELOPMENT CONSTRAINTS & ASSUMPTIONS

16.1 Technical Constraints

•  Firestore free tier (Spark): 50,000 reads/day, 20,000 writes/day, 20,000 deletes/day. Monitor

usage via Firebase console during testing.

•  Cloud Functions require Blaze plan for outbound HTTP calls (FCM Admin SDK). Upgrade

Firebase project before deploying functions.

•  Google Maps API: Requires valid billing-enabled Google Cloud project. Restrict API key to app

package name.

•  Flutter 3.x required — do not downgrade. Check: flutter --version ≥ 3.19.
•  Dart 3.x required for null safety and latest Riverpod features.

16.2 Academic Constraints

•  This is an academic prototype — production scalability is designed for but not load-tested.
•  Payment processing is OUT OF SCOPE for this submission per Section 1.6.
•  The prototype will be evaluated by Eng. Abdul Kirobo at ATC — ensure the Admin dashboard is

functional for demonstration.

16.3 Assumptions

•  The AI agent has internet access and can install npm/pub packages from the allowed domains

list.

•  Stitch MCP + Antigravity connector is authenticated and functional before UI generation begins.
•  Firebase project 'fursafy-prod' is already created and Blaze plan enabled before Cloud

Functions deployment.

•  Google Maps API key is provisioned and available as environment variable

GOOGLE_MAPS_API_KEY.

Ordinary Diploma in Computer Science | Arusha Technical College

Page 36 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

17. GLOSSARY

Term

Antigravity

Cloud Function

FCM

Firestore

GeoPoint

GoRouter

Haversine Distance

Matching Engine

MCP

Riverpod

SRS

Definition

UI generation platform that produces production-ready Flutter widget code from
design prompts

Serverless function hosted on Firebase that runs on specific triggers (Firestore
events, HTTP calls)

Firebase Cloud Messaging — Google's push notification service for Android and
iOS

Firebase's NoSQL cloud database, organised in collections and documents

Firebase data type storing latitude and longitude as a single field

Flutter navigation package providing declarative routing with deep-link support

Mathematical formula for computing the shortest distance between two points on a
sphere using lat/lng

Firebase Cloud Function that matches youth to job listings based on skills and
proximity

Model Context Protocol — a standard allowing AI agents to connect to external tools
and services

Flutter state management framework; AsyncNotifier and StreamProvider used in
Fursafy

Software Requirements Specification — this document

Stitch MCP

MCP server providing AI agents access to Antigravity and other connected services

Skills Taxonomy

Predefined list of skill categories stored in skills_taxonomy Firestore collection

SUS

Waterfall

Youth

System Usability Scale — standardised questionnaire for measuring UI usability
(score 0–100)

Sequential software development methodology: Requirements → Design →
Implementation → Testing → Deployment

Primary user type: aged 18–35, registered as job seeker on Fursafy

Ordinary Diploma in Computer Science | Arusha Technical College

Page 37 of 38

Fursafy SRS — Software Requirements Specification

Ashtek | ATC | 2025/2026

18. REFERENCES
Braun, V., & Clarke, V. (2006). Using thematic analysis in psychology. Qualitative Research in Psychology,

3(2), 77–101.

CloudDevs. (2024). Creating a job search app with Flutter: Filters and job listings. Retrieved from

https://clouddevs.com/flutter/job-search-app/

Creswell, J. W. (2014). Research design: Qualitative, quantitative, and mixed methods approaches (4th

ed.). SAGE Publications.

Daily News. (2025). Digital economy key to youth employment. Retrieved from https://dailynews.co.tz
Daily News. (2026). Vijana platform: Empowering Tanzania's youth to shape future. Retrieved from

https://dailynews.co.tz

Evans, C., & Lean, J. (2025). Exploring university students' reasons for not working while studying:

Implications for employability. Journal of Education and Work, 38(2).

Google. (2023). Firebase documentation. Retrieved from https://firebase.google.com/docs
Grunewald, A. (2022). A gig economy solution to boost employment in Africa. Brookings Institution.

Retrieved from https://www.brookings.edu

Hevner, A. R., March, S. T., Park, J., & Ram, S. (2004). Design science in information systems research.

MIS Quarterly, 28(1), 75–105.

Ifakara Innovation Hub. (2021). Mchongoo: A digital marketplace bridging skills and job opportunities in

Tanzania.

International Labour Organization. (2022). Global employment trends for youth 2022. ILO.
ISO 9241-11. (1998). Ergonomic requirements for office work with visual display terminals (VDTs) — Part

11: Guidance on usability. ISO.

Mtebe, J., Kissaka, M. M., Raphael, C., & Stephen, J. K. (2020). Promoting youth employment through ICT

in vocational education in Tanzania. Journal of Learning for Development, 7(1), 90–107.

NACEWEB. (2024). Reimagining student employment. National Association of Colleges and Employers.
Oates, B. J. (2006). Researching information systems and computing. SAGE Publications.
Pressman, R. S. (2014). Software engineering: A practitioner's approach (8th ed.). McGraw-Hill.
Saunders, M., Lewis, P., & Thornhill, A. (2019). Research methods for business students (8th ed.).

Pearson.

Sommerville, I. (2016). Software engineering (10th ed.). Pearson.
The Citizen. (2022). How Tanzanian university students are turning side hustles into survival strategies.

Mwananchi Communications.

The Citizen. (2023). DayWaka app connects Tanzanians to short-term jobs. Mwananchi Communications.
Winn, H. L. (2021). The influence of part-time work on graduates' careers. Higher Education, Skills and

Work-based Learning, 11(2), 372–387.

World Bank. (2021). Tanzania economic update: Addressing youth unemployment through skills

development. World Bank Group.

World Bank. (2023). The promise and peril of online gig work in developing countries. World Bank Group.

Ordinary Diploma in Computer Science | Arusha Technical College

Page 38 of 38

