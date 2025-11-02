import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'employee_dashboard_screen.dart';
import 'manager_dashboard_screen.dart';

/// Home Screen - Routes ke dashboard yang sesuai berdasarkan role
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Route ke dashboard yang sesuai berdasarkan role
    if (user.isManager) {
      return const ManagerDashboardScreen();
    } else {
      return const EmployeeDashboardScreen();
    }
  }
}
