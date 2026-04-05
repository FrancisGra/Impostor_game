import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:impostor_game/main.dart';
import 'package:impostor_game/providers/game_provider.dart';
import 'package:impostor_game/screens/home_screen.dart';
import 'package:impostor_game/screens/result_screen.dart';
import 'package:impostor_game/screens/role_reveal_screen.dart';
import 'package:impostor_game/screens/round_screen.dart';
import 'package:impostor_game/data/categories.dart';
import 'package:impostor_game/models/game_config.dart';

/// Crea un [ProviderScope] con SharedPreferences vacías para tests.
Widget buildTestApp({Widget? home, GameState? initialGameState}) {
  SharedPreferences.setMockInitialValues({});
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWith(
        (ref) => throw UnimplementedError('Use FakeSharedPreferences'),
      ),
    ],
    child: MaterialApp(
      home: home ?? const HomeScreen(),
    ),
  );
}

/// Construye la app completa con ProviderScope y SharedPreferences mock.
Future<ProviderContainer> buildContainer() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );
  return container;
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('HomeScreen', () {
    testWidgets('muestra el título El Impostor', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const ImpostorApp(),
        ),
      );
      expect(find.text('El Impostor'), findsOneWidget);
    });

    testWidgets('muestra el botón Nueva Partida', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const ImpostorApp(),
        ),
      );
      expect(find.text('Nueva Partida'), findsOneWidget);
    });

    testWidgets('el botón ¿Cómo se juega? abre un diálogo', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const ImpostorApp(),
        ),
      );
      await tester.tap(find.text('¿Cómo se juega?'));
      await tester.pumpAndSettle();
      expect(find.text('¿Cómo se juega?'), findsWidgets);
      expect(find.text('Entendido'), findsOneWidget);
    });
  });

  group('ResultScreen', () {
    testWidgets('muestra la palabra secreta y botones de acción', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final config = GameConfig(
        playerNames: ['Alice', 'Bob', 'Carlos', 'Diana'],
        numImpostors: 1,
        category: kDefaultCategories.first,
        roundDurationSeconds: 0,
      );
      container.read(gameProvider.notifier).startGame(config);
      // Simular que todos los roles fueron revelados
      final state = container.read(gameProvider)!;
      for (var i = 0; i < state.players.length; i++) {
        container.read(gameProvider.notifier).revealRole();
        container.read(gameProvider.notifier).hideRole();
      }

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ResultScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('¡Fin de la Ronda!'), findsOneWidget);
      expect(find.text('La palabra secreta era:'), findsOneWidget);
      expect(find.text('Otra Ronda (mismos jugadores)'), findsOneWidget);
      expect(find.text('Nueva Partida'), findsOneWidget);
    });
  });

  group('AppNavigator', () {
    testWidgets('muestra HomeScreen cuando no hay partida', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const MaterialApp(home: AppNavigator()),
        ),
      );
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('navega a RoleRevealScreen cuando hay partida activa',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final config = GameConfig(
        playerNames: ['Alice', 'Bob', 'Carlos'],
        numImpostors: 1,
        category: kDefaultCategories.first,
      );
      container.read(gameProvider.notifier).startGame(config);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: AppNavigator()),
        ),
      );
      await tester.pump();

      expect(find.byType(RoleRevealScreen), findsOneWidget);
    });
  });
}
