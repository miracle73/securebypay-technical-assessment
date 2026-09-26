/// Client-side rules mirroring the backend DTOs, so users see the same
/// constraints before a request is sent.
abstract final class Validators {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _phone = RegExp(r'^\d{7,12}$');
  static final _separators = RegExp(r'[\s-]');

  static String? required(String? value, String field) =>
      (value == null || value.trim().isEmpty) ? '$field is required' : null;

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    return _email.hasMatch(value.trim()) ? null : 'Enter a valid email address';
  }

  static String? phone(String? value) {
    final digits = (value ?? '').replaceAll(_separators, '');
    if (digits.isEmpty) return 'Phone number is required';
    return _phone.hasMatch(digits) ? null : 'Enter a valid phone number';
  }

  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Use at least 8 characters';
    if (!value.contains(RegExp(r'[A-Za-z]')) || !value.contains(RegExp(r'\d'))) {
      return 'Include at least one letter and one number';
    }
    return null;
  }
}
