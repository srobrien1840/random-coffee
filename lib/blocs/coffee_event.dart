part of 'coffee_bloc.dart';

abstract class CoffeeEvent extends Equatable {
  const CoffeeEvent();

  @override
  List<Object> get props => [];
}

class RandomCoffeeRequested extends CoffeeEvent {
  const RandomCoffeeRequested();
}

class AddCoffeeToFavoritesRequested extends CoffeeEvent {
  final Coffee coffee;

  const AddCoffeeToFavoritesRequested(this.coffee);

  @override
  List<Object> get props => [coffee];
}

class RemoveCoffeeFromFavoritesRequested extends CoffeeEvent {
  final Coffee coffee;

  const RemoveCoffeeFromFavoritesRequested(this.coffee);

  @override
  List<Object> get props => [coffee];
}
