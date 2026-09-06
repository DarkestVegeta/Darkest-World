import 'package:flutter/material.dart';

import '../core/create_your_world_repository.dart';

class CreateYourWorldPage extends StatefulWidget {
  final String title;
  final String description;

  const CreateYourWorldPage({
    super.key,
    this.title = 'Create Your World',
    this.description = 'Create your own personal world inside DarkestWorld.',
  });

  @override
  State<CreateYourWorldPage> createState() => _CreateYourWorldPageState();
}

class _CreateYourWorldPageState extends State<CreateYourWorldPage> {
  final _repository = CreateYourWorldRepository();
  late Future<CreateYourWorldSystem> _system;

  @override
  void initState() {
    super.initState();
    _system = _repository.load();
  }

  void _reload() {
    setState(() => _system = _repository.load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<CreateYourWorldSystem>(
        future: _system,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Create Your World laden mislukt.'),
                      const SizedBox(height: 8),
                      Text('${snapshot.error}'),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _reload,
                        child: const Text('Opnieuw'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final system = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        system.featureName,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(widget.description),
                      const SizedBox(height: 20),
                      Chip(
                        avatar: const Icon(Icons.construction, size: 18),
                        label: Text(_statusLabel(system.status)),
                      ),
                      const SizedBox(height: 12),
                      Text(system.description),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'World construction',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your personal world will grow over time. The foundation is visible now, while progression features remain under construction.',
                      ),
                      const SizedBox(height: 18),
                      _FeatureRow(
                        icon: Icons.auto_awesome,
                        label: 'Soul Points',
                        enabled: system.soulPointsEnabled,
                      ),
                      _FeatureRow(
                        icon: Icons.menu_book,
                        label: 'Lore discovery',
                        enabled: system.loreEnabled,
                      ),
                      _FeatureRow(
                        icon: Icons.lock_open,
                        label: 'World unlocks',
                        enabled: system.worldUnlocksEnabled,
                      ),
                      _FeatureRow(
                        icon: Icons.visibility,
                        label: 'Visible locked areas',
                        enabled: system.visibleLockedAreasEnabled,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'No personal-world data is created or changed here yet. This page currently exposes the construction state of the system only.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'construction':
        return 'In construction';
      default:
        return status;
    }
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;

  const _FeatureRow({
    required this.icon,
    required this.label,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(enabled ? 'Enabled' : 'Under construction'),
    );
  }
}
