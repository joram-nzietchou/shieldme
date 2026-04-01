class Formatters {
  static String formatPhoneNumber(String phone) {
    // Format: +237 6XX XXX XXX
    final clean = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (clean.length == 9) {
      return '+237 ${clean.substring(0, 3)} ${clean.substring(3, 6)} ${clean.substring(6, 9)}';
    }
    return phone;
  }

  static String formatCurrency(int amount) {
    return '${amount.toString()} FCFA';
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  static String truncateString(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}