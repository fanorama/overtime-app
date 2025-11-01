import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/employee_repository.dart';
import '../../domain/entities/employee_entity.dart';

/// Provider untuk EmployeeRepository
final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository();
});

/// Provider untuk stream semua employees
final employeesStreamProvider = StreamProvider<List<EmployeeEntity>>((ref) {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getAllEmployees();
});

/// Provider untuk search employees
final employeeSearchProvider =
    StreamProvider.family<List<EmployeeEntity>, String>((ref, query) {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.searchEmployees(query);
});

/// Controller untuk employee operations
final employeeControllerProvider =
    StateNotifierProvider<EmployeeController, AsyncValue<void>>((ref) {
  return EmployeeController(
    repository: ref.watch(employeeRepositoryProvider),
  );
});

/// Controller class untuk handle employee CRUD operations
class EmployeeController extends StateNotifier<AsyncValue<void>> {
  final EmployeeRepository repository;

  EmployeeController({required this.repository})
      : super(const AsyncValue.data(null));

  /// Add new employee
  Future<String?> addEmployee(EmployeeEntity employee) async {
    state = const AsyncValue.loading();
    try {
      final id = await repository.addEmployee(employee);
      state = const AsyncValue.data(null);
      return id;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Update employee
  Future<bool> updateEmployee(String id, EmployeeEntity employee) async {
    state = const AsyncValue.loading();
    try {
      await repository.updateEmployee(id, employee);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Delete employee
  Future<bool> deleteEmployee(String id) async {
    state = const AsyncValue.loading();
    try {
      await repository.deleteEmployee(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Check if employee ID exists
  Future<bool> employeeIdExists(String employeeId, {String? excludeId}) async {
    try {
      return await repository.employeeIdExists(employeeId,
          excludeId: excludeId);
    } catch (e) {
      return false;
    }
  }
}
