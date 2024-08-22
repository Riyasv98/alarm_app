import 'package:flutter/material.dart';

class DateTimeUtils {
  static String getDay(DateTime selectedDateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = selectedDateTime.difference(today).inDays;

    switch (difference) {
      case 0:
        return 'Today';
      case 1:
        return 'Tomorrow';
      case 2:
        return 'After tomorrow';
      default:
        return 'In $difference days';
    }
  }

  static Future<DateTime> pickTime(
      DateTime selectedDateTime, BuildContext context) async {
    final res = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      context: context,
    );

    if (res != null) {
      final now = DateTime.now();
      selectedDateTime = now.copyWith(
        hour: res.hour,
        minute: res.minute,
        second: 0,
        millisecond: 0,
        microsecond: 0,
      );
      if (selectedDateTime.isBefore(now)) {
        selectedDateTime = selectedDateTime.add(const Duration(days: 1));
      }
    }
    return selectedDateTime;
  }
}
