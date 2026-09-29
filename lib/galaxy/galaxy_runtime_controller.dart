import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:webview_windows/webview_windows.dart';
import 'galaxy_node.dart';

enum WorldEntryPhase { idle, preparing, entering, entered }

class GalaxyRuntimeController extends ChangeNotifier {
 final WebviewController webview;
 bool ready=false,loading=false;
 String? error;
 WorldEntryPhase entryPhase=WorldEntryPhase.idle;
 String? entryNodeKey;
 final List<GalaxyNode> _nodes=[];
 final Set<String> _loadedNodeIds={};
 List<GalaxyNode> get nodes=>List.unmodifiable(_nodes);
 Set<String> get loadedNodeIds=>Set.unmodifiable(_loadedNodeIds);

 GalaxyRuntimeController(this.webview);

 Future<void> initialize() async {
  loading=true; error=null; notifyListeners();
  try {
   if(await WebviewController.getWebViewVersion()==null) {
    throw StateError('WebView2 Runtime is not installed.');
   }
   await webview.initialize();
   await webview.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
   await webview.loadStringContent(await rootBundle.loadString('assets/babylon/galaxy_runtime.html'));
   ready=true; loading=false; notifyListeners();
  } catch(e) {
   error=e.toString(); loading=false; notifyListeners();
  }
 }

 Future<void> setNodes(List<GalaxyNode> nodes) async {
  _nodes..clear()..addAll(nodes);
  notifyListeners();
  if(!ready)return;
  final payload=jsonEncode(nodes.map((n)=>n.toRuntimeMap()).toList());
  await webview.executeScript('window.DarkestWorldBabylon && window.DarkestWorldBabylon.setNodes($payload);');
  _loadedNodeIds..clear()..addAll(nodes.map((n)=>n.id));
  notifyListeners();
 }

 Future<void> updateStreamingBudget({double loadDistance=20,double unloadDistance=28}) async {
  if(!ready)return;
  final payload=jsonEncode({'loadDistance':loadDistance,'unloadDistance':unloadDistance});
  await webview.executeScript('window.DarkestWorldBabylon && window.DarkestWorldBabylon.setStreamingPolicy($payload);');
 }

 Future<void> focusWorld(String nodeKey) async {
  if(ready) {
   final safe=nodeKey.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'),'');
   await webview.executeScript('window.DarkestWorldBabylon && window.DarkestWorldBabylon.focusWorld("$safe");');
  }
 }

 /// Starts Planet -> World lifecycle without pretending the final World scene/assets exist yet.
 Future<void> enterWorld(String nodeKey) async {
  if(!ready)return;
  GalaxyNode? node;
  for(final candidate in _nodes) {
   if(candidate.nodeKey==nodeKey) { node=candidate; break; }
  }
  if(node==null) {
   error='Galaxy node not found: $nodeKey';
   notifyListeners();
   return;
  }
  entryPhase=WorldEntryPhase.preparing;
  entryNodeKey=nodeKey;
  notifyListeners();

  final safe=nodeKey.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'),'');
  entryPhase=WorldEntryPhase.entering;
  notifyListeners();
  await webview.executeScript('window.DarkestWorldBabylon && window.DarkestWorldBabylon.enterWorld("$safe");');
 }

 /// Future World scene/asset lifecycle calls this when its destination is ready.
 void completeWorldEntry() {
  if(entryNodeKey==null)return;
  entryPhase=WorldEntryPhase.entered;
  notifyListeners();
 }

 void cancelWorldEntry() {
  entryPhase=WorldEntryPhase.idle;
  entryNodeKey=null;
  notifyListeners();
 }

 Future<void> resetGalaxy() async {
  if(ready)await webview.executeScript('window.DarkestWorldBabylon && window.DarkestWorldBabylon.resetGalaxy();');
  cancelWorldEntry();
 }

 @override void dispose(){webview.dispose();super.dispose();}
}
