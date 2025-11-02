import 'package:flutter/material.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/validators/form_validators.dart';
import '../../../../../core/constants/app_constants.dart';

/// Section 5: Work Description & Follow-up
class OvertimeWorkDescriptionSection extends StatelessWidget {
  final TextEditingController workingDescriptionController;
  final TextEditingController nextActivityController;
  final TextEditingController versionController;
  final TextEditingController picController;
  final TextEditingController responseTimeController;

  const OvertimeWorkDescriptionSection({
    super.key,
    required this.workingDescriptionController,
    required this.nextActivityController,
    required this.versionController,
    required this.picController,
    required this.responseTimeController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Deskripsi Pekerjaan & Follow-up'),
        const SizedBox(height: 8),

        // Working Description / Solution / Comment
        CustomTextField(
          controller: workingDescriptionController,
          label: 'Deskripsi Pekerjaan / Solusi',
          hint: 'Jelaskan pekerjaan yang dilakukan dan solusi (minimal 10 karakter)',
          prefixIcon: Icons.description,
          maxLines: 4,
          validator: (value) {
            final requiredCheck = FormValidators.required(value);
            if (requiredCheck != null) return requiredCheck;

            if (value!.length < AppConstants.minWorkingDescriptionLength) {
              return 'Deskripsi minimal ${AppConstants.minWorkingDescriptionLength} karakter';
            }
            return null;
          },
          maxLength: AppConstants.maxWorkingDescriptionLength,
        ),
        const SizedBox(height: 16),

        // Next Possible Activity
        CustomTextField(
          controller: nextActivityController,
          label: 'Aktivitas Selanjutnya (Opsional)',
          hint: 'Rencana aktivitas follow-up',
          prefixIcon: Icons.next_plan,
          maxLines: 2,
          maxLength: AppConstants.maxNextActivityLength,
        ),
        const SizedBox(height: 16),

        // Version & PIC Row
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: versionController,
                label: 'Versi (Opsional)',
                hint: 'Versi software/hardware',
                prefixIcon: Icons.label,
                maxLength: AppConstants.maxVersionLength,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextField(
                controller: picController,
                label: 'PIC (Opsional)',
                hint: 'Person In Charge',
                prefixIcon: Icons.person,
                maxLength: AppConstants.maxPicLength,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Response Time
        CustomTextField(
          controller: responseTimeController,
          label: 'Response Time (menit)',
          hint: 'Waktu respon dalam menit',
          prefixIcon: Icons.timer,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Response time wajib diisi';
            }
            final number = int.tryParse(value);
            if (number == null || number < 0) {
              return 'Masukkan angka yang valid (minimal 0)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
