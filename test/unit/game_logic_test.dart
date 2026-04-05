import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_game/data/categories.dart';
import 'package:impostor_game/models/game_category.dart';
import 'package:impostor_game/providers/game_provider.dart';

void main() {
  group('assignRoles', () {
    test('asigna exactamente 1 impostor por defecto', () {
      const names = ['Alice', 'Bob', 'Carlos', 'Diana', 'Elena'];
      final players = assignRoles(playerNames: names, numImpostors: 1);
      final impostors = players.where((p) => p.isImpostor).length;
      expect(impostors, equals(1));
    });

    test('asigna 2 impostores correctamente', () {
      const names = ['A', 'B', 'C', 'D', 'E', 'F'];
      final players = assignRoles(playerNames: names, numImpostors: 2);
      final impostors = players.where((p) => p.isImpostor).length;
      expect(impostors, equals(2));
    });

    test('el número de jugadores coincide con los nombres', () {
      const names = ['A', 'B', 'C', 'D'];
      final players = assignRoles(playerNames: names, numImpostors: 1);
      expect(players.length, equals(names.length));
    });

    test('los nombres se asignan en el orden original', () {
      const names = ['Alice', 'Bob', 'Carlos'];
      final players = assignRoles(playerNames: names, numImpostors: 1);
      for (var i = 0; i < names.length; i++) {
        expect(players[i].name, equals(names[i]));
      }
    });

    test('con semilla fija produce resultados reproducibles', () {
      const names = ['A', 'B', 'C', 'D', 'E'];
      final players1 =
          assignRoles(playerNames: names, numImpostors: 1, random: Random(42));
      final players2 =
          assignRoles(playerNames: names, numImpostors: 1, random: Random(42));
      for (var i = 0; i < players1.length; i++) {
        expect(players1[i].isImpostor, equals(players2[i].isImpostor));
      }
    });

    test('todos los jugadores tienen IDs únicos', () {
      const names = ['A', 'B', 'C', 'D', 'E'];
      final players = assignRoles(playerNames: names, numImpostors: 1);
      final ids = players.map((p) => p.id).toSet();
      expect(ids.length, equals(names.length));
    });

    test('la distribución impostor/tripulante suma al total de jugadores', () {
      const names = ['A', 'B', 'C', 'D', 'E'];
      final players = assignRoles(playerNames: names, numImpostors: 1);
      final impostors = players.where((p) => p.isImpostor).length;
      final crewmates = players.where((p) => !p.isImpostor).length;
      expect(impostors + crewmates, equals(names.length));
    });

    test('al menos 1 tripulante siempre (numImpostors < total)', () {
      const names = ['A', 'B', 'C'];
      final players = assignRoles(playerNames: names, numImpostors: 1);
      expect(players.where((p) => !p.isImpostor).length, greaterThan(0));
    });
  });

  group('pickSecretWord', () {
    test('devuelve una palabra de la categoría dada', () {
      const category = GameCategory(
        id: 'test',
        name: 'Test',
        words: ['Manzana', 'Pera', 'Naranja'],
      );
      final word = pickSecretWord(category: category);
      expect(category.words, contains(word));
    });

    test('devuelve la misma palabra con semilla fija', () {
      const category = GameCategory(
        id: 'test',
        name: 'Test',
        words: ['Manzana', 'Pera', 'Naranja'],
      );
      final w1 = pickSecretWord(category: category, random: Random(1));
      final w2 = pickSecretWord(category: category, random: Random(1));
      expect(w1, equals(w2));
    });

    test('categoría aleatoria devuelve una palabra de las categorías globales', () {
      final word = pickSecretWord(category: kRandomCategory);
      final allWords =
          kDefaultCategories.expand((c) => c.words).toSet();
      expect(allWords, contains(word));
    });

    test('resultado nunca está vacío para categorías con palabras', () {
      for (final cat in kDefaultCategories) {
        final word = pickSecretWord(category: cat);
        expect(word, isNotEmpty);
      }
    });
  });

  group('Modelo Player', () {
    test('assignRoles asigna nombres correctamente', () {
      final players = assignRoles(
        playerNames: ['Alice', 'Bob', 'Carlos'],
        numImpostors: 1,
      );
      expect(players.map((p) => p.name).toList(),
          equals(['Alice', 'Bob', 'Carlos']));
    });
  });
}
