import 'package:flutter/material.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/validators/form_validators.dart';
import '../../../../../core/constants/app_constants.dart';

/// Section 2: Customer & Problem
class OvertimeCustomerSection extends StatelessWidget {
  final TextEditingController customerController;
  final TextEditingController reportedProblemController;

  const OvertimeCustomerSection({
    super.key,
    required this.customerController,
    required this.reportedProblemController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Informasi Pelanggan'),
        const SizedBox(height: 8),

        CustomTextField(
          controller: customerController,
          label: 'Nama Pelanggan',
          hint: 'Masukkan nama pelanggan',
          prefixIcon: Icons.business,
          validator: FormValidators.required,
          maxLength: AppConstants.maxCustomerLength,
        ),
        const SizedBox(height: 16),

        CustomTextField(
          controller: reportedProblemController,
          label: 'Deskripsi Masalah',
          hint: 'Jelaskan masalah yang dilaporkan (minimal 10 karakter)',
          prefixIcon: Icons.description,
          maxLines: 3,
          validator: (value) {
            final requiredCheck = FormValidators.required(value);
            if (requiredCheck != null) return requiredCheck;

            if (value!.length < AppConstants.minReportedProblemLength) {
              return 'Deskripsi minimal ${AppConstants.minReportedProblemLength} karakter';
            }
            return null;
          },
          maxLength: AppConstants.maxReportedProblemLength,
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
