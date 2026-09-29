import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_windows/webview_windows.dart';

class BabylonGalaxyRuntime extends StatefulWidget {
  const BabylonGalaxyRuntime({super.key});
  @override State<BabylonGalaxyRuntime> createState() => _BabylonGalaxyRuntimeState();
}

class _BabylonGalaxyRuntimeState extends State<BabylonGalaxyRuntime> {
  final WebviewController _controller = WebviewController();
  bool _ready = false;
  String? _error;

  @override
  void initState() { super.initState(); _initialize(); }

  Future<void> _initialize() async {
    try {
      if (await WebviewController.getWebViewVersion() == null) {
        throw StateError('WebView2 Runtime is not installed.');
      }
      await _controller.initialize();
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.loadStringContent(await rootBundle.loadString('assets/babylon/galaxy_runtime.html'));
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> resetGalaxy() async {
    if (_ready) await _controller.executeScript('window.DarkestWorldBabylon&&window.DarkestWorldBabylon.resetGalaxy();');
  }

  Future<void> focusWorld(String id) async {
    if (!_ready) return;
    final safeId=id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'),'');
    await _controller.executeScript('window.DarkestWorldBabylon&&window.DarkestWorldBabylon.focusWorld("$safeId");');
  }

  @override void dispose(){ _controller.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    if (_error != null) return ColoredBox(color: const Color(0xFF010107), child: Center(child: Text('GALAXY RUNTIME UNAVAILABLE\n$_error',textAlign:TextAlign.center,style:const TextStyle(color:Color(0x66FFFFFF),fontSize:9,letterSpacing:1.5))));
    if (!_ready || !_controller.value.isInitialized) return const ColoredBox(color:Color(0xFF010107),child:Center(child:SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:1))));
    return Webview(_controller);
  }
}