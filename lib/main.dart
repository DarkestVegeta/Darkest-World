import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/asset_gallery_page.dart';
import 'screens/basic_section_page.dart';
import 'screens/content_browser_page.dart';
import 'screens/test_asset_lab_page.dart';
import 'screens/world_status_page.dart';

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
      title: 'Darkest-World',
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
      body: Center(child: Text('Darkest-World configuration is missing.')),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Darkest-World')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Darkest-World',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text(
            'Worlds',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _SectionButton(label: 'Games', onTap: () => _openContent(context, 'Games', 'game')),
          _SectionButton(label: 'Movies', onTap: () => _openContent(context, 'Movies', 'movie')),
          _SectionButton(label: 'Series', onTap: () => _openContent(context, 'Series', 'series')),
          _SectionButton(label: 'Gallery', onTap: () => _openGallery(context)),
          _SectionButton(label: '10-Artbox Test Lab', onTap: () => _openTestLab(context)),
          _SectionButton(label: 'World Status', onTap: () => _openStatus(context)),
          const SizedBox(height: 24),
          const Text(
            'Darkest-World Systems',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _SectionButton(label: 'Events', onTap: () => _openBasic(context, 'Events', 'Events and world activity.')),
          _SectionButton(label: 'Marathons', onTap: () => _openBasic(context, 'Marathons', 'Franchise marathon planning and progress.')),
          _SectionButton(label: 'Social Media', onTap: () => _openBasic(context, 'Social Media', 'Darkest-World social channels and posts.')),
          _SectionButton(label: 'Chat', onTap: () => _openBasic(context, 'Chat', 'Community chat foundation.')),
          _SectionButton(label: 'Identity World', onTap: () => _openBasic(context, 'Identity World', 'DarkestVegeta, DarkestFamily and persona information.')),
          _SectionButton(label: 'Dark Core', onTap: () => _openBasic(context, 'Dark Core', 'Core lore, rules and world foundations.')),
          _SectionButton(label: 'Create Your World', onTap: () => _openBasic(context, 'Create Your World', 'Future creation and customization layer.')),
        ],
      ),
    );
  }

  void _openContent(BuildContext context, String title, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContentBrowserPage(title: title, contentType: type),
      ),
    );
  }

  void _openGallery(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AssetGalleryPage(title: 'Gallery'),
      ),
    );
  }

  void _openTestLab(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TestAssetLabPage()),
    );
  }

  void _openStatus(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WorldStatusPage()),
    );
  }

  void _openBasic(BuildContext context, String title, String description) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BasicSectionPage(title: title, description: description),
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
