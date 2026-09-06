import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/world_navigation.dart';
import 'core/world_sections_repository.dart';
import 'screens/asset_gallery_page.dart';
import 'screens/basic_section_page.dart';
import 'screens/chat_world_page.dart';
import 'screens/content_browser_page.dart';
import 'screens/events_world_page.dart';
import 'screens/marathons_world_page.dart';
import 'screens/music_world_page.dart';
import 'screens/suggestions_page.dart';
import 'screens/test_asset_lab_page.dart';
import 'screens/world_status_page.dart';
import 'widgets/living_world_scene.dart';

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
      body: Center(child: Text('DarkestWorld configuration is missing.')),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  final _repository = WorldSectionsRepository();
  late Future<List<WorldSection>> _sections;

  @override
  void initState() {
    super.initState();
    _sections = _repository.load();
  }

  void _reloadSections() {
    setState(() => _sections = _repository.load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Darkest-World'),
        backgroundColor: Colors.black.withValues(alpha: 0.35),
        actions: [
          IconButton(
            tooltip: 'Vernieuwen',
            onPressed: _reloadSections,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LivingWorldScene(
        child: FutureBuilder<List<WorldSection>>(
          future: _sections,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Card(
                  color: Colors.black.withValues(alpha: 0.70),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Worlds laden mislukt: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: _reloadSections,
                          child: const Text('Opnieuw'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final sections = snapshot.data ?? const <WorldSection>[];
            if (sections.isEmpty) {
              return const Center(child: Text('Geen worlds beschikbaar.'));
            }

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Card(
                  color: Colors.black.withValues(alpha: 0.48),
                  child: const Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Darkest-World',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Een levende wereld. De werelden en content groeien mee met het systeem.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  color: Colors.black.withValues(alpha: 0.42),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text('${sections.length} worlds geladen uit Supabase.'),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Worlds',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                for (final section in sections)
                  _SectionButton(
                    label: section.name,
                    onTap: () => _openSection(context, section),
                  ),
                const SizedBox(height: 24),
                const Text(
                  'Development',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _SectionButton(
                  label: 'Suggestions',
                  onTap: () => _openSuggestions(context),
                ),
                _SectionButton(
                  label: 'Gallery',
                  onTap: () => _openGallery(context),
                ),
                _SectionButton(
                  label: '10-Artbox Test Lab',
                  onTap: () => _openTestLab(context),
                ),
                _SectionButton(
                  label: 'World Status',
                  onTap: () => _openStatus(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openSection(BuildContext context, WorldSection section) {
    switch (WorldNavigation.destinationForSlug(section.slug)) {
      case WorldDestination.gameContent:
        _openContent(context, section.name, 'game');
        return;
      case WorldDestination.movieContent:
        _openContent(context, section.name, 'movie');
        return;
      case WorldDestination.seriesContent:
        _openContent(context, section.name, 'series');
        return;
      case WorldDestination.music:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MusicWorldPage(
              title: section.name,
              description: section.description,
            ),
          ),
        );
        return;
      case WorldDestination.chat:
        _openChat(context);
        return;
      case WorldDestination.events:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventsWorldPage(
              title: section.name,
              description: section.description,
            ),
          ),
        );
        return;
      case WorldDestination.marathons:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MarathonsWorldPage(
              title: section.name,
              description: section.description,
            ),
          ),
        );
        return;
      case WorldDestination.basic:
        _openBasic(context, section.name, section.description);
        return;
    }
  }

  void _openContent(BuildContext context, String title, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContentBrowserPage(title: title, contentType: type),
      ),
    );
  }

  void _openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ChatWorldPage(marathonChatActive: true),
      ),
    );
  }

  void _openSuggestions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SuggestionsPage()),
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
        builder: (_) => BasicSectionPage(
          title: title,
          description: description,
        ),
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
