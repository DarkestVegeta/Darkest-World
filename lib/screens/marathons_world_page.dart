import 'package:flutter/material.dart';

import '../core/marathons_world_repository.dart';

class MarathonsWorldPage extends StatefulWidget {
  final String title;
  final String description;

  const MarathonsWorldPage({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  State<MarathonsWorldPage> createState() => _MarathonsWorldPageState();
}

class _MarathonsWorldPageState extends State<MarathonsWorldPage> {
  final _repository = MarathonsWorldRepository();
  late Future<List<WorldMarathon>> _marathons;

  @override
  void initState() {
    super.initState();
    _marathons = _repository.loadMarathons();
  }

  void _reload() {
    setState(() => _marathons = _repository.loadMarathons());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Vernieuwen',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<WorldMarathon>>(
        future: _marathons,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Marathons laden mislukt: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _reload, child: const Text('Opnieuw')),
                ],
              ),
            );
          }

          final marathons = snapshot.data ?? const <WorldMarathon>[];
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(widget.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(widget.description),
              const SizedBox(height: 24),
              if (marathons.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Nog geen marathons beschikbaar.'),
                  ),
                )
              else
                for (final marathon in marathons) _MarathonCard(marathon: marathon),
            ],
          );
        },
      ),
    );
  }
}

class _MarathonCard extends StatelessWidget {
  final WorldMarathon marathon;

  const _MarathonCard({required this.marathon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(marathon.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            if (marathon.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(marathon.description),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (marathon.status.isNotEmpty) Chip(label: Text(marathon.status)),
                if (marathon.startsAt != null) Chip(label: Text('Start: ${_formatDate(marathon.startsAt!)}')),
                if (marathon.endsAt != null) Chip(label: Text('Einde: ${_formatDate(marathon.endsAt!)}')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    final two = (int number) => number.toString().padLeft(2, '0');
    return '${two(local.day)}-${two(local.month)}-${local.year} ${two(local.hour)}:${two(local.minute)}';
  }
}
