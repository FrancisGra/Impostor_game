import 'game_config.dart';
import 'player.dart';

/// Fase actual del juego.
enum GamePhase {
  idle,
  roleReveal,
  round,
  roundEnd,
}

/// Estado completo de una partida en curso.
class GameState {
  const GameState({
    required this.config,
    required this.players,
    required this.secretWord,
    this.phase = GamePhase.idle,
    this.currentRevealIndex = 0,
    this.roleRevealed = false,
    this.secondsRemaining = 0,
    this.timerRunning = false,
  });

  final GameConfig config;
  final List<Player> players;
  final String secretWord;
  final GamePhase phase;

  /// Índice del jugador al que actualmente se le muestra el rol.
  final int currentRevealIndex;

  /// Si el jugador actual ya tocó "Ver rol".
  final bool roleRevealed;

  final int secondsRemaining;
  final bool timerRunning;

  bool get allRolesRevealed => currentRevealIndex >= players.length;

  Player? get currentPlayer =>
      currentRevealIndex < players.length ? players[currentRevealIndex] : null;

  GameState copyWith({
    GameConfig? config,
    List<Player>? players,
    String? secretWord,
    GamePhase? phase,
    int? currentRevealIndex,
    bool? roleRevealed,
    int? secondsRemaining,
    bool? timerRunning,
  }) {
    return GameState(
      config: config ?? this.config,
      players: players ?? this.players,
      secretWord: secretWord ?? this.secretWord,
      phase: phase ?? this.phase,
      currentRevealIndex: currentRevealIndex ?? this.currentRevealIndex,
      roleRevealed: roleRevealed ?? this.roleRevealed,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      timerRunning: timerRunning ?? this.timerRunning,
    );
  }
}
