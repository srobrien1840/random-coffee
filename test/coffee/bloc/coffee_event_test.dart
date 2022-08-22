// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:random_coffee/blocs/coffee_bloc.dart';
import 'package:random_coffee/models/coffee.dart';

void main() {
  group('CoffeeEvent', () {
    final mockCoffee =
        Coffee(file: "https://coffee.alexflipnote.dev/iYXDL1YRUFs_coffee.jpg");

    group('RandomCoffeeRequested', () {
      test('supports value equality', () {
        expect(
          RandomCoffeeRequested(),
          equals(RandomCoffeeRequested()),
        );
      });

      test('props are correct', () {
        expect(
          RandomCoffeeRequested().props,
          equals(<Object?>[]),
        );
      });
    });

    group('AddCoffeeToFavoritesRequested', () {
      test('supports value equality', () {
        expect(
          AddCoffeeToFavoritesRequested(mockCoffee),
          equals(
            AddCoffeeToFavoritesRequested(mockCoffee),
          ),
        );
      });

      test('props are correct', () {
        expect(
          AddCoffeeToFavoritesRequested(mockCoffee).props,
          equals(<Object?>[mockCoffee]),
        );
      });
    });

    group('RemoveCoffeeFromFavoritesRequested', () {
      test('supports value equality', () {
        expect(
          RemoveCoffeeFromFavoritesRequested(mockCoffee),
          equals(RemoveCoffeeFromFavoritesRequested(mockCoffee)),
        );
      });

      test('props are correct', () {
        expect(
          RemoveCoffeeFromFavoritesRequested(mockCoffee).props,
          equals(<Object?>[
            mockCoffee,
          ]),
        );
      });
    });
  });
}
