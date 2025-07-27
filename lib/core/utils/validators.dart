/// Utility class for form validation
/// Contains validation methods for different input types
class Validators {
  /// Validate required text fields
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate phone number format
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10 || digitsOnly.length > 15) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate positive numbers
  static String? validatePositiveNumber(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number <= 0) {
      return '${fieldName ?? 'Value'} must be greater than 0';
    }

    return null;
  }

  /// Validate percentage (0-100)
  static String? validatePercentage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Percentage is required';
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid percentage';
    }

    if (number < 0 || number > 100) {
      return 'Percentage must be between 0 and 100';
    }

    return null;
  }

  /// Validate sun hours (reasonable range)
  static String? validateSunHours(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Sun hours is required';
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number <= 0 || number > 12) {
      return 'Sun hours must be between 0 and 12';
    }

    return null;
  }

  /// Validate backup hours (0-24)
  static String? validateBackupHours(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Backup hours is required';
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number < 0 || number > 24) {
      return 'Backup hours must be between 0 and 24';
    }

    return null;
  }

  /// Validate price/currency values
  static String? validatePrice(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Price'} is required';
    }

    // Remove currency symbols and commas
    final cleanValue = value.replaceAll(RegExp(r'[₱,\s]'), '');
    final number = double.tryParse(cleanValue);

    if (number == null) {
      return 'Please enter a valid price';
    }

    if (number < 0) {
      return 'Price cannot be negative';
    }

    return null;
  }

  /// Validate quantity (positive integer)
  static String? validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }

    final number = int.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid quantity';
    }

    if (number <= 0) {
      return 'Quantity must be greater than 0';
    }

    return null;
  }

  /// Validate project name (no special characters)
  static String? validateProjectName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Project name is required';
    }

    if (value.trim().length < 3) {
      return 'Project name must be at least 3 characters';
    }

    if (value.trim().length > 50) {
      return 'Project name must be less than 50 characters';
    }

    return null;
  }

  /// Validate client name
  static String? validateClientName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Client name is required';
    }

    if (value.trim().length < 2) {
      return 'Client name must be at least 2 characters';
    }

    if (value.trim().length > 50) {
      return 'Client name must be less than 50 characters';
    }

    return null;
  }

  /// Validate location/address
  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }

    if (value.trim().length < 5) {
      return 'Please enter a more detailed location';
    }

    if (value.trim().length > 100) {
      return 'Location must be less than 100 characters';
    }

    return null;
  }
}
