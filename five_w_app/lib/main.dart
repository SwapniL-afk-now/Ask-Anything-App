import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/profession_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState(apiService: ApiService())),
      ],
      child: const FiveWApp(),
    ),
  );
}

class FiveWApp extends StatelessWidget {
  const FiveWApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '5W1H Analysis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1392EC)),
        useMaterial3: true,
      ),
      home: ProfessionScreen(),
    );
  }
}
