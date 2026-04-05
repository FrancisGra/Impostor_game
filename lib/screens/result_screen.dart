import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/game_provider.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    if (gameState == null) return const SizedBox.shrink();

    final impostors =
        gameState.players.where((p) => p.isImpostor).toList();
    final crewmates =
        gameState.players.where((p) => !p.isImpostor).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                '¡Fin de la Ronda!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),

              // Revelar palabra
              _RevealCard(
                secretWord: gameState.secretWord,
                categoryName: gameState.config.category.name,
              ),
              const SizedBox(height: 24),

              // Impostores
              _RoleListCard(
                title: '🕵️ Impostores',
                names: impostors.map((p) => p.name).toList(),
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),

              // Tripulantes
              _RoleListCard(
                title: '✅ Tripulantes',
                names: crewmates.map((p) => p.name).toList(),
                color: Colors.greenAccent,
              ),
              const SizedBox(height: 32),

              // Acciones
              ElevatedButton.icon(
                key: const Key('btn_restart_same'),
                icon: const Icon(Icons.refresh),
                label: const Text('Otra Ronda (mismos jugadores)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () =>
                    ref.read(gameProvider.notifier).restartSamePlayers(),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('btn_new_game'),
                icon: const Icon(Icons.home),
                label: const Text('Nueva Partida'),
                onPressed: () => ref.read(gameProvider.notifier).newGame(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets internos
// ---------------------------------------------------------------------------

class _RevealCard extends StatelessWidget {
  const _RevealCard({super.key, required this.secretWord, required this.categoryName});

  final String secretWord;
  final String categoryName;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Text(
              'La palabra secreta era:',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              secretWord,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Categoría: $categoryName',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleListCard extends StatelessWidget {
  const _RoleListCard({
    super.key,
    required this.title,
    required this.names,
    required this.color,
  });

  final String title;
  final List<String> names;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...names.map(
              (name) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 18, color: color),
                    const SizedBox(width: 8),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
