import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:webview_windows/webview_windows.dart';
import 'galaxy_node.dart';
class GalaxyRuntimeController extends ChangeNotifier {
 final WebviewController webview; bool ready=false,loading=false; String? error; final List<GalaxyNode> _nodes=[]; final Set<String> _loadedNodeIds={};
 List<GalaxyNode> get nodes=>List.unmodifiable(_nodes); Set<String> get loadedNodeIds=>Set.unmodifiable(_loadedNodeIds);
 GalaxyRuntimeController(this.webview);
 Future<void> initialize() async {loading=true;error=null;notifyListeners();try{if(await WebviewController.getWebViewVersion()==null)throw StateError('WebView2 Runtime is not installed.');await webview.initialize();await webview.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);await webview.loadStringContent(await rootBundle.loadString('assets/babylon/galaxy_runtime.html'));ready=true;loading=false;notifyListeners();}catch(e){error=e.toString();loading=false;notifyListeners();}}
 Future<void> setNodes(List<GalaxyNode> nodes) async {_nodes..clear()..addAll(nodes);notifyListeners();if(!ready)return;final payload=jsonEncode(nodes.map((n)=>n.toRuntimeMap()).toList());await webview.executeScript('window.DarkestWorldBabylon && window.DarkestWorldBabylon.setNodes('+payload+');');_loadedNodeIds..clear()..addAll(nodes.map((n)=>n.id));notifyListeners();}
 Future<void> updateStreamingBudget({double loadDistance=20,double unloadDistance=28}) async {if(!ready)return;final payload=jsonEncode({'loadDistance':loadDistance,'unloadDistance':unloadDistance});await webview.executeScript('window.DarkestWorldBabylon && window.DarkestWorldBabylon.setStreamingPolicy('+payload+');');}
 Future<void> focusWorld(String nodeKey) async {if(ready){final safe=nodeKey.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'),'');await webview.executeScript('window.DarkestWorldBabylon && window.DarkestWorldBabylon.focusWorld("'+safe+'");');}}
 Future<void> enterWorld(String nodeKey) async {if(ready){final safe=nodeKey.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'),'');await webview.executeScript('window.DarkestWorldBabylon && window.DarkestWorldBabylon.enterWorld("'+safe+'");');}}\n Future<void> resetGalaxy() async {if(ready)await webview.executeScript('window.DarkestWorldBabylon && window.DarkestWorldBabylon.resetGalaxy();');}
 @override void dispose(){webview.dispose();super.dispose();}
}