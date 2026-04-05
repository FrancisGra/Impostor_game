import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/categories.dart';
import '../models/game_category.dart';
import '../models/game_config.dart';
import '../models/game_state.dart';
import '../models/player.dart';

// ---------------------------------------------------------------------------
// Shared preferences provider
// ---------------------------------------------------------------------------

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize SharedPreferences before using');
});

// ---------------------------------------------------------------------------
// Lógica de asignación de roles
// ---------------------------------------------------------------------------

/// Asigna roles (impostor / tripulante) a la lista de jugadores de forma aleatoria.
/// Devuelve una nueva lista de [Player] con los roles asignados.
List<Player> assignRoles({
  required List<String> playerNames,
  required int numImpostors,
  Random? random,
}) {
  assert(playerNames.isNotEmpty, 'La lista de jugadores no puede estar vacía');
  assert(numImpostors >= 1, 'Debe haber al menos 1 impostor');
  assert(
    numImpostors < playerNames.length,
    'Los impostores deben ser menos que el total de jugadores',
  );

  final rng = random ?? Random();

  // Crear lista de índices y barajar
  final indices = List<int>.generate(playerNames.length, (i) => i);
  for (var i = indices.length - 1; i > 0; i--) {
    final j = rng.nextInt(i + 1);
    final tmp = indices[i];
    indices[i] = indices[j];
    indices[j] = tmp;
  }

  final impostorIndices = indices.take(numImpostors).toSet();

  return List<Player>.generate(
    playerNames.length,
    (i) => Player(
      id: i,
      name: playerNames[i],
      isImpostor: impostorIndices.contains(i),
    ),
  );
}

/// Selecciona una palabra aleatoria de una categoría.
/// Si la categoría es "aleatorio", elige una de las categorías predefinidas.
String pickSecretWord({
  required GameCategory category,
  Random? random,
}) {
  final rng = random ?? Random();

  List<String> wordPool;
  if (category.id == kRandomCategory.id) {
    final allWords =
        kDefaultCategories.expand((c) => c.words).toList();
    wordPool = allWords;
  } else {
    wordPool = category.words;
  }

  if (wordPool.isEmpty) return 'Sin palabra';
  return wordPool[rng.nextInt(wordPool.length)];
}

// ---------------------------------------------------------------------------
// GameNotifier – maneja el estado completo de la partida
// ---------------------------------------------------------------------------

class GameNotifier extends StateNotifier<GameState?> {
  GameNotifier(this._prefs) : super(null);

  final SharedPreferences _prefs;

  static const _keyLastPlayerNames = 'last_player_names';

  /// Inicia una nueva partida con la configuración dada.
  void startGame(GameConfig config, {Random? random}) {
    final players = assignRoles(
      playerNames: config.playerNames,
      numImpostors: config.numImpostors,
      random: random,
    );

    final secretWord = pickSecretWord(
      category: config.category,
      random: random,
    );

    state = GameState(
      config: config,
      players: players,
      secretWord: secretWord,
      phase: GamePhase.roleReveal,
      currentRevealIndex: 0,
      roleRevealed: false,
      secondsRemaining: config.roundDurationSeconds,
      timerRunning: false,
    );

    // Guardar nombres para siguiente partida
    _savePlayerNames(config.playerNames);
  }

  /// El jugador toca "Ver rol".
  void revealRole() {
    final s = state;
    if (s == null) return;
    state = s.copyWith(roleRevealed: true);
  }

  /// El jugador toca "Ocultar" – pasa al siguiente jugador.
  void hideRole() {
    final s = state;
    if (s == null) return;
    final nextIndex = s.currentRevealIndex + 1;
    if (nextIndex >= s.players.length) {
      // Todos los roles revelados → iniciar ronda
      state = s.copyWith(
        phase: GamePhase.round,
        currentRevealIndex: nextIndex,
        roleRevealed: false,
        timerRunning: s.config.hasTimer,
      );
    } else {
      state = s.copyWith(
        currentRevealIndex: nextIndex,
        roleRevealed: false,
      );
    }
  }

  /// Actualiza el temporizador (llamado cada segundo desde la UI).
  void tickTimer() {
    final s = state;
    if (s == null || !s.timerRunning) return;
    if (s.secondsRemaining <= 0) {
      state = s.copyWith(timerRunning: false);
      return;
    }
    state = s.copyWith(secondsRemaining: s.secondsRemaining - 1);
  }

  /// Pausa/reanuda el temporizador.
  void toggleTimer() {
    final s = state;
    if (s == null) return;
    state = s.copyWith(timerRunning: !s.timerRunning);
  }

  /// Termina la ronda y muestra la pantalla de resultados.
  void endRound() {
    final s = state;
    if (s == null) return;
    state = s.copyWith(
      phase: GamePhase.roundEnd,
      timerRunning: false,
    );
  }

  /// Reinicia con los mismos jugadores.
  void restartSamePlayers({Random? random}) {
    final s = state;
    if (s == null) return;
    startGame(s.config, random: random);
  }

  /// Vuelve a la pantalla inicial.
  void newGame() {
    state = null;
  }

  // ---------------------------------------------------------------------------
  // Persistencia
  // ---------------------------------------------------------------------------

  List<String> get savedPlayerNames {
    final raw = _prefs.getString(_keyLastPlayerNames) ?? '';
    if (raw.isEmpty) return [];
    return raw.split('|');
  }

  void _savePlayerNames(List<String> names) {
    _prefs.setString(_keyLastPlayerNames, names.join('|'));
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState?>(
  (ref) => GameNotifier(ref.watch(sharedPreferencesProvider)),
);
