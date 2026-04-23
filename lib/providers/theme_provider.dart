import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme state provider - dark/light mode manage karta hai
/// User ka preference yahan se access hota hai
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  /// Toggle between dark and light mode
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  /// Set specific theme mode
  void setTheme(ThemeMode mode) {
    state = mode;
  }

  /// Check if dark mode is active
  bool get isDarkMode => state == ThemeMode.dark;
}

/// Global theme notifier provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Convenience provider for checking dark mode
final isDarkModeProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider) == ThemeMode.dark;
});
