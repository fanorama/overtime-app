# Design Document: Overtime Management App

**Tanggal**: 2025-11-02
**Platform**: Flutter (Multi-platform)
**Backend**: Firebase (Auth, Firestore, Cloud Messaging, Cloud Functions)

---

## 1. Project Overview

Aplikasi Flutter untuk manajemen dan pencatatan aktivitas lembur karyawan dengan sistem approval manager. Aplikasi ini khusus untuk tracking overtime dalam konteks technical support/field service dengan data detail mencakup customer, engineers involved, severity, dan perhitungan earning otomatis.

### Key Features
- Submit overtime request dengan 15+ field data detail
- Manager approval/rejection workflow
- Re-approval mechanism untuk edited overtime
- Automatic earning calculation (weekday/weekend, type of work multipliers, meal allowance)
- Push notifications + email notifications
- Dashboard sederhana untuk employee dan manager
- Master data management untuk employees

---

## 2. Architecture Overview

### Architecture Pattern
**Clean Architecture Simplified** dengan 3 layer:

1. **Presentation Layer**: UI (Flutter Widgets) + State Management (Riverpod)
2. **Business Logic Layer**: Services untuk business rules dan orchestration
3. **Data Layer**: Firebase integration (Firestore, Auth, Cloud Functions)

### Folder Structure
```
lib/
├── main.dart
├── core/
│   ├── constants/          # App constants, colors, strings, formulas
│   ├── utils/              # Helpers, formatters, validators, calculators
│   └── widgets/            # Reusable widgets (buttons, cards, chips)
│
├── features/
│   ├── auth/
│   │   ├── models/         # User model
│   │   ├── providers/      # Auth state management
│   │   ├── services/       # Firebase Auth service
│   │   └── screens/        # Login, Registration screens
│   │
│   ├── overtime/
│   │   ├── models/         # OvertimeRequest model
│   │   ├── providers/      # Overtime state management
│   │   ├── services/       # Firestore CRUD operations
│   │   └── screens/        # List, Form, Detail screens
│   │
│   ├── employees/
│   │   ├── models/         # Employee model
│   │   ├── providers/      # Employee state management
│   │   ├── services/       # Employee CRUD
│   │   └── screens/        # Employee management (Manager only)
│   │
│   └── dashboard/
│       ├── providers/      # Dashboard data aggregation
│       ├── services/       # Query & calculation services
│       └── screens/        # Dashboard untuk Employee & Manager
│
└── firebase_options.dart   # Firebase configuration
```

---

## 3. Data Models & Firebase Schema

### 3.1 Firebase Collections

#### users/
```
users/{userId}
  - username: string (unique, for login)
  - displayName: string
  - role: string ("employee" | "manager")
  - createdAt: timestamp
```

#### employees/
```
employees/{employeeId}
  - name: string
  - role: string ("engineer" | "maintenance" | "postsales" | "onsite")
  - isActive: boolean
  - createdAt: timestamp
```

#### overtime_requests/
```
overtime_requests/{requestId}
  - submittedBy: userId (reference)
  - submittedByName: string
  - status: string ("pending" | "approved" | "rejected")

  # Time & Duration
  - startDateTime: timestamp
  - finishDateTime: timestamp
  - totalHours: number (calculated)
  - isWeekend: boolean (auto-detect)

  # Customer & Problem
  - customer: string
  - reportedProblem: string

  # Involved People (arrays of employeeIds)
  - involvedEngineers: array
  - involvedMaintenance: array
  - involvedPostsales: array

  # Work Details
  - typeOfWork: array of strings ["Overtime", "Call", "Unplanned", "NonOT", "Visit Siang"]
  - product: string
  - severity: string ("low" | "medium" | "high" | "critical")

  # Work Description & Follow-up
  - workingDescription: string
  - nextPossibleActivity: string
  - version: string
  - pic: string
  - responseTime: number (in minutes)

  # Earnings (auto-calculated)
  - calculatedEarnings: number
  - mealAllowance: number
  - totalEarnings: number

  # Approval Info
  - approvedBy: userId (nullable)
  - approvedAt: timestamp (nullable)
  - rejectionReason: string (nullable)

  # Edit Tracking
  - isEdited: boolean
  - editHistory: array of {editedAt: timestamp, editedBy: userId, reason: string}

  # Timestamps
  - createdAt: timestamp
  - updatedAt: timestamp
```

### 3.2 Dart Models

**OvertimeRequest Model:**
- Properties untuk semua fields di atas
- Methods: `toJson()`, `fromJson()`, `copyWith()`
- Computed properties: `totalHours`, `isApproved`, `isPending`, `needsReapproval`

