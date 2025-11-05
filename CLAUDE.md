# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Flutter cross-platform application** for managing overtime requests in a technical support/field service organization. The app handles overtime submission, approval workflows, and automatic earnings calculations with role-based access control (Employee/Manager).

**Tech Stack:**
- Flutter 3.9.2+ with Dart SDK 3.9.2+
- Riverpod 2.6+ for state management (with code generation)
- Firebase (Authentication, Cloud Firestore)
- Freezed for immutable models
- JSON Serializable for model serialization

## Essential Commands

### Development Workflow
```bash
# Install/update dependencies
flutter pub get

# Code generation (after modifying models/providers)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file changes)
flutter pub run build_runner watch

# Run app
flutter run                    # Debug mode with hot reload
flutter run --release          # Release/production build
flutter run -d chrome          # Run in web browser

# Testing
flutter test                   # Run all tests
flutter test test/unit/earnings_calculator_test.dart  # Single test file

# Code quality
flutter analyze                # Static analysis
dart format .                  # Format all Dart files
dart fix --apply               # Auto-fix linter issues

# Clean build (when encountering build issues)
flutter clean && flutter pub get
```

### Firebase Operations
```bash
# Deploy Firestore indexes (required after modifying firestore.indexes.json)
firebase deploy --only firestore:indexes

# Deploy security rules
firebase deploy --only firestore:rules

# Note: Indexes can take 2-10 minutes to build after deployment
```

### Running a Single Test
```bash
# Run specific test file
flutter test test/unit/earnings_calculator_test.dart

# Run tests with coverage
flutter test --coverage
```

## Architecture

The app follows **Clean Architecture Simplified** with 3 distinct layers:

### 1. Presentation Layer (`lib/features/*/presentation/`)
- **Screens**: Full-page UI components
- **Widgets**: Reusable UI components
- **Providers**: Riverpod state management
  - Generated with `@riverpod` annotation
  - Use `AsyncValue<T>` for loading/error/data states
  - Controllers manage business logic

### 2. Business Logic Layer (`lib/features/*/domain/`)
- **Entities**: Core business objects (immutable with Freezed)
- **UseCases**: Single-responsibility business operations
  - `SubmitOvertimeUseCase`: Validate and submit overtime
  - `ApproveOvertimeUseCase`: Manager approval logic
  - `RejectOvertimeUseCase`: Manager rejection logic

### 3. Data Layer (`lib/features/*/data/`)
- **Models**: Serializable data objects (extend entities)
  - Use Freezed + JSON Serializable
  - Include `fromJson`/`toJson` factories
- **Repositories**: Data access and Firestore CRUD operations
  - Handle error conversion to `AppException`
  - Implement retry logic for transient failures

### Feature Modules

Each feature is self-contained in `lib/features/`:
- **auth**: Authentication (login, register, session management)
- **overtime**: Core overtime CRUD, approval workflow
- **employee**: Employee master data management (manager-only)
- **dashboard**: Analytics and reporting (role-specific views)
- **profile**: User profile and settings

### Core Shared Code (`lib/core/`)

