import 'package:flutter/material.dart';

import '../core/timeline_models.dart';
import '../core/timeline_repository.dart';

class TimelineWorldPage extends StatefulWidget {
  final String title;
  final String description;
  final TimelineRepository repository;

  const TimelineWorldPage({
    super.key,
    required this.title,
    required this.description,
    this.repository = const TimelineRepository(),
  });

  @override
  State<TimelineWorldPage> createState() => _TimelineWorldPageState();
}

class _TimelineWorldPageState extends State<TimelineWorldPage> {
  List<TimelineItem> _items = const [];
  bool _loading = true;
  String? _error;
  String? _contentType;

  @override
  void initState() {
    super.initState();
    _loadTimeline();
  }

  Future<void> _loadTimeline() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final items = await widget.repository.getTimelineItems(
        contentType: _contentType,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _setContentType(String? value) {
    if (_contentType == value) return;
    setState(() => _contentType = value);
    _loadTimeline();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Vernieuwen',
            onPressed: _loading ? null : _loadTimeline,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Timeline / Chronology',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.description),
                  const SizedBox(height: 18),
                  const Text(
                    'Live chronology',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Games, Movies and Series are shown in the chronology order stored in DarkestWorld.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _filter('All', null),
              _filter('Games', 'game'),
              _filter('Movies', 'movie'),
              _filter('Series', 'series'),
            ],
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _ErrorCard(error: _error!, onRetry: _loadTimeline)
          else if (_items.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nog geen timeline-content beschikbaar. Zodra Games, Movies of Series aan de timeline zijn gekoppeld, verschijnen ze hier automatisch.',
                ),
              ),
            )
          else ...[
            Text(
              '${_items.length} timeline-items',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < _items.length; index++)
              _TimelineItemCard(item: _items[index], position: index + 1),
          ],
        ],
      ),
    );
  }

  Widget _filter(String label, String? value) {
    return ChoiceChip(
      label: Text(label),
      selected: _contentType == value,
      onSelected: (_) => _setContentType(value),
    );
  }
}

class _TimelineItemCard extends StatelessWidget {
  final TimelineItem item;
  final int position;

  const _TimelineItemCard({required this.item, required this.position});

  @override
  Widget build(BuildContext context) {
    final type = item.contentType.name.toUpperCase();
    final date = item.releaseDate == null
        ? null
        : item.releaseDate!.toIso8601String().split('T').first;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              child: Text(
                item.chronologyOrder?.toString() ?? position.toString(),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Chip(label: Text(type)),
                      if (item.franchise != null) Chip(label: Text(item.franchise!)),
                      if (date != null) Chip(label: Text(date)),
                    ],
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 8),
                    Text(item.description!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorCard({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Timeline laden mislukt: $error'),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Opnieuw')),
          ],
        ),
      ),
    );
  }
}