**Employee Model:**
- Basic info + filtering by role

**User Model:**
- Authentication + role-based access control

---

## 4. Authentication & Role-Based Access

### 4.1 Authentication Method
- **Username + Password** (bukan email)
- Menggunakan Firebase Auth dengan format: `{username}@overtime.internal`
- Username asli disimpan di Firestore `users` collection untuk display

### 4.2 Initial User Setup
- **Temporary Registration Screen** di app (untuk create user sebelum admin web ready)
- Form sederhana: username, display name, password, pilih role
- Screen ini bisa di-hide/remove setelah admin web tersedia

### 4.3 Role-Based Permissions

**Employee Role:**
- Submit overtime request baru
- View list overtime mereka sendiri
- Edit overtime mereka (trigger re-approval jika sudah approved)
- View dashboard personal (hanya data mereka)

**Manager Role:**
- Semua yang bisa Employee (manager juga bisa submit overtime)
- View ALL overtime requests dari semua karyawan
- Approve/Reject overtime requests
- View dashboard lengkap (seluruh tim)
- Manage master data employees (CRUD)

**Note:** Struktur sederhana - 1 manager central yang handle semua approval.

---

## 5. UI Flow & Screen Structure

### 5.1 Screen Navigation Flow

**Authentication Screens:**
1. **Login Screen** - Username + password input
2. **Registration Screen** - Temporary untuk create account

**Employee Screens:**
1. **Home/List Screen** - List overtime mereka dengan filter status
2. **Create/Edit Form Screen** - Form lengkap dengan semua fields
3. **Detail Screen** - View detail dengan status approval
4. **Dashboard Screen** - Personal stats (jam lembur, earnings, status breakdown)
5. **Profile Screen** - Info user & logout

**Manager Screens (Additional):**
1. **All Requests Screen** - List semua overtime dengan filter (pending/approved/rejected)
2. **Approval Detail Screen** - Detail overtime + tombol Approve/Reject
3. **Enhanced Dashboard** - Stats seluruh tim
4. **Employee Management Screen** - CRUD master data employees

### 5.2 Navigation Structure

**Bottom Navigation Bar:**
- **Employee**: Home | Dashboard | Profile
- **Manager**: Requests (All) | Dashboard | Employees | Profile

### 5.3 Design Reference
Mengikuti design pattern yang clean dan modern:
- White cards dengan rounded corners
- Section headers dengan subtle dividers
- Blue primary button
- Status badges dengan color coding (Green: Approved, Orange: Pending, Red: Rejected)
- Clean spacing dan typography

---

## 6. Form UI Organization

### Overtime Form Structure (Scrollable Single Page)

**Section 1: Time & Duration**
- Date (date picker)
- Start time (time picker)
- End time (time picker)
- Calculated: Working time (auto-calculated, display only)

**Section 2: Customer & Problem**
- Customer (text input, required)
- Reported Problem / Summary (multiline text, required, min 10 char)

**Section 3: Involved People**
- Involved Engineers (multi-select chips dari master employees)
- Involved Maintenance Engineers (multi-select chips)
- Involved Postsales & Onsite Engineers (multi-select chips)

**Section 4: Work Details**
- Type of Work (multi-checkbox: Overtime, Call, Unplanned, NonOT, Visit Siang, required minimal 1)
- Product (text input)
- Severity (dropdown: Low, Medium, High, Critical dengan color coding)

**Section 5: Work Description & Follow-up**
- Working Description / Solution / Comment (multiline text, required, min 10 char)
- Next Possible Activity (text input)
- Version (text input)
- PIC (text input)
- Response Time (number input dalam menit)

**Section 6: Earnings Preview (Display Only)**
- Base earnings (auto-calculated)
- Meal allowance (auto-calculated)
- Total earnings (display only)

**Submit Button** di bottom dengan validation sebelum submit.

---

## 7. Approval Flow & Re-approval Logic

### 7.1 Basic Approval Process

**Employee Submits:**
1. Fill form → Submit
2. Status: `pending`
3. Manager dapat notification

**Manager Reviews:**
1. Open detail screen (status: Pending)
2. Review all information
3. Actions:
   - **Approve**: Status → `approved`, save `approvedBy`, `approvedAt`
   - **Reject**: Show dialog untuk input reason, Status → `rejected`, save `rejectionReason`
4. Employee dapat notification

### 7.2 Re-approval Flow (Edited Overtime)

**Scenario:** Karyawan edit overtime yang sudah approved

1. User tap "Edit" pada approved overtime
2. App tampilkan warning: "Editing akan reset status ke Pending dan memerlukan approval ulang"
3. User confirm dan edit data
4. Saat save:
   - Status: `approved` → `pending`
   - `isEdited` = true
   - Add entry ke `editHistory`: `{editedAt, editedBy, oldStatus: 'approved'}`
   - Clear `approvedBy` dan `approvedAt`
