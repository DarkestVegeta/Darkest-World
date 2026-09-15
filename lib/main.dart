import 'package:flutter/material.dart';
import 'screens/galaxy_home_page.dart';
import 'widgets/darkest_world_system_hud.dart';
import 'widgets/darkest_world_route_history.dart';
import 'widgets/darkest_world_content_navigation.dart';
import 'widgets/darkest_world_detail_navigation_bridge.dart';
import 'widgets/darkest_world_archive_atmosphere.dart';
import 'widgets/darkest_world_cinematic_optics.dart';
import 'widgets/darkest_world_archive_lens.dart';
import 'widgets/darkest_world_archive_stage.dart';

final GlobalKey<NavigatorState> darkestWorldNavigatorKey = GlobalKey<NavigatorState>();
final DarkestWorldNavigationObserver darkestWorldNavigationObserver = DarkestWorldNavigationObserver();
final DarkestWorldContentDetailObserver darkestWorldContentDetailObserver = DarkestWorldContentDetailObserver();

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
      navigatorKey: darkestWorldNavigatorKey,
      navigatorObservers: [
        darkestWorldNavigationObserver,
        darkestWorldContentDetailObserver,
      ],
      theme: ThemeData.dark(useMaterial3: true),
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [
          child ?? const SizedBox.shrink(),
          const DarkestWorldArchiveAtmosphere(),
          const DarkestWorldCinematicOptics(),
          const DarkestWorldArchiveLens(),
          const DarkestWorldArchiveStage(),
          const DarkestWorldContentNavigation(),
          DarkestWorldRouteHistory(
            navigatorKey: darkestWorldNavigatorKey,
            observer: darkestWorldNavigationObserver,
          ),
          DarkestWorldSystemHud(
            navigatorKey: darkestWorldNavigatorKey,
            observer: darkestWorldNavigationObserver,
          ),
        ],
      ),
      home: const GalaxyHomePage(),
    );
  }
}
