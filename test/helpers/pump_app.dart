import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:random_coffee/api/coffee_api.dart';

class MockCoffeeApiClient extends Mock implements CoffeeApiClient {}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    CoffeeApiClient? coffeeApiClient,
  }) {
    return pumpWidget(
      RepositoryProvider.value(
        value: coffeeApiClient ?? MockCoffeeApiClient(),
        child: MaterialApp(
          home: Scaffold(body: widget),
        ),
      ),
    );
  }

  Future<void> pumpRoute(
    Route<dynamic> route, {
    CoffeeApiClient? coffeeApiClient,
  }) {
    return pumpApp(
      Navigator(onGenerateRoute: (_) => route),
      coffeeApiClient: coffeeApiClient,
    );
  }
}
