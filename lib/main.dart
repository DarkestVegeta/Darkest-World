import 'package:flutter/material.dart';
import 'screens/galaxy_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DarkestWorldApp());
}

class DarkestWorldApp extends StatelessWidget {
  const DarkestWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Darkest-World',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const GalaxyHomePage(),
    );
  }
}
