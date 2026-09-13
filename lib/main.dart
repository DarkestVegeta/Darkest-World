import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/access_policy.dart';
import 'screens/guest_mode_page.dart';
import 'screens/galaxy_home_page.dart';

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
  Widget build(BuildContext context) => MaterialApp(
        title: 'Darkest-World',
        theme: ThemeData.dark(useMaterial3: true),
        home: configurationMissing ? const _ConfigurationMissingPage() : const _AccessControlledHome(),
      );
}

class _ConfigurationMissingPage extends StatelessWidget {
  const _ConfigurationMissingPage();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('DarkestWorld configuration is missing.')),
      );
}

class _AccessControlledHome extends StatefulWidget {
  const _AccessControlledHome();
  @override
  State<_AccessControlledHome> createState() => _AccessControlledHomeState();
}

class _AccessControlledHomeState extends State<_AccessControlledHome> {
  late bool _signedIn;
  late final StreamSubscription<AuthState> _authSubscription;

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

  @override
  Widget build(BuildContext context) {
    if (!DarkestWorldAccessPolicy.canEnterGalaxy(signedIn: _signedIn)) {
      return const GuestModePage();
    }
    // GalaxyHomePage owns the complete Galaxy navigation session. Keeping a
    // second command center here would create a disconnected state machine:
    // its mapped/visited/selection state could not reflect the live Galaxy.
    return const GalaxyHomePage();
  }
}
