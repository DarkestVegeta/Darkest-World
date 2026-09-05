import 'package:flutter/material.dart';

class BasicSectionPage extends StatelessWidget {
  final String title;
  final String description;
  final List<String> items;

  const BasicSectionPage({
    super.key,
    required this.title,
    required this.description,
    this.items = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(description),
          const SizedBox(height: 24),
          if (items.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Nog geen data beschikbaar.'),
              ),
            )
          else
            for (final item in items)
              Card(
                child: ListTile(
                  title: Text(item),
                  onTap: () {},
                ),
              ),
        ],
      ),
    );
  }
}
