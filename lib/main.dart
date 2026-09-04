import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/content_browser_page.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabasePublishableKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    runApp(const DarkestWorldApp(configurationMissing: true));
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
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
      theme: ThemeData.dark(useMaterial3: true),
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
      body: Center(child: Text('DarkestWorld configuration is missing.')),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DarkestWorld')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'DarkestWorld',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _SectionButton(label: 'Games', onTap: () => _open(context, 'Games', 'game')),
          _SectionButton(label: 'Movies', onTap: () => _open(context, 'Movies', 'movie')),
          _SectionButton(label: 'Series', onTap: () => _open(context, 'Series', 'series')),
        ],
      ),
    );
  }

  void _open(BuildContext context, String title, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContentBrowserPage(title: title, contentType: type),
      ),
    );
  }
}

class _SectionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SectionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FilledButton(
        onPressed: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(label),
        ),
      ),
    );
  }
}
