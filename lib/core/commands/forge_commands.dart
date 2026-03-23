import '../models/widget_node.dart';
import '../models/screen_model.dart';

// ── Abstract Command ──────────────────────────────────────────
abstract class ForgeCommand {
  String get description;
  void execute(List<ForgeScreen> screens, int screenIndex);
  void undo(List<ForgeScreen> screens, int screenIndex);
}

// ── Add Node ──────────────────────────────────────────────────
class AddNodeCommand extends ForgeCommand {
  final WidgetNode node;
  @override String get description => 'Add ${node.type.name}';

  AddNodeCommand(this.node);

  @override
  void execute(List<ForgeScreen> screens, int si) {
    node.zIndex = screens[si].nextZIndex;
    screens[si].nodes.add(node);
  }

  @override
  void undo(List<ForgeScreen> screens, int si) {
    screens[si].nodes.removeWhere((n) => n.id == node.id);
  }
}

// ── Delete Node ───────────────────────────────────────────────
class DeleteNodeCommand extends ForgeCommand {
  final WidgetNode node;
  final int originalIndex;
  @override String get description => 'Delete ${node.type.name}';

  DeleteNodeCommand(this.node, this.originalIndex);

  @override
  void execute(List<ForgeScreen> screens, int si) {
    screens[si].nodes.removeWhere((n) => n.id == node.id);
  }

  @override
  void undo(List<ForgeScreen> screens, int si) {
    final idx = originalIndex.clamp(0, screens[si].nodes.length);
    screens[si].nodes.insert(idx, node.copyWith());
  }
}

// ── Move Node ─────────────────────────────────────────────────
class MoveNodeCommand extends ForgeCommand {
  final String nodeId;
  final double oldX, oldY, newX, newY;
  @override String get description => 'Move';

  MoveNodeCommand({
    required this.nodeId,
    required this.oldX, required this.oldY,
    required this.newX, required this.newY,
  });

  @override
  void execute(List<ForgeScreen> screens, int si) {
    _findNode(screens[si].nodes, nodeId)?.let((n) {
      n.x = newX; n.y = newY;
    });
  }

  @override
  void undo(List<ForgeScreen> screens, int si) {
    _findNode(screens[si].nodes, nodeId)?.let((n) {
      n.x = oldX; n.y = oldY;
    });
  }
}

// ── Resize Node ───────────────────────────────────────────────
class ResizeNodeCommand extends ForgeCommand {
  final String nodeId;
  final double oldX, oldY, oldW, oldH;
  final double newX, newY, newW, newH;
  @override String get description => 'Resize';

  ResizeNodeCommand({
    required this.nodeId,
    required this.oldX, required this.oldY,
    required this.oldW, required this.oldH,
    required this.newX, required this.newY,
    required this.newW, required this.newH,
  });

  @override
  void execute(List<ForgeScreen> screens, int si) {
    _findNode(screens[si].nodes, nodeId)?.let((n) {
      n.x = newX; n.y = newY; n.width = newW; n.height = newH;
    });
  }

  @override
  void undo(List<ForgeScreen> screens, int si) {
    _findNode(screens[si].nodes, nodeId)?.let((n) {
      n.x = oldX; n.y = oldY; n.width = oldW; n.height = oldH;
    });
  }
}

// ── Update Property ───────────────────────────────────────────
class UpdatePropCommand extends ForgeCommand {
  final String nodeId;
  final String key;
  final dynamic oldVal, newVal;
  @override String get description => 'Edit $key';

  UpdatePropCommand({
    required this.nodeId, required this.key,
    required this.oldVal, required this.newVal,
  });

  @override
  void execute(List<ForgeScreen> screens, int si) {
    _findNode(screens[si].nodes, nodeId)?.props[key] = newVal;
  }

  @override
  void undo(List<ForgeScreen> screens, int si) {
    _findNode(screens[si].nodes, nodeId)?.props[key] = oldVal;
  }
}

// ── Update Node Field (x/y/w/h/visible/locked) ───────────────
class UpdateNodeFieldCommand extends ForgeCommand {
  final String nodeId;
  final String field;
  final dynamic oldVal, newVal;
  @override String get description => 'Update $field';

  UpdateNodeFieldCommand({
    required this.nodeId, required this.field,
    required this.oldVal, required this.newVal,
  });

  @override
  void execute(List<ForgeScreen> screens, int si) =>
      _applyField(screens, si, newVal);

  @override
  void undo(List<ForgeScreen> screens, int si) =>
      _applyField(screens, si, oldVal);

  void _applyField(List<ForgeScreen> screens, int si, dynamic val) {
    final n = _findNode(screens[si].nodes, nodeId);
    if (n == null) return;
    switch (field) {
      case 'visible': n.visible = val as bool; break;
      case 'locked': n.locked = val as bool; break;
      case 'name': n.name = val as String?; break;
      case 'zIndex': n.zIndex = val as int; break;
    }
  }
}

// ── Reorder Layers ────────────────────────────────────────────
class ReorderLayersCommand extends ForgeCommand {
  final List<String> oldOrder; // node ids in order
  final List<String> newOrder;
  @override String get description => 'Reorder layers';

  ReorderLayersCommand({required this.oldOrder, required this.newOrder});

  @override
  void execute(List<ForgeScreen> screens, int si) =>
      _applyOrder(screens[si].nodes, newOrder);

  @override
  void undo(List<ForgeScreen> screens, int si) =>
      _applyOrder(screens[si].nodes, oldOrder);

  void _applyOrder(List<WidgetNode> nodes, List<String> order) {
    for (int i = 0; i < order.length; i++) {
      _findNode(nodes, order[i])?.zIndex = i;
    }
  }
}

// ── Helpers ───────────────────────────────────────────────────
WidgetNode? _findNode(List<WidgetNode> nodes, String id) {
  for (final n in nodes) {
    if (n.id == id) return n;
    final found = _findNode(n.children, id);
    if (found != null) return found;
  }
  return null;
}

extension NullSafe<T> on T? {
  void let(void Function(T) fn) {
    if (this != null) fn(this as T);
  }
}

// ── Command History Stack ─────────────────────────────────────
class CommandHistory {
  static const int maxHistory = 50;

  final List<ForgeCommand> _undoStack = [];
  final List<ForgeCommand> _redoStack = [];

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  String? get undoDescription =>
      _undoStack.isNotEmpty ? _undoStack.last.description : null;
  String? get redoDescription =>
      _redoStack.isNotEmpty ? _redoStack.last.description : null;

  void execute(ForgeCommand cmd, List<ForgeScreen> screens, int si) {
    cmd.execute(screens, si);
    _undoStack.add(cmd);
    _redoStack.clear();
    if (_undoStack.length > maxHistory) {
      _undoStack.removeAt(0);
    }
  }

  bool undo(List<ForgeScreen> screens, int si) {
    if (!canUndo) return false;
    final cmd = _undoStack.removeLast();
    cmd.undo(screens, si);
    _redoStack.add(cmd);
    return true;
  }

  bool redo(List<ForgeScreen> screens, int si) {
    if (!canRedo) return false;
    final cmd = _redoStack.removeLast();
    cmd.execute(screens, si);
    _undoStack.add(cmd);
    return true;
  }

  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}

// Extension to allow provider to silently record post-drag/resize commands
extension CommandHistoryRecorder on CommandHistory {
  void record(ForgeCommand cmd) {
    _undoStack.add(cmd);
    if (_undoStack.length > maxHistory) _undoStack.removeAt(0);
  }
}
