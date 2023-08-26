import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'data/drift/drift_repository.dart';
import 'data/repository.dart';
import 'data/sqlite/sqlite_repository.dart';
import 'network/recipe_service.dart';
import 'network/service_interface.dart';
import 'ui/main_screen.dart';

Future<void> main() async {
  _setupLogging();
  WidgetsFlutterBinding.ensureInitialized();
  final repository = DriftRepository();
  repository.init();
  runApp(MyApp(repository: repository));
}

/// Initializes the logging package and allows Chopper to log requests and
/// responses. `Level.ALL` makes you be able to see every log statement.
void _setupLogging() {
  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((LogRecord record) =>
      log('${record.level.name}: ${record.time}: ${record.message}'));
}

class MyApp extends StatelessWidget {
  final Repository repository;

  const MyApp({required this.repository, Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Repository>(
          lazy: false,
          create: (BuildContext context) => repository,
          dispose: (BuildContext context, Repository repository) {
            repository.close();
          },
        ),
        Provider<ServiceInterface>(
            lazy: false,
            create: (BuildContext context) => RecipeService.create()),
      ],
      child: MaterialApp(
        title: 'Recipes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.white,
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MainScreen(),
      ),
    );
  }
}
