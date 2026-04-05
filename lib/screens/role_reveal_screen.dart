import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/game_provider.dart';

class RoleRevealScreen extends ConsumerWidget {
  const RoleRevealScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    if (gameState == null) return const SizedBox.shrink();

    final totalPlayers = gameState.players.length;
    final currentIndex = gameState.currentRevealIndex;
    final roleRevealed = gameState.roleRevealed;

    if (gameState.allRolesRevealed) {
      // Todos los roles revelados → navegación manejada por AppNavigator
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final player = gameState.currentPlayer!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progreso
              LinearProgressIndicator(
                value: (currentIndex) / totalPlayers,
                backgroundColor:
                    Theme.of(context).colorScheme.surface,
              ),
              const SizedBox(height: 8),
              Text(
                'Jugador ${currentIndex + 1} de $totalPlayers',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),

              if (!roleRevealed) ...[
                // Pantalla de "pasa el teléfono"
                _PassPhoneCard(playerName: player.name),
              ] else ...[
                // Pantalla de rol revelado
                _RoleCard(
                  playerName: player.name,
                  isImpostor: player.isImpostor,
                  secretWord:
                      player.isImpostor ? null : gameState.secretWord,
                  category: player.isImpostor
                      ? null
                      : gameState.config.category.name,
                ),
              ],

              const Spacer(),

              // Botón de acción
              if (!roleRevealed)
                ElevatedButton.icon(
                  key: const Key('btn_ver_rol'),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Ver mi rol'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () =>
                      ref.read(gameProvider.notifier).revealRole(),
                )
              else
                ElevatedButton.icon(
                  key: const Key('btn_ocultar_rol'),
                  icon: const Icon(Icons.visibility_off),
                  label: Text(
                    currentIndex + 1 < totalPlayers
                        ? 'Ocultar y pasar al siguiente'
                        : 'Ocultar y comenzar ronda',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () =>
                      ref.read(gameProvider.notifier).hideRole(),
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

class _PassPhoneCard extends StatelessWidget {
  const _PassPhoneCard({super.key, required this.playerName});
  final String playerName;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.smartphone, size: 80),
            const SizedBox(height: 24),
            Text(
              'Pasa el teléfono a',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              playerName,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Que nadie más vea la pantalla 👀',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white60),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    super.key,
    required this.playerName,
    required this.isImpostor,
    this.secretWord,
    this.category,
  });

  final String playerName;
  final bool isImpostor;
  final String? secretWord;
  final String? category;

  @override
  Widget build(BuildContext context) {
    final color =
        isImpostor ? Colors.redAccent : Colors.green;

    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: color.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              isImpostor ? Icons.person_off : Icons.verified_user,
              size: 80,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              playerName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 2),
              ),
              child: Text(
                isImpostor ? '🕵️ IMPOSTOR' : '✅ TRIPULANTE',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            if (!isImpostor && secretWord != null) ...[
              Text(
                'Categoría: ${category ?? ""}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white60),
              ),
              const SizedBox(height: 8),
              Text(
                'La palabra secreta es:',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                secretWord!,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                textAlign: TextAlign.center,
              ),
            ] else if (isImpostor) ...[
              Text(
                '¡No sabes la palabra!\nDescúbrela durante el juego.',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            Text(
              '⚠️ ¡Memoriza tu rol y no lo reveles!',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.orange),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
