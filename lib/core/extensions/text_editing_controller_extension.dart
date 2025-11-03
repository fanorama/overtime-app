import 'package:flutter/material.dart';
import '../security/input_sanitizer.dart';

/// Extension untuk TextEditingController
///
/// Menyediakan helper methods untuk sanitize input
extension TextEditingControllerExtension on TextEditingController {
  /// Get sanitized text value
  ///
  /// Returns sanitized version of text, safe for database storage
  String get sanitizedText => InputSanitizer.sanitizeTextField(text);

  /// Get sanitized multiline text value
  ///
  /// Preserves line breaks but removes dangerous content
  String get sanitizedMultilineText =>
      InputSanitizer.sanitizeMultilineText(text);

  /// Check if current text is safe
  bool get isSafe => InputSanitizer.isSafe(text);
}
