import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_coffee/blocs/coffee_bloc.dart';
import 'package:random_coffee/widgets/coffee_image.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Favorites')),
        body: BlocBuilder<CoffeeBloc, CoffeeState>(
          builder: ((context, state) {
            if (state.favorites.isNotEmpty) {
              return GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  crossAxisCount: 3,
                ),
                itemCount: state.favorites.length,
                itemBuilder: (BuildContext context, int index) {
                  return CoffeeImage(url: state.favorites[index].file);
                },
              );
            } else {
              return const _NoFavorites();
            }
          }),
        ));
  }
}

class _NoFavorites extends StatelessWidget {
  const _NoFavorites({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('You have no favorite coffee images'));
  }
}
