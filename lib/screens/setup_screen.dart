import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/categories.dart';
import '../models/game_category.dart';
import '../models/game_config.dart';
import '../providers/game_provider.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  // Número de jugadores
  int _numPlayers = 4;

  // Impostores
  int _numImpostors = 1;

  // Nombres de jugadores
  late List<TextEditingController> _nameControllers;

  // Categoría seleccionada
  GameCategory _selectedCategory = kDefaultCategories.first;

  // Duración (minutos; 0 = sin temporizador)
  int _durationMinutes = 0;

  static const int _minPlayers = 3;
  static const int _maxPlayers = 15;

  @override
  void initState() {
    super.initState();
    _initControllers();

    // Intentar restaurar últimos nombres guardados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final saved = ref.read(gameProvider.notifier).savedPlayerNames;
      if (saved.isNotEmpty) {
        setState(() {
          _numPlayers = saved.length.clamp(_minPlayers, _maxPlayers);
          _initControllers();
          for (var i = 0; i < _numPlayers && i < saved.length; i++) {
            _nameControllers[i].text = saved[i];
          }
        });
      }
    });
  }

  void _initControllers() {
    _nameControllers = List.generate(
      _numPlayers,
      (i) => TextEditingController(text: 'Jugador ${i + 1}'),
    );
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  int get _maxImpostors => (_numPlayers / 2).floor();

  void _setNumPlayers(int n) {
    final newN = n.clamp(_minPlayers, _maxPlayers);
    setState(() {
      if (newN > _numPlayers) {
        for (var i = _numPlayers; i < newN; i++) {
          _nameControllers.add(TextEditingController(text: 'Jugador ${i + 1}'));
        }
      } else {
        for (var i = _numPlayers - 1; i >= newN; i--) {
          _nameControllers[i].dispose();
          _nameControllers.removeAt(i);
        }
      }
      _numPlayers = newN;
      _numImpostors = _numImpostors.clamp(1, _maxImpostors);
    });
  }

  List<String> _getPlayerNames() {
    return _nameControllers.map((c) {
      final text = c.text.trim();
      return text.isEmpty ? 'Jugador' : text;
    }).toList();
  }

  void _startGame() {
    final allCategories = [kRandomCategory, ...kDefaultCategories];
    final category = _selectedCategory.id == kRandomCategory.id
        ? kRandomCategory
        : allCategories.firstWhere((c) => c.id == _selectedCategory.id);

    final config = GameConfig(
      playerNames: _getPlayerNames(),
      numImpostors: _numImpostors,
      category: category,
      roundDurationSeconds: _durationMinutes * 60,
    );

    ref.read(gameProvider.notifier).startGame(config);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Partida'),
        backgroundColor: colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Número de jugadores ---
            _SectionTitle(title: 'Número de jugadores'),
            const SizedBox(height: 8),
            _NumberSelector(
              key: const Key('player_count_selector'),
              value: _numPlayers,
              min: _minPlayers,
              max: _maxPlayers,
              onChanged: _setNumPlayers,
            ),
            const SizedBox(height: 20),

            // --- Nombres ---
            _SectionTitle(title: 'Nombres de los jugadores'),
            const SizedBox(height: 8),
            ...List.generate(_numPlayers, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: _nameControllers[i],
                  decoration: InputDecoration(
                    labelText: 'Jugador ${i + 1}',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
              );
            }),
            const SizedBox(height: 20),

            // --- Número de impostores ---
            _SectionTitle(title: 'Impostores'),
            const SizedBox(height: 8),
            _NumberSelector(
              key: const Key('impostor_count_selector'),
              value: _numImpostors,
              min: 1,
              max: _maxImpostors,
              onChanged: (v) => setState(() => _numImpostors = v),
            ),
            const SizedBox(height: 20),

            // --- Categoría ---
            _SectionTitle(title: 'Categoría / Tema'),
            const SizedBox(height: 8),
            DropdownButtonFormField<GameCategory>(
              key: const Key('category_dropdown'),
              value: _selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [kRandomCategory, ...kDefaultCategories]
                  .map(
                    (cat) => DropdownMenuItem<GameCategory>(
                      value: cat,
                      child: Text(
                        cat.id == kRandomCategory.id
                            ? '🎲 ${cat.name}'
                            : cat.name,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (cat) {
                if (cat != null) setState(() => _selectedCategory = cat);
              },
            ),
            const SizedBox(height: 20),

            // --- Duración ---
            _SectionTitle(title: 'Duración de la ronda'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    key: const Key('duration_slider'),
                    value: _durationMinutes.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: _durationMinutes == 0
                        ? 'Sin límite'
                        : '$_durationMinutes min',
                    onChanged: (v) =>
                        setState(() => _durationMinutes = v.round()),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    _durationMinutes == 0
                        ? 'Sin límite'
                        : '$_durationMinutes min',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- Botón iniciar ---
            ElevatedButton.icon(
              key: const Key('btn_start_game'),
              icon: const Icon(Icons.play_circle_filled),
              label: const Text('¡Empezar!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: _startGame,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets helpers
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}

class _NumberSelector extends StatelessWidget {
  const _NumberSelector({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          icon: const Icon(Icons.remove),
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        const SizedBox(width: 16),
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 16),
        IconButton.filledTonal(
          icon: const Icon(Icons.add),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}
