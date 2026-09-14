import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DarkestWorldNavigationObserver extends NavigatorObserver {
  final ValueNotifier<List<Route<dynamic>>> stack = ValueNotifier<List<Route<dynamic>>>(const []);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final current = [...stack.value];
    current.removeWhere((item) => identical(item, route));
    current.add(route);
    _emit(current);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final current = [...stack.value]..removeWhere((item) => identical(item, route));
    if (previousRoute != null && !current.contains(previousRoute)) current.add(previousRoute);
    _emit(current);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final current = [...stack.value];
    if (oldRoute != null) current.removeWhere((item) => identical(item, oldRoute));
    if (newRoute != null) current.add(newRoute);
    _emit(current);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    final current = [...stack.value]..removeWhere((item) => identical(item, route));
    _emit(current);
  }

  void _emit(List<Route<dynamic>> routes) {
    stack.value = routes.length > 10 ? routes.sublist(routes.length - 10) : routes;
  }

  String get currentLabel {
    final route = stack.value.isEmpty ? null : stack.value.last;
    final name = route?.settings.name;
    if (name != null && name.isNotEmpty) return name.replaceAll('/', ' / ').toUpperCase();
    return _friendlyRoute(route?.runtimeType.toString() ?? 'GalaxyHomePage');
  }

  static String _friendlyRoute(String raw) {
    var value = raw.replaceAll('Page', '').replaceAll('_', ' ');
    value = value.replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m.group(1)} ${m.group(2)}');
    return value.trim().toUpperCase();
  }
}

class DarkestWorldSystemHud extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final DarkestWorldNavigationObserver observer;
  const DarkestWorldSystemHud({super.key, required this.navigatorKey, required this.observer});

  @override
  State<DarkestWorldSystemHud> createState() => _DarkestWorldSystemHudState();
}

class _DarkestWorldSystemHudState extends State<DarkestWorldSystemHud> {
  bool commandOpen = false;

  void _home() {
    widget.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    setState(() => commandOpen = false);
  }

  void _back() {
    final nav = widget.navigatorKey.currentState;
    if (nav?.canPop() ?? false) nav!.pop();
  }

  void _toggleCommand() => setState(() => commandOpen = !commandOpen);

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final ctrlOrMeta = HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed;
    if (ctrlOrMeta && event.logicalKey == LogicalKeyboardKey.keyK) {
      _toggleCommand();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape && commandOpen) {
      setState(() => commandOpen = false);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape && !commandOpen) {
      _back();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 620;
    return Focus(
      autofocus: true,
      onKeyEvent: _key,
      child: AnimatedBuilder(
        animation: widget.observer.stack,
        builder: (context, _) => Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: IgnorePointer(child: _TopAtmosphere(compact: compact))),
            if (commandOpen)
              Positioned.fill(child: _CommandOverlay(onClose: _toggleCommand, onHome: _home, onBack: _back, routeLabel: widget.observer.currentLabel)),
            IgnorePointer(
              ignoring: false,
              child: SafeArea(
                minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: _HudBar(compact: compact, routeLabel: widget.observer.currentLabel, onHome: _home, onBack: _back, onCommand: _toggleCommand),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopAtmosphere extends StatelessWidget {
  final bool compact;
  const _TopAtmosphere({required this.compact});
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Row(children: [
              const Text('DARKESTWORLD', style: TextStyle(color: Color(0x99FFFFFF), fontSize: 7, letterSpacing: 2.8)),
              const SizedBox(width: 10),
              Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x777F70B0))),
              const SizedBox(width: 8),
              Expanded(child: Text(compact ? 'SYSTEM ONLINE' : 'SYSTEM ONLINE  /  CINEMATIC ATLAS', overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x45FFFFFF), fontSize: 5.5, letterSpacing: 1.2))),
              if (!compact) const SizedBox(width: 10),
              if (!compact) const Text('CTRL / K  COMMAND', style: TextStyle(color: Color(0x38FFFFFF), fontSize: 5, letterSpacing: 1)),
            ]),
          ),
        ),
      );
}

class _HudBar extends StatelessWidget {
  final bool compact;
  final String routeLabel;
  final VoidCallback onHome, onBack, onCommand;
  const _HudBar({required this.compact, required this.routeLabel, required this.onHome, required this.onBack, required this.onCommand});

