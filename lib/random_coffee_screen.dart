import 'package:flutter/material.dart';
import 'package:random_coffee/blocs/coffee_bloc.dart';
import 'package:random_coffee/favorites_screen.dart';
import 'package:random_coffee/widgets/coffee_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_coffee/models/coffee.dart';

class RandomCoffeeScreen extends StatelessWidget {
  const RandomCoffeeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CoffeeBloc()..add(const RandomCoffeeRequested()),
      child: const RandomCoffeeView(),
    );
  }
}

class RandomCoffeeView extends StatelessWidget {
  const RandomCoffeeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Random coffee!'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => FavoritesScreen())),
                child: const Text('Favorites'))
          ],
        ),
        body: BlocBuilder<CoffeeBloc, CoffeeState>(
          builder: (context, state) {
            if (state.status == CoffeeStatus.success &&
                state.randomCoffee?.file != null) {
              return _RandomCoffeeSuccess(randomCoffee: state.randomCoffee!);
            } else if (state.status == CoffeeStatus.loading) {
              return const _RandomCoffeeLoading();
            } else {
              return const _RandomCoffeeFailure();
            }
          },
        ));
  }
}

class _RandomCoffeeSuccess extends StatelessWidget {
  const _RandomCoffeeSuccess({Key? key, required this.randomCoffee})
      : super(key: key);
  final Coffee randomCoffee;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(child: CoffeeImage(url: randomCoffee.file)),
      _RandomCoffeeButtons(coffee: randomCoffee)
    ]);
  }
}

class _RandomCoffeeLoading extends StatelessWidget {
  const _RandomCoffeeLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        _RandomCoffeeButtons()
      ],
    );
  }
}

class _RandomCoffeeFailure extends StatelessWidget {
  const _RandomCoffeeFailure({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Text(
                'Oh no! There seems to be an issue. Please try again later.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        _RandomCoffeeButtons()
      ],
    );
  }
}

class _RandomCoffeeButtons extends StatelessWidget {
  const _RandomCoffeeButtons({Key? key, this.coffee}) : super(key: key);
  final Coffee? coffee;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: (coffee != null)
              ? () {
                  CoffeeBloc coffeeBloc = context.read<CoffeeBloc>();
                  if (coffee!.favorite) {
                    coffeeBloc.add(RemoveCoffeeFromFavoritesRequested(coffee!));
                  } else {
                    coffeeBloc.add(AddCoffeeToFavoritesRequested(coffee!));
                  }
                }
              : null,
          child: Icon(_starIcon(coffee)),
        ),
        ElevatedButton(
          onPressed: () =>
              context.read<CoffeeBloc>().add(const RandomCoffeeRequested()),
          child: const Text('Shuffle'),
        )
      ],
    );
  }

  IconData _starIcon(Coffee? coffee) {
    return (coffee?.favorite ?? false)
        ? Icons.star_rounded
        : Icons.star_border_rounded;
  }
}
