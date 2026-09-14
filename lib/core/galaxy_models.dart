enum GalaxyWorldKind {
  vegeta,
  game,
  identity,
  cinema,
  creation,
  music,
  family,
  archive,
  comingSoon,
}

class GalaxyWorld {
  final GalaxyWorldKind kind;
  final String title;
  final String description;

  const GalaxyWorld({
    required this.kind,
    required this.title,
    required this.description,
  });
}
