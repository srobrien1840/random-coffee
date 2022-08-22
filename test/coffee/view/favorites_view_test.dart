import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:random_coffee/api/coffee_api.dart';
import 'package:random_coffee/blocs/coffee_bloc.dart';
import 'package:random_coffee/favorites_screen.dart';
import 'package:random_coffee/models/coffee.dart';
import 'package:random_coffee/widgets/coffee_image.dart';

import '../../helpers/helpers.dart';

class MockCoffeeApiClient extends Mock implements CoffeeApiClient {}

class MockCoffeeBloc extends MockBloc<CoffeeEvent, CoffeeState>
    implements CoffeeBloc {}

void main() {
  initHydratedStorage();

  final mockCoffee =
      Coffee(file: "https://coffee.alexflipnote.dev/iYXDL1YRUFs_coffee.jpg");

  late CoffeeApiClient mockCoffeeApiClient;

  group('FavoritesScreen', () {
    setUp(() {
      mockCoffeeApiClient = MockCoffeeApiClient();
      when(mockCoffeeApiClient.getRandomCoffee)
          .thenAnswer((_) async => Future.value(mockCoffee));
    });

    Widget buildSubject() {
      return BlocProvider(
        create: (_) => CoffeeBloc(coffeeApiClient: mockCoffeeApiClient),
        child: const FavoritesScreen(),
      );
    }

    testWidgets('renders RandomCoffeeView', (tester) async {
      await tester.pumpApp(
        buildSubject(),
        coffeeApiClient: mockCoffeeApiClient,
      );

      expect(find.byType(FavoritesScreen), findsOneWidget);
    });
  });

  group('FavoritesScreen', () {
    late CoffeeBloc coffeeBloc;

    setUp(() {
      mockCoffeeApiClient = MockCoffeeApiClient();
      coffeeBloc = MockCoffeeBloc();
      when(() => coffeeBloc.state).thenReturn(
        CoffeeState(
          status: CoffeeStatus.success,
          randomCoffee: mockCoffee,
        ),
      );

      when(mockCoffeeApiClient.getRandomCoffee)
          .thenAnswer((_) async => Future.value(mockCoffee));
    });

    Widget buildSubject() {
      return BlocProvider.value(
        value: coffeeBloc,
        child: const FavoritesScreen(),
      );
    }

    testWidgets(
      'renders AppBar with title text',
      (tester) async {
        await tester.pumpApp(
          buildSubject(),
          coffeeApiClient: mockCoffeeApiClient,
        );

        expect(find.byType(AppBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text('Favorites'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders image '
      'when favorites exist',
      (tester) async {
        whenListen<CoffeeState>(
          coffeeBloc,
          Stream.fromIterable([
            const CoffeeState(),
            CoffeeState(
              favorites: [mockCoffee],
            ),
          ]),
        );

        await tester.pumpApp(
          buildSubject(),
          coffeeApiClient: mockCoffeeApiClient,
        );
        await tester.pumpAndSettle();

        expect(find.byType(CoffeeImage), findsOneWidget);
      },
    );
    testWidgets(
      'reders no favorites message '
      'when no favorites exist',
      (tester) async {
        await tester.pumpApp(
          buildSubject(),
          coffeeApiClient: mockCoffeeApiClient,
        );
        expect(find.text('You have no favorite coffee images'), findsOneWidget);
      },
    );
  });
}
