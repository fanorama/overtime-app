import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/employee/data/models/employee_model.dart';
import '../../features/employee/domain/entities/employee_entity.dart';
import '../constants/app_constants.dart';
import 'app_logger.dart';

/// Utility untuk seed dummy data ke Firestore
class SeedData {
  final FirebaseFirestore _firestore;

  SeedData({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Seed 7 dummy employees with correct role positions
  Future<void> seedEmployees() async {
    final employees = [
      // Engineers
      EmployeeEntity(
        id: '', // Will be auto-generated
        employeeId: 'EMP001',
        name: 'Ahmad Fauzi',
        position: AppConstants.employeeRoleEngineer,
        department: 'Technical Support',
        baseRate: AppConstants.baseWeekdayRate,
        weekendRate: AppConstants.baseWeekendRate,
        phoneNumber: '081234567890',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      EmployeeEntity(
        id: '',
        employeeId: 'EMP002',
        name: 'Siti Nurhaliza',
        position: AppConstants.employeeRoleEngineer,
        department: 'Technical Support',
        baseRate: AppConstants.baseWeekdayRate,
        weekendRate: AppConstants.baseWeekendRate,
        phoneNumber: '081234567891',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      // Maintenance
      EmployeeEntity(
        id: '',
        employeeId: 'EMP003',
        name: 'Budi Santoso',
        position: AppConstants.employeeRoleMaintenance,
        department: 'IT Infrastructure',
        baseRate: AppConstants.baseWeekdayRate,
        weekendRate: AppConstants.baseWeekendRate,
        phoneNumber: '081234567892',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      EmployeeEntity(
        id: '',
        employeeId: 'EMP006',
        name: 'Andi Wijaya',
        position: AppConstants.employeeRoleMaintenance,
        department: 'IT Infrastructure',
        baseRate: AppConstants.baseWeekdayRate,
        weekendRate: AppConstants.baseWeekendRate,
        phoneNumber: '081234567895',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      // Postsales
      EmployeeEntity(
        id: '',
        employeeId: 'EMP004',
        name: 'Dewi Lestari',
        position: AppConstants.employeeRolePostsales,
        department: 'Customer Success',
        baseRate: AppConstants.baseWeekdayRate,
        weekendRate: AppConstants.baseWeekendRate,
        phoneNumber: '081234567893',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      // Onsite
      EmployeeEntity(
        id: '',
        employeeId: 'EMP005',
        name: 'Rudi Hartono',
        position: AppConstants.employeeRoleOnsite,
        department: 'Field Operations',
        baseRate: AppConstants.baseWeekdayRate,
        weekendRate: AppConstants.baseWeekendRate,
        phoneNumber: '081234567894',
        isActive: true,
        createdAt: DateTime.now(),
      ),
      EmployeeEntity(
        id: '',
        employeeId: 'EMP007',
        name: 'Maya Sari',
        position: AppConstants.employeeRoleOnsite,
        department: 'Field Operations',
        baseRate: AppConstants.baseWeekdayRate,
        weekendRate: AppConstants.baseWeekendRate,
        phoneNumber: '081234567896',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    final collection = _firestore.collection(AppConstants.employeesCollection);

    int added = 0;
    int skipped = 0;

    for (final employee in employees) {
      // Check if employee ID already exists
      final existing = await collection
          .where('employeeId', isEqualTo: employee.employeeId)
          .get();

      if (existing.docs.isEmpty) {
        // Add employee
        final model = EmployeeModel.fromEntity(employee);
        await collection.add(model.toFirestore());
        added++;
        appLogger.i('✅ Added: ${employee.name} (${employee.employeeId})');
      } else {
        skipped++;
        appLogger.i('⏭️  Skipped: ${employee.name} (${employee.employeeId}) - already exists');
      }
    }

    appLogger.i('\n📊 Summary:');
    appLogger.i('   Added: $added employees');
    appLogger.i('   Skipped: $skipped employees');
    appLogger.i('   Total: ${employees.length} employees processed');
  }

  /// Clear all employees (untuk testing)
  Future<void> clearEmployees() async {
    final collection = _firestore.collection(AppConstants.employeesCollection);
    final snapshot = await collection.get();

    int deleted = 0;
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
      deleted++;
    }

    appLogger.i('🗑️  Deleted $deleted employees');
  }
}