- **constants/**: App-wide constants (rates, multipliers, validation rules)
- **utils/**: Helpers (earnings calculator, date formatters, logger)
- **widgets/**: Reusable UI components (buttons, badges, dialogs)
- **security/**: Input sanitization, authorization checks
- **validators/**: Form validation logic
- **exceptions/**: Custom exception types
- **navigation/**: App navigation and routing

## Critical Implementation Details

### Firestore Collections

1. **`users/{userId}`**: User authentication data
   - Fields: `username`, `displayName`, `role`, `createdAt`
   - Roles: `"employee"` or `"manager"`

2. **`employees/{employeeId}`**: Master employee data
   - Fields: `name`, `role`, `isActive`, `createdAt`
   - Roles: `"engineer"`, `"maintenance"`, `"postsales"`, `"onsite"`

3. **`overtime_requests/{requestId}`**: Overtime submissions
   - 20+ fields including customer, problem, engineers, work type, earnings
   - Status: `"pending"`, `"approved"`, `"rejected"` (lowercase only)
   - Auto-calculated fields: `totalHours`, `isWeekend`, `calculatedEarnings`

### Firestore Indexes

The app requires 4 composite indexes for efficient queries (defined in `firestore.indexes.json`):
1. `submittedBy + status + createdAt DESC` - Employee filtered overtime list
2. `submittedBy + startTime ASC` - Date range queries per user
3. `status + createdAt DESC` - Manager view with status filter
4. `submittedBy + createdAt DESC` - Base user overtime query

**Important**: After modifying indexes, deploy with `firebase deploy --only firestore:indexes` and wait for index build completion.

### Earnings Calculation

Automatic earnings are calculated using `EarningsCalculator` utility:

```
Formula: hours × base_rate × max(work_type_multipliers) + meal_allowance

Base Rates:
- Weekday: Rp 50,000/hour
- Weekend: Rp 75,000/hour (1.5x weekday)

Work Type Multipliers:
- Overtime: 1.0x
- Call: 1.2x
- Unplanned: 1.5x
- NonOT: 0.5x
- Visit Siang: 1.0x

Meal Allowance: Rp 25,000 per employee
```

**Critical**: All calculations use `_roundTo2Decimals()` to avoid floating-point precision errors in Firestore validation.

### Security & Validation

1. **Firestore Security Rules**: Enforce role-based access
   - Managers: Full CRUD on all collections
   - Employees: Read/write only their own overtime requests
   - Protected fields: `createdAt`, `submittedBy` (immutable after creation)

2. **Input Sanitization**: Always use `InputSanitizer.sanitize()` for user inputs
   - Prevents XSS, SQL injection patterns
   - Trims whitespace, removes dangerous characters

3. **Authorization Checks**: Use `AuthorizationHelper.checkManagerRole()` before manager operations

### Re-approval Mechanism

When an approved overtime is edited:
1. Status automatically reverts to `"pending"`
2. `isEdited` flag set to `true`
3. Original approval metadata cleared (`approvedBy`, `approvedAt`)
4. Edit details logged in `editHistory` array

### Code Generation

After modifying files with these annotations, run `flutter pub run build_runner build --delete-conflicting-outputs`:
- `@freezed`: Entity/model classes (generates `.freezed.dart`)
- `@JsonSerializable`: JSON serialization (generates `.g.dart`)
- `@riverpod`: Providers (generates `.g.dart`)

Always commit the generated files (`.freezed.dart`, `.g.dart`) to version control.

## Common Patterns

### Creating a New Feature

1. Create feature directory: `lib/features/new_feature/`
2. Add subdirectories: `domain/`, `data/`, `presentation/`
3. Define entity in `domain/entities/` with `@freezed`
4. Create model in `data/models/` extending entity (add `@JsonSerializable`)
5. Implement repository in `data/repositories/`
6. Create providers in `presentation/providers/` with `@riverpod`
7. Build UI in `presentation/screens/` and `presentation/widgets/`
8. Run code generation

### Adding a New Firestore Field

1. Update entity in `domain/entities/`
2. Update model in `data/models/` (add field to `fromJson`/`toJson`)
3. Run `flutter pub run build_runner build --delete-conflicting-outputs`
4. Update repository methods
5. Update Firestore security rules if needed
6. Update UI to display/edit new field

### Creating a Provider

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_provider.g.dart';

@riverpod
class MyController extends _$MyController {
  @override
  FutureOr<MyState> build() async {
    // Initialize state
    return MyState();
  }

  Future<void> myMethod() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Business logic
      return newState;
    });
  }
}
```

### Error Handling Pattern

```dart
try {
  // Risky operation
} on FirebaseException catch (e) {
  throw AppException(
    code: 'firebase_error',
    message: 'Failed to perform operation: ${e.message}',
    originalException: e,
  );
} catch (e) {
  throw AppException(
    code: 'unknown_error',
    message: 'An unexpected error occurred',
    originalException: e,
  );
}
```

## Development Constraints

1. **Firebase Project**: `overtime-itpro` (hardcoded in `firebase.json`)
2. **Minimum Flutter**: 3.9.2+ required
3. **No Backend Code**: All business logic in Flutter app; Firestore security rules enforce server-side validation
4. **Phase 1 Limitations** (current):
   - No push notifications (planned for Phase 2)
   - No Excel/PDF export (planned for Phase 2)
   - No offline mode beyond Firestore cache
   - Hardcoded earning rates (not configurable via admin panel)

## Debugging Tips

### Common Issues

**Firestore Query Fails with Index Error**
- Check console for Firebase-provided index creation link
- Or deploy indexes: `firebase deploy --only firestore:indexes`
- Wait 2-10 minutes for index build

**Build Runner Conflicts**
- Use `--delete-conflicting-outputs` flag
- If persistent: Delete generated files manually, then regenerate

**State Not Updating**
- Verify `state = ...` assignment in Riverpod controller
- Check `AsyncValue` error state for exceptions
- Add debug logging with `AppLogger.debug()`

**Earnings Mismatch**
- Check `EarningsCalculator._roundTo2Decimals()` usage
- Verify work type multipliers in `AppConstants`
- Confirm weekend detection logic in `DateTimeUtils.isWeekend()`

### Debug Logging

Use `AppLogger` for consistent logging:
```dart
import 'package:overtime_app/core/utils/app_logger.dart';

AppLogger.debug('Debug message');
AppLogger.info('Info message');
AppLogger.warning('Warning message');
AppLogger.error('Error message', error, stackTrace);
```

## Testing Strategy

- **Unit Tests**: Focus on business logic (UseCases, calculators, validators)
- **Widget Tests**: Test UI components in isolation
- **Integration Tests**: Test full user flows (submit → approve → dashboard)

Current test coverage focuses on earnings calculator and core utilities. Expand as needed.

## Important Files

- `lib/core/constants/app_constants.dart` - All rates, multipliers, validation rules
- `lib/core/utils/earnings_calculator.dart` - Earnings calculation logic (critical)
- `lib/main.dart` - App entry point, Firebase initialization
- `firestore.indexes.json` - Firestore composite indexes (deploy after changes)
- `firestore.rules` - Security rules (reference in Firebase Console)
- `README.md` - Comprehensive project documentation
- `docs/plans/2025-11-02-overtime-app-design.md` - Full design specification

## Roadmap Context

**Current Phase**: MVP v0.1.0 (Feature-complete)
**Next Phase**: Notifications, configurable rates, admin panel, Excel export, advanced filtering

When implementing new features, maintain consistency with existing patterns and ensure backward compatibility with Phase 1 data structures.
