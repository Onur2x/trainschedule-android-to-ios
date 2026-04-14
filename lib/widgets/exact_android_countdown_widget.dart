import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/time_calculator.dart';
import '../services/alarm_manager.dart';
import '../services/train_schedule_service.dart';
import '../providers/train_schedule_provider.dart';

class ExactAndroidCountdownWidget extends StatefulWidget {
  const ExactAndroidCountdownWidget({Key? key}) : super(key: key);

  @override
  State<ExactAndroidCountdownWidget> createState() => _ExactAndroidCountdownWidgetState();
}

class _ExactAndroidCountdownWidgetState extends State<ExactAndroidCountdownWidget> {
  Timer? _timer;
  String _countdownText = '--:--:--';
  String _hintText = 'Tur bulunamadı';
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

  void _updateCountdown() async {
    final now = DateTime.now();
    
    // Provider'dan seçili görev numarasýný al
    final provider = context.read<TrainScheduleProvider>();
    final selectedTrainNumber = provider.selectedTrainNumber ?? 1;
    
    // Gerçek veriyi yükle
    final timetables = await TrainScheduleService.getTimetables();
    
    // Görev numarasýna göre filtrele
    final filteredTimetables = timetables.where((t) => t.trainNumber == selectedTrainNumber).toList();
    
    // direction 0 = uç istasyon kalkýþlarý
    final departureTimes = filteredTimetables
        .where((t) => t.direction == 0)
        .map((t) => TimeCalculator.parseTime(t.time))
        .where((time) => time != null)
        .cast<DateTime>()
        .toList();

    // Sonraki kalkýþý bul
    _nextDeparture = TimeCalculator.findNextDeparture(departureTimes, now);

    if (_nextDeparture != null) {
      final remainingSeconds = TimeCalculator.secondsUntil(now, _nextDeparture!);
      _countdownText = TimeCalculator.formatHhMmSs(remainingSeconds);
      
      // Orijinal saat formatýný bul
      final originalTime = filteredTimetables
          .where((t) => t.direction == 0)
          .firstWhere((t) => TimeCalculator.parseTime(t.time) == _nextDeparture,
              orElse: () => filteredTimetables.first);
      
      _hintText = 'Bir sonraki tur saati: ${originalTime.time}';

      // Alarm kontrolü
      AlarmManager.evaluateAlarm(_nextDeparture!, selectedTrainNumber);
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
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
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
