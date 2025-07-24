import 'package:flutter/material.dart';
import '../models/workspace.dart';
import '../graph/graph_view.dart';

class GraphViewScreen extends StatefulWidget {
  final Workspace workspace;
  
  const GraphViewScreen({
    super.key,
    required this.workspace,
  });
  
  @override
  GraphViewScreenState createState() => GraphViewScreenState();
}

class GraphViewScreenState extends State<GraphViewScreen> {
  late GraphViewController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = GraphViewController(workspace: widget.workspace);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graph View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _controller.refresh();
              });
            },
            tooltip: 'Refresh graph',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GraphView(controller: _controller),
          ),
        ],
      ),
    );
  }
}