5. Manager dapat notifikasi: "Edited overtime needs re-approval"
6. Di detail screen, tampilkan badge "EDITED" dan history

### 7.3 Edit Restrictions

- **Pending overtime**: Edit freely tanpa re-approval
- **Approved/Rejected overtime**: Bisa edit tapi trigger re-approval flow
- User bisa cancel edit tanpa save

---

## 8. Notifications & Email Integration

### 8.1 Push Notifications (Firebase Cloud Messaging)

**Trigger Events:**

**Untuk Manager:**
- New overtime submitted → "New overtime request from [Name]"
- Overtime edited (needs re-approval) → "[Name] edited overtime - needs re-approval"

**Untuk Employee:**
- Overtime approved → "Your overtime on [Date] approved"
- Overtime rejected → "Your overtime on [Date] rejected. Reason: [reason]"

### 8.2 Email Notifications

**Implementation:**
- Firebase Cloud Functions listen to Firestore changes
- Detect status changes (`pending`, `approved`, `rejected`)
- Send email via service (SendGrid/Mailgun/Firebase Extensions)
- Email template sederhana dengan info overtime

**Email Recipients:**
- Derived dari username: `{username}@overtime.internal`
- Atau field email terpisah di user profile (future)

### 8.3 Notification Settings

Untuk fase awal: Notifications default ON untuk semua events.

---

## 9. Dashboard & Reporting

### 9.1 Employee Dashboard (Personal Stats)

**Metrics untuk Bulan Ini:**
- Total jam overtime (sum dari approved requests)
- Total earnings (calculated earnings + meal allowance)
- Jumlah overtime requests
- Status breakdown:
  - Approved (count + total earnings)
  - Pending (count)
  - Rejected (count)

**Visual Components:**
- Card-based layout dengan icons
- Simple chart untuk trend per minggu
- Color coding: Green (approved), Orange (pending), Red (rejected)

### 9.2 Manager Dashboard (Team Overview)

**Metrics untuk Bulan Ini:**
- Total jam overtime seluruh team
- Total earnings/payout team
- Total requests (breakdown by status)
- Pending requests count (dengan quick access button)

**Top Lists:**
- Top 5 engineers dengan jam overtime terbanyak (nama + hours)
- Breakdown by severity (High/Critical issues count)

**Quick Actions:**
- Button "View Pending Requests"
- Filter by date range (This Month, Last Month, Custom)

### 9.3 Data Aggregation

Query Firestore:
- Filter by date range (`startDateTime`)
- Filter by user (employee) atau all (manager)
- Filter by status
- Aggregate: SUM hours, SUM earnings, COUNT requests

---

## 10. Earning Calculation Logic

### 10.1 Hardcoded Constants (MVP)

```dart
// Base hourly rates
const double WEEKDAY_HOURLY_RATE = 50000;   // Rp per hour
const double WEEKEND_HOURLY_RATE = 75000;   // Rp per hour (1.5x weekday)
const double MEAL_ALLOWANCE = 25000;         // Rp per day

// Type of Work Multipliers
const Map<String, double> TYPE_MULTIPLIERS = {
  'Overtime': 1.0,      // Base rate
  'Call': 1.2,          // 20% extra
  'Unplanned': 1.5,     // 50% extra
  'NonOT': 0.5,         // Half rate
  'Visit Siang': 1.0,   // Base rate
};
```

**Note:** Constants ini akan di-migrate ke Firebase config saat admin web ready (configurable).

### 10.2 Calculation Steps

**Algorithm:**
1. Calculate `totalHours` = `finishDateTime - startDateTime` (in hours)
2. Determine `isWeekend` dari `startDateTime` (Saturday/Sunday)
3. Get `baseRate`:
   - Weekday: `WEEKDAY_HOURLY_RATE`
   - Weekend: `WEEKEND_HOURLY_RATE`
4. Get `highestMultiplier` dari selected `typeOfWork` array (ambil yang tertinggi)
5. Calculate `earnings` = `totalHours * baseRate * highestMultiplier`
6. Add `mealAllowance` = `MEAL_ALLOWANCE` (fixed per day)
7. `totalEarnings` = `earnings + mealAllowance`

**Timing:**
- Auto-calculate saat user input finish time
- Re-calculate saat edit
- Display breakdown di form (preview) dan detail screen

### 10.3 Display Format

**Di Form (Preview):**
- Base earnings: Rp XXX,XXX
- Meal allowance: Rp 25,000
- **Total: Rp XXX,XXX**

