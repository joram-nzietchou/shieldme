class Validators {
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro de téléphone';
    }
    // Remove spaces and special characters for validation
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (cleanPhone.length < 9) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre nom';
    }
    if (value.length < 2) {
      return 'Nom trop court';
    }
    if (value.length > 50) {
      return 'Nom trop long';
    }
    return null;
  }

  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer le code OTP';
    }
    if (value.length != 6) {
      return 'Le code doit contenir 6 chiffres';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Le code ne doit contenir que des chiffres';
    }
    return null;
  }

  static String? validateReferralCode(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (!RegExp(r'^[A-Z]{3,4}-\d{4}$').hasMatch(value.toUpperCase())) {
      return 'Format invalide (ex: SHIELD-1234)';
    }
    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un lien';
    }
    final urlPattern = RegExp(
      r'^(https?:\/\/)?' // http:// or https://
      r'([\da-z\.-]+)\.([a-z\.]{2,6})' // domain
      r'([\/\w \.-]*)*\/?$', // path
      caseSensitive: false,
    );
    if (!urlPattern.hasMatch(value)) {
      return 'Lien invalide';
    }
    return null;
  }
}