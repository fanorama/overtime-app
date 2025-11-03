# Firestore Indexes Documentation

Documentation untuk composite indexes yang digunakan di Overtime App.

## Index Mapping

### Index 1: submittedBy + status + createdAt (DESC)
**File:** `firestore.indexes.json` lines 3-20
**Used by:** `getRequestsByUserAndStatus()` method
**Query Pattern:**
```dart
.where('submittedBy', isEqualTo: userId)
.where('status', isEqualTo: status)
.orderBy('createdAt', descending: true)
```
**Use Case:** Manager/Employee filter overtime by user + specific status (pending/approved/rejected)

---

### Index 2: submittedBy + startTime (ASC)
**File:** `firestore.indexes.json` lines 21-34
**Used by:** `getRequestsByDateRange()` method with userId
**Query Pattern:**
```dart
.where('submittedBy', isEqualTo: userId)
.where('startTime', isGreaterThanOrEqualTo: startDate)
.where('startTime', isLessThanOrEqualTo: endDate)
.orderBy('startTime', descending: true)
```
**Use Case:** Employee/Manager dashboard - date range filtering per user

---

### Index 3: status + createdAt (DESC)
**File:** `firestore.indexes.json` lines 35-48
**Used by:** `getRequestsByStatus()` method
**Query Pattern:**
```dart
.where('status', isEqualTo: status)
.orderBy('createdAt', descending: true)
```
**Use Case:** Manager view all requests by status (e.g., all pending requests)

---

### Index 4: startTime (ASC)
**File:** `firestore.indexes.json` lines 49-58
**Used by:** `getRequestsByDateRange()` method without userId
**Query Pattern:**
```dart
.where('startTime', isGreaterThanOrEqualTo: startDate)
.where('startTime', isLessThanOrEqualTo: endDate)
.orderBy('startTime', descending: true)
```
**Use Case:** Manager dashboard - view all overtime in date range (entire team)

---

### Index 5: submittedBy + createdAt (DESC)
**File:** `firestore.indexes.json` lines 59-72
**Used by:** `getRequestsByUser()` method
**Query Pattern:**
```dart
.where('submittedBy', isEqualTo: userId)
.orderBy('createdAt', descending: true)
```
**Use Case:** **PRIMARY USE CASE** - Employee home screen showing their overtime list
**Notes:**
- Most frequently used query in the app (every time employee opens home screen)
- Could theoretically be covered by Index 1 (superset), but standalone index provides better performance for this common query
- Trade-off: Slightly more storage for significantly better read performance on main employee screen

---

## Index Optimization Notes

### Current Strategy: Hybrid (Standalone + Superset)
We maintain both standalone index (#5) and superset index (#1) because:

1. **Performance**: Standalone index is more efficient for simple queries
2. **Usage Pattern**: Employee screens frequently query without status filter
3. **Storage Cost**: Minimal overhead (~10% increase) for significant performance gain
4. **Firestore Behavior**: While Firestore can use superset indexes for subset queries, dedicated indexes perform better

### Alternative Considered: Remove Index #5
**Pros:**
- Slightly less storage usage
- Faster writes (one less index to maintain)

**Cons:**
- Potential performance degradation on most common query
- Employee home screen could be slower
- Not justified for minimal storage savings

### Future Optimization
Monitor index usage via Firebase Console and adjust if usage patterns change.

---

## Deployment Instructions

After modifying `firestore.indexes.json`:

```bash
# Deploy indexes to Firebase
firebase deploy --only firestore:indexes

# Monitor build status in Firebase Console
# https://console.firebase.google.com/project/overtime-itpro/firestore/indexes
```

**Build time:** Typically 2-10 minutes depending on collection size.

---

## Related Files
- **Index Configuration:** `firestore.indexes.json`
- **Query Implementation:** `lib/features/overtime/data/repositories/overtime_repository.dart`
- **Design Document:** `docs/plans/2025-11-02-overtime-app-design.md`

---

**Last Updated:** 2025-11-03
**Status:** All indexes deployed and active
