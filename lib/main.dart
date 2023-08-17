import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import 'data/memory_repository.dart';
import 'mock_service/mock_service.dart';
import 'ui/main_screen.dart';

Future<void> main() async {
  _setupLogging();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Initializes the logging package and allows Chopper to log requests and
/// responses. `Level.ALL` makes you be able to see every log statement.
void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord record) =>
      log('${record.level.name}: ${record.time}: ${record.message}'));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MemoryRepository>(
            lazy: false, create: (BuildContext context) => MemoryRepository()),
        Provider(
            lazy: false,
            /* You should use double dots, which return the caller, not the
             * return of the method. */
            create: (BuildContext context) => MockService()..create()),
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
