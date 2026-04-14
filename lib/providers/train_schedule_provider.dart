import 'package:flutter/foundation.dart';
import '../models/timetable_entity.dart';
import '../services/train_schedule_service.dart';

class TrainScheduleProvider extends ChangeNotifier {
  TrainScheduleProvider() {
    _initialize();
  }

  // State variables
  List<TimetableEntity> _timetables = [];
  List<TimetableEntity> _filteredTimetables = [];
  int? _selectedTrainNumber;
  bool _isLoading = false;
  String _errorMessage = '';
  int _currentDataVersion = 1;

  // Getters
  List<TimetableEntity> get timetables => _timetables;
  List<TimetableEntity> get filteredTimetables => _filteredTimetables;
  int? get selectedTrainNumber => _selectedTrainNumber;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get currentDataVersion => _currentDataVersion;

  // Initialize data
  Future<void> _initialize() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _loadTimetables();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Veriler yüklenemedi: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load timetables
  Future<void> _loadTimetables() async {
    _timetables = await TrainScheduleService.getTimetables();
    _currentDataVersion = await TrainScheduleService.getCurrentDataVersion();
  }

  // Set train number
  void setTrainNumber(String trainNumber) {
    _selectedTrainNumber = int.tryParse(trainNumber);
    _filterTimetables();
    notifyListeners();
  }

  // Load timetable for train
  Future<void> loadTimetableForTrain(int trainNumber) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();
      
      _selectedTrainNumber = trainNumber;
      _filteredTimetables = await TrainScheduleService.getTimetableByTrainNumber(trainNumber);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Tren çizelgesi yüklenemedi: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter timetables
  void _filterTimetables() {
    if (_selectedTrainNumber != null) {
      _filteredTimetables = _timetables
          .where((t) => t.trainNumber == _selectedTrainNumber)
          .toList();
    } else {
      _filteredTimetables = [];
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
