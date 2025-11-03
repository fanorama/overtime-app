import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/overtime_provider.dart';
import '../widgets/overtime_card.dart';
import 'overtime_form_screen.dart';
import 'overtime_detail_screen.dart';

/// Screen untuk menampilkan list overtime requests
class OvertimeListScreen extends ConsumerStatefulWidget {
  const OvertimeListScreen({super.key});

  @override
  ConsumerState<OvertimeListScreen> createState() => _OvertimeListScreenState();
}

class _OvertimeListScreenState extends ConsumerState<OvertimeListScreen> {
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final userId = authState.user?.id ?? '';

    // Build filter params
    final filterParams = OvertimeFilterParams(
      userId: userId,
      status: _selectedStatus,
      startDate: _startDate,
      endDate: _endDate,
    );

    final overtimeRequestsAsync = _startDate != null && _endDate != null
        ? ref.watch(filteredOvertimeRequestsStreamProvider(filterParams))
        : _selectedStatus != null
            ? ref.watch(overtimeRequestsByStatusStreamProvider(_selectedStatus!))
            : ref.watch(userOvertimeRequestsStreamProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Lembur'),
        actions: [
          // Filter button
          PopupMenuButton<String>(
            icon: Icon(
              _selectedStatus != null || _startDate != null
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
            ),
            onSelected: (value) {
              if (value == 'clear') {
                setState(() {
                  _selectedStatus = null;
                  _startDate = null;
                  _endDate = null;
                });
              } else if (value == 'date_range') {
                _showDateRangePicker();
              } else {
                setState(() {
                  _selectedStatus = value == 'all' ? null : value;
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive),
                    SizedBox(width: 8),
                    Text('Semua'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: AppConstants.statusPending,
                child: Row(
                  children: [
                    Icon(Icons.pending, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Pending'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: AppConstants.statusApproved,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Approved'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: AppConstants.statusRejected,
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Rejected'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'date_range',
                child: Row(
                  children: [
                    Icon(Icons.date_range),
                    SizedBox(width: 8),
                    Text('Pilih Rentang Tanggal'),
                  ],
                ),
              ),
              if (_selectedStatus != null || _startDate != null) ...[
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Hapus Filter'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Show active filters
          if (_selectedStatus != null || _startDate != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (_selectedStatus != null)
                          Chip(
                            label: Text(
                              _selectedStatus!,
                              style: const TextStyle(fontSize: 12),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() => _selectedStatus = null);
                            },
                          ),
                        if (_startDate != null && _endDate != null)
                          Chip(
                            label: Text(
                              '${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM').format(_endDate!)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                _startDate = null;
                                _endDate = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // List of overtime requests
          Expanded(
            child: overtimeRequestsAsync.when(
              data: (requests) {
                if (requests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedStatus != null || _startDate != null
                              ? 'Tidak ada data sesuai filter'
                              : 'Belum ada data lembur',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // Refresh data by invalidating the provider
                    ref.invalidate(filteredOvertimeRequestsStreamProvider);
                    ref.invalidate(userOvertimeRequestsStreamProvider);
                    ref.invalidate(overtimeRequestsByStatusStreamProvider);
                  },
                  child: ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return OvertimeCard(
                        request: request,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OvertimeDetailScreen(
                                requestId: request.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi kesalahan',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.invalidate(filteredOvertimeRequestsStreamProvider);
                        ref.invalidate(userOvertimeRequestsStreamProvider);
                        ref.invalidate(overtimeRequestsByStatusStreamProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }
}
