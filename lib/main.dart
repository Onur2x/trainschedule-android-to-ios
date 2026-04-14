import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/train_schedule_provider.dart';
import 'screens/exact_android_screen.dart';

void main() {
  runApp(const TrainScheduleApp());
}

class TrainScheduleApp extends StatelessWidget {
  const TrainScheduleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrainScheduleProvider()),
      ],
      child: MaterialApp(
        title: 'GÖREV NO TAKÝBÝ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            primary: const Color(0xFF6366F1),
            secondary: const Color(0xFF9C27B0),
            surface: const Color(0xFFFFFFFF),
            background: const Color(0xFFFAFBFF),
          ),
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF1A237E),
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Color(0xFF1A237E),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        home: const ExactAndroidScreen(),
      ),
    );
  }
}
