import 'package:flutter/material.dart';
import '../models/timetable_entity.dart';

class ExactAndroidGridWidget extends StatelessWidget {
  const ExactAndroidGridWidget({
    Key? key,
    required this.schedules,
  }) : super(key: key);

  final List<TimetableEntity> schedules;

  @override
  Widget build(BuildContext context) {
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
                'Bu görev numarasýna ait çizelge bulunamadý',
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

    return Column(
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
                  'Ýstasyon',
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
                  'Ýstasyon',
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
        
        // Grid Rows
        ...groupedSchedules.entries.map((entry) {
          final runId = entry.key;
          final runSchedules = entry.value;
          
          return Column(
            children: runSchedules.asMap().entries.map((rowEntry) {
              final index = rowEntry.key;
              final schedule = rowEntry.value;
              final isEvenRow = index % 2 == 0;
              final isActive = false; // TODO: Calculate active based on current time
              
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: isEvenRow ? const Color(0xFFFFFFFF) : const Color(0xFFF8F9FA),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFFE8EAF6),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // First Station
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive 
                              ? const Color(0xFF6366F1)
                              : schedule.direction == 0 
                                  ? const Color(0xFFF3E5F5)
                                  : const Color(0xFFE8F5E8),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isActive 
                                ? const Color(0xFF6366F1)
                                : const Color(0xFFE8EAF6),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          schedule.station,
                          style: TextStyle(
                            fontSize: 13,
                            color: isActive 
                                ? Colors.white
                                : const Color(0xFF1A237E),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    // First Time
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive 
                              ? const Color(0xFF6366F1)
                              : const Color(0xFFE8F5E8),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isActive 
                                ? const Color(0xFF6366F1)
                                : const Color(0xFFE8EAF6),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          schedule.time,
                          style: TextStyle(
                            fontSize: 13,
                            color: isActive 
                                ? Colors.white
                                : const Color(0xFF1A237E),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    // Second Station
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive 
                              ? const Color(0xFF6366F1)
                              : schedule.direction == 1 
                                  ? const Color(0xFFF3E5F5)
                                  : const Color(0xFFE8F5E8),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isActive 
                                ? const Color(0xFF6366F1)
                                : const Color(0xFFE8EAF6),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          schedule.station,
                          style: TextStyle(
                            fontSize: 13,
                            color: isActive 
                                ? Colors.white
                                : const Color(0xFF1A237E),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    // Second Time
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive 
                              ? const Color(0xFF6366F1)
                              : const Color(0xFFE8F5E8),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isActive 
                                ? const Color(0xFF6366F1)
                                : const Color(0xFFE8EAF6),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          schedule.time,
                          style: TextStyle(
                            fontSize: 13,
                            color: isActive 
                                ? Colors.white
                                : const Color(0xFF1A237E),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    // Rest Time
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
                          _calculateRestTime(runSchedules, index),
                          style: TextStyle(
                            fontSize: 13,
                            color: isActive 
                                ? Colors.white
                                : const Color(0xFF1A237E),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }).toList(),
      ],
    );
  }

  String _calculateRestTime(List<TimetableEntity> runSchedules, int currentIndex) {
    if (currentIndex >= runSchedules.length - 1) {
      return '-';
    }
    
    final currentSchedule = runSchedules[currentIndex];
    final nextSchedule = runSchedules[currentIndex + 1];
    
    // Simple rest time calculation
    final currentTime = currentSchedule.time.split(':');
    final nextTime = nextSchedule.time.split(':');
    
    if (currentTime.length >= 2 && nextTime.length >= 2) {
      final currentMinutes = int.parse(currentTime[0]) * 60 + int.parse(currentTime[1]);
      final nextMinutes = int.parse(nextTime[0]) * 60 + int.parse(nextTime[1]);
      
      final restMinutes = nextMinutes - currentMinutes;
      if (restMinutes > 0) {
        final hours = restMinutes ~/ 60;
        final minutes = restMinutes % 60;
        return '${hours}sa ${minutes}dk';
      }
    }
    
    return '-';
  }
}
