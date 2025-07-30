import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/page.dart' as app_models;
import '../models/workspace.dart';
import '../models/blocks/special_blocks.dart';

/// Graph view for visualizing connections between pages
class GraphViewController extends ChangeNotifier {
  final Workspace? workspace;
  final Map<String, NodeData> _nodes = {};
  final List<EdgeData> _edges = [];
  bool _isInitialized = false;

  GraphViewController({required this.workspace});

  /// Initialize the graph view
  void initialize() {
    if (_isInitialized) return;

    _buildGraph();
    _isInitialized = true;
    notifyListeners();
  }

  /// Build the graph from workspace data
  void _buildGraph() {
    if (workspace == null) return;
    _nodes.clear();
    _edges.clear();

    // Workspace guarantees pageOrder is a non-null List<String>
    final safePageOrder =
        workspace!.pageOrder.where((e) => e.isNotEmpty && e != 'null').toList();
    for (var e in workspace!.pageOrder) {
      if (e.isEmpty || e == 'null') {
        debugPrint('GraphView: pageOrder entry is empty or "null": $e');
      }
    }

    // Add nodes for each page
    for (final pageId in safePageOrder) {
      final page = workspace!.pages[pageId];
      if (page != null) {
        _nodes[pageId] = NodeData(
          id: pageId,
          title: page.title,
          tags: page.tags,
        );
      }
    }

    // Add edges based on links between pages
    for (final pageId in safePageOrder) {
      final page = workspace!.pages[pageId];
      if (page == null) continue;

      // Find links in page blocks
      for (final block in page.blocks.values) {
        if (block.type == 'link' && block is LinkBlock) {
          final targetId = block.targetId;
          if (targetId.isNotEmpty && _nodes.containsKey(targetId)) {
            _edges.add(EdgeData(
              source: pageId,
              target: targetId,
              type: EdgeType.link,
            ));
          }
        }
      }

      // Add edges based on tags
      for (final otherPageId in safePageOrder) {
        if (pageId == otherPageId) continue;

        final otherPage = workspace!.pages[otherPageId];
        if (otherPage == null) continue;

        // Check for shared tags
        final sharedTags =
            page.tags.toSet().intersection(otherPage.tags.toSet());
        if (sharedTags.isNotEmpty) {
          _edges.add(EdgeData(
            source: pageId,
            target: otherPageId,
            type: EdgeType.tag,
            weight: sharedTags.length,
          ));
        }
      }
    }
  }

  /// Get all nodes
  List<NodeData> get nodes => _nodes.values.toList();

  /// Get all edges
  List<EdgeData> get edges => _edges;

  /// Refresh the graph
  void refresh() {
    _buildGraph();
    notifyListeners();
  }
}

/// Node data for graph view
class NodeData {
  final String id;
  final String title;
  final List<String> tags;

  NodeData({
    required this.id,
    required this.title,
    required this.tags,
  });
}

/// Edge data for graph view
class EdgeData {
  final String source;
  final String target;
  final EdgeType type;
  final int weight;

  EdgeData({
    required this.source,
    required this.target,
    required this.type,
    this.weight = 1,
  });
}

/// Edge type enum
enum EdgeType {
  link,
  tag,
  reference,
}

/// Graph view widget
class GraphView extends StatefulWidget {
  final GraphViewController controller;

  const GraphView({
    super.key,
    required this.controller,
  });

  @override
  GraphViewState createState() => GraphViewState();
}

class GraphViewState extends State<GraphView> {
  late Graph graph;
  late Algorithm algorithm;
  double _zoom = 1.0;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();

    // Initialize graph
    graph = Graph();
    algorithm = FruchtermanReingoldAlgorithm(iterations: 1000);

    // Initialize controller
    widget.controller.addListener(_updateGraph);
    widget.controller.initialize();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateGraph);
    super.dispose();
  }

  void _updateGraph() {
    setState(() {
      _buildGraph();
    });
  }

  void _buildGraph() {
    graph = Graph();

    // Add nodes
    final nodes = <String, Node>{};
    for (final nodeData in widget.controller.nodes) {
      final node = Node.Id(nodeData.id);
      nodes[nodeData.id] = node;
      graph.addNode(node);
    }

    // Add edges
    for (final edgeData in widget.controller.edges) {
      final sourceNode = nodes[edgeData.source];
      final targetNode = nodes[edgeData.target];

      if (sourceNode != null && targetNode != null) {
        graph.addEdge(
          sourceNode,
          targetNode,
          paint: Paint()
            ..color = _getEdgeColor(edgeData.type)
            ..strokeWidth = math.min(1.0 + edgeData.weight * 0.5, 3.0),
        );
      }
    }
  }

  Color _getEdgeColor(EdgeType type) {
    switch (type) {
      case EdgeType.link:
        return Colors.blue;
      case EdgeType.tag:
        return Colors.green;
      case EdgeType.reference:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        // Store initial scale and offset
      },
      onScaleUpdate: (details) {
        setState(() {
          _zoom = (_zoom * details.scale).clamp(0.5, 2.0);
          _offset += details.focalPointDelta;
        });
      },
      child: ClipRect(
        child: CustomPaint(
          painter: _GraphPainter(
            graph: graph,
            algorithm: algorithm,
            controller: widget.controller,
            zoom: _zoom,
            offset: _offset,
          ),
          child: Container(),
        ),
      ),
    );
  }
}

