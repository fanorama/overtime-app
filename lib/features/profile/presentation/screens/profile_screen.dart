import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/seed_data.dart';

/// Screen untuk menampilkan profil user dan logout
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          user.username.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.username,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          user.role == 'manager' ? 'Manager' : 'Karyawan',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: user.role == 'manager'
                            ? Colors.purple
                            : Colors.blue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Profile Information
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.badge),
                        title: const Text('User ID'),
                        subtitle: Text(user.id),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Username'),
                        subtitle: Text(user.username),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings),
                        title: const Text('Role'),
                        subtitle: Text(
                          user.role == 'manager' ? 'Manager' : 'Karyawan',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Developer Tools (only for managers)
                if (user.role == 'manager') ...[
                  Card(
                    color: Colors.amber.shade50,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.developer_mode, color: Colors.amber),
                          title: const Text(
                            'Developer Tools',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: const Text('Tools untuk testing dan development'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.group_add),
                          title: const Text('Seed 7 Dummy Employees'),
                          subtitle: const Text('Tambahkan 7 karyawan dummy ke database'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Seed Dummy Employees'),
                                content: const Text(
                                  'Akan menambahkan 7 karyawan dummy:\n'
                                  '• Ahmad Fauzi (EMP001) - Engineer\n'
                                  '• Siti Nurhaliza (EMP002) - Engineer\n'
                                  '• Budi Santoso (EMP003) - Maintenance\n'
                                  '• Andi Wijaya (EMP006) - Maintenance\n'
                                  '• Dewi Lestari (EMP004) - Postsales\n'
                                  '• Rudi Hartono (EMP005) - Onsite\n'
                                  '• Maya Sari (EMP007) - Onsite\n\n'
                                  'Lanjutkan?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Tambahkan'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true && context.mounted) {
                              // Show loading
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircularProgressIndicator(),
                                          SizedBox(height: 16),
                                          Text('Menambahkan karyawan...'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );

                              try {
                                final seedData = SeedData();
                                await seedData.seedEmployees();

                                if (context.mounted) {
                                  Navigator.pop(context); // Close loading
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('✅ Berhasil menambahkan dummy employees!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  Navigator.pop(context); // Close loading
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('❌ Error: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Konfirmasi Logout'),
                          content:
                              const Text('Apakah Anda yakin ingin keluar?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        await ref
                            .read(authControllerProvider.notifier)
                            .logout();
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
