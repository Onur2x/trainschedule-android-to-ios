import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/train_schedule_provider.dart';
import '../services/alarm_manager.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _firstStationController = TextEditingController();
  final TextEditingController _lastStationController = TextEditingController();
  final TextEditingController _alarmThresholdController = TextEditingController();
  
  bool _alarmEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkTheme = false;
  int _alarmMode = AlarmManager.MODE_ONCE;
  int _alarmThreshold = 300; // 5 dakika
  String _selectedAlarmSound = 'Klasik Zil';
  bool _showUpdatePreview = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final settings = await SettingsService.loadSettings();
    
    setState(() {
      _firstStationController.text = settings['firstStationName'] ?? 'UÇ ÝSTASYON';
      _lastStationController.text = settings['lastStationName'] ?? 'SON ÝSTASYON';
      _alarmEnabled = settings['alarmEnabled'] ?? true;
      _soundEnabled = settings['alarmSoundEnabled'] ?? true;
      _vibrationEnabled = settings['alarmVibrationEnabled'] ?? true;
      _darkTheme = settings['darkTheme'] ?? false;
      _alarmThreshold = settings['alarmThreshold'] ?? 300;
      _alarmMode = settings['alarmMode'] ?? AlarmManager.MODE_ONCE;
      _selectedAlarmSound = settings['alarmSound'] ?? 'Klasik Zil';
    });
  }

  void _saveSettings() async {
    final firstStation = _firstStationController.text.trim();
    final lastStation = _lastStationController.text.trim();
    final thresholdText = _alarmThresholdController.text.trim();
    final alarmThreshold = int.tryParse(thresholdText) ?? 300;

    if (firstStation.isEmpty || lastStation.isEmpty) {
      _showErrorDialog('Eksik Bilgi', 'Ýstasyon adlarý boþ býrakýlamaz.');
      return;
    }

    if (alarmThreshold < 1 || alarmThreshold > 3600) {
      _showErrorDialog('Geçersiz Deðer', 'Alarm eþiði 1 ile 3600 saniye arasýnda olmalýdýr.');
      return;
    }

    // Ayarlarý kaydet
    await SettingsService.saveSettings(
      firstStationName: firstStation,
      lastStationName: lastStation,
      alarmEnabled: _alarmEnabled,
      alarmSoundEnabled: _soundEnabled,
      alarmVibrationEnabled: _vibrationEnabled,
      alarmThreshold: alarmThreshold,
      alarmMode: _alarmMode,
      alarmSound: _selectedAlarmSound,
      darkTheme: _darkTheme,
    );
    
    // AlarmManager'a bildirim
    AlarmManager.setAlarmSettings(
      threshold: alarmThreshold,
      mode: _alarmMode,
      soundEnabled: _soundEnabled,
      vibrationEnabled: _vibrationEnabled,
      alarmEnabled: _alarmEnabled,
    );
    
    _showSuccessDialog('Baþarýldý', 'Ayarlar kaydedildi!');
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showAlarmSoundDialog() {
    final alarmSounds = [
      'Klasik Zil',
      'Tren Düdük',
      'Saat Zili',
      'Yumuþak Melodi',
      'Dijital Bip',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alarm Sesini Seç'),
        content: SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: alarmSounds.length,
            itemBuilder: (context, index) {
              final sound = alarmSounds[index];
              return ListTile(
                title: Text(sound),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedAlarmSound = sound;
                  });
                },
                trailing: Radio<String>(
                  value: sound,
                  groupValue: _selectedAlarmSound,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedAlarmSound = value;
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ýptal'),
          ),
        ],
      ),
    );
  }

  void _showAlarmModeDialog() {
    final alarmModes = [
      'Bir kez çal',
      'Sürekli çal',
      'Her dakika çal',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alarm Davranýþý'),
        content: SizedBox(
          height: 150,
          child: ListView.builder(
            itemCount: alarmModes.length,
            itemBuilder: (context, index) {
              final mode = alarmModes[index];
              return ListTile(
                title: Text(mode),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _alarmMode = index;
                  });
                },
                trailing: Radio<String>(
                  value: alarmModes[index],
                  groupValue: _getAlarmModeString(_alarmMode),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _alarmMode = _getAlarmModeFromString(value);
                      });
                    }
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ýptal'),
          ),
        ],
      ),
    );
  }

  String _getAlarmModeString(int mode) {
    switch (mode) {
      case AlarmManager.MODE_ONCE:
        return 'Bir kez çal';
      case AlarmManager.MODE_CONTINUOUS:
        return 'Sürekli çal';
      case AlarmManager.MODE_EVERY_MINUTE:
        return 'Her dakika çal';
      default:
        return 'Bir kez çal';
    }
  }

  int _getAlarmModeFromString(String modeString) {
    switch (modeString) {
      case 'Bir kez çal':
        return AlarmManager.MODE_ONCE;
      case 'Sürekli çal':
        return AlarmManager.MODE_CONTINUOUS;
      case 'Her dakika çal':
        return AlarmManager.MODE_EVERY_MINUTE;
      default:
        return AlarmManager.MODE_ONCE;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Genel Ayarlar
            Card(
              elevation: 6,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(
                  color: const Color(0xFFE8EAF6),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                    'Genel Ayarlar',
                    style: TextStyle(
                      color: Color(0xFF1A237E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                    const SizedBox(height: 8),
                    const Text(
                    'Ýstasyon isimleri ve alarm davranýþýný buradan yönetebilirsiniz.',
                    style: TextStyle(
                      color: Color(0xFF6C757D),
                      fontSize: 14,
                    ),
                  ),
                    const SizedBox(height: 12),
                    
                    // Uç Ýstasyon
                    TextField(
                      controller: _firstStationController,
                      decoration: const InputDecoration(
                        labelText: 'Uç istasyon adý',
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Son Ýstasyon
                    TextField(
                      controller: _lastStationController,
                      decoration: const InputDecoration(
                        labelText: 'Son istasyon adý',
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Alarm Ayarlarý
            Card(
              elevation: 6,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(
                  color: const Color(0xFFE8EAF6),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alarm Ayarlarý',
                    style: TextStyle(
                      color: Color(0xFF1A237E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                    const SizedBox(height: 8),
                    
                    // Alarm açýk/kapatý
                    SwitchListTile(
                      title: const Text('Alarm açýk'),
                      value: _alarmEnabled,
                      onChanged: (value) {
                        setState(() {
                          _alarmEnabled = value;
                        });
                        AlarmManager.setAlarmSettings(
                          soundEnabled: _soundEnabled,
                          vibrationEnabled: _vibrationEnabled,
                          alarmEnabled: _alarmEnabled,
                        );
                      },
                    ),
                    
                    // Karanlýk tema
                    SwitchListTile(
                      title: const Text('Karanlýk tema'),
                      value: _darkTheme,
                      onChanged: (value) {
                        _darkTheme = value;
                        // ThemeManager.setDarkModeEnabled(value);
                      },
                    ),
                    
                    // Alarm sesi
                    SwitchListTile(
                      title: const Text('Alarm sesi açýk'),
                      value: _soundEnabled,
                      onChanged: (value) {
                        setState(() {
                          _soundEnabled = value;
                        });
                        AlarmManager.setAlarmSettings(
                          soundEnabled: _soundEnabled,
                          vibrationEnabled: _vibrationEnabled,
                          alarmEnabled: _alarmEnabled,
                        );
                      },
                    ),
                    
                    // Alarm titreþimi
                    SwitchListTile(
                      title: const Text('Alarm titreþimi açýk'),
                      value: _vibrationEnabled,
                      onChanged: (value) {
                        setState(() {
                          _vibrationEnabled = value;
                        });
                        AlarmManager.setAlarmSettings(
                          soundEnabled: _soundEnabled,
                          vibrationEnabled: _vibrationEnabled,
                          alarmEnabled: _alarmEnabled,
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Alarm sesi seçimi
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showAlarmSoundDialog(),
                            icon: const Icon(Icons.music_note),
                            label: const Text('Alarm Sesini Deðiþ'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedAlarmSound,
                            style: const TextStyle(
                              color: Color(0xFF1A237E),
                              fontSize: 14,
                            ),
                          textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Alarm eþi
                    TextFormField(
                      controller: _alarmThresholdController,
                      decoration: const InputDecoration(
                        labelText: 'Alarm eþiði (saniye)',
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Güncelleme Ayarlarý
            Card(
              elevation: 6,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(
                  color: const Color(0xFFE8EAF6),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Veri ve Uygulama Güncellemeleri',
                    style: TextStyle(
                      color: Color(0xFF1A237E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    ),
                    const SizedBox(height: 8),
                    
                    const Text(
                      'Veri ve uygulama güncellemelerini buradan yönetebilirsiniz.',
                    style: TextStyle(
                      color: Color(0xFF6C757D),
                      fontSize: 14,
                    ),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Güncelleme kontrolü
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Güncelleme Kontrol Et'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Veri güncelleme
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Veri Güncelle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Veri Geri Yükle
            Card(
              elevation: 6,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(
                  color: const Color(0xFFE8EAF6),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Veri Geri Yükle',
                    style: TextStyle(
                      color: Color(0xFF1A237E),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Veri geri yükle
                            },
                            icon: const Icon(Icons.restore),
                            label: const Text('Veri Geri Yükle'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE74C3C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Önizleme gizle
                            },
                            icon: const Icon(Icons.preview),
                            label: const Text('Önizleme Göster'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9C27B0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Güncelleme Önizleme Kartý
            if (_showUpdatePreview)
              Card(
                elevation: 2,
                color: const Color(0xFFF8F9FA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFFE8EAF6),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Veri güncelleme önizleme',
                        style: TextStyle(
                          color: Color(0xFF1A237E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mevcut sürüm: v1\nYeni sürüm: v2\nKaynak satýr: 100\nGeçerli satýr: 150\nAtlanan satýr: 10\nTarife sayýsý: 2\nMükerrer kayýt: 0\nEksik yön çifti: 0\nEksik TTID eþleþmesi: 0',
                        style: TextStyle(
                          color: Color(0xFF424242),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showUpdatePreview = false;
                              });
                            },
                            child: const Text('Kapat'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Güncellemeyi uygula
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Güncellemeyi Uygula'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Kaydet Butonu
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text('Ayarlarlarý Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
