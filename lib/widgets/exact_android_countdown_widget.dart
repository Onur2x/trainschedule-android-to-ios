import 'package:flutter/material.dart';
import 'dart:async';
import '../services/time_calculator.dart';
import '../services/alarm_manager.dart';

class ExactAndroidCountdownWidget extends StatefulWidget {
  const ExactAndroidCountdownWidget({Key? key}) : super(key: key);

  @override
  State<ExactAndroidCountdownWidget> createState() => _ExactAndroidCountdownWidgetState();
}

class _ExactAndroidCountdownWidgetState extends State<ExactAndroidCountdownWidget> {
  Timer? _timer;
  String _countdownText = '--:--:--';
  String _hintText = 'Tur bulunamadý';
  DateTime? _nextDeparture;
  List<DateTime> _departureTimes = [];

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final now = DateTime.now();
    
    // Örnek kalkýþ saatleri (gerçek veriden gelmeli)
    _departureTimes = [
      DateTime(now.year, now.month, now.day, 6, 0, 0),
      DateTime(now.year, now.month, now.day, 6, 8, 29),
      DateTime(now.year, now.month, now.day, 6, 16, 58),
      DateTime(now.year, now.month, now.day, 6, 25, 27),
      DateTime(now.year, now.month, now.day, 6, 33, 56),
      DateTime(now.year, now.month, now.day, 6, 42, 25),
      DateTime(now.year, now.month, now.day, 6, 50, 54),
      DateTime(now.year, now.month, now.day, 7, 7, 52),
      DateTime(now.year, now.month, now.day, 7, 15, 8),
      DateTime(now.year, now.month, now.day, 7, 22, 24),
      DateTime(now.year, now.month, now.day, 7, 29, 40),
      DateTime(now.year, now.month, now.day, 7, 36, 56),
    ];

    // Sonraki kalkýþý bul
    _nextDeparture = TimeCalculator.findNextDeparture(_departureTimes, now);

    if (_nextDeparture != null) {
      final remainingSeconds = TimeCalculator.secondsUntil(now, _nextDeparture!);
      _countdownText = TimeCalculator.formatHhMmSs(remainingSeconds);
      _hintText = 'Bir sonraki tur saati: ${TimeCalculator.formatTime(_nextDeparture!)}';

      // Alarm kontrolü
      AlarmManager.evaluateAlarm(_nextDeparture!, 1);
    } else {
      _countdownText = '--:--:--';
      _hintText = 'Bugünkü turlar bitti';
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bir sonraki tura kalan süre',
              style: TextStyle(
                color: Color(0xFF1A237E),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AlarmManager.isRinging 
                      ? const Color(0xFFE74C3C)
                      : const Color(0xFFE8EAF6),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AlarmManager.isRinging ? Icons.notifications_active : Icons.timer,
                    color: AlarmManager.isRinging 
                        ? const Color(0xFFE74C3C)
                        : const Color(0xFF6366F1),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _countdownText,
                    style: TextStyle(
                      color: AlarmManager.isRinging 
                          ? const Color(0xFFE74C3C)
                          : const Color(0xFF6366F1),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _hintText,
              style: const TextStyle(
                color: Color(0xFF6C757D),
                fontSize: 14,
              ),
            ),
            if (AlarmManager.isRinging) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        AlarmManager.stopAlarm();
                      },
                      icon: const Icon(Icons.stop),
                      label: const Text('Alarm Durdur'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE74C3C),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
