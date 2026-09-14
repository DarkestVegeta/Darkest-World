import 'package:flutter/material.dart';

class DarkestWorldSystemHud extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const DarkestWorldSystemHud({super.key, required this.navigatorKey});

  void _home() {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  void _back() {
    final nav = navigatorKey.currentState;
    if (nav?.canPop() ?? false) nav!.pop();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 620;
    return IgnorePointer(
      ignoring: false,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Container(
              height: compact ? 42 : 46,
              decoration: BoxDecoration(
                color: const Color(0xE805060D),
                border: Border.all(color: const Color(0x267F70B0)),
                boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 28, spreadRadius: 2)],
              ),
              child: Row(children: [
                _HudButton(icon: Icons.public, label: compact ? 'GALAXY' : 'GALAXY / HOME', onTap: _home, active: true),
                _HudButton(icon: Icons.arrow_back_ios_new, label: 'BACK', onTap: _back),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(children: [
                      Container(width: 5, height: 5, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xAA8F82A9))),
                      const SizedBox(width: 9),
                      const Expanded(child: Text('DARKESTWORLD  /  SYSTEM NAVIGATION', overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 6, letterSpacing: 1.8, color: Color(0x66FFFFFF)))),
                      if (!compact) const Text('WORLD → ARCHIVE → DETAIL', style: TextStyle(fontSize: 5.5, letterSpacing: 1.1, color: Color(0x3FFFFFFF))),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _HudButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  const _HudButton({required this.icon, required this.label, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: active ? const Color(0x10FFFFFF) : Colors.transparent,
            border: const Border(right: BorderSide(color: Color(0x18FFFFFF))),
          ),
          child: Row(children: [
            Icon(icon, size: 12, color: active ? const Color(0xAAFFFFFF) : const Color(0x667F8AA2)),
            const SizedBox(width: 7),
            Text(label, style: TextStyle(fontSize: 5.5, letterSpacing: 1.3, color: active ? const Color(0xBBFFFFFF) : const Color(0x667F8AA2))),
          ]),
        ),
      );
}
