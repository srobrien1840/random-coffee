// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:random_coffee/blocs/coffee_bloc.dart';
import 'package:random_coffee/models/coffee.dart';

void main() {
  final mockCoffee =
      Coffee(file: "https://coffee.alexflipnote.dev/iYXDL1YRUFs_coffee.jpg");

  final mockCoffees = [mockCoffee];
  group('CoffeeState', () {
    CoffeeState createSubject({
      CoffeeStatus status = CoffeeStatus.initial,
      Coffee? randomCoffee,
      List<Coffee> favorites = const [],
    }) {
      return CoffeeState(
        status: status,
        favorites: mockCoffees,
        randomCoffee: randomCoffee,
      );
    }

    test('supports value equality', () {
      expect(
        createSubject(),
        equals(createSubject()),
      );
    });

    test('props are correct', () {
      expect(
        createSubject(
                status: CoffeeStatus.initial,
                favorites: mockCoffees,
                randomCoffee: mockCoffee)
            .props,
        equals(<Object?>[
          CoffeeStatus.initial,
          mockCoffee,
          mockCoffees,
        ]),
      );
    });

    group('copyWith', () {
      test('returns the same object if not arguments are provided', () {
        expect(
          createSubject().copyWith(),
          equals(createSubject()),
        );
      });

      test('retains the old value for every parameter if null is provided', () {
        expect(
          createSubject().copyWith(
            randomCoffee: null,
            status: null,
            favorites: null,
          ),
          equals(createSubject()),
        );
      });

      test('replaces every non-null parameter', () {
        expect(
          createSubject().copyWith(
            randomCoffee: () => mockCoffee,
            favorites: () => [mockCoffee],
            status: () => CoffeeStatus.success,
          ),
          equals(
            createSubject(
              randomCoffee: mockCoffee,
              favorites: [mockCoffee],
              status: CoffeeStatus.success,
            ),
          ),
        );
      });
    });

    test('can copyWith null randomCoffee', () {
      expect(
        createSubject(randomCoffee: mockCoffee).copyWith(
          randomCoffee: () => null,
        ),
        equals(createSubject(randomCoffee: null)),
      );
    });
  });
}
