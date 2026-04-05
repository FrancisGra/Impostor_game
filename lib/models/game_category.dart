/// Modelo de categoría del juego con sus palabras asociadas.
class GameCategory {
  const GameCategory({
    required this.id,
    required this.name,
    required this.words,
  });

  final String id;
  final String name;
  final List<String> words;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
