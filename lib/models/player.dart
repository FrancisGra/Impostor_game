/// Modelo de jugador con su nombre y rol asignado.
class Player {
  const Player({
    required this.id,
    required this.name,
    this.isImpostor = false,
  });

  final int id;
  final String name;
  final bool isImpostor;

  Player copyWith({
    int? id,
    String? name,
    bool? isImpostor,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      isImpostor: isImpostor ?? this.isImpostor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Player(id: $id, name: $name, isImpostor: $isImpostor)';
}
