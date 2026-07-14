class Formatters {
  static String formatNumber(int number) {
    // Format 129000 to "129 000"
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return number.toString().replaceAllMapped(reg, (Match match) => '${match[1]} ');
  }

  static String formatSum(int number) {
    return '${formatNumber(number)} so\'m';
  }
}
