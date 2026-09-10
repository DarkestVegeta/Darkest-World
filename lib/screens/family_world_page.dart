import 'package:flutter/material.dart';

class FamilyWorldPage extends StatelessWidget {
  final String title;
  final String description;

  const FamilyWorldPage({super.key, required this.title, required this.description});

  static const members = <String>[
    'VEGETARR',
    'MURKHAL',
    'VALKYRRA',
    'ELDRAVER',
    'EIRLYTH',
    'SKJARNETH',
    'HELVYR',
    'THUNVARR',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03050A),
      appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: ListView(
            padding: const EdgeInsets.all(28),
            children: [
              const Text('DARKESTFAMILY', style: TextStyle(fontSize: 34, letterSpacing: 5, fontWeight: FontWeight.w300)),
              const SizedBox(height: 10),
              Text(description, style: TextStyle(color: Colors.white.withValues(alpha: .55), fontSize: 14)),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(gradient: const RadialGradient(colors: [Color(0xFF17243A), Color(0xFF080C14), Color(0xFF03050A)]), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF7193C4).withValues(alpha: .18))),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('THE FAMILY', style: TextStyle(fontSize: 16, letterSpacing: 3)),
                  SizedBox(height: 8),
                  Text('Personas and companion identities belonging to the DarkestFamily. The Burdened remains a group name, not a separate world.'),
                ]),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 250, mainAxisExtent: 130, crossAxisSpacing: 14, mainAxisSpacing: 14),
                itemCount: members.length,
                itemBuilder: (_, i) => _MemberCard(name: members[i], index: i),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final String name;
  final int index;
  const _MemberCard({required this.name, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .025), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: .08))),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0xFF526D99).withValues(alpha: .45), const Color(0xFF080B12)]), border: Border.all(color: const Color(0xFF829BC4).withValues(alpha: .22))), child: Center(child: Text('${index + 1}', style: TextStyle(color: Colors.white.withValues(alpha: .55), fontSize: 11)))),
        const SizedBox(width: 14),
        Expanded(child: Text(name, style: const TextStyle(fontSize: 12, letterSpacing: 1.7))),
      ]),
    );
  }
}
