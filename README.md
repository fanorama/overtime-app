# ⏰ Overtime Management App

<div align="center">

![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)
![License](https://img.shields.io/badge/license-Private-red.svg)

**Sistem Manajemen Lembur Modern untuk Tim Technical Support & Field Service**

*Simplify overtime tracking • Automate earning calculations • Streamline approvals*

[Features](#-fitur-utama) • [Quick Start](#-quick-start) • [Architecture](#-arsitektur) • [Roadmap](#-roadmap--next-phase)

</div>

---

## 📖 Tentang Proyek

**Overtime Management App** adalah aplikasi Flutter cross-platform yang dirancang khusus untuk mengelola aktivitas lembur karyawan dengan sistem approval yang terstruktur. Aplikasi ini mengotomatisasi proses pencatatan overtime, perhitungan earning, dan workflow approval antara karyawan dan manager.

### 🎯 Problem yang Diselesaikan

- ❌ **Manual tracking** lembur via spreadsheet yang error-prone
- ❌ **Approval workflow** yang tidak terstruktur dan sulit ditrack
- ❌ **Perhitungan earning** yang memakan waktu dan rawan kesalahan
- ❌ **Tidak ada visibility** untuk employee tentang status approval
- ❌ **Sulit mengagregasi data** untuk reporting dan dashboard

### ✅ Solusi yang Ditawarkan

- ✅ **Digital form** dengan validasi otomatis dan field lengkap
- ✅ **Structured approval** workflow dengan notification real-time
- ✅ **Automatic calculation** untuk earning (weekday/weekend, multipliers, meal allowance)
- ✅ **Real-time dashboard** untuk employee dan manager
- ✅ **Firebase-powered** untuk sync otomatis dan offline support

---

## ✨ Fitur Utama

### 👤 Untuk Karyawan (Employee)

| Fitur | Deskripsi |
|-------|-----------|
| 📝 **Submit Overtime** | Form lengkap dengan 15+ fields: customer, problem, engineers involved, severity, work description, dll |
| 📊 **Personal Dashboard** | Tracking jam lembur, earnings bulan ini, status breakdown (pending/approved/rejected) |
| ✏️ **Edit & Re-approval** | Edit overtime yang sudah disubmit (trigger re-approval jika sudah approved) |
| 🔔 **Notifications** | Push notification saat overtime approved/rejected |
| 💰 **Earning Preview** | Lihat preview earnings otomatis sebelum submit (weekday/weekend rates, multipliers) |

### 👔 Untuk Manager

| Fitur | Deskripsi |
|-------|-----------|
| ✅ **Approve/Reject** | Review dan approve/reject overtime requests dengan reason |
| 📋 **All Requests View** | Lihat semua overtime requests dari seluruh team dengan filter status |
| 📈 **Team Dashboard** | Aggregate stats: total jam, total earnings, top performers, severity breakdown |
| 👥 **Employee Management** | CRUD master data employees (name, role, status) |
| 🔔 **Smart Notifications** | Notifikasi saat ada new submission atau edited overtime yang butuh re-approval |

### 🧮 Automatic Earning Calculation

```
Total Earnings = (Hours × Base Rate × Type Multiplier) + Meal Allowance

Base Rate:
- Weekday: Rp 50,000/jam
- Weekend: Rp 75,000/jam (1.5x)

Type Multipliers:
- Overtime: 1.0x
- Call: 1.2x (20% extra)
- Unplanned: 1.5x (50% extra)
- NonOT: 0.5x
- Visit Siang: 1.0x

Meal Allowance: Rp 25,000 per day
```

---

## 🛠️ Tech Stack

### Frontend
- **Flutter 3.9.2+** - Cross-platform UI framework
- **Dart SDK 3.9.2+** - Programming language
- **Riverpod 2.6+** - State management yang powerful dan type-safe
- **Freezed** - Immutable models dengan code generation
- **JSON Serializable** - Automatic JSON parsing

### Backend & Cloud
- **Firebase Authentication** - Username/password authentication
- **Cloud Firestore** - NoSQL database dengan real-time sync
- **Firebase Cloud Functions** *(Phase 2)* - Serverless backend untuk notifications
- **Firebase Cloud Messaging** *(Phase 2)* - Push notifications

### Development Tools
- **Flutter DevTools** - Debugging & profiling
- **Build Runner** - Code generation
- **Flutter Lints** - Static analysis untuk best practices

---

## 🏗️ Arsitektur

Aplikasi ini menggunakan **Clean Architecture Simplified** dengan 3 layer:

```
┌─────────────────────────────────────────┐
│     Presentation Layer                  │
│  (Screens, Widgets, Providers)          │
│         [Riverpod State]                │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│     Business Logic Layer                │
│  (Services, UseCases, Validators)       │
└────────────┬────────────────────────────┘
             │
┌────────────▼────────────────────────────┐
│     Data Layer                          │
│  (Repositories, Firebase Integration)   │
└─────────────────────────────────────────┘
```

### 📂 Project Structure

```
lib/
├── main.dart                    # Entry point & Firebase initialization
│
├── core/                        # Shared utilities & components
│   ├── constants/               # App constants (earning rates, validation rules)
│   ├── utils/                   # Helpers (date formatter, earnings calculator)
│   ├── widgets/                 # Reusable widgets (buttons, badges, cards)
│   ├── theme/                   # App theming & colors
│   ├── security/                # Input sanitizer, authorization
│   └── navigation/              # Navigation config
│
├── features/                    # Feature modules (by domain)
│   ├── auth/                    # Authentication & user management
│   │   ├── domain/entities/     # User entity
│   │   ├── data/models/         # User model dengan JSON serialization
│   │   ├── data/repositories/   # Auth repository (Firebase Auth)
│   │   ├── presentation/        # Login, Register screens
│   │   └── presentation/providers/  # Auth state management
│   │
│   ├── overtime/                # Core overtime management
│   │   ├── domain/entities/     # OvertimeRequest entity
│   │   ├── domain/usecases/     # Submit, Approve, Reject usecases
│   │   ├── data/models/         # OvertimeRequest model
│   │   ├── data/repositories/   # Firestore CRUD operations
│   │   ├── presentation/screens/    # List, Form, Detail screens
│   │   └── presentation/widgets/    # Form sections, status badges
│   │
│   ├── employee/                # Employee master data
│   │   ├── domain/entities/     # Employee entity
│   │   ├── data/repositories/   # Employee CRUD
│   │   └── presentation/        # Employee list & form (Manager only)
│   │
│   ├── dashboard/               # Analytics & reporting
│   │   ├── presentation/providers/  # Data aggregation logic
│   │   ├── presentation/screens/    # Employee & Manager dashboards
│   │   └── presentation/widgets/    # Metric cards, charts, breakdowns
│   │
│   └── profile/                 # User profile & settings
│       └── presentation/screens/    # Profile screen dengan logout
│
└── firebase_options.dart        # Firebase configuration (auto-generated)
```

### 🔥 Firebase Collections Schema

#### `users/{userId}`
```json
{
  "username": "john_doe",
  "displayName": "John Doe",
  "role": "employee",  // "employee" | "manager"
  "createdAt": "2025-11-04T10:00:00Z"
}
```

#### `employees/{employeeId}`
```json
{
  "name": "Jane Smith",
  "role": "engineer",  // "engineer" | "maintenance" | "postsales" | "onsite"
  "isActive": true,
  "createdAt": "2025-11-04T10:00:00Z"
}
```

#### `overtime_requests/{requestId}`
```json
{
  "submittedBy": "userId",
  "submittedByName": "John Doe",
  "status": "pending",  // "pending" | "approved" | "rejected"
  "startDateTime": "2025-11-04T18:00:00Z",
  "finishDateTime": "2025-11-04T22:00:00Z",
  "totalHours": 4,
  "isWeekend": false,
  "customer": "PT ABC Indonesia",
  "reportedProblem": "Server down, urgent fix needed",
  "involvedEngineers": ["emp1", "emp2"],
  "involvedMaintenance": ["emp3"],
  "involvedPostsales": [],
  "typeOfWork": ["Overtime", "Unplanned"],
  "product": "Server Infrastructure",
  "severity": "high",
  "workingDescription": "Fixed server crash, restored services",
  "nextPossibleActivity": "Monitor server health",
  "version": "v2.1.0",
  "pic": "John Doe",
  "responseTime": 45,
  "calculatedEarnings": 300000,
  "mealAllowance": 25000,
  "totalEarnings": 325000,
  "approvedBy": null,
  "approvedAt": null,
  "rejectionReason": null,
  "isEdited": false,
  "editHistory": [],
  "createdAt": "2025-11-04T22:30:00Z",
  "updatedAt": "2025-11-04T22:30:00Z"
}
```

📚 **Detail lengkap**: Lihat [Design Document](docs/plans/2025-11-02-overtime-app-design.md)

---

## 🚀 Quick Start

### Prerequisites

Pastikan sudah terinstall:
- Flutter SDK 3.9.2 atau lebih tinggi
- Dart SDK 3.9.2 atau lebih tinggi
- Android Studio / Xcode (untuk emulator)
- Git

### 1. Clone Repository

```bash
git clone <repository-url>
cd overtime_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

1. **Setup Firebase project** di [Firebase Console](https://console.firebase.google.com/)
2. **Enable Authentication** (Email/Password method)
3. **Create Firestore database** (Test mode untuk development)
4. **Download configuration files**:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
5. **Generate Firebase options**:
   ```bash
   flutterfire configure
   ```

### 4. Deploy Firestore Indexes

```bash
firebase deploy --only firestore:indexes
```

### 5. Setup Firestore Security Rules

Copy security rules dari [Design Document](docs/plans/2025-11-02-overtime-app-design.md#134-security-rules-firestore) ke Firebase Console → Firestore → Rules.

### 6. Run the App

```bash
# Lihat available devices
flutter devices

# Run di device/emulator
flutter run

# Run dengan hot reload
flutter run --hot

# Run di chrome (web)
flutter run -d chrome
```

### 7. First Login

**Development Quick Login** (tersedia di login screen):
- **Employee**: Klik tombol "Login sebagai Employee"
- **Manager**: Klik tombol "Login sebagai Manager"

Atau register akun baru via Registration Screen.

---

## 📱 Development

### Common Commands

```bash
# Install/update dependencies
flutter pub get
flutter pub upgrade

# Run app
flutter run                      # Debug mode (default)
flutter run --release           # Release mode (optimized)
flutter run --profile           # Profile mode (performance testing)

# Code generation (models, providers)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode untuk code generation
flutter pub run build_runner watch

# Run tests
flutter test                    # All tests
flutter test --coverage         # With coverage report

# Code analysis
flutter analyze                 # Static analysis
dart fix --apply                # Auto-fix issues
dart format .                   # Format code

# Clean build
flutter clean
flutter pub get
```

### Development Workflow

1. **Buat branch baru** untuk setiap feature
   ```bash
   git checkout -b feature/nama-feature
   ```

2. **Jalankan code generation** jika modify models
   ```bash
   flutter pub run build_runner watch
   ```

3. **Run analyzer** sebelum commit
   ```bash
   flutter analyze
   ```

4. **Run tests** untuk pastikan tidak ada breaking changes
   ```bash
   flutter test
   ```

5. **Format code** sebelum commit
   ```bash
   dart format .
   ```

### Debugging Tips

```bash
# Flutter DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Debug specific issues
flutter run --verbose           # Detailed logs
flutter logs                    # View logs dari running app
flutter doctor -v               # Diagnostic report
```

---

## 🔐 Firebase Setup Details

### Firestore Indexes

Aplikasi membutuhkan composite indexes untuk query yang efficient. File `firestore.indexes.json` sudah tersedia dengan 4 indexes:

1. **submittedBy + status + createdAt** - Employee overtime list dengan filter status
2. **submittedBy + startTime** - Query by date range untuk specific user
3. **status + createdAt** - Manager view all requests dengan filter status
4. **submittedBy + createdAt** - Base query untuk user's overtimes

**Deploy command:**
```bash
firebase deploy --only firestore:indexes
```

**Monitor deployment:** [Firebase Console Indexes](https://console.firebase.google.com/project/overtime-itpro/firestore/indexes)

📖 **Detail index mapping**: Lihat `firestore.indexes.md`

### Security Rules

Firestore security rules enforce:
- ✅ **Authentication required** untuk semua operations
- ✅ **Role-based access**: Manager bisa CRUD semua data, Employee hanya data mereka
- ✅ **Prevent tampering**: `createdAt`, `submittedBy` tidak bisa diubah
- ✅ **Manager-only operations**: Approve/reject, employee management

---

## 🧪 Testing

### Test Structure

```
test/
├── unit/                       # Unit tests (utilities, calculators, validators)
├── widget/                     # Widget tests (UI components)
└── integration/                # Integration tests (full user flows)
```

### Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/unit/earnings_calculator_test.dart

# With coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Watch mode (re-run on changes)
flutter test --watch
```

### Test Coverage Goals

- **Unit Tests**: ≥ 80% coverage untuk business logic
- **Widget Tests**: Semua core widgets dan screens
- **Integration Tests**: Critical user flows (submit → approve → dashboard)

---

## 📝 Development Guidelines

### Coding Standards

#### 1. **Code Organization**
- ✅ Group imports: Dart SDK → Flutter → Packages → Relative
- ✅ One widget/class per file (kecuali helper classes kecil)
- ✅ File naming: `snake_case.dart`
- ✅ Class naming: `PascalCase`

#### 2. **State Management**
- ✅ Use Riverpod untuk state management
- ✅ Separate business logic dari UI
- ✅ Use `AsyncValue` untuk handle loading/error states
- ✅ Dispose controllers properly

#### 3. **Error Handling**
- ✅ Always handle errors di async operations
- ✅ Show user-friendly error messages
- ✅ Log errors untuk debugging (`app_logger.dart`)
- ✅ Implement retry mechanism untuk network errors

#### 4. **Performance**
- ✅ Use `const` constructors whenever possible
- ✅ Optimize Firestore queries (use indexes)
- ✅ Lazy load data (pagination untuk large lists)
- ✅ Profile performance dengan Flutter DevTools

#### 5. **Security**
- ✅ Sanitize user inputs (`input_sanitizer.dart`)
- ✅ Validate data di client & server (Firestore rules)
- ✅ Never expose sensitive data di logs
- ✅ Use secure storage untuk tokens

### Git Workflow

```bash
# Branch naming
feature/nama-feature           # New feature
bugfix/issue-description       # Bug fix
hotfix/critical-issue         # Critical production fix

# Commit messages (Conventional Commits)
feat: add overtime edit functionality
fix: resolve earning calculation rounding error
docs: update README with Firebase setup
refactor: simplify approval flow logic
test: add unit tests for earnings calculator
chore: update dependencies
```

### Before Committing

**Checklist:**
- [ ] Code formatted (`dart format .`)
- [ ] No analyzer warnings (`flutter analyze`)
- [ ] Tests passing (`flutter test`)
- [ ] Remove debugging code (print statements, dev buttons)
- [ ] Update documentation if needed

---

## 🗺️ Roadmap & Next Phase

### ✅ Phase 1: MVP (Current - v0.1.0)

- [x] Authentication system (username/password)
- [x] Overtime CRUD dengan full fields (15+ fields)
- [x] Approval/Reject workflow dengan status tracking
- [x] Re-approval mechanism untuk edited overtimes
- [x] Automatic earning calculation (hardcoded formulas)
- [x] Employee & Manager dashboards
- [x] Employee master data management
- [x] Role-based access control
- [x] Firestore security rules
- [x] Clean Architecture implementation

### 🚧 Phase 2: Enhancements (Planned)

#### 🔔 Notifications & Communication
- [ ] **Push Notifications** (Firebase Cloud Messaging)
  - New overtime submission → notify manager
  - Approval/rejection → notify employee
  - Edited overtime → notify manager
- [ ] **Email Notifications** (Cloud Functions + SendGrid/Mailgun)
  - Same triggers as push notifications
  - HTML email templates
  - Email preferences per user

#### 🖥️ Admin & Configuration
- [ ] **Web-based Admin Panel**
  - User management (CRUD employees & managers)
  - Role assignment
  - Bulk user import (CSV)
- [ ] **Configurable Earning Formula**
  - Dynamic rates storage di Firestore
  - Admin UI untuk edit rates tanpa redeploy
  - History tracking untuk rate changes
  - Support untuk custom formulas per department

#### 🔍 Search & Filtering
- [ ] **Advanced Search**
  - Full-text search di overtime descriptions
  - Multi-field filtering (date range, customer, severity, status)
  - Saved search filters
  - Search suggestions
- [ ] **Smart Filters**
  - Filter by employee/team
  - Filter by earnings range
  - Filter by response time
  - Custom filter combinations

#### 📊 Reporting & Export
- [ ] **Excel Export**
  - Export overtime list to XLSX
  - Custom columns selection
  - Formatted tables dengan formulas
- [ ] **PDF Reports**
  - Monthly summary reports
  - Individual overtime detail PDF
  - Manager approval reports
- [ ] **Advanced Analytics**
  - Trend analysis (overtime patterns over time)
  - Team performance metrics
  - Customer incident analysis
  - Response time analytics

#### 💾 Offline Support
- [ ] **Offline Mode**
  - Local database cache (Hive/Isar)
  - Submit overtime saat offline
  - Auto-sync saat online
  - Conflict resolution untuk edits
- [ ] **Draft Management**
  - Save form drafts locally
  - Resume incomplete submissions
  - Draft expiration policy

#### 🎨 UI/UX Improvements
- [ ] **Dark Mode** support
- [ ] **Multi-language** (EN/ID toggle)
- [ ] **Accessibility** improvements (screen reader, font scaling)
- [ ] **Custom themes** per organization
- [ ] **Onboarding tutorial** untuk new users

#### 🔧 Technical Improvements
- [ ] **Performance Optimization**
  - Implement pagination untuk large lists
  - Image caching strategy
  - Memory leak detection & fixes
- [ ] **Testing Coverage**
  - Increase unit test coverage to 90%+
  - Add comprehensive integration tests
  - E2E testing dengan Patrol/Integration Test
- [ ] **CI/CD Pipeline**
  - Automated testing di GitHub Actions
  - Automated builds untuk Android/iOS
  - Automated deployment ke Firebase App Distribution

### 🔮 Phase 3: Advanced Features (Future)

- [ ] **Multi-Manager Approval** (approval hierarchy)
- [ ] **Approval Templates** (pre-defined approval rules)
- [ ] **Integration dengan HR Systems** (payroll integration)
- [ ] **Mobile App untuk iOS** (currently Android-focused)
- [ ] **Desktop App** (Windows/macOS/Linux)
- [ ] **API Gateway** untuk third-party integrations
- [ ] **Webhook Support** untuk external notifications
- [ ] **AI-powered Insights** (overtime prediction, anomaly detection)

---

## 🤝 Contributing

### How to Contribute

1. **Fork** repository ini
2. **Create feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit changes** (`git commit -m 'feat: add amazing feature'`)
4. **Push to branch** (`git push origin feature/AmazingFeature`)
5. **Open Pull Request**

### Pull Request Guidelines

- ✅ Follow coding standards & guidelines di atas
- ✅ Add tests untuk new features
- ✅ Update documentation (README, comments)
- ✅ Pastikan semua tests passing
- ✅ No merge conflicts dengan `main` branch
- ✅ PR description jelas (what, why, how)

### Code Review Process

1. **Automated checks** (linter, tests) harus passing
2. **Peer review** dari minimal 1 developer
3. **Manager review** untuk breaking changes
4. **Merge** setelah approved

---

## 🐛 Troubleshooting

### Common Issues

#### Firebase Connection Error
```bash
# Solution: Re-configure Firebase
flutterfire configure
flutter clean
flutter pub get
```

#### Build Runner Conflicts
```bash
# Solution: Delete conflicting outputs
flutter pub run build_runner build --delete-conflicting-outputs
```

#### Index Missing Error (Firestore)
```bash
# Solution: Deploy indexes
firebase deploy --only firestore:indexes
# Wait 2-10 minutes untuk index build
```

#### Gradle Build Failed (Android)
```bash
# Solution: Clean & rebuild
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

## 📄 License

This project is **private** and proprietary. All rights reserved.

---

## 📞 Contact & Support

**Project Maintainer:** Development Team
**Firebase Project:** [overtime-itpro](https://console.firebase.google.com/project/overtime-itpro)

### Documentation Links

- 📖 [Design Document](docs/plans/2025-11-02-overtime-app-design.md) - Complete architecture & specifications
- 🔥 [Firestore Indexes](firestore.indexes.md) - Index mapping & usage patterns
- 📋 [CLAUDE.md](CLAUDE.md) - AI assistant guidelines

### Support Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev/)

---

<div align="center">

**Built with ❤️ using Flutter & Firebase**

⭐ Star this repo if you find it helpful!

</div>
