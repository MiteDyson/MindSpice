import 'package:intl/intl.dart';

class DateUtilsHelper {
  static String formatForHeader(DateTime date) {
    return DateFormat('EEE, MMM d yyyy').format(date);
  }

  static String formatShort(DateTime date) {
    return DateFormat('MMM d').format(date);
  }
}
