import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    runApp(const DarkestWorldApp(configurationMissing: true));
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const DarkestWorldApp());
}

class DarkestWorldApp extends StatelessWidget {
  final bool configurationMissing;

  const DarkestWorldApp({super.key, this.configurationMissing = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DarkestWorld',
      theme: ThemeData.dark(),
      home: configurationMissing
          ? const _ConfigurationMissingPage()
          : const _HomePage(),
    );
  }
}

class _ConfigurationMissingPage extends StatelessWidget {
  const _ConfigurationMissingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('DarkestWorld configuration is missing.'),
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DarkestWorld')),
      body: const Center(
        child: Text('DarkestWorld is connected to Supabase.'),
      ),
    );
  }
}
