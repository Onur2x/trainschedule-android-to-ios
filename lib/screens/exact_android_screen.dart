import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/train_schedule_provider.dart';
import '../models/timetable_entity.dart';
import '../widgets/exact_android_grid_widget.dart';
import '../widgets/exact_android_countdown_widget.dart';
import '../widgets/exact_android_update_widget.dart';
import '../widgets/exact_android_search_widget.dart';
import 'settings_screen.dart';

class ExactAndroidScreen extends StatefulWidget {
  const ExactAndroidScreen({Key? key}) : super(key: key);

  @override
  State<ExactAndroidScreen> createState() => _ExactAndroidScreenState();
}

class _ExactAndroidScreenState extends State<ExactAndroidScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF9C27B0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Toolbar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'GÖREV NO TAKÝBÝ',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF1A237E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Info button
                    IconButton(
                      onPressed: () => _showInfoDialog(),
                      icon: const Icon(Icons.info_outline),
                      color: const Color(0xFF1A237E),
                    ),
                    // Error button
                    IconButton(
                      onPressed: () => _showErrorDialog(),
                      icon: const Icon(Icons.error_outline),
                      color: const Color(0xFF1A237E),
                    ),
                    // Settings button
                    IconButton(
                      onPressed: () => _showSettingsDialog(),
                      icon: const Icon(Icons.settings_outlined),
                      color: const Color(0xFF1A237E),
                    ),
                  ],
                ),
              ),
              
              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                child: const Text(
                  'Canlý görev akýþý ve sonraki tur takibi',
                  style: TextStyle(
                    color: Color(0xFF424242),
                    fontSize: 13,
                  ),
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Search Card
              const ExactAndroidSearchWidget(),
              
              const SizedBox(height: 16),
              
              // Countdown Card
              const ExactAndroidCountdownWidget(),
              
              const SizedBox(height: 16),
              
              // Update Card
              const ExactAndroidUpdateWidget(),
              
              const SizedBox(height: 16),
              
              // Grid
              Expanded(
                child: Consumer<TrainScheduleProvider>(
                  builder: (context, provider, child) {
                    if (provider.filteredTimetables.isEmpty) {
                      return const Center(
                        child: Text(
                          'Görev numarasý girerek çizelge görüntüleyin',
                          style: TextStyle(
                            color: Color(0xFF1A237E),
                            fontSize: 16,
                          ),
                        ),
                      );
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
                          // TTID Selector
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Tarife seçimi',
                                  style: TextStyle(
                                    color: Color(0xFF1A237E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                DropdownButton<String>(
                                  value: 'Hafta Içi',
                                  items: const [
                                    DropdownMenuItem(value: 'Hafta Içi', child: Text('Hafta Içi')),
                                    DropdownMenuItem(value: 'Hafta Sonu', child: Text('Hafta Sonu')),
                                  ],
                                  onChanged: (value) {},
                                ),
                              ],
                            ),
                          ),
                          
                          // Grid
                          Expanded(
                            child: ExactAndroidGridWidget(
                              schedules: provider.filteredTimetables,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Genel Bilgiler'),
        content: const Text(
          'GÖREV NO TAKÝBÝ\n\n'
          'Versiyon: 1.0.0\n'
          'Geliþtirici: Onur\n\n'
          'Bu uygulama TCDD tren çizelgelerini göstermek için geliþtirilmiþtir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arýza Bildirimi'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView(
            children: const [
              ListTile(title: Text('Kayýtlý arýza bulunamadý')),
              ListTile(title: Text('Arýza bildirim sistemi Aktif')),
              ListTile(title: Text('Son kontrol: Bugün 14:30')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
}
