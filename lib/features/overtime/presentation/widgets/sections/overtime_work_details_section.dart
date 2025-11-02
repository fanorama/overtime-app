import 'package:flutter/material.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/validators/form_validators.dart';
import '../../../../../core/constants/app_constants.dart';

/// Section 4: Work Details
class OvertimeWorkDetailsSection extends StatelessWidget {
  final Set<String> selectedWorkTypes;
  final TextEditingController productController;
  final String selectedSeverity;
  final Function(String) onWorkTypeChanged;
  final Function(String) onSeverityChanged;

  const OvertimeWorkDetailsSection({
    super.key,
    required this.selectedWorkTypes,
    required this.productController,
    required this.selectedSeverity,
    required this.onWorkTypeChanged,
    required this.onSeverityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Detail Pekerjaan'),
        const SizedBox(height: 8),

        // Type of Work
        Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jenis Pekerjaan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildWorkTypeCheckboxes(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Product
        CustomTextField(
          controller: productController,
          label: 'Produk',
          hint: 'Masukkan nama produk',
          prefixIcon: Icons.devices,
          validator: FormValidators.required,
          maxLength: AppConstants.maxProductLength,
        ),
        const SizedBox(height: 16),

        // Severity
        _buildSeveritySelector(),
      ],
    );
  }

  Widget _buildWorkTypeCheckboxes() {
    final workTypes = [
      AppConstants.workTypeOvertime,
      AppConstants.workTypeCall,
      AppConstants.workTypeUnplanned,
      AppConstants.workTypeNonOT,
      AppConstants.workTypeVisitSiang,
    ];

    return Column(
      children: workTypes.map((type) {
        final isSelected = selectedWorkTypes.contains(type);
        return CheckboxListTile(
          title: Text(type),
          subtitle: Text(
            'Multiplier: ${AppConstants.workTypeMultipliers[type]}x',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          value: isSelected,
          onChanged: (value) => onWorkTypeChanged(type),
        );
      }).toList(),
    );
  }

  Widget _buildSeveritySelector() {
    final severities = [
      AppConstants.severityLow,
      AppConstants.severityMedium,
      AppConstants.severityHigh,
      AppConstants.severityCritical,
    ];

    final colors = {
      AppConstants.severityLow: Colors.blue,
      AppConstants.severityMedium: Colors.orange,
      AppConstants.severityHigh: Colors.deepOrange,
      AppConstants.severityCritical: Colors.red,
    };

    final labels = {
      AppConstants.severityLow: 'Low',
      AppConstants.severityMedium: 'Medium',
      AppConstants.severityHigh: 'High',
      AppConstants.severityCritical: 'Critical',
    };

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Tingkat Keseriusan',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.priority_high),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSeverity,
          isExpanded: true,
          items: severities.map((severity) {
            return DropdownMenuItem(
              value: severity,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[severity],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(labels[severity] ?? severity),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onSeverityChanged(value);
            }
          },
        ),
      ),
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
