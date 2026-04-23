// lib/main.dart
// GAX Forge - Entry Point

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/app_models.dart';
import 'screens/home/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  // Init Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(WidgetPropertyAdapter());
  Hive.registerAdapter(CanvasScreenAdapter());
  Hive.registerAdapter(GaxProjectAdapter());

  // Open boxes
  await Hive.openBox<GaxProject>('projects');

  runApp(
    const ProviderScope(
      child: GaxForgeApp(),
    ),
  );
}

class GaxForgeApp extends ConsumerWidget {
  const GaxForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'GAX Forge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
