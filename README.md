# Workforce Pro 🚀

**Workforce Pro** is a production-grade, enterprise workforce management and real-time shift scheduling mobile application built using **Flutter**, **Firebase Auth**, and **Cloud Firestore**.

Designed following **Feature-First Clean Architecture** and **BLoC (Cubit)** pattern, Workforce Pro provides real-time shift synchronization, interactive time-marker timelines, 1-on-1 employee-manager messaging, automated adherence tolerance tracking, and role-based manager tools.

---

## 📸 Core Features & Capabilities

### 📍 1. Real-Time Interactive Daily Timeline
- **Moving Live Red Marker (`📍 hh:mm a`):** Ticker timer updating dynamically every 15 seconds to point to the current minute on the schedule.
- **Attendance-Controlled Shift Activation:** Shift progress and live timeline activation are strictly synchronized with Attendance (`Clock In`).
- **Activity Progress Bar:** Proportional progress fraction updated dynamically per activity.

### 🗓️ 2. Real-Time Manager Schedule Builder
- **Canonical Document Sync (`sched_${employeeId}_${startOfDay}`):** 1-to-1 deterministic document ID matching for instant, query-free manager-to-employee schedule updates.
- **Interactive Shift & Activity Creator:** TimeOfDay pickers, activity color codes, icons, and real-time Firestore persistence.

### 💬 3. Real-Time 1-on-1 Conversations & Chat
- **Real-Time Firestore Streams:** Instant messaging via sub-collections (`chats/chat_${roomId}/messages`).
- **Modern Message Bubbles:** Responsive sender/receiver alignment, gradient styling, avatars, and timestamps.
- **Employee Directory Search:** Instant name/department search for one-tap messaging.

### 👤 4. Employee Details & 30-Day Monthly Evaluation
- **30-Day Monthly Performance Card:** Star rating (⭐⭐⭐⭐⭐), attendance rate calculation, and performance tier badges (`Excellent`, `Very Good`, `Good`, `Needs Improvement`).
- **Manager Date Selector Bar (`◀ Date Picker ▶`):** Interactive day-by-day navigation to view historical or future shift schedules.
- **Date-Filtered Logs:** Attendance log and activity transition adherence log filtered strictly for the selected shift date.

### ⏱️ 5. Attendance & Adherence Tracking
- **Clock In / Clock Out:** Real-time Firestore records mapped to canonical IDs (`att_${employeeId}_${startOfDay}`).
- **2-Minute Adherence Tolerance:** Automatic calculation comparing planned vs actual activity transitions (**On-Time**, **Late**, **Early**, **Unplanned**).

### 📋 6. Role-Aware Request Management
- Submit requests for PTO, Late Arrival, or Early Departure.
- Role-based manager review with approval/rejection notes.

### 🌐 7. Multi-Language & Theme Support
- **Easy Localization:** Full English & Arabic support with LTR/RTL layouts.
- **Persistent Dark/Light Mode:** Custom `ThemeCubit` storing user preferences in `SharedPreferences`.

---

## 🏗️ Architecture & Project Structure

The project follows **Feature-First Clean Architecture** for optimal modularity, maintainability, and testability.

```text
lib/
├── main.dart                      # App Entrypoint & Firebase Initialization
├── workforce_app.dart             # Root App Widget & MultiBlocProvider Setup
├── core/                          # Shared Application Layer
│   ├── cach/                      # SharedPreferences Helper
│   ├── di/                        # GetIt Dependency Injection Registration
│   ├── reusable_component/        # App Buttons, Badges, Loaders, Error States
│   ├── routes_manager/            # Route Names & Page Transitions
│   └── utils/                     # Colors, Constants, Text Styles, Theme Cubit
└── features/                      # Feature-First Modules
    ├── attendance/                # Clock In/Out, Attendance History
    ├── auth/                      # Firebase Sign In, Sign Up, Persistent Session
    ├── chat/                      # Real-time 1-on-1 Messaging
    ├── company/                   # Departments & Activity Library
    ├── dashboard/                 # Manager Dashboard Metrics & Quick Tools
    ├── employees/                 # Directory & Employee Details Screen
    ├── home/                      # Employee Home Dashboard & Quick Actions
    ├── main_layout/               # Bottom Navigation Bar Layout
    ├── profile/                   # Profile Settings, Language, Dark Mode
    ├── reports/                   # Company Reports & Analytics
    ├── requests/                  # Requests Submission & Manager Approval
    └── schedules/                 # Daily Timeline View, Schedule Builder, Adherence Logic
```

---

## 🛠️ Technology Stack & Dependencies

- **Framework:** Flutter 3.29 / Dart 3.7
- **Architecture:** Feature-First Clean Architecture
- **State Management:** `flutter_bloc` (Cubit)
- **Dependency Injection:** `get_it` & `injectable`
- **Backend Services:** Firebase Core, Firebase Auth, Cloud Firestore
- **Localization:** `easy_localization` (English & Arabic)
- **Responsive Layout:** `flutter_screenutil`
- **Session Caching:** `shared_preferences`
- **Routing:** `page_transition`

---

## 🔐 Firestore Security Rules

Copy and paste these rules into **Firebase Console -> Firestore Database -> Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // User Accounts
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // Schedules & Activity Transitions
    match /planned_schedules/{scheduleId} {
      allow read, write: if request.auth != null;
    }

    match /actual_activity_transitions/{transitionId} {
      allow read, write: if request.auth != null;
    }

    // Attendance Records
    match /attendance_records/{recordId} {
      allow read, write: if request.auth != null;
    }

    // Requests
    match /requests/{requestId} {
      allow read, write: if request.auth != null;
    }

    // Companies, Departments & Activities
    match /companies/{companyId} {
      allow read, write: if request.auth != null;
    }

    match /departments/{departmentId} {
      allow read, write: if request.auth != null;
    }

    match /activity_definitions/{activityId} {
      allow read, write: if request.auth != null;
    }

    // Real-Time Conversations & Chat Messages
    match /chats/{chatId} {
      allow read, write: if request.auth != null;
      
      match /messages/{messageId} {
        allow read, write: if request.auth != null;
      }
    }
  }
}
```

---

## 🚀 Getting Started

### Prerequisites
1. [Flutter SDK](https://docs.flutter.dev/get-started/install) (version ^3.29.0)
2. Android Studio / VS Code
3. An active Firebase Project with Auth and Cloud Firestore enabled.

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/workforce.git
   cd workforce
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run code analysis & unit tests:
   ```bash
   flutter analyze
   flutter test
   ```
4. Run the application:
   ```bash
   flutter run
   ```

---

## 🧪 Testing

The codebase includes unit tests verifying schedule progress calculations, adherence tolerance windows, and state management logic.

To run all unit tests:
```bash
flutter test
```

---

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