**Di Detail & Dashboard:**
- Show total earnings per request
- Aggregate untuk monthly total

---

## 11. Error Handling & Validation

### 11.1 Form Validation

**Required Fields:**
- Start/Finish DateTime (tidak boleh kosong)
- Customer (tidak boleh kosong)
- Reported Problem (minimum 10 karakter)
- Type of Work (minimal 1 dipilih)
- Working Description (minimum 10 karakter)

**Business Rules:**
- Finish DateTime harus > Start DateTime
- Total hours tidak boleh > 24 jam (warning jika anomali)
- Start time tidak boleh di masa depan
- Finish time tidak boleh > now (karena record lembur yang sudah dilakukan)

**Validation Timing:**
- Real-time validation saat user input
- Final validation saat tap Submit
- Show error messages di bawah field yang error

### 11.2 Error Handling

**Network Errors:**
- Show snackbar dengan retry option
- Optional: Offline mode (save draft locally, sync saat online)

**Firebase Errors:**
- Permission denied → Error message & logout
- Document not found → Error message & refresh
- Timeout → Show retry option

**General UX:**
- Loading indicators untuk semua async operations
- Success snackbar/dialog setelah submit/approve/reject
- Confirmation dialogs untuk destructive actions (reject, delete)

---

## 12. Testing Strategy

### 12.1 Unit Tests
- Test earning calculation logic (various scenarios)
- Test hours calculation
- Test model serialization (toJson/fromJson)
- Test form validators

### 12.2 Widget Tests
- Test form validation UI
- Test status badges display correctly
- Test navigation flows
- Test conditional UI (employee vs manager screens)

### 12.3 Integration Tests (Optional untuk MVP)
- Test complete flow: Login → Submit → Approve
- Test re-approval flow
- Test notifications delivery

---

## 13. Implementation Notes

### 13.1 Development Phases

**Phase 1: MVP (Minimum Viable Product)**
- Authentication (username/password)
- Overtime CRUD dengan full fields
- Approval/Reject flow
- Basic dashboard
- Earning calculation (hardcoded formula)
- Employee master data management

**Phase 2: Enhancements (Future)**
- Push notifications + email
- Admin web-based untuk user & formula management
- Configurable earning formula
- Advanced filtering & search
- Export to Excel/PDF
- Offline mode dengan sync

### 13.2 Dependencies

**Pubspec.yaml additions:**
```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.x.x

  # Firebase
  firebase_core: ^2.x.x
  firebase_auth: ^4.x.x
  cloud_firestore: ^4.x.x
  firebase_messaging: ^14.x.x (Phase 2)

  # UI
  intl: ^0.18.x (date formatting)

  # Utils
  uuid: ^4.x.x (generate IDs)
```

### 13.3 Firebase Setup Tasks

1. Create Firebase project
2. Enable Firebase Auth (Email/Password)
3. Create Firestore database dengan security rules
4. Setup Cloud Messaging (Phase 2)
5. Setup Cloud Functions untuk email (Phase 2)

### 13.4 Security Rules (Firestore)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isManager() {
      return isAuthenticated() &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'manager';
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated(); // Temporary for registration
      allow update, delete: if isManager();
    }

    // Employees collection
    match /employees/{employeeId} {
      allow read: if isAuthenticated();
      allow write: if isManager();
    }

    // Overtime requests collection
    match /overtime_requests/{requestId} {
      allow read: if isAuthenticated() &&
                    (isManager() || resource.data.submittedBy == request.auth.uid);
      allow create: if isAuthenticated();
      allow update: if isAuthenticated() &&
                      (isManager() || resource.data.submittedBy == request.auth.uid);
      allow delete: if isManager();
    }
  }
}
```

---

## 14. Success Criteria

Aplikasi dianggap berhasil jika:

1. **Functional:**
   - Employee bisa submit overtime dengan semua fields
   - Manager bisa approve/reject dengan notification
   - Re-approval mechanism bekerja saat edit
   - Earning calculation akurat
   - Dashboard menampilkan data real-time

2. **Performance:**
   - Form load < 2 detik
   - Dashboard query < 3 detik
   - Smooth scrolling untuk list dengan 100+ items

3. **Usability:**
   - Intuitive UI/UX mengikuti design reference
   - Clear error messages
   - Easy navigation antara screens

4. **Reliability:**
   - No data loss saat network error
   - Consistent data antara employee & manager views
   - Proper validation prevent bad data

---

## Revision History

| Date       | Version | Changes                          | Author |
|------------|---------|----------------------------------|--------|
| 2025-11-02 | 1.0     | Initial design document created  | Claude |

---

**End of Design Document**
