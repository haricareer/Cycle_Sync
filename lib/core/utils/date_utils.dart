import 'package:intl/intl.dart';

class AppDateUtils {
  /// Format a DateTime to a readable string (e.g., 'Oct 12, 2026')
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Format a DateTime to a short string (e.g., '12 Oct')
  static String formatShortDate(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  /// Get DateTime representing only the Date portion (hours, minutes stripped)
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get today's date with hours, minutes, seconds stripped
  static DateTime get today => dateOnly(DateTime.now());

  /// Calculate the difference in days between two dates
  static int daysDifference(DateTime start, DateTime end) {
    start = dateOnly(start);
    end = dateOnly(end);
    return end.difference(start).inDays;
  }
}