  @override
  Widget build(BuildContext context) => Material(
        type: MaterialType.transparency,
        child: Container(
          height: compact ? 48 : 52,
          decoration: BoxDecoration(
            color: const Color(0xEC05060D),
            border: Border.all(color: const Color(0x307F70B0)),
            boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 30, spreadRadius: 2)],
          ),
          child: Row(children: [
            _HudButton(icon: Icons.public, label: compact ? 'GALAXY' : 'GALAXY / HOME', onTap: onHome, active: true),
            _HudButton(icon: Icons.arrow_back_ios_new, label: 'BACK', onTap: onBack),
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Row(children: [
              const Text('CURRENT', style: TextStyle(fontSize: 5, letterSpacing: 1.3, color: Color(0x45FFFFFF))),
              const SizedBox(width: 9),
              Expanded(child: Text(routeLabel, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 6, letterSpacing: 1.2, color: Color(0x99FFFFFF)))),
              if (!compact) const SizedBox(width: 12),
              if (!compact) const Flexible(child: Text('WORLD / ARCHIVE / DETAIL', overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: TextStyle(fontSize: 5, letterSpacing: .9, color: Color(0x35FFFFFF)))),
            ]))),
            _HudButton(icon: Icons.terminal, label: compact ? 'CMD' : 'COMMAND', onTap: onCommand),
          ]),
        ),
      );
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
          decoration: BoxDecoration(color: active ? const Color(0x10FFFFFF) : Colors.transparent, border: const Border(right: BorderSide(color: Color(0x18FFFFFF))),),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 12, color: active ? const Color(0xAAFFFFFF) : const Color(0x667F8AA2)),
            const SizedBox(width: 7),
            Text(label, style: TextStyle(fontSize: 5.5, letterSpacing: 1.3, color: active ? const Color(0xBBFFFFFF) : const Color(0x667F8AA2))),
          ]),
        ),
      );
}

class _CommandOverlay extends StatelessWidget {
  final VoidCallback onClose, onHome, onBack;
  final String routeLabel;
  const _CommandOverlay({required this.onClose, required this.onHome, required this.onBack, required this.routeLabel});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onClose,
          child: Container(
            color: const Color(0xA8000005),
            child: Center(child: GestureDetector(
              onTap: () {},
              child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xF0080910), border: Border.all(color: const Color(0x357F70B0)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 50, spreadRadius: 4)]),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(padding: const EdgeInsets.fromLTRB(20, 18, 14, 14), child: Row(children: [const Expanded(child: Text('DARKESTWORLD COMMAND', style: TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 2.2))), InkWell(onTap: onClose, child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.close, size: 15, color: Color(0x88FFFFFF))))])),
                  const Divider(height: 1, color: Color(0x18FFFFFF)),
                  Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                    _CommandRow(label: 'CURRENT LOCATION', value: routeLabel, icon: Icons.my_location),
                    const SizedBox(height: 7),
                    _CommandAction(icon: Icons.public, label: 'RETURN TO GALAXY', detail: 'Reset the world route', onTap: onHome),
                    _CommandAction(icon: Icons.arrow_back_ios_new, label: 'STEP BACK', detail: 'Return to previous layer', onTap: onBack),
                  ])),
                  Container(padding: const EdgeInsets.all(14), decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x18FFFFFF)))), child: const Row(children: [Expanded(child: Text('ESC / CLICK OUTSIDE  CLOSE', style: TextStyle(color: Color(0x45FFFFFF), fontSize: 5, letterSpacing: 1))), Text('SYSTEM CONTROL', style: TextStyle(color: Color(0x35FFFFFF), fontSize: 5, letterSpacing: 1))])),
                ]),
              )),
            )),
          ),
        ),
      );
}

class _CommandRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _CommandRow({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0x0AFFFFFF), border: Border.all(color: const Color(0x14FFFFFF))), child: Row(children: [Icon(icon, size: 13, color: const Color(0x70FFFFFF)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Color(0x45FFFFFF), fontSize: 5, letterSpacing: 1.2)), const SizedBox(height: 4), Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xB3FFFFFF), fontSize: 7, letterSpacing: 1))]))]));
}

class _CommandAction extends StatelessWidget {
  final IconData icon;
  final String label, detail;
  final VoidCallback onTap;
  const _CommandAction({required this.icon, required this.label, required this.detail, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(type: MaterialType.transparency, child: InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10), child: Row(children: [Icon(icon, size: 12, color: const Color(0x70FFFFFF)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Color(0xAAFFFFFF), fontSize: 6.5, letterSpacing: 1)), const SizedBox(height: 3), Text(detail, style: const TextStyle(color: Color(0x45FFFFFF), fontSize: 5.5))])), const Icon(Icons.chevron_right, size: 14, color: Color(0x45FFFFFF))]))));
}
