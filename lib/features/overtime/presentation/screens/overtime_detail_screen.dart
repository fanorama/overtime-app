import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/overtime_provider.dart';
import '../widgets/status_badge.dart';
import '../widgets/severity_badge.dart';
import 'overtime_form_screen.dart';
import '../widgets/rejection_reason_dialog.dart';
import '../../domain/entities/overtime_request_entity.dart';
import '../../../auth/presentation/providers/auth_state.dart';

/// Screen untuk menampilkan detail overtime request
class OvertimeDetailScreen extends ConsumerWidget {
  final String requestId;

  const OvertimeDetailScreen({
    super.key,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestAsync = ref.watch(overtimeRequestByIdStreamProvider(requestId));
    final authState = ref.watch(authControllerProvider);
    final isManager = authState.user?.role == AppConstants.roleManager;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Lembur'),
        actions: requestAsync.maybeWhen(
          data: (request) {
            if (request == null) return null;

            // Show edit button jika:
            // 1. User adalah submitter AND status bukan approved, ATAU
            // 2. User adalah manager
            final canEdit = (authState.user?.id == request.submittedBy &&
                    request.status != AppConstants.statusApproved) ||
                isManager;

            if (!canEdit) return null;

            return [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OvertimeFormScreen(
                        overtimeRequest: request,
                      ),
                    ),
                  );
                },
                tooltip: 'Edit',
              ),
            ];
          },
          orElse: () => null,
        ),
      ),
      body: requestAsync.when(
        data: (request) {
          if (request == null) {
            return const Center(
              child: Text('Data tidak ditemukan'),
            );
          }

          final dateFormat = DateFormat('dd MMMM yyyy');
          final timeFormat = DateFormat('HH:mm');
          final dateTimeFormat = DateFormat('dd MMM yyyy HH:mm');
          final currencyFormat = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section: Status & Date
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusBadge(
                        status: request.status,
                        isEdited: request.isEdited,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dateFormat.format(request.startTime),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${timeFormat.format(request.startTime)} - ${timeFormat.format(request.endTime)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Customer & Problem Section
                _buildSection(
                  context,
                  title: 'Informasi Customer',
                  children: [
                    _buildInfoRow(
                      icon: Icons.business,
                      label: 'Nama Customer',
                      value: request.customer,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.description,
                      label: 'Masalah yang Dilaporkan',
                      value: request.reportedProblem,
                      isMultiline: true,
                    ),
                  ],
                ),

                // Work Details Section
                _buildSection(
                  context,
                  title: 'Detail Pekerjaan',
                  children: [
                    _buildInfoRow(
                      icon: Icons.priority_high,
                      label: 'Severity',
                      value: '',
                      customValue: SeverityBadge(severity: request.severity),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.category,
                      label: 'Produk',
                      value: request.product,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.build,
                      label: 'Jenis Pekerjaan',
                      value: '',
                      customValue: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: request.typeOfWork.map((type) {
                          return Chip(
                            label: Text(type),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.description,
                      label: 'Deskripsi Pekerjaan',
                      value: request.workingDescription,
                      isMultiline: true,
                    ),
                    if (request.nextPossibleActivity != null &&
                        request.nextPossibleActivity!.isNotEmpty) ...[
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.next_plan,
                        label: 'Aktivitas Selanjutnya',
                        value: request.nextPossibleActivity!,
                        isMultiline: true,
                      ),
                    ],
                    if (request.version != null && request.version!.isNotEmpty) ...[
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.info,
                        label: 'Versi',
                        value: request.version!,
                      ),
                    ],
                    if (request.pic != null && request.pic!.isNotEmpty) ...[
                      const Divider(height: 24),
                      _buildInfoRow(
                        icon: Icons.person_outline,
                        label: 'PIC',
                        value: request.pic!,
                      ),
                    ],
                  ],
                ),

                // Employees Section
                _buildSection(
                  context,
                  title: 'Tim Lembur',
                  children: [
                    _buildInfoRow(
                      icon: Icons.group,
                      label: 'Jumlah Karyawan',
                      value: '${request.allInvolvedEmployees.length} orang',
                    ),
                    const SizedBox(height: 12),
                    if (request.involvedEngineers.isNotEmpty) ...[
                      const Text(
                        'Engineers:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...request.involvedEngineers.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.blue,
                                child: Text(
                                  "${entry.key + 1}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                    ],
                    if (request.involvedMaintenance.isNotEmpty) ...[
                      const Text(
                        'Maintenance:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...request.involvedMaintenance.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.green,
                                child: Text(
                                  "${entry.key + 1}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                    ],
                    if (request.involvedPostsales.isNotEmpty) ...[
                      const Text(
                        'Postsales:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...request.involvedPostsales.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.orange,
                                child: Text(
                                  "${entry.key + 1}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),

                // Earnings Section
                _buildSection(
                  context,
                  title: 'Perhitungan Lembur',
                  children: [
                    _buildInfoRow(
                      icon: Icons.access_time,
                      label: 'Total Jam',
                      value: '${request.totalHours.toStringAsFixed(1)} jam',
                    ),
                    const Divider(height: 24),
                    _buildEarningsRow(
                      'Upah Lembur',
                      request.calculatedEarnings,
                      currencyFormat,
                    ),
                    _buildEarningsRow(
                      'Uang Makan',
                      request.mealAllowance,
                      currencyFormat,
                    ),
                    const Divider(height: 16),
                    _buildEarningsRow(
                      'Total Pendapatan',
                      request.totalEarnings,
                      currencyFormat,
                      isTotal: true,
                    ),
                  ],
                ),

                // Approval Information Section
                if (request.status != AppConstants.statusPending)
                  _buildSection(
                    context,
                    title: 'Informasi Approval',
                    children: [
                      if (request.approverName != null) ...[
                        _buildInfoRow(
                          icon: Icons.person,
                          label: 'Disetujui/Ditolak oleh',
                          value: request.approverName!,
                        ),
                      ],
                      if (request.approvedAt != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          label: 'Tanggal',
                          value: dateTimeFormat.format(request.approvedAt!),
                        ),
                      ],
                      if (request.rejectionReason != null &&
                          request.rejectionReason!.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildInfoRow(
                          icon: Icons.comment,
                          label: 'Alasan Penolakan',
                          value: request.rejectionReason!,
                          isMultiline: true,
                        ),
                      ],
                    ],
                  ),

                // Edit History Section
                if (request.isEdited && request.editHistory.isNotEmpty)
                  _buildSection(
                    context,
                    title: 'Riwayat Edit',
                    children: [
                      ...request.editHistory.asMap().entries.map((entry) {
                        final history = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      child: Text('${entry.key + 1}'),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        dateTimeFormat.format(history.editedAt),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (history.editedBy.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Diedit oleh: ${history.editedBy}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                                if (history.reason != null && history.reason!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Alasan: ${history.reason}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),

                // Submitter Information
                _buildSection(
                  context,
                  title: 'Informasi Pengajuan',
                  children: [
                    _buildInfoRow(
                      icon: Icons.person_outline,
                      label: 'Diajukan oleh',
                      value: request.submitterName,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.access_time,
                      label: 'Tanggal Pengajuan',
                      value: dateTimeFormat.format(request.createdAt),
                    ),
                    if (request.updatedAt != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.update,
                        label: 'Terakhir Diupdate',
                        value: dateTimeFormat.format(request.updatedAt!),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 80), // Space for FAB
              ],
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
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Terjadi kesalahan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(error.toString()),
            ],
          ),
        ),
      ),
      // Approval buttons for manager (hanya untuk pending requests)
      floatingActionButton: requestAsync.maybeWhen(
        data: (request) {
          if (request == null) return null;

          // Only show for managers and pending status
          if (!isManager || request.status != AppConstants.statusPending) {
            return null;
          }

          return _buildApprovalButtons(context, ref, request);
        },
        orElse: () => null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Widget untuk approval buttons
  Widget _buildApprovalButtons(
    BuildContext context,
    WidgetRef ref,
    OvertimeRequestEntity request,
  ) {
    final authState = ref.watch(authControllerProvider);
    final controller = ref.watch(overtimeControllerProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Reject Button
          Expanded(
            child: FloatingActionButton.extended(
              onPressed: controller.isLoading
                  ? null
                  : () => _handleReject(context, ref, authState),
              backgroundColor: Colors.red,
              heroTag: 'reject',
              icon: const Icon(Icons.cancel),
              label: const Text('Tolak'),
            ),
          ),
          const SizedBox(width: 16),
          // Approve Button
          Expanded(
            child: FloatingActionButton.extended(
              onPressed: controller.isLoading
                  ? null
                  : () => _handleApprove(context, ref, authState),
              backgroundColor: Colors.green,
              heroTag: 'approve',
              icon: const Icon(Icons.check_circle),
              label: const Text('Setujui'),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle approve action
  Future<void> _handleApprove(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Approval'),
        content: const Text('Apakah Anda yakin ingin menyetujui request lembur ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final controller = ref.read(overtimeControllerProvider.notifier);
    final success = await controller.approveRequest(
      requestId,
      authState.user!.id,
      authState.user!.displayName ?? authState.user!.username,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request berhasil disetujui'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(); // Kembali ke list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyetujui request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Handle reject action
  Future<void> _handleReject(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const RejectionReasonDialog(),
    );

    if (reason == null || reason.isEmpty || !context.mounted) return;

    final controller = ref.read(overtimeControllerProvider.notifier);
    final success = await controller.rejectRequest(
      requestId,
      authState.user!.id,
      authState.user!.displayName ?? authState.user!.username,
      reason,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request berhasil ditolak'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.of(context).pop(); // Kembali ke list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menolak request'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? customValue,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment:
          isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              if (customValue != null)
                customValue
              else
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsRow(
    String label,
    double amount,
    NumberFormat format, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            format.format(amount),
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
