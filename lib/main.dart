import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/game_provider.dart';
import 'screens/home_screen.dart';
import 'screens/role_reveal_screen.dart';
import 'screens/round_screen.dart';
import 'screens/result_screen.dart';
import 'models/game_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const ImpostorApp(),
    ),
  );
}

class ImpostorApp extends StatelessWidget {
  const ImpostorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El Impostor',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const AppNavigator(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1A1A2E),
        brightness: Brightness.dark,
        primary: const Color(0xFFE94560),
        secondary: const Color(0xFF0F3460),
        surface: const Color(0xFF16213E),
        onPrimary: Colors.white,
      ),
      useMaterial3: true,
      fontFamily: 'sans-serif',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

/// Navega entre pantallas según el estado del juego.
class AppNavigator extends ConsumerWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    if (gameState == null) {
      return const HomeScreen();
    }

    switch (gameState.phase) {
      case GamePhase.idle:
        return const HomeScreen();
      case GamePhase.roleReveal:
        return const RoleRevealScreen();
      case GamePhase.round:
        return const RoundScreen();
      case GamePhase.roundEnd:
        return const ResultScreen();
    }
  }
}
