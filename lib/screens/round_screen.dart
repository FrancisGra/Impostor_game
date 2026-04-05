import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/game_provider.dart';

class RoundScreen extends ConsumerStatefulWidget {
  const RoundScreen({super.key});

  @override
  ConsumerState<RoundScreen> createState() => _RoundScreenState();
}

class _RoundScreenState extends ConsumerState<RoundScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(gameProvider.notifier).tickTimer();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    if (gameState == null) return const SizedBox.shrink();

    final hasTimer = gameState.config.hasTimer;
    final remaining = gameState.secondsRemaining;
    final isRunning = gameState.timerRunning;
    final timeUp = hasTimer && remaining <= 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado
              Text(
                '¡Partida en curso!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Categoría: ${gameState.config.category.name}',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white60),
              ),
              const Spacer(),

              // Temporizador
              if (hasTimer) ...[
                _TimerDisplay(
                  seconds: remaining,
                  isRunning: isRunning,
                  timeUp: timeUp,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      key: const Key('btn_toggle_timer'),
                      icon: Icon(
                        isRunning ? Icons.pause : Icons.play_arrow,
                      ),
                      label: Text(isRunning ? 'Pausar' : 'Continuar'),
                      onPressed: timeUp
                          ? null
                          : () => ref
                              .read(gameProvider.notifier)
                              .toggleTimer(),
                    ),
                  ],
                ),
              ] else ...[
                const Icon(Icons.timer_off, size: 80, color: Colors.white30),
                const SizedBox(height: 16),
                Text(
                  'Sin límite de tiempo',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white60),
                ),
              ],

              const Spacer(),

              // Lista de jugadores
              _PlayersList(
                players: gameState.players.map((p) => p.name).toList(),
              ),
              const SizedBox(height: 32),

              // Botón terminar ronda
              ElevatedButton.icon(
                key: const Key('btn_end_round'),
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('Terminar Ronda'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => ref.read(gameProvider.notifier).endRound(),
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

class _TimerDisplay extends StatelessWidget {
  const _TimerDisplay({
    required this.seconds,
    required this.isRunning,
    required this.timeUp,
  });

  final int seconds;
  final bool isRunning;
  final bool timeUp;

  String _format(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final color = timeUp
        ? Colors.redAccent
        : isRunning
            ? Colors.greenAccent
            : Colors.white70;

    return Column(
      children: [
        Text(
          _format(seconds),
          style: TextStyle(
            fontSize: 96,
            fontWeight: FontWeight.bold,
            color: color,
            fontFeatures: const [],
          ),
        ),
        if (timeUp)
          const Text(
            '¡Tiempo!',
            style: TextStyle(
              fontSize: 24,
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}

class _PlayersList extends StatelessWidget {
  const _PlayersList({required this.players});
  final List<String> players;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jugadores (${players.length}):',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: players
              .map(
                (name) => Chip(
                  avatar: const Icon(Icons.person, size: 16),
                  label: Text(name),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
