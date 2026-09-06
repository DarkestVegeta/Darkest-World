import 'package:flutter/material.dart';

class DarkestVegetaVisualHubPage extends StatelessWidget {
  final String title;
  final String description;

  const DarkestVegetaVisualHubPage({
    super.key,
    this.title = 'DarkestVegeta Visual Hub',
    this.description = 'Visual streaming-room navigation hub for DarkestWorld.',
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                  const SizedBox(height: 16),
                  const Text(
                    'Construction layer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The room is the navigation hub. The persona and physical screens provide the identity, while interactive targets can later connect to existing DarkestWorld destinations.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _RoomPreview(),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Navigation targets',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text('Left vertical screen — secondary navigation target'),
                  Text('Center display — primary DarkestWorld target'),
                  Text('Right horizontal screen — secondary navigation target'),
                  Text('Desk/persona area — identity and future interaction point'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No artwork, database rows, or stored images are created or changed by this construction layer.',
          ),
        ],
      ),
    );
  }
}

class _RoomPreview extends StatelessWidget {
  const _RoomPreview();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Streaming Room',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _ScreenPanel(
                    label: 'LEFT',
                    icon: Icons.stay_current_portrait,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _ScreenPanel(
                    label: 'CENTER',
                    icon: Icons.tv,
                    primary: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ScreenPanel(
                    label: 'RIGHT',
                    icon: Icons.desktop_windows,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: const Column(
                children: [
                  Icon(Icons.person, size: 42),
                  SizedBox(height: 8),
                  Text('DarkestVegeta persona / desk area'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenPanel extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;

  const _ScreenPanel({
    required this.label,
    required this.icon,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: primary ? 16 / 9 : 9 / 16,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: primary ? 42 : 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