/// Custom painter for graph view
class _GraphPainter extends CustomPainter {
  final Graph graph;
  final Algorithm algorithm;
  final GraphViewController controller;
  final double zoom;
  final Offset offset;

  _GraphPainter({
    required this.graph,
    required this.algorithm,
    required this.controller,
    required this.zoom,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offset.dx + size.width / 2, offset.dy + size.height / 2);
    canvas.scale(zoom);

    // Draw edges
    for (final edge in graph.edges) {
      final sourceNode = edge.source;
      final targetNode = edge.destination;

      final sourcePos = algorithm.nodePosition(sourceNode);
      final targetPos = algorithm.nodePosition(targetNode);

      canvas.drawLine(
        Offset(sourcePos.dx, sourcePos.dy),
        Offset(targetPos.dx, targetPos.dy),
        edge.paint ?? Paint()..color = Colors.grey,
      );
    }

    // Draw nodes
    for (final node in graph.nodes) {
      final nodeId = (node.key as ValueKey<String>).value;

      final nodeData = controller._nodes[nodeId];
      if (nodeData == null) continue;

      final pos = algorithm.nodePosition(node);
      const nodeSize = 40.0;

      // Draw node background
      canvas.drawCircle(
        Offset(pos.dx, pos.dy),
        nodeSize / 2,
        Paint()..color = Colors.blue.shade100,
      );

      // Draw node border
      canvas.drawCircle(
        Offset(pos.dx, pos.dy),
        nodeSize / 2,
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      // Draw node title
      final textSpan = TextSpan(
        text: nodeData.title.length > 10
            ? '${nodeData.title.substring(0, 10)}...'
            : nodeData.title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          pos.dx - textPainter.width / 2,
          pos.dy + nodeSize / 2 + 5,
        ),
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_GraphPainter oldDelegate) {
    return oldDelegate.graph != graph ||
        oldDelegate.zoom != zoom ||
        oldDelegate.offset != offset;
  }
}

/// Fruchterman-Reingold algorithm for graph layout
class FruchtermanReingoldAlgorithm implements Algorithm {
  final int iterations;
  final double k;
  final Map<Node, Offset> _positions = {};

  FruchtermanReingoldAlgorithm({
    this.iterations = 1000,
    double? k,
  }) : k = k ?? 100.0;

  @override
  void step(Graph graph) {
    // Initialize positions if needed
    if (_positions.isEmpty) {
      _initializePositions(graph);
    }

    // Run algorithm
    _runAlgorithm(graph);
  }

  void _initializePositions(Graph graph) {
    final random = math.Random(42);

    for (final node in graph.nodes) {
      _positions[node] = Offset(
        (random.nextDouble() - 0.5) * 200,
        (random.nextDouble() - 0.5) * 200,
      );
    }
  }

  void _runAlgorithm(Graph graph) {
    final forces = <Node, Offset>{};

    // Calculate repulsive forces
    for (final v in graph.nodes) {
      forces[v] = Offset.zero;

      for (final u in graph.nodes) {
        if (v == u) continue;

        final delta = (_positions[v] ?? Offset.zero) -
            (_positions[u] ?? Offset.zero);
        final distance = delta.distance;

        if (distance > 0) {
          final repulsiveForce = k * k / distance;
          forces[v] = (forces[v] ?? Offset.zero) +
              delta / distance * repulsiveForce;
        }
      }
    }

    // Calculate attractive forces
    for (final edge in graph.edges) {
      final v = edge.source;
      final u = edge.destination;

      final delta =
          (_positions[v] ?? Offset.zero) - (_positions[u] ?? Offset.zero);
      final distance = delta.distance;

      if (distance > 0) {
        final attractiveForce = distance * distance / k;
        forces[v] = (forces[v] ?? Offset.zero) -
            delta / distance * attractiveForce;
        forces[u] = (forces[u] ?? Offset.zero) +
            delta / distance * attractiveForce;
      }
    }

    // Apply forces
    for (final v in graph.nodes) {
      final force = forces[v] ?? Offset.zero;
      final distance = force.distance;

      if (distance > 0) {
        _positions[v] = (_positions[v] ?? Offset.zero) +
            force / distance * math.min(distance, 10.0);
      }
    }
  }

  @override
  Offset nodePosition(Node node) {
    return _positions[node] ?? Offset.zero;
  }

  @override
  void setNodePosition(Node node, Offset position) {
    _positions[node] = position;
  }
}

/// Graph algorithm interface
abstract class Algorithm {
  void step(Graph graph);
  Offset nodePosition(Node node);
  void setNodePosition(Node node, Offset position);
}

/// Graph class
class Graph {
  final List<Node> nodes = [];
  final List<Edge> edges = [];

  void addNode(Node node) {
    if (!nodes.contains(node)) {
      nodes.add(node);
    }
  }

  void addEdge(Node source, Node destination, {Paint? paint}) {
    edges.add(Edge(source, destination, paint: paint));
  }
}

/// Node class
class Node {
  final Key key;

  Node({required this.key});

  factory Node.Id(String id) {
    return Node(key: ValueKey(id));
  }
}

/// Edge class
class Edge {
  final Node source;
  final Node destination;
  final Paint? paint;

  Edge(this.source, this.destination, {this.paint});
}
