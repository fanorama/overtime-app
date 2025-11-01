import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee_model.dart';
import '../../domain/entities/employee_entity.dart';
import '../../../../core/constants/app_constants.dart';

/// Repository untuk mengelola data employee di Firestore
class EmployeeRepository {
  final FirebaseFirestore _firestore;

  EmployeeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get collection reference
  CollectionReference get _collection =>
      _firestore.collection(AppConstants.employeesCollection);

  /// Get all employees
  Stream<List<EmployeeEntity>> getAllEmployees() {
    return _collection
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EmployeeModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    });
  }

  /// Get employee by ID
  Future<EmployeeEntity?> getEmployeeById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        return EmployeeModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get employee: $e');
    }
  }

  /// Search employees by name
  Stream<List<EmployeeEntity>> searchEmployees(String query) {
    if (query.isEmpty) {
      return getAllEmployees();
    }

    // Firestore doesn't support full-text search, so we'll filter on client side
    return getAllEmployees().map((employees) {
      return employees
          .where((employee) =>
              employee.name.toLowerCase().contains(query.toLowerCase()) ||
              employee.employeeId.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  /// Add new employee
  Future<String> addEmployee(EmployeeEntity employee) async {
    try {
      // Check if employee ID already exists
      final existingQuery = await _collection
          .where('employeeId', isEqualTo: employee.employeeId)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        throw Exception('Employee ID already exists');
      }

      final model = EmployeeModel.fromEntity(employee);
      final docRef = await _collection.add(model.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add employee: $e');
    }
  }

  /// Update employee
  Future<void> updateEmployee(String id, EmployeeEntity employee) async {
    try {
      // Check if new employee ID conflicts with existing (excluding current)
      if (employee.id != id) {
        final existingQuery = await _collection
            .where('employeeId', isEqualTo: employee.employeeId)
            .get();

        if (existingQuery.docs.isNotEmpty &&
            existingQuery.docs.first.id != id) {
          throw Exception('Employee ID already exists');
        }
      }

      final model = EmployeeModel.fromEntity(employee);
      await _collection.doc(id).update(model.toFirestore());
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  /// Delete employee
  Future<void> deleteEmployee(String id) async {
    try {
      // TODO: Check if employee is referenced in any overtime requests
      // For now, just delete
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete employee: $e');
    }
  }

  /// Check if employee ID exists
  Future<bool> employeeIdExists(String employeeId, {String? excludeId}) async {
    try {
      final query =
          await _collection.where('employeeId', isEqualTo: employeeId).get();

      if (query.docs.isEmpty) return false;
      if (excludeId == null) return true;

      return query.docs.any((doc) => doc.id != excludeId);
    } catch (e) {
      throw Exception('Failed to check employee ID: $e');
    }
  }

  /// Get employees by IDs (untuk form selection)
  Future<List<EmployeeEntity>> getEmployeesByIds(List<String> ids) async {
    try {
      if (ids.isEmpty) return [];

      // Firestore has a limit of 10 items for 'in' queries
      // So we need to batch the requests
      const batchSize = 10;
      final List<EmployeeEntity> allEmployees = [];

      for (var i = 0; i < ids.length; i += batchSize) {
        final batch = ids.skip(i).take(batchSize).toList();
        final query = await _collection.where(FieldPath.documentId, whereIn: batch).get();

        final employees = query.docs
            .map((doc) => EmployeeModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList();

        allEmployees.addAll(employees);
      }

      return allEmployees;
    } catch (e) {
      throw Exception('Failed to get employees by IDs: $e');
    }
  }
}
