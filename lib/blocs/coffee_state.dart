part of 'coffee_bloc.dart';

enum CoffeeStatus { initial, loading, success, failure }

class CoffeeState extends Equatable {
  const CoffeeState({
    this.status = CoffeeStatus.initial,
    this.randomCoffee,
    this.favorites = const [],
  });

  final CoffeeStatus status;
  final List<Coffee> favorites;
  final Coffee? randomCoffee;

  CoffeeState copyWith({
    CoffeeStatus Function()? status,
    Coffee? Function()? randomCoffee,
    List<Coffee> Function()? favorites,
  }) {
    return CoffeeState(
      status: status != null ? status() : this.status,
      randomCoffee: randomCoffee != null ? randomCoffee() : this.randomCoffee,
      favorites: favorites != null ? favorites() : this.favorites,
    );
  }

  @override
  List<Object?> get props => [
        status,
        randomCoffee,
        favorites,
      ];
}
