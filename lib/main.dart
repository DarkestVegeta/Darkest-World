import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/access_policy.dart';
import 'core/world_navigation.dart';
import 'core/world_sections_repository.dart';
import 'screens/asset_gallery_page.dart';
import 'screens/archive_world_page.dart';
import 'screens/basic_section_page.dart';
import 'screens/chat_world_page.dart';
import 'screens/cinema_world_page.dart';
import 'screens/content_browser_page.dart';
import 'screens/coming_soon_world_page.dart';
import 'screens/create_your_world_page.dart';
import 'screens/creation_world_page.dart';
import 'screens/dark_core_page.dart';
import 'screens/darkest_vegeta_visual_hub_page.dart';
import 'screens/events_world_page.dart';
import 'screens/family_world_page.dart';
import 'screens/game_world_planet_page.dart';
import 'screens/guest_mode_page.dart';
import 'screens/identity_world_page.dart';
import 'screens/marathons_world_page.dart';
import 'screens/music_world_page.dart';
import 'screens/social_media_world_page.dart';
import 'screens/suggestions_page.dart';
import 'screens/test_asset_lab_page.dart';
import 'screens/timeline_world_page.dart';
import 'screens/world_status_page.dart';
import 'widgets/living_world_scene.dart';
import 'screens/galaxy_home_page.dart';
import 'screens/galaxy_command_center_page.dart';
import 'widgets/darkest_world_universe.dart';

const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabasePublishableKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    runApp(const DarkestWorldApp(configurationMissing: true));
    return;
  }
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePublishableKey);
  runApp(const DarkestWorldApp());
}

class DarkestWorldApp extends StatelessWidget {
  final bool configurationMissing;
  const DarkestWorldApp({super.key, this.configurationMissing = false});
  @override
  Widget build(BuildContext context) => MaterialApp(title: 'Darkest-World', theme: ThemeData.dark(useMaterial3: true), home: configurationMissing ? const _ConfigurationMissingPage() : const _AccessControlledHome());
}

class _ConfigurationMissingPage extends StatelessWidget {
  const _ConfigurationMissingPage();
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('DarkestWorld configuration is missing.')));
}

class _AccessControlledHome extends StatefulWidget {
  const _AccessControlledHome();
  @override
  State<_AccessControlledHome> createState() => _AccessControlledHomeState();
}

class _AccessControlledHomeState extends State<_AccessControlledHome> {
  late bool _signedIn;
  late final StreamSubscription<AuthState> _authSubscription;

  static const _worlds = <GalaxyWorld>[
    GalaxyWorld(kind: GalaxyWorldKind.vegeta, title: 'VEGETA', description: 'The darker heart of DarkestWorld.'),
    GalaxyWorld(kind: GalaxyWorldKind.game, title: 'GAME-WORLD', description: 'Games you have played and what comes next.'),
    GalaxyWorld(kind: GalaxyWorldKind.music, title: 'MUSIC-WORLD', description: 'Music, sound and the worlds they create.'),
    GalaxyWorld(kind: GalaxyWorldKind.identity, title: 'DARKEST-IDENTITY', description: 'The identity behind DarkestWorld.'),
    GalaxyWorld(kind: GalaxyWorldKind.family, title: 'DARKESTFAMILY', description: 'Personas, people and stories.'),
    GalaxyWorld(kind: GalaxyWorldKind.cinema, title: 'CINEMA-WORLD', description: 'Films and series.'),
    GalaxyWorld(kind: GalaxyWorldKind.creation, title: 'CREATION', description: 'Art, projects and experiments.'),
    GalaxyWorld(kind: GalaxyWorldKind.archive, title: 'ARCHIVE', description: 'Things worth keeping.'),
    GalaxyWorld(kind: GalaxyWorldKind.comingSoon, title: 'COMING SOON', description: 'What DarkestWorld can become.'),
  ];

  @override
  void initState() {
    super.initState();
    _signedIn = Supabase.instance.client.auth.currentUser != null;
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) setState(() => _signedIn = data.session != null);
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  void _openCommandWorld(BuildContext context, GalaxyWorld world) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GalaxyHomePage()));
  }

  @override
  Widget build(BuildContext context) {
    if (!DarkestWorldAccessPolicy.canEnterGalaxy(signedIn: _signedIn)) return const GuestModePage();
    return Stack(fit: StackFit.expand, children: [
      const GalaxyHomePage(),
      Positioned(
        right: 18,
        bottom: 18,
        child: Semantics(
          button: true,
          label: 'Open Galaxy Command Center',
          child: Material(
            color: const Color(0xE0060710),
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GalaxyCommandCenterPage(
                worlds: _worlds,
                selected: null,
                mapped: const <GalaxyWorldKind>{},
                visited: const <GalaxyWorldKind>{},
                onOpen: (world) => _openCommandWorld(context, world),
                onClose: () => Navigator.of(context).pop(),
              ))),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                decoration: BoxDecoration(border: Border.all(color: Colors.white24), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 18)]),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('COMMAND', style: TextStyle(color: Colors.white70, fontSize: 7, letterSpacing: 1.8)), SizedBox(width: 9), Text('⌘', style: TextStyle(color: Color(0x4DFFFFFF), fontSize: 10))]),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
