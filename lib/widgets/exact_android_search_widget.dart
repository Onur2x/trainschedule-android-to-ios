import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/train_schedule_provider.dart';

class ExactAndroidSearchWidget extends StatefulWidget {
  const ExactAndroidSearchWidget({Key? key}) : super(key: key);

  @override
  State<ExactAndroidSearchWidget> createState() => _ExactAndroidSearchWidgetState();
}

class _ExactAndroidSearchWidgetState extends State<ExactAndroidSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _recentTrains = ['51','52', '53', '54', '55', '56', '57', '58', '59'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE8EAF6),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Text Input
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Görev numarası',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                helperText: 'Son kullanılan görevler önerilir',
                helperStyle: TextStyle(
                  color: Color(0xFF6C757D),
                  fontSize: 12,
                ),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                context.read<TrainScheduleProvider>().setTrainNumber(value);
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.read<TrainScheduleProvider>().loadTimetableForTrain(int.parse(value));
                  _addToRecentTrains(value);
                }
              },
            ),
            
            const SizedBox(height: 12),
            
            // Recent Trains
            if (_recentTrains.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recentTrains.map((train) {
                  return Chip(
                    label: Text(train),
                    backgroundColor: const Color(0xFFE3F2FD),
                    labelStyle: const TextStyle(color: Color(0xFF1A237E)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _recentTrains.remove(train);
                      });
                    },
                  );
                }).toList(),
              ),
            
            const SizedBox(height: 12),
            
            // Show Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  final trainNo = _controller.text;
                  if (trainNo.isNotEmpty) {
                    context.read<TrainScheduleProvider>().loadTimetableForTrain(int.parse(trainNo));
                    _addToRecentTrains(trainNo);
                  }
                },
                icon: const Icon(Icons.search),
                label: const Text('Göster'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToRecentTrains(String trainNo) {
    setState(() {
      _recentTrains.remove(trainNo);
      _recentTrains.insert(0, trainNo);
      if (_recentTrains.length > 8) {
        _recentTrains.removeLast();
      }
    });
  }
}
