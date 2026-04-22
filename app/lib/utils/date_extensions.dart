import 'package:intl/intl.dart';

extension DateFormatter on DateTime {
  String get formatFull => DateFormat('MMM dd, yyyy h:mm a').format(this);
  String get formatMDY => DateFormat('MMM d, yyyy').format(this);
  String get formatDetails => DateFormat('MMMM d, yyyy - h:mm a').format(this);
  String get formatShort => DateFormat('MMM d, h:mm a').format(this);

  bool get isToday {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }
}
