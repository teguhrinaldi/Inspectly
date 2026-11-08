import 'package:intl/intl.dart';

import '../../data/models/inspection.dart';

/// "Today · 09:30", "Tomorrow · 09:00", "Dec 5, 2026 · 08:00".
String relativeDateTime(DateTime date, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final today = DateTime(ref.year, ref.month, ref.day);
  final day = DateTime(date.year, date.month, date.day);
  final diff = day.difference(today).inDays;
  final time = DateFormat('HH:mm').format(date);
  final prefix = switch (diff) {
    0 => 'Today',
    1 => 'Tomorrow',
    -1 => 'Yesterday',
    _ => DateFormat('MMM d, yyyy').format(date),
  };
  return '$prefix · $time';
}

/// "Today, 09:30" style used in detail rows.
String relativeDateTimeComma(DateTime date) =>
    relativeDateTime(date).replaceFirst(' · ', ', ');

String shortDate(DateTime date) => DateFormat('MMM d, yyyy').format(date);

/// The date an inspection is best described by in lists.
DateTime? displayDate(Inspection i) =>
    i.scheduledAt ?? i.startedAt ?? i.completedAt;

/// Months (rounded) from [from] to [to], for "(in 3 months)".
String inTimeLabel(DateTime to, {DateTime? from}) {
  final start = from ?? DateTime.now();
  final days = to.difference(start).inDays;
  if (days <= 0) return 'due now';
  if (days < 14) return 'in $days day${days == 1 ? '' : 's'}';
  if (days < 60) return 'in ${(days / 7).round()} weeks';
  return 'in ${(days / 30.4).round()} months';
}
