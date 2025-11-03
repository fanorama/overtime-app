/// Input sanitizer untuk prevent XSS dan injection attacks
///
/// Class ini menyediakan utility methods untuk sanitize user input
/// sebelum disimpan ke database atau ditampilkan di UI.
class InputSanitizer {
  /// Sanitize string input dari user
  ///
  /// Removes:
  /// - HTML tags
  /// - SQL injection patterns
  /// - Script tags
  /// - Leading/trailing whitespace
  ///
  /// Returns sanitized string
  static String sanitize(String input) {
    if (input.isEmpty) return input;

    String sanitized = input.trim();

    // Remove HTML tags
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');

    // Remove script tags specifically (double check)
    sanitized = sanitized.replaceAll(RegExp(r'<script[^>]*>.*?</script>',
        caseSensitive: false, multiLine: true), '');

    // Remove potentially dangerous characters for SQL injection
    // Keep only: letters, numbers, spaces, and common punctuation
    // Allow Unicode characters for international names
    sanitized = sanitized.replaceAll(
      RegExp(r'[<>{}\\;]'),
      '',
    );

    // Remove multiple spaces
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    return sanitized.trim();
  }

  /// Sanitize text field (customer, names, etc.)
  ///
  /// More permissive than general sanitize, allows most characters
  /// but still prevents XSS
  static String sanitizeTextField(String input) {
    if (input.isEmpty) return input;

    String sanitized = input.trim();

    // Remove HTML/script tags
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');
    sanitized = sanitized.replaceAll(
        RegExp(r'<script[^>]*>.*?</script>',
            caseSensitive: false, multiLine: true),
        '');

    // Remove only the most dangerous characters
    sanitized = sanitized.replaceAll(RegExp(r'[<>{}]'), '');

    // Remove multiple spaces
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    return sanitized.trim();
  }

  /// Sanitize multiline text (descriptions, notes, etc.)
  ///
  /// Preserves line breaks but removes dangerous content
  static String sanitizeMultilineText(String input) {
    if (input.isEmpty) return input;

    String sanitized = input.trim();

    // Remove HTML/script tags
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');
    sanitized = sanitized.replaceAll(
        RegExp(r'<script[^>]*>.*?</script>',
            caseSensitive: false, multiLine: true),
        '');

    // Remove dangerous characters
    sanitized = sanitized.replaceAll(RegExp(r'[<>{}]'), '');

    // Normalize line breaks (convert all to \n)
    sanitized = sanitized.replaceAll(RegExp(r'\r\n'), '\n');
    sanitized = sanitized.replaceAll(RegExp(r'\r'), '\n');

    // Remove excessive line breaks (max 2 consecutive)
    sanitized = sanitized.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // Remove multiple spaces on same line
    sanitized = sanitized.replaceAll(RegExp(r'[ \t]+'), ' ');

    return sanitized.trim();
  }

  /// Sanitize email-like input
  ///
  /// Very restrictive, only allows valid email characters
  static String sanitizeEmail(String input) {
    if (input.isEmpty) return input;

    String sanitized = input.trim().toLowerCase();

    // Allow only: alphanumeric, @, ., -, _
    sanitized = sanitized.replaceAll(RegExp(r'[^a-z0-9@.\-_]'), '');

    return sanitized;
  }

  /// Sanitize username input
  ///
  /// Only allows alphanumeric and underscores
  static String sanitizeUsername(String input) {
    if (input.isEmpty) return input;

    String sanitized = input.trim().toLowerCase();

    // Allow only: alphanumeric and underscore
    sanitized = sanitized.replaceAll(RegExp(r'[^a-z0-9_]'), '');

    return sanitized;
  }

  /// Validate if input contains potentially dangerous patterns
  ///
  /// Returns true if input is safe, false if dangerous patterns detected
  static bool isSafe(String input) {
    if (input.isEmpty) return true;

    // Check for script tags
    if (RegExp(r'<script', caseSensitive: false).hasMatch(input)) {
      return false;
    }

    // Check for iframe tags
    if (RegExp(r'<iframe', caseSensitive: false).hasMatch(input)) {
      return false;
    }

    // Check for javascript: protocol
    if (RegExp(r'javascript:', caseSensitive: false).hasMatch(input)) {
      return false;
    }

    // Check for event handlers
    if (RegExp(r'on\w+\s*=', caseSensitive: false).hasMatch(input)) {
      return false;
    }

    // Check for SQL injection patterns
    final sqlPatterns = [
      r"('\s*(or|and)\s*')",
      r'(--\s*$)',
      r'(;\s*(drop|delete|update|insert)\s+)',
      r'(\bunion\s+select\b)',
    ];

    for (final pattern in sqlPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return false;
      }
    }

    return true;
  }

  /// Batch sanitize map of strings
  ///
  /// Useful for sanitizing form data at once
  static Map<String, String> sanitizeMap(
    Map<String, String> data, {
    Set<String>? multilineFields,
  }) {
    final sanitized = <String, String>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (multilineFields != null && multilineFields.contains(key)) {
        sanitized[key] = sanitizeMultilineText(value);
      } else {
        sanitized[key] = sanitizeTextField(value);
      }
    }

    return sanitized;
  }
}
