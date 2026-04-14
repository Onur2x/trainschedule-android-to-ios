import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import '../models/timetable_entity.dart';

class TrainScheduleService {
  static const String _timetableUrl = 'https://raw.githubusercontent.com/Onur2x/train-schedule-updates/main/timetable_v2.json';

  // Get all timetables
  static Future<List<TimetableEntity>> getTimetables() async {
    try {
      // Try to load from GitHub first
      final response = await http.get(Uri.parse(_timetableUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseTimetables(data);
      }
    } catch (e) {
      print('GitHub yüklenemedi, local kullanýlýyor: $e');
    }
    
    // Fallback to local
    return _getLocalTimetables();
  }

  // Get local timetables
  static Future<List<TimetableEntity>> _getLocalTimetables() async {
    try {
      final timetableString = await rootBundle.loadString('assets/data/test_timetable.json');
      final data = json.decode(timetableString);
      return _parseTimetables(data);
    } catch (e) {
      print('Local timetable yüklenemedi: $e');
      return [];
    }
  }

  // Parse timetables
  static List<TimetableEntity> _parseTimetables(Map<String, dynamic> data) {
    final timetables = <TimetableEntity>[];
    
    if (data['rows'] != null) {
      for (final row in data['rows']) {
        final gorevno = int.tryParse(row['gorevno']?.toString() ?? '') ?? 1;
        
        timetables.add(TimetableEntity(
          id: row.hashCode,
          trainNumber: gorevno,
          station: _getStationName(gorevno),
          time: _formatTime(row['saat'] ?? ''),
          direction: row['yon'] ?? 0,
          ttid: row['ttid'] ?? 1,
          runId: int.tryParse(row['run']?.toString() ?? '') ?? 1,
        ));
      }
    }
    
    return timetables;
  }

  // Get timetable by train number
  static Future<List<TimetableEntity>> getTimetableByTrainNumber(int trainNumber) async {
    final allTimetables = await getTimetables();
    return allTimetables.where((t) => t.trainNumber == trainNumber).toList();
  }

  // Get current data version
  static Future<int> getCurrentDataVersion() async {
    return 1;
  }

  // Get station name - Android'den gelen gerçek mantýk
  static String _getStationName(int gorevno) {
    final stationMap = {
      1: 'UÇ ÝSTASYON',
      2: 'SON ÝSTASYON',
      3: 'UÇ ÝSTASYON',
      4: 'SON ÝSTASYON',
      5: 'UÇ ÝSTASYON',
      6: 'SON ÝSTASYON',
      7: 'UÇ ÝSTASYON',
      21: 'UÇ ÝSTASYON',
      22: 'SON ÝSTASYON',
      23: 'UÇ ÝSTASYON',
    };
    return stationMap[gorevno] ?? 'Ýstasyon $gorevno';
  }

  // Format time
  static String _formatTime(String time) {
    if (time.isEmpty) return '00:00';
    
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return time;
  }

  // Get available train numbers
  static Future<List<int>> getAvailableTrainNumbers() async {
    final timetables = await getTimetables();
    final trainNumbers = timetables.map((t) => t.trainNumber).toSet().toList();
    trainNumbers.sort();
    return trainNumbers;
  }
}
