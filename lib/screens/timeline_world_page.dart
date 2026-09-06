import 'package:flutter/material.dart';

class TimelineWorldPage extends StatelessWidget {
  final String title;
  final String description;

  const TimelineWorldPage({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
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
                  Text(description),
                  const SizedBox(height: 20),
                  const Text(
                    'Construction layer',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The timeline is designed for chronological navigation across Games, Movies and Series, including cross-media and franchise chronology.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const _TimelineCard(
            label: 'Chronology',
            detail: 'Game → Game → Movie → Series → Game',
          ),
          const _TimelineCard(
            label: 'Supported content',
            detail: 'Games • Movies • Series • Franchise timelines • Related content',
          ),
          const _TimelineCard(
            label: 'Current state',
            detail: 'Timeline data is not populated yet. No timeline data is created or changed by this page.',
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final String label;
  final String detail;

  const _TimelineCard({required this.label, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(detail),
        ),
      ),
    );
  }
}
