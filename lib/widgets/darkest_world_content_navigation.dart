import 'package:flutter/material.dart';

/// Reserved global content-navigation surface.
/// Detail pages own actionable navigation; this global layer stays inert until
/// the navigation session has a safe host surface.
class DarkestWorldContentNavigation extends StatelessWidget {
  const DarkestWorldContentNavigation({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
