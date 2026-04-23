import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/screens.dart';
import 'theme/app_theme.dart';

/// Gax Forge - Flutter UI Builder App
/// A drag-drop UI designer for Flutter applications
///
/// Features:
/// - Drag and drop widgets to design screens
/// - Edit widget properties with live preview
/// - Export working Dart code
/// - Save and load projects

void main() {
  runApp(
    const ProviderScope(
      child: GaxForgeApp(),
    ),
  );
}

/// Main application widget
class GaxForgeApp extends ConsumerWidget {
  const GaxForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Gax Forge',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeMode,

      // Initial screen
      home: const HomeScreen(),

      // Route configuration
      routes: {
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

/// Theme provider import for main.dart
/// Note: This is imported from providers.dart
import 'providers/providers.dart';
