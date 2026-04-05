import 'game_category.dart';

/// Configuración de una partida antes de iniciar.
class GameConfig {
  const GameConfig({
    required this.playerNames,
    required this.numImpostors,
    required this.category,
    this.roundDurationSeconds = 0,
  });

  final List<String> playerNames;
  final int numImpostors;
  final GameCategory category;

  /// 0 = sin temporizador
  final int roundDurationSeconds;

  int get numPlayers => playerNames.length;

  bool get hasTimer => roundDurationSeconds > 0;

  GameConfig copyWith({
    List<String>? playerNames,
    int? numImpostors,
    GameCategory? category,
    int? roundDurationSeconds,
  }) {
    return GameConfig(
      playerNames: playerNames ?? this.playerNames,
      numImpostors: numImpostors ?? this.numImpostors,
      category: category ?? this.category,
      roundDurationSeconds: roundDurationSeconds ?? this.roundDurationSeconds,
    );
  }

  @override
  String toString() =>
      'GameConfig(players: ${playerNames.length}, impostors: $numImpostors, '
      'category: ${category.name}, duration: ${roundDurationSeconds}s)';
}
