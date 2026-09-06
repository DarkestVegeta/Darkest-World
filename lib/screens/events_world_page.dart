import 'package:flutter/material.dart';

import '../core/events_world_repository.dart';

class EventsWorldPage extends StatefulWidget {
  final String title;
  final String description;

  const EventsWorldPage({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  State<EventsWorldPage> createState() => _EventsWorldPageState();
}

class _EventsWorldPageState extends State<EventsWorldPage> {
  final _repository = EventsWorldRepository();
  late Future<List<WorldEvent>> _events;

  @override
  void initState() {
    super.initState();
    _events = _repository.loadEvents();
  }

  void _reload() {
    setState(() => _events = _repository.loadEvents());
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
      body: FutureBuilder<List<WorldEvent>>(
        future: _events,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Events laden mislukt: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _reload,
                    child: const Text('Opnieuw'),
                  ),
                ],
              ),
            );
          }

          final events = snapshot.data ?? const <WorldEvent>[];
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(widget.description),
              const SizedBox(height: 24),
              if (events.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Nog geen events beschikbaar.'),
                  ),
                )
              else
                for (final event in events) _EventCard(event: event),
            ],
          );
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final WorldEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            if (event.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(event.description),
            ],
            if (event.startsAt != null || event.endsAt != null || event.location.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (event.startsAt != null)
                    Chip(label: Text('Start: ${_formatDate(event.startsAt!)}')),
                  if (event.endsAt != null)
                    Chip(label: Text('Einde: ${_formatDate(event.endsAt!)}')),
                  if (event.location.isNotEmpty)
                    Chip(label: Text(event.location)),
                ],
              ),
            ],
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
