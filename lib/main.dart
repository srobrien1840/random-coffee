import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:random_coffee/blocs/coffee_bloc.dart';
import 'package:random_coffee/random_coffee_screen.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = CoffeeBlocObserver();

  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  HydratedBlocOverrides.runZoned(
    () => runApp(const CoffeeApp()),
    storage: storage,
  );

  // final storage = await HydratedStorage.build(
  //     storageDirectory: await getTemporaryDirectory());
  // HydratedBlocOverrides.runZoned(
  //   () => runApp(const CoffeeApp()),
  //   storage: storage,
  // );
}

class CoffeeApp extends StatelessWidget {
  const CoffeeApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CoffeeBloc()..add(const RandomCoffeeRequested()),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
            appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey[50],
                foregroundColor: Colors.black),
            colorScheme:
                ColorScheme.fromSwatch().copyWith(primary: Colors.indigo)),
        home: const RandomCoffeeView(),
      ),
    );
  }
}

class CoffeeBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }
}
