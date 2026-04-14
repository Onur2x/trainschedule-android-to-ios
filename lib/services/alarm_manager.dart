import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'time_calculator.dart';

class AlarmManager {
  static const int MODE_ONCE = 0;
  static const int MODE_CONTINUOUS = 1;
  static const int MODE_EVERY_MINUTE = 2;

  static bool _isRinging = false;
  static Timer? _alarmTimer;
  static Timer? _countdownTimer;
  static int _currentTrainNumber = 0;
  static DateTime? _nextDeparture;
  static int _alarmThreshold = 300; // 5 dakika
  static int _alarmMode = MODE_ONCE;
  static bool _soundEnabled = true;
  static bool _vibrationEnabled = true;

  static bool get isRinging => _isRinging;
  static int get currentTrainNumber => _currentTrainNumber;
  static DateTime? get nextDeparture => _nextDeparture;

  static void onNewTrainLoaded() {
    stopAlarm();
    _currentTrainNumber = 0;
    _nextDeparture = null;
  }

  static void startCountdownTimer(VoidCallback callback) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      callback();
    });
  }

  static void stopCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  static void evaluateAlarm(DateTime departureTime, int trainNumber) {
    if (!_soundEnabled && !_vibrationEnabled) return;
    if (_isRinging) return;

    final now = DateTime.now();
    final secondsUntil = TimeCalculator.secondsUntil(now, departureTime);

    if (secondsUntil <= _alarmThreshold && secondsUntil > 0) {
      _currentTrainNumber = trainNumber;
      _nextDeparture = departureTime;

      switch (_alarmMode) {
        case MODE_ONCE:
          _triggerAlarm(false);
          break;
        case MODE_CONTINUOUS:
          _triggerAlarm(true);
          break;
        case MODE_EVERY_MINUTE:
          _triggerAlarm(false);
          break;
      }
    }
  }

  static void _triggerAlarm(bool continuous) {
    if (_isRinging) return;
    
    _isRinging = true;

    // Vibration
    if (_vibrationEnabled) {
      _startVibration(continuous);
    }

    // Sound (platform-specific)
    if (_soundEnabled) {
      _playAlarmSound(continuous);
    }

    // Notification
    _showNotification(_currentTrainNumber, _nextDeparture!);
  }

  static void stopAlarm() {
    _isRinging = false;
    _alarmTimer?.cancel();
    _alarmTimer = null;
    HapticFeedback.lightImpact();
  }

  static void _startVibration(bool continuous) {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    if (continuous) {
      _alarmTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        HapticFeedback.heavyImpact();
      });
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  static void _playAlarmSound(bool continuous) {
    // Sound implementation would require platform-specific code
    // For now, just use haptic feedback
    HapticFeedback.lightImpact();
  }

  static void _showNotification(int trainNumber, DateTime departureTime) {
    // Notification implementation would require platform-specific code
    debugPrint('ALARM: Görev $trainNumber - Kalkýþ: ${TimeCalculator.formatTime(departureTime)}');
  }

  static void setAlarmSettings({
    int? threshold,
    int? mode,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    if (threshold != null) _alarmThreshold = threshold;
    if (mode != null) _alarmMode = mode;
    if (soundEnabled != null) _soundEnabled = soundEnabled;
    if (vibrationEnabled != null) _vibrationEnabled = vibrationEnabled;
  }

  static Map<String, dynamic> getAlarmSettings() {
    return {
      'threshold': _alarmThreshold,
      'mode': _alarmMode,
      'soundEnabled': _soundEnabled,
      'vibrationEnabled': _vibrationEnabled,
    };
  }
}
