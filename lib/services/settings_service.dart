import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _firstStationKey = 'first_station_name';
  static const String _lastStationKey = 'last_station_name';
  static const String _alarmEnabledKey = 'alarm_enabled';
  static const String _alarmSoundEnabledKey = 'alarm_sound_enabled';
  static const String _alarmVibrationEnabledKey = 'alarm_vibration_enabled';
  static const String _alarmThresholdKey = 'alarm_threshold';
  static const String _alarmModeKey = 'alarm_mode';
  static const String _alarmSoundKey = 'alarm_sound';
  static const String _darkThemeKey = 'dark_theme';

  static Future<void> saveSettings({
    String? firstStationName,
    String? lastStationName,
    bool? alarmEnabled,
    bool? alarmSoundEnabled,
    bool? alarmVibrationEnabled,
    int? alarmThreshold,
    int? alarmMode,
    String? alarmSound,
    bool? darkTheme,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (firstStationName != null) {
      await prefs.setString(_firstStationKey, firstStationName);
    }
    if (lastStationName != null) {
      await prefs.setString(_lastStationKey, lastStationName);
    }
    if (alarmEnabled != null) {
      await prefs.setBool(_alarmEnabledKey, alarmEnabled);
    }
    if (alarmSoundEnabled != null) {
      await prefs.setBool(_alarmSoundEnabledKey, alarmSoundEnabled);
    }
    if (alarmVibrationEnabled != null) {
      await prefs.setBool(_alarmVibrationEnabledKey, alarmVibrationEnabled);
    }
    if (alarmThreshold != null) {
      await prefs.setInt(_alarmThresholdKey, alarmThreshold);
    }
    if (alarmMode != null) {
      await prefs.setInt(_alarmModeKey, alarmMode);
    }
    if (alarmSound != null) {
      await prefs.setString(_alarmSoundKey, alarmSound);
    }
    if (darkTheme != null) {
      await prefs.setBool(_darkThemeKey, darkTheme);
    }
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'firstStationName': prefs.getString(_firstStationKey) ?? 'UÇ ÝSTASYON',
      'lastStationName': prefs.getString(_lastStationKey) ?? 'SON ÝSTASYON',
      'alarmEnabled': prefs.getBool(_alarmEnabledKey) ?? true,
      'alarmSoundEnabled': prefs.getBool(_alarmSoundEnabledKey) ?? true,
      'alarmVibrationEnabled': prefs.getBool(_alarmVibrationEnabledKey) ?? true,
      'alarmThreshold': prefs.getInt(_alarmThresholdKey) ?? 300,
      'alarmMode': prefs.getInt(_alarmModeKey) ?? 0,
      'alarmSound': prefs.getString(_alarmSoundKey) ?? 'Klasik Zil',
      'darkTheme': prefs.getBool(_darkThemeKey) ?? false,
    };
  }

  static Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
