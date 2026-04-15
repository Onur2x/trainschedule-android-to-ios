import 'package:flutter/material.dart';
import '../models/timetable_entity.dart';
import '../services/time_calculator.dart';
import '../services/settings_service.dart';

class ExactAndroidGridWidget extends StatelessWidget {
  const ExactAndroidGridWidget({
    Key? key,
    required this.schedules,
  }) : super(key: key);

  final List<TimetableEntity> schedules;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: SettingsService.loadSettings(),
      builder: (context, snapshot) {
        final firstStationName = snapshot.data?['firstStationName'] ?? 'PARSELLER';
        final lastStationName = snapshot.data?['lastStationName'] ?? 'BOSTANCI';
        
        if (schedules.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            child: const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.train,
                    size: 64,
                    color: Color(0xFF6C757D),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Bu görev numarasına ait çizelge bulunamadı',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6C757D),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Group by runId
        final groupedSchedules = <int, List<TimetableEntity>>{};
        for (final schedule in schedules) {
          if (!groupedSchedules.containsKey(schedule.runId)) {
            groupedSchedules[schedule.runId] = [];
          }
          groupedSchedules[schedule.runId]!.add(schedule);
        }

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE3F2FD),
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE8EAF6),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        firstStationName,
                        style: const TextStyle(
                          color: Color(0xFF1A237E),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Saat',
                        style: const TextStyle(
                          color: Color(0xFF1A237E),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        lastStationName,
                        style: const TextStyle(
                          color: Color(0xFF1A237E),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Saat',
                        style: const TextStyle(
                          color: Color(0xFF1A237E),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Dinlenme',
                        style: const TextStyle(
                          color: Color(0xFF1A237E),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Grid Rows - Android mantýðýna göre
              ...groupedSchedules.entries.map((entry) {
                final runId = entry.key;
                final runSchedules = entry.value;
                final now = DateTime.now();
                
                // Android mantýðý: direction 0 = outgoing, direction 1 = incoming
                // Saatlere gore sýrala (kronolojik)
                final outgoingSchedules = runSchedules.where((s) => s.direction == 0).toList()
                  ..sort((a, b) => TimeCalculator.parseTime(a.time).compareTo(TimeCalculator.parseTime(b.time)));
                final incomingSchedules = runSchedules.where((s) => s.direction == 1).toList()
                  ..sort((a, b) => TimeCalculator.parseTime(a.time).compareTo(TimeCalculator.parseTime(b.time)));
                
                return Column(
                  children: List.generate(
                    outgoingSchedules.length > incomingSchedules.length 
                        ? outgoingSchedules.length 
                        : incomingSchedules.length,
                    (index) {
                      final outgoingSchedule = index < outgoingSchedules.length 
                          ? outgoingSchedules[index] 
                          : null;
                      final incomingSchedule = index < incomingSchedules.length 
                          ? incomingSchedules[index] 
                          : null;
                      final isEvenRow = index % 2 == 0;
                      
                      // Calculate active based on current time
                      final outgoingTime = outgoingSchedule != null 
                          ? TimeCalculator.parseTime(outgoingSchedule.time) 
                          : null;
                      final incomingTime = incomingSchedule != null 
                          ? TimeCalculator.parseTime(incomingSchedule.time) 
                          : null;
                          
                      // Sonraki kalkýþ saatini bul (dinlenme hesabý için)
                      // Dinlenme = Sonraki PARSELLER kalkýþ - (Mevcut BOSTANCI varýþ + 25.5 dk)
                      DateTime? nextOutgoingTime;
                      if (index + 1 < outgoingSchedules.length) {
                        nextOutgoingTime = TimeCalculator.parseTime(outgoingSchedules[index + 1].time);
                      }
                          
                      final isActive = (outgoingTime != null && !TimeCalculator.isPast(outgoingTime, now)) ||
                                     (incomingTime != null && !TimeCalculator.isPast(incomingTime, now));
                      
                      // Geçmiþ saat kontrolü - hem uç hem son istasyon geçmiþte mi?
                      final isPastRow = (outgoingTime != null && TimeCalculator.isPast(outgoingTime, now)) &&
                                        (incomingTime != null && TimeCalculator.isPast(incomingTime, now));
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isPastRow 
                              ? const Color(0xFFE8E8E8)  // Geçmiþ satýrlar için soluk gri
                              : (isEvenRow ? const Color(0xFFFFFFFF) : const Color(0xFFF8F9FA)),
                          border: Border(
                            bottom: BorderSide(
                              color: const Color(0xFFE8EAF6),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Uç Istasyon (sol) - outgoing
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isPastRow
                                      ? const Color(0xFFD0D0D0)  // Geçmiþ için koyu gri
                                      : (isActive 
                                          ? const Color(0xFF6366F1)
                                          : const Color(0xFFF3E5F5)),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isPastRow
                                        ? const Color(0xFFBDBDBD)
                                        : (isActive 
                                            ? const Color(0xFF6366F1)
                                            : const Color(0xFFE8EAF6)),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  firstStationName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isPastRow
                                        ? const Color(0xFF757575)  // Geçmiþ için soluk metin
                                        : (isActive 
                                            ? Colors.white
                                            : const Color(0xFF1A237E)),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            
                            // Uç Saat (sol)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (outgoingTime != null && TimeCalculator.isPast(outgoingTime, now))
                                      ? const Color(0xFFE0E0E0)  // Geçmiþ saat için soluk
                                      : (isActive 
                                          ? const Color(0xFF6366F1)
                                          : const Color(0xFFE8F5E8)),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: (outgoingTime != null && TimeCalculator.isPast(outgoingTime, now))
                                        ? const Color(0xFFBDBDBD)
                                        : (isActive 
                                            ? const Color(0xFF6366F1)
                                            : const Color(0xFFE8EAF6)),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  outgoingTime != null 
                                      ? TimeCalculator.formatTime(outgoingTime)
                                      : '-',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: (outgoingTime != null && TimeCalculator.isPast(outgoingTime, now))
                                        ? const Color(0xFF9E9E9E)  // Geçmiþ saat metni
                                        : (isActive 
                                            ? Colors.white
                                            : const Color(0xFF1A237E)),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            
                            // Son Istasyon (sað)
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isPastRow
                                      ? const Color(0xFFD0D0D0)  // Geçmiþ için koyu gri
                                      : (isActive 
                                          ? const Color(0xFF6366F1)
                                          : const Color(0xFFF3E5F5)),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isPastRow
                                        ? const Color(0xFFBDBDBD)
                                        : (isActive 
                                            ? const Color(0xFF6366F1)
                                            : const Color(0xFFE8EAF6)),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  lastStationName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isPastRow
                                        ? const Color(0xFF757575)  // Geçmiþ için soluk metin
                                        : (isActive 
                                            ? Colors.white
                                            : const Color(0xFF1A237E)),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            
                            // Son Saat (sað)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (incomingTime != null && TimeCalculator.isPast(incomingTime, now))
                                      ? const Color(0xFFE0E0E0)  // Geçmiþ saat için soluk
                                      : (isActive 
                                          ? const Color(0xFF6366F1)
                                          : const Color(0xFFE8F5E8)),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: (incomingTime != null && TimeCalculator.isPast(incomingTime, now))
                                        ? const Color(0xFFBDBDBD)
                                        : (isActive 
                                            ? const Color(0xFF6366F1)
                                            : const Color(0xFFE8EAF6)),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  incomingTime != null 
                                      ? TimeCalculator.formatTime(incomingTime)
                                      : '-',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: (incomingTime != null && TimeCalculator.isPast(incomingTime, now))
                                        ? const Color(0xFF9E9E9E)  // Geçmiþ saat metni
                                        : (isActive 
                                            ? Colors.white
                                            : const Color(0xFF1A237E)),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            
                            // Dinlenme (sað)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive 
                                      ? const Color(0xFF6366F1)
                                      : const Color(0xFFFCE4EC),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isActive 
                                        ? const Color(0xFF6366F1)
                                        : const Color(0xFFE8EAF6),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _calculateRestTime(outgoingTime, incomingTime, nextOutgoingTime),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isPastRow
                                        ? const Color(0xFF9E9E9E)
                                        : (isActive 
                                            ? Colors.white
                                            : const Color(0xFF1A237E)),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  String _calculateRestTime(DateTime? outgoingTime, DateTime? incomingTime, DateTime? nextOutgoingTime) {
    // Dinlenme hesaplama:
    // Mevcut satýr: PARSELLER -> BOSTANCI (incomingTime = BOSTANCI varýþ)
    // Sonraki satýr: PARSELLER (nextOutgoingTime = sonraki PARSELLER kalkýþ)
    // Formül: Sonraki PARSELLER kalkýþ - (BOSTANCI varýþ + 25.5 dk)
    if (incomingTime == null || nextOutgoingTime == null) {
      return '-';
    }
    
    // BOSTANCI varýþ saatine 25.5 dk ekle
    final restStart = incomingTime.add(const Duration(minutes: 25, seconds: 30)); // 25.5 dk
    
    // Sonraki PARSELLER kalkýþtan çýkar
    final difference = nextOutgoingTime.difference(restStart);
    
    if (difference.isNegative) {
      return '-';
    }

    // Sadece dakika olarak göster (saat yoksa sadece dakika)
    final totalMinutes = difference.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0) {
      return '${hours}sa ${minutes}dk';
    } else {
      return '${minutes}dk';
    }
  }
}
