import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vish/pages/homepage.dart';
import 'firebase_options.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';

final storage = FirebaseStorage.instance;
final functions = FirebaseFunctions.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    try {
      storage.useStorageEmulator('192.168.37.79', 9199);
      functions.useFunctionsEmulator('192.168.37.79', 5001);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Homepage(),
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          splashColor: Colors.transparent,
          brightness: Brightness.dark,
          highlightColor: Colors.transparent,
          colorScheme: ColorScheme.dark(
            brightness: Brightness.dark,
            background: const Color.fromARGB(255, 38, 41, 65),
            surface: const Color.fromARGB(255, 30, 32, 50),
            primary: const Color.fromARGB(255, 62, 118, 238),
            onSurface: Colors.white.withOpacity(0.8),
            onPrimary: Colors.white.withOpacity(0.8),
            onBackground: Colors.white.withOpacity(0.8),
          ),
        ));
  }
}
