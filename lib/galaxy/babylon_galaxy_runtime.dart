import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'galaxy_node.dart';
import 'galaxy_runtime_controller.dart';

class BabylonGalaxyRuntime extends StatefulWidget {
  final List<GalaxyNode> nodes;
  final String? focusedNodeKey;
  const BabylonGalaxyRuntime({super.key,this.nodes=const [],this.focusedNodeKey});
  @override State<BabylonGalaxyRuntime> createState()=>_BabylonGalaxyRuntimeState();
}
class _BabylonGalaxyRuntimeState extends State<BabylonGalaxyRuntime>{
  late final GalaxyRuntimeController _runtime;
  @override void initState(){super.initState();_runtime=GalaxyRuntimeController(WebviewController());_runtime.addListener(_changed);_initialize();}
  Future<void> _initialize() async {
    await _runtime.initialize();
    if(_runtime.ready){
      await _runtime.setNodes(widget.nodes);
      await _runtime.updateStreamingBudget();
      await _runtime.setGameWorldNavigation();
      if(widget.focusedNodeKey!=null)await _runtime.focusWorld(widget.focusedNodeKey!);
    }
  }
  void _changed(){if(mounted)setState((){});}
  @override void didUpdateWidget(covariant BabylonGalaxyRuntime oldWidget){
    super.didUpdateWidget(oldWidget);
    if(oldWidget.nodes!=widget.nodes&&_runtime.ready)_runtime.setNodes(widget.nodes);
    if(oldWidget.focusedNodeKey!=widget.focusedNodeKey&&widget.focusedNodeKey!=null&&_runtime.ready)_runtime.focusWorld(widget.focusedNodeKey!);
  }
  @override void dispose(){_runtime.removeListener(_changed);_runtime.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    if(_runtime.error!=null)return ColoredBox(color:const Color(0xFF010107),child:Center(child:Text('GALAXY RUNTIME UNAVAILABLE\n'+_runtime.error!,textAlign:TextAlign.center,style:const TextStyle(color:Color(0x66FFFFFF),fontSize:9,letterSpacing:1.5))));
    if(!_runtime.ready)return const ColoredBox(color:Color(0xFF010107),child:Center(child:SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:1))));
    return Webview(_runtime.webview);
  }
}