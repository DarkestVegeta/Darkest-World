import 'package:flutter/material.dart';
import '../core/world_status_repository.dart';

class WorldStatusPage extends StatefulWidget {
  const WorldStatusPage({super.key});

  @override
  State<WorldStatusPage> createState() => _WorldStatusPageState();
}

class _WorldStatusPageState extends State<WorldStatusPage> {
  final _repository = WorldStatusRepository();
  Future<WorldStatus>? _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() => _future = _repository.load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Darkest-World Status'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<WorldStatus>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Status laden mislukt: ${snapshot.error}'));
          }
          final status = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text('Basic system check', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Live counts rechtstreeks uit Supabase. Dit is bewust basic en bedoeld om de hele basis te testen.'),
              const SizedBox(height: 24),
              _row('World sections', status.sections),
              _row('All assets', status.assets),
              _row('SNES sealed assets', status.snesAssets),
              _row('Assets with public URL', status.publicAssets),
              _row('Content records', status.content),
              _row('Relations', status.relations),
              _row('Timeline records', status.timeline),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    status.snesAssets >= 890
                        ? 'SNES minimum: PASS (890+ aanwezig)'
                        : 'SNES minimum: NOT READY (minder dan 890)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, int value) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text('$value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
