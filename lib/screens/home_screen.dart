import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/game_provider.dart';
import 'setup_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo / título
              Icon(
                Icons.people_alt,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'El Impostor',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '¿Quién es el impostor?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                key: const Key('btn_nueva_partida'),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Nueva Partida'),
                onPressed: () => _goToSetup(context, ref),
              ),
              const SizedBox(height: 16),
              _HowToPlayButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _goToSetup(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProviderScope(
          parent: ProviderScope.containerOf(context),
          child: const SetupScreen(),
        ),
      ),
    );
  }
}

class _HowToPlayButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.help_outline),
      label: const Text('¿Cómo se juega?'),
      onPressed: () => _showHowToPlay(context),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cómo se juega?'),
        content: const SingleChildScrollView(
          child: Text(
            '1. Configura la partida: elige jugadores, impostores y categoría.\n\n'
            '2. Pasa el teléfono a cada jugador en secreto para que vea su rol.\n\n'
            '3. Los tripulantes ven la palabra secreta. El impostor NO la recibe.\n\n'
            '4. Durante la ronda, todos hablan sobre la palabra sin revelarla.\n\n'
            '5. Voten quién creen que es el impostor. ¡El impostor gana si no lo descubren!',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
