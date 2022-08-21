import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:random_coffee/api/coffee_api.dart';
import 'package:random_coffee/models/coffee.dart';
import 'package:equatable/equatable.dart';

part 'coffee_event.dart';
part 'coffee_state.dart';

class CoffeeBloc extends HydratedBloc<CoffeeEvent, CoffeeState> {
  CoffeeBloc() : super(const CoffeeState()) {
    on<RandomCoffeeRequested>(_onRandomCoffeeRequested);
    on<AddCoffeeToFavoritesRequested>(_onAddFavoriteRequested);
    on<RemoveCoffeeFromFavoritesRequested>(_onRemoveFavoriteRequested);
  }
  final CoffeeApiClient _coffeeApiClient = CoffeeApiClient();

  Future<void> _onRandomCoffeeRequested(
      RandomCoffeeRequested event, Emitter<CoffeeState> emit) async {
    emit(state.copyWith(status: () => CoffeeStatus.loading));
    try {
      Coffee randomCoffee = await _coffeeApiClient.getRandomCoffee();
      emit(state.copyWith(
          status: () => CoffeeStatus.success,
          randomCoffee: () => randomCoffee));
    } catch (_) {
      emit(state.copyWith(status: (() => CoffeeStatus.failure)));
    }
  }

  Future<void> _onAddFavoriteRequested(
      AddCoffeeToFavoritesRequested event, Emitter<CoffeeState> emit) async {
    Coffee coffee = event.coffee.copyWith(favorite: true);
    List<Coffee> favorites = [];
    favorites.addAll([...state.favorites, coffee]);
    emit(
        state.copyWith(favorites: () => favorites, randomCoffee: () => coffee));
  }

  Future<void> _onRemoveFavoriteRequested(
      RemoveCoffeeFromFavoritesRequested event,
      Emitter<CoffeeState> emit) async {
    Coffee coffee = event.coffee.copyWith(favorite: false);
    state.favorites.remove(event.coffee);
    emit(state.copyWith(randomCoffee: (() => coffee)));
  }

  @override
  CoffeeState? fromJson(Map<String, dynamic> json) {
    CoffeeStatus status = CoffeeStatus.values.byName(json['status']);
    Coffee randomCoffee = Coffee.fromJson(json['randomCoffee']);
    List<Coffee> favorites = (json['favorites'] ?? [])
        .map<Coffee>((e) => Coffee.fromJson(e))
        .toList();

    return CoffeeState(
        status: status, randomCoffee: randomCoffee, favorites: favorites);
  }

  @override
  Map<String, dynamic>? toJson(CoffeeState state) {
    return <String, dynamic>{
      'status': state.status.name,
      'randomCoffee': state.randomCoffee?.toJson(),
      'favorites': state.favorites.map((coffee) => coffee.toJson()).toList()
    };
  }
}
