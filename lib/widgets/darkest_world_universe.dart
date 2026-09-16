import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show PointMode;
import 'package:flutter/material.dart';
import '../screens/galaxy_navigation_session.dart';

enum GalaxyWorldKind { vegeta, game, identity, cinema, creation, music, family, archive, comingSoon }
class GalaxyWorld { final GalaxyWorldKind kind; final String title; final String description; const GalaxyWorld({required this.kind, required this.title, required this.description}); }

class DarkestWorldUniverse extends StatefulWidget {
  final List<GalaxyWorld> worlds; final ValueChanged<GalaxyWorld>? onWorldTap;