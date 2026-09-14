import 'package:flutter/material.dart';
import 'darkest_world_system_hud.dart';

class DarkestWorldRouteHistory extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final DarkestWorldNavigationObserver observer;
  const DarkestWorldRouteHistory({super.key, required this.navigatorKey, required this.observer});

  String _label(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) return name.replaceAll('/', ' / ').toUpperCase();
    var raw = route.runtimeType.toString().replaceAll('Page', '').replaceAll('_', ' ');
    raw = raw.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m.group(1)} ${m.group(2)}');
    return raw.trim().toUpperCase();
  }

  void _jump(Route<dynamic> target) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    navigator.popUntil((route) => identical(route, target));
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 720;
    return ValueListenableBuilder<List<Route<dynamic>>>(
      valueListenable: observer.stack,
      builder: (context, routes, _) {
        if (routes.length < 2) return const SizedBox.shrink();
        final visible = routes.length > (compact ? 3 : 5) ? routes.sublist(routes.length - (compact ? 3 : 5)) : routes;
        return SafeArea(
          minimum: EdgeInsets.fromLTRB(12, compact ? 34 : 38, 12, compact ? 62 : 66),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xD9070810), border: Border.all(color: const Color(0x237F70B0)), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 18)]),
                  child: Row(children: [
                    const Icon(Icons.route, size: 10, color: Color(0x667F8AA2)),
                    const SizedBox(width: 8),
                    const Text('ROUTE', style: TextStyle(fontSize: 5, letterSpacing: 1.5, color: Color(0x45FFFFFF))),
                    const SizedBox(width: 8),
                    Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                      for (var i = 0; i < visible.length; i++) ...[
                        if (i > 0) const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.chevron_right, size: 9, color: Color(0x305F6880))),
                        InkWell(
                          onTap: i == visible.length - 1 ? null : () => _jump(visible[i]),
                          child: Text(_label(visible[i]), style: TextStyle(fontSize: 5.5, letterSpacing: 1, color: i == visible.length - 1 ? const Color(0xB3FFFFFF) : const Color(0x557F8AA2), fontWeight: i == visible.length - 1 ? FontWeight.w600 : FontWeight.normal)),
                        ),
                      ],
                    ]))),
                    const SizedBox(width: 8),
                    Text('${routes.length}', style: const TextStyle(fontSize: 5, letterSpacing: 1, color: Color(0x356F7890))),
                  ]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
