import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/overtime/presentation/screens/overtime_list_screen.dart';
import '../../features/overtime/presentation/screens/manager_request_list_screen.dart';
import '../../features/employee/presentation/screens/employee_list_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

/// Main navigation screen with bottom navigation bar
class AppNavigation extends ConsumerStatefulWidget {
  const AppNavigation({super.key});

  @override
  ConsumerState<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends ConsumerState<AppNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isManager = authState.user?.role == 'manager';

    // Navigation items berbeda untuk employee dan manager
    final List<_NavigationItem> navigationItems = isManager
        ? [
            _NavigationItem(
              icon: Icons.dashboard,
              label: 'Dashboard',
              screen: const HomeScreen(),
            ),
            _NavigationItem(
              icon: Icons.access_time,
              label: 'Lembur Saya',
              screen: const OvertimeListScreen(),
            ),
            _NavigationItem(
              icon: Icons.approval,
              label: 'Approval',
              screen: const ManagerRequestListScreen(),
            ),
            _NavigationItem(
              icon: Icons.people,
              label: 'Karyawan',
              screen: const EmployeeListScreen(),
            ),
            _NavigationItem(
              icon: Icons.person,
              label: 'Profil',
              screen: const ProfileScreen(),
            ),
          ]
        : [
            _NavigationItem(
              icon: Icons.dashboard,
              label: 'Dashboard',
              screen: const HomeScreen(),
            ),
            _NavigationItem(
              icon: Icons.access_time,
              label: 'Lembur',
              screen: const OvertimeListScreen(),
            ),
            _NavigationItem(
              icon: Icons.person,
              label: 'Profil',
              screen: const ProfileScreen(),
            ),
          ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: navigationItems.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: navigationItems
            .map(
              (item) => BottomNavigationBarItem(
                icon: Icon(item.icon),
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

/// Navigation item data class
class _NavigationItem {
  final IconData icon;
  final String label;
  final Widget screen;

  _NavigationItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}
