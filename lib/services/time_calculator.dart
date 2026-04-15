import 'dart:core';

class TimeCalculator {
  static DateTime parseTime(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hours, minutes, seconds);
      } else if (parts.length >= 2) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hours, minutes, 0);
      }
    } catch (e) {
      return DateTime.now();
    }
    return DateTime.now();
  }

  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  static bool isPast(DateTime time, DateTime now) {
    return time.isBefore(now);
  }

  static String formatHhMmSs(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  static int secondsUntil(DateTime now, DateTime target) {
    if (target.isBefore(now)) {
      return 0;
    }
    return target.difference(now).inSeconds;
  }

  static String formatRestDuration(DateTime? incomingTime, DateTime? nextOutgoingTime) {
    if (incomingTime == null || nextOutgoingTime == null) {
      return '-';
    }

    final difference = nextOutgoingTime.difference(incomingTime);
    if (difference.isNegative) {
      return '-';
    }

    final totalMinutes = difference.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0) {
      return '${hours}sa ${minutes}dk';
    } else {
      return '${minutes}dk';
    }
  }

  static DateTime? findNextDeparture(List<DateTime> departureTimes, DateTime now) {
    if (departureTimes.isEmpty) return null;

    DateTime? nextDeparture;
    for (final departure in departureTimes) {
      if (departure.isAfter(now)) {
        if (nextDeparture == null || departure.isBefore(nextDeparture)) {
          nextDeparture = departure;
        }
      }
    }

    return nextDeparture;
  }
}
