import 'package:flutter/material.dart';
import 'content_browser_page.dart';

class CinemaWorldPage extends StatelessWidget {
  final String title;
  final String description;

  const CinemaWorldPage({super.key, required this.title, required this.description});

  void _open(BuildContext context, String type, String label) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ContentBrowserPage(title: label, contentType: type),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03030A),
      appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: ListView(
            padding: const EdgeInsets.all(28),
            children: [
              const Text('CINEMA-WORLD', style: TextStyle(fontSize: 34, letterSpacing: 5, fontWeight: FontWeight.w300)),
              const SizedBox(height: 10),
              Text(description, style: TextStyle(color: Colors.white.withValues(alpha: .55), fontSize: 14)),
              const SizedBox(height: 34),
              LayoutBuilder(builder: (context, c) {
                final wide = c.maxWidth > 650;
                final cards = [
                  _Portal(title: 'FILMS', subtitle: 'Live movie discovery via TMDB', icon: Icons.movie_outlined, onTap: () => _open(context, 'movie', 'FILMS • CINEMA-WORLD')),
                  _Portal(title: 'SERIES', subtitle: 'Live series discovery via TMDB', icon: Icons.tv_outlined, onTap: () => _open(context, 'series', 'SERIES • CINEMA-WORLD')),
                ];
                return Flex(direction: wide ? Axis.horizontal : Axis.vertical, children: [for (var i = 0; i < cards.length; i++) ...[Expanded(flex: 1, child: cards[i]), if (i == 0) SizedBox(width: wide ? 18 : 0, height: wide ? 0 : 18)]]);
              }),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .035), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: .08))),
                child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.cloud_outlined), SizedBox(width: 14), Expanded(child: Text('Zoekresultaten komen live van TMDB en worden niet opgeslagen in de DarkestWorld-database.'))]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Portal extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _Portal({required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 245,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          gradient: const RadialGradient(colors: [Color(0xFF242044), Color(0xFF080812), Color(0xFF03030A)]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF8B76D8).withValues(alpha: .22)),
          boxShadow: [BoxShadow(color: const Color(0xFF604BA0).withValues(alpha: .12), blurRadius: 35)],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 52, color: const Color(0xFFB8A8FF).withValues(alpha: .75)),
          const SizedBox(height: 22),
          Text(title, style: const TextStyle(fontSize: 22, letterSpacing: 4)),
          const SizedBox(height: 9),
          Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: .42))),
          const SizedBox(height: 20),
          Text('ENTER', style: TextStyle(fontSize: 9, letterSpacing: 3, color: Colors.white.withValues(alpha: .28))),
        ]),
      ),
    );
  }
}
