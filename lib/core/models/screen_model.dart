import 'package:uuid/uuid.dart';
import 'widget_node.dart';

// ── Screen (Page) Model ───────────────────────────────────────
class ForgeScreen {
  final String id;
  String name;
  List<WidgetNode> nodes; // All root-level nodes (free-positioned)

  // Screen design settings
  double canvasWidth;
  double canvasHeight;
  String backgroundColor;
  bool showGrid;

  ForgeScreen({
    String? id,
    required this.name,
    List<WidgetNode>? nodes,
    this.canvasWidth = 390,   // iPhone 14 width
    this.canvasHeight = 844,  // iPhone 14 height
    this.backgroundColor = '#FFFFFF',
    this.showGrid = false,
  })  : id = id ?? const Uuid().v4(),
        nodes = nodes ?? [];

  // Nodes sorted by zIndex (render order)
  List<WidgetNode> get sortedNodes {
    final list = List<WidgetNode>.from(nodes);
    list.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return list;
  }

  int get nextZIndex =>
      nodes.isEmpty ? 0 : nodes.map((n) => n.zIndex).reduce((a, b) => a > b ? a : b) + 1;

  ForgeScreen copyWith({
    String? name, List<WidgetNode>? nodes,
    double? canvasWidth, double? canvasHeight,
    String? backgroundColor, bool? showGrid,
  }) {
    return ForgeScreen(
      id: id,
      name: name ?? this.name,
      nodes: nodes ?? this.nodes.map((n) => n.copyWith()).toList(),
      canvasWidth: canvasWidth ?? this.canvasWidth,
      canvasHeight: canvasHeight ?? this.canvasHeight,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      showGrid: showGrid ?? this.showGrid,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name,
    'canvasWidth': canvasWidth, 'canvasHeight': canvasHeight,
    'backgroundColor': backgroundColor, 'showGrid': showGrid,
    'nodes': nodes.map((n) => n.toJson()).toList(),
  };

  factory ForgeScreen.fromJson(Map<String, dynamic> j) {
    return ForgeScreen(
      id: j['id'], name: j['name'],
      canvasWidth: (j['canvasWidth'] as num?)?.toDouble() ?? 390,
      canvasHeight: (j['canvasHeight'] as num?)?.toDouble() ?? 844,
      backgroundColor: j['backgroundColor'] ?? '#FFFFFF',
      showGrid: j['showGrid'] as bool? ?? false,
      nodes: (j['nodes'] as List?)
          ?.map((n) => WidgetNode.fromJson(n as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  static ForgeScreen defaultHome() =>
      ForgeScreen(name: 'HomeScreen');
}
