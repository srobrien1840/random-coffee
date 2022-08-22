import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:random_coffee/api/coffee_api.dart';
import 'package:random_coffee/blocs/coffee_bloc.dart';
import 'package:random_coffee/models/coffee.dart';
import 'package:random_coffee/random_coffee_screen.dart';
import 'package:random_coffee/widgets/coffee_image.dart';

import '../../helpers/helpers.dart';

class MockCoffeeApiClient extends Mock implements CoffeeApiClient {}

class MockCoffeeBloc extends MockBloc<CoffeeEvent, CoffeeState>
    implements CoffeeBloc {}

void main() {
  initHydratedStorage();

  final mockCoffee =
      Coffee(file: "https://coffee.alexflipnote.dev/iYXDL1YRUFs_coffee.jpg");
  final favoritedCoffee = Coffee(
      file: "https://coffee.alexflipnote.dev/iYXDL1YRUFs_coffee.jpg",
      favorite: true);

  late CoffeeApiClient mockCoffeeApiClient;

  group('RandomCoffeeView', () {
    setUp(() {
      mockCoffeeApiClient = MockCoffeeApiClient();
      when(mockCoffeeApiClient.getRandomCoffee)
          .thenAnswer((_) async => Future.value(mockCoffee));
    });

    Widget buildSubject() {
      return BlocProvider(
        create: (_) => CoffeeBloc(coffeeApiClient: mockCoffeeApiClient)
          ..add(const RandomCoffeeRequested()),
        child: const RandomCoffeeView(),
      );
    }

    testWidgets('renders RandomCoffeeView', (tester) async {
      await tester.pumpApp(
        buildSubject(),
        coffeeApiClient: mockCoffeeApiClient,
      );

      expect(find.byType(RandomCoffeeView), findsOneWidget);
    });

    testWidgets(
      'Requests a random coffee on initialization',
      (tester) async {
        await tester.pumpApp(
          buildSubject(),
          coffeeApiClient: mockCoffeeApiClient,
        );

        verify(() => mockCoffeeApiClient.getRandomCoffee()).called(1);
      },
    );
  });

  group('RandomCoffeeView', () {
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
        child: const RandomCoffeeView(),
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
            matching: find.text('Random coffee!'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders network image '
      'when status changes to success',
      (tester) async {
        whenListen<CoffeeState>(
          coffeeBloc,
          Stream.fromIterable([
            const CoffeeState(),
            const CoffeeState(
              status: CoffeeStatus.success,
            ),
          ]),
        );

        await tester.pumpApp(
          buildSubject(),
          coffeeApiClient: mockCoffeeApiClient,
        );
        await tester.pumpAndSettle();

        expect(
            find.byWidget(CoffeeImage(
              url: mockCoffee.file,
            )),
            findsOneWidget);
      },
    );
    testWidgets(
      'renders error message '
      'when status changes to failure',
      (tester) async {
        whenListen<CoffeeState>(
          coffeeBloc,
          Stream.fromIterable([
            const CoffeeState(),
            const CoffeeState(
              status: CoffeeStatus.failure,
            ),
          ]),
        );

        await tester.pumpApp(
          buildSubject(),
          coffeeApiClient: mockCoffeeApiClient,
        );
        await tester.pumpAndSettle();

        expect(
          find.text(
              'Oh no! There seems to be an issue. Please try again later.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders loader '
      'when status changes to loading',
      (tester) async {
        whenListen<CoffeeState>(
          coffeeBloc,
          Stream.fromIterable([
            const CoffeeState(),
            const CoffeeState(
              status: CoffeeStatus.loading,
            ),
          ]),
        );

        await tester.pumpApp(
          buildSubject(),
          coffeeApiClient: mockCoffeeApiClient,
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
        'Shuffle button is rendered'
        'and adds RandomCoffeeRequested ', (tester) async {
      await tester.pumpApp(
        buildSubject(),
        coffeeApiClient: mockCoffeeApiClient,
      );

      expect(find.widgetWithText(ElevatedButton, 'Shuffle'), findsOneWidget);

      final shuffleButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Shuffle'));

      shuffleButton.onPressed!();

      verify(
        () => coffeeBloc.add(
          RandomCoffeeRequested(),
        ),
      ).called(1);
    });

    testWidgets(
        'Favorite button is rendered with an empty star'
        'and adds AddCoffeeToFavoritesRequested '
        'to CoffeeBloc when randomCoffee is not a favorite', (tester) async {
      await tester.pumpApp(
        buildSubject(),
        coffeeApiClient: mockCoffeeApiClient,
      );

      expect(find.widgetWithIcon(ElevatedButton, Icons.star_border_rounded),
          findsOneWidget);

      final favoriteButton = tester.widget<ElevatedButton>(
          find.widgetWithIcon(ElevatedButton, Icons.star_border_rounded));

      favoriteButton.onPressed!();

      verify(
        () => coffeeBloc.add(
          AddCoffeeToFavoritesRequested(mockCoffee),
        ),
      ).called(1);
    });

    testWidgets(
      'Favorite button '
      'adds RemoveCoffeeFromFavoritesRequested '
      'and icon is filled ',
      (tester) async {
        whenListen<CoffeeState>(
          coffeeBloc,
          Stream.fromIterable([
            const CoffeeState(),
            CoffeeState(
              status: CoffeeStatus.success,
              randomCoffee: favoritedCoffee,
            ),
          ]),
        );

        await tester.pumpApp(
          buildSubject(),
          coffeeApiClient: mockCoffeeApiClient,
        );
        //I believe this is timing out due to the circular progress indicator in my Image widget
        await tester.pumpAndSettle();

        expect(find.widgetWithIcon(ElevatedButton, Icons.star_rounded),
            findsOneWidget);

        final favoriteButton = tester.widget<ElevatedButton>(
            find.widgetWithIcon(ElevatedButton, Icons.star_rounded));

        favoriteButton.onPressed!();

        verify(
          () => coffeeBloc.add(RemoveCoffeeFromFavoritesRequested(
              mockCoffee.copyWith(favorite: true))),
        ).called(1);
      },
    );
  });
}
