import '../constants/app_constants.dart';

/// Extension methods for String
extension StringExtensions on String {
  /// Check if string represents pending status (case-insensitive)
  bool get isPending =>
      toLowerCase() == AppConstants.statusPending.toLowerCase();

  /// Check if string represents approved status (case-insensitive)
  bool get isApproved =>
      toLowerCase() == AppConstants.statusApproved.toLowerCase();

  /// Check if string represents rejected status (case-insensitive)
  bool get isRejected =>
      toLowerCase() == AppConstants.statusRejected.toLowerCase();

  /// Get normalized status (lowercase)
  String get normalizedStatus => toLowerCase().trim();

  /// Check if status is processable (pending)
  ///
  /// Only pending requests can be approved/rejected
  bool get canBeProcessed => isPending;

  /// Check if status is final (approved or rejected)
  bool get isFinalStatus => isApproved || isRejected;

  /// Check if status is editable by owner
  ///
  /// Owner can edit pending requests freely
  /// Editing approved/rejected requires confirmation and resets to pending
  bool get requiresEditConfirmation => isFinalStatus;

  /// Check if severity level matches
  bool get isLowSeverity =>
      toLowerCase() == AppConstants.severityLow.toLowerCase();
  bool get isMediumSeverity =>
      toLowerCase() == AppConstants.severityMedium.toLowerCase();
  bool get isHighSeverity =>
      toLowerCase() == AppConstants.severityHigh.toLowerCase();
  bool get isCriticalSeverity =>
      toLowerCase() == AppConstants.severityCritical.toLowerCase();

  /// Get status display text (capitalize first letter)
  String get statusDisplay {
    if (isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Get status color based on status
  /// Returns hex color string
  String get statusColor {
    if (isPending) return '#FFA726'; // Orange
    if (isApproved) return '#66BB6A'; // Green
    if (isRejected) return '#EF5350'; // Red
    return '#757575'; // Grey (unknown status)
  }

  /// Get severity color based on severity level
  String get severityColor {
    if (isLowSeverity) return '#66BB6A'; // Green
    if (isMediumSeverity) return '#FFA726'; // Orange
    if (isHighSeverity) return '#FF7043'; // Deep Orange
    if (isCriticalSeverity) return '#EF5350'; // Red
    return '#757575'; // Grey (unknown)
  }

  /// Capitalize first letter of each word
  String get titleCase {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// Convert to snake_case
  String get toSnakeCase {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^_'), '');
  }

  /// Convert to camelCase
  String get toCamelCase {
    if (isEmpty) return this;
    final words = split(RegExp(r'[_\s]+'));
    if (words.isEmpty) return this;

    return words.first.toLowerCase() +
        words
            .skip(1)
            .map((word) => word.isEmpty
                ? ''
                : word[0].toUpperCase() + word.substring(1).toLowerCase())
            .join('');
  }

  /// Truncate string dengan ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Remove special characters (keep only alphanumeric and spaces)
  String get alphanumericOnly {
    return replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
  }

  /// Check if string is valid email format
  bool get isValidEmail {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(this);
  }

  /// Check if string contains only numbers
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// Parse to double or return default
  double toDoubleOrDefault([double defaultValue = 0.0]) {
    return double.tryParse(this) ?? defaultValue;
  }

  /// Parse to int or return default
  int toIntOrDefault([int defaultValue = 0]) {
    return int.tryParse(this) ?? defaultValue;
  }
}
