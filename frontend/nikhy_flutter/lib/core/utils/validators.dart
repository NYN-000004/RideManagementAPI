class Validators {
  static String? requiredField(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? latitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Latitude is required';
    }
    final num = double.tryParse(value.trim());
    if (num == null) {
      return 'Enter a valid decimal number';
    }
    if (num < -90 || num > 90) {
      return 'Latitude must be between -90 and 90';
    }
    return null;
  }

  static String? longitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Longitude is required';
    }
    final num = double.tryParse(value.trim());
    if (num == null) {
      return 'Enter a valid decimal number';
    }
    if (num < -180 || num > 180) {
      return 'Longitude must be between -180 and 180';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String fieldName = 'Amount']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final num = double.tryParse(value.trim());
    if (num == null) {
      return 'Enter a valid number';
    }
    if (num <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }
}
