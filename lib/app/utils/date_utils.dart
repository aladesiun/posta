import 'package:intl/intl.dart';

class DateUtils {
  static String formatPostDate(dynamic dateValue) {
    if (dateValue == null) return 'Unknown time';

    // Handle both string and DateTime inputs
    DateTime date;
    if (dateValue is String) {
      try {
        date = DateTime.parse(dateValue);
      } catch (e) {
        return 'Invalid date';
      }
    } else if (dateValue is DateTime) {
      date = dateValue;
    } else {
      return 'Unknown time';
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    // Less than 1 minute
    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    // Less than 1 hour
    if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }

    // Less than 24 hours
    if (difference.inDays < 1) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }

    // Less than 7 days
    if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }

    // Less than 30 days
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    }

    // Less than 365 days
    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    }

    // More than 1 year
    final years = (difference.inDays / 365).floor();
    return '$years ${years == 1 ? 'year' : 'years'} ago';
  }

  static String formatFullDate(dynamic dateValue) {
    if (dateValue == null) return 'Unknown date';

    DateTime date;
    if (dateValue is String) {
      try {
        date = DateTime.parse(dateValue);
      } catch (e) {
        return 'Invalid date';
      }
    } else if (dateValue is DateTime) {
      date = dateValue;
    } else {
      return 'Unknown date';
    }

    return DateFormat('MMM d, y \'at\' h:mm a').format(date);
  }
}
