import 'package:flutter/material.dart';
import 'overtime_form_screen.dart';

/// Screen untuk menampilkan list overtime requests
class OvertimeListScreen extends StatelessWidget {
  const OvertimeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Lembur'),
      ),
      body: const Center(
        child: Text('Overtime List Screen - Coming Soon\n\nImplementasi akan ditambahkan di Phase 4'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OvertimeFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
