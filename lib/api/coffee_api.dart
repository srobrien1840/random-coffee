import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:random_coffee/models/coffee.dart';

class RandomCoffeeRequestFailure implements Exception {}

class MissingImageFailure implements Exception {}

class CoffeeApiClient {
  CoffeeApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _baseUrl = 'coffee.alexflipnote.dev';
  final http.Client _httpClient;

  Future<Coffee> getRandomCoffee() async {
    final randomCoffeeRequest = Uri.https(
      _baseUrl,
      '/random.json',
    );
    final randomCoffeeResponse = await _httpClient.get(randomCoffeeRequest);

    if (randomCoffeeResponse.statusCode != 200) {
      throw RandomCoffeeRequestFailure();
    }

    final randomCoffeeJson = jsonDecode(
      randomCoffeeResponse.body,
    );

    if (randomCoffeeJson['file'] == null) {
      throw MissingImageFailure();
    }

    return Coffee.fromJson(randomCoffeeJson as Map<String, dynamic>);
  }
}
