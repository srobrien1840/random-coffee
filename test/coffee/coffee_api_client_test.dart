// ignore_for_file: prefer_const_constructors
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:random_coffee/api/coffee_api.dart';
import 'package:random_coffee/models/coffee.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

void main() {
  group('CoffeeApiClient', () {
    late http.Client httpClient;
    late CoffeeApiClient coffeeApiClient;

    setUpAll(() {
      registerFallbackValue(FakeUri());
    });

    setUp(() {
      httpClient = MockHttpClient();
      coffeeApiClient = CoffeeApiClient(httpClient: httpClient);
    });

    group('constructor', () {
      test('does not require an httpClient', () {
        expect(CoffeeApiClient(), isNotNull);
      });
    });

    group('randomCoffee', () {
      test('makes correct http request', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('[]');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        try {
          await coffeeApiClient.getRandomCoffee();
        } catch (_) {}
        verify(
          () => httpClient.get(
            Uri.https(
              'coffee.alexflipnote.dev',
              '/random.json',
            ),
          ),
        ).called(1);
      });

      test('throws RandomCoffeeRequestFailure on non-200 response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => coffeeApiClient.getRandomCoffee(),
          throwsA(isA<RandomCoffeeRequestFailure>()),
        );
      });

      test('throws MissingImageFailure on empty response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        await expectLater(
          coffeeApiClient.getRandomCoffee(),
          throwsA(isA<MissingImageFailure>()),
        );
      });

      test('returns Coffee on valid response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn(
          '''
{
  "file": "https://coffee.alexflipnote.dev/d7-hiMLXlGs_coffee.jpg"
}''',
        );
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        final actual = await coffeeApiClient.getRandomCoffee();
        expect(
            actual,
            isA<Coffee>().having((l) => l.file, 'file',
                'https://coffee.alexflipnote.dev/d7-hiMLXlGs_coffee.jpg'));
      });
    });
  });
}
