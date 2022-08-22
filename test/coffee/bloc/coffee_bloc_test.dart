import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:random_coffee/api/coffee_api.dart';
import 'package:random_coffee/blocs/coffee_bloc.dart';
import 'package:random_coffee/models/coffee.dart';

import '../../helpers/hydrated_bloc.dart';

class MockCoffeeApiClient extends Mock implements CoffeeApiClient {}

class FakeCoffee extends Fake implements Coffee {}

void main() {
  initHydratedStorage();

  const Coffee randomCoffee =
      Coffee(file: "https://coffee.alexflipnote.dev/iYXDL1YRUFs_coffee.jpg");

  const Coffee favoritedRandomCoffee = Coffee(
      file: "https://coffee.alexflipnote.dev/iYXDL1YRUFs_coffee.jpg",
      favorite: true);

  group('CoffeeBloc', () {
    MockCoffeeApiClient mockCoffeeApiClient = MockCoffeeApiClient();

    setUpAll(() {
      registerFallbackValue(FakeCoffee());
    });

    setUp(() {
      when(mockCoffeeApiClient.getRandomCoffee)
          .thenAnswer((_) async => Future.value(randomCoffee));
    });

    CoffeeBloc buildBloc() {
      return CoffeeBloc(coffeeApiClient: mockCoffeeApiClient);
    }

    group('constructor', () {
      test(
        'works properly',
        () => expect(buildBloc, returnsNormally),
      );

      test('has correct initial state', () {
        expect(
          buildBloc().state,
          equals(const CoffeeState()),
        );
      });
    });

    group('RandomCoffeeRequested', () {
      blocTest<CoffeeBloc, CoffeeState>(
        'requests random coffee image from API',
        build: buildBloc,
        act: (bloc) => bloc.add(const RandomCoffeeRequested()),
        verify: (_) {
          verify(() => mockCoffeeApiClient.getRandomCoffee()).called(1);
        },
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'emits state with loading status '
        'then success status with updated coffee object',
        build: buildBloc,
        act: (bloc) => bloc.add(const RandomCoffeeRequested()),
        expect: () => [
          const CoffeeState(
            status: CoffeeStatus.loading,
          ),
          const CoffeeState(
            status: CoffeeStatus.success,
            randomCoffee: randomCoffee,
          ),
        ],
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'emits state with loading status then failure status'
        'when api client throws an error',
        setUp: () {
          when(() => mockCoffeeApiClient.getRandomCoffee())
              .thenThrow((_) => Exception(':('));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const RandomCoffeeRequested()),
        expect: () => [
          const CoffeeState(status: CoffeeStatus.loading),
          const CoffeeState(status: CoffeeStatus.failure),
        ],
      );
    });

    group('AddCoffeeToFavoritesRequested', () {
      blocTest<CoffeeBloc, CoffeeState>(
          'adds coffee to favorites list and sets state.randomCoffee.favorite to true',
          build: buildBloc,
          act: (bloc) =>
              bloc.add(const AddCoffeeToFavoritesRequested(randomCoffee)),
          expect: () => [
                CoffeeState(
                    randomCoffee: favoritedRandomCoffee,
                    favorites: [favoritedRandomCoffee])
              ]);
    });

    group('RemoveCoffeeFromFavoritesRequested', () {
      blocTest<CoffeeBloc, CoffeeState>(
          'removes coffee from favorites list and sets state.randomCoffee.favorite to false',
          build: buildBloc,
          seed: () => const CoffeeState(
              randomCoffee: favoritedRandomCoffee,
              favorites: [favoritedRandomCoffee]),
          act: (bloc) => bloc.add(
              const RemoveCoffeeFromFavoritesRequested(favoritedRandomCoffee)),
          expect: (() => [const CoffeeState(randomCoffee: randomCoffee)]));
    });
  });
}
