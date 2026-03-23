import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/widget_node.dart';
import '../models/screen_model.dart';
import '../commands/forge_commands.dart';

class ForgeProvider extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────────
  List<ForgeScreen> _screens = [ForgeScreen.defaultHome()];
  int _currentScreenIndex = 0;
  String? _selectedNodeId;
  bool _multiSelect = false;
  Set<String> _multiSelected = {};

  // Canvas state
  double _canvasScale = 1.0;
  Offset _canvasOffset = Offset.zero;
  bool _showGrid = false;
  bool _snapToGrid = false;
  double _gridSize = 8.0;

  // Drag state
  bool _isDragging = false;
  String? _draggingId;
  Offset? _dragStartPos;    // pointer start
  Offset? _nodeStartPos;    // node x/y start

  // Resize state
  bool _isResizing = false;
  String? _resizingId;
  String? _resizeHandle;  // 'nw','n','ne','e','se','s','sw','w'
  Offset? _resizeStartPointer;
  double? _resizeStartX, _resizeStartY, _resizeStartW, _resizeStartH;

  // Undo/redo
  final CommandHistory _history = CommandHistory();

  // Panel visibility (mobile)
  int _activeSidePanel = 0; // 0=layers, 1=palette, 2=props

  ForgeProvider() {
    _load();
  }

  // ── Getters ───────────────────────────────────────────────
  List<ForgeScreen> get screens => _screens;
  int get currentScreenIndex => _currentScreenIndex;
  ForgeScreen get currentScreen => _screens[_currentScreenIndex];
  String? get selectedNodeId => _selectedNodeId;
  Set<String> get multiSelected => _multiSelected;
  double get canvasScale => _canvasScale;
  Offset get canvasOffset => _canvasOffset;
  bool get showGrid => _showGrid;
  bool get snapToGrid => _snapToGrid;
  double get gridSize => _gridSize;
  bool get isDragging => _isDragging;
  bool get isResizing => _isResizing;
  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;
  String? get undoDesc => _history.undoDescription;
  String? get redoDesc => _history.redoDescription;
  int get activeSidePanel => _activeSidePanel;

  WidgetNode? get selectedNode {
    if (_selectedNodeId == null) return null;
    return _findById(_selectedNodeId!, currentScreen.nodes);
  }

  // ── Screen Operations ─────────────────────────────────────
  void switchScreen(int idx) {
    _currentScreenIndex = idx;
    _selectedNodeId = null;
    notifyListeners();
  }

  void addScreen({String? name}) {
    final n = _screens.length + 1;
    _screens.add(ForgeScreen(name: name ?? 'Screen$n'));
    _currentScreenIndex = _screens.length - 1;
    _selectedNodeId = null;
    _save();
    notifyListeners();
  }

  void deleteScreen(int idx) {
    if (_screens.length <= 1) return;
    _screens.removeAt(idx);
    if (_currentScreenIndex >= _screens.length) {
      _currentScreenIndex = _screens.length - 1;
    }
    _selectedNodeId = null;
    _save();
    notifyListeners();
  }

  void renameScreen(int idx, String name) {
    _screens[idx].name = name;
    _save();
    notifyListeners();
  }

  void updateScreenBg(String hex) {
    currentScreen.backgroundColor = hex;
    _save();
    notifyListeners();
  }

  void toggleGrid() {
    _showGrid = !_showGrid;
    currentScreen.showGrid = _showGrid;
    notifyListeners();
  }

  void toggleSnap() {
    _snapToGrid = !_snapToGrid;
    notifyListeners();
  }

  // ── Selection ─────────────────────────────────────────────
  void selectNode(String? id) {
    _selectedNodeId = id;
    _multiSelected.clear();
    if (id != null) _activeSidePanel = 2; // open props
    notifyListeners();
  }

  void clearSelection() {
    _selectedNodeId = null;
    _multiSelected.clear();
    notifyListeners();
  }

  // ── Add Node (via palette drop/tap) ──────────────────────
  void addNode(WType type, {double x = 60, double y = 80}) {
    final snap = _snap(x, y);
    final node = WidgetNode(type: type, x: snap.dx, y: snap.dy);
    final cmd = AddNodeCommand(node);
    _history.execute(cmd, _screens, _currentScreenIndex);
    _selectedNodeId = node.id;
    _activeSidePanel = 2;
    _save();
    notifyListeners();
  }

  // ── Delete Node ───────────────────────────────────────────
  void deleteNode(String id) {
    final idx = currentScreen.nodes.indexWhere((n) => n.id == id);
    if (idx < 0) return;
    final node = currentScreen.nodes[idx].copyWith();
    final cmd = DeleteNodeCommand(node, idx);
    _history.execute(cmd, _screens, _currentScreenIndex);
    if (_selectedNodeId == id) _selectedNodeId = null;
    _save();
    notifyListeners();
  }

  void deleteSelected() {
    if (_selectedNodeId != null) deleteNode(_selectedNodeId!);
  }

  // ── Duplicate ─────────────────────────────────────────────
  void duplicateNode(String id) {
    final orig = _findById(id, currentScreen.nodes);
    if (orig == null) return;
    final copy = orig.copyWith(
      id: null,
      x: orig.x + 20,
      y: orig.y + 20,
      props: Map.from(orig.props),
    );
    final cmd = AddNodeCommand(copy);
    _history.execute(cmd, _screens, _currentScreenIndex);
    _selectedNodeId = copy.id;
    _save();
    notifyListeners();
  }

  // ── Drag Operations ───────────────────────────────────────

  void onDragStart(String id, Offset pointer) {
    final node = _findById(id, currentScreen.nodes);
    if (node == null || node.locked) return;
    _isDragging = true;
    _draggingId = id;
    _dragStartPos = pointer;
    _nodeStartPos = Offset(node.x, node.y);
    selectNode(id);
  }

  void onDragUpdate(Offset pointer) {
    if (!_isDragging || _draggingId == null) return;
    final delta = pointer - _dragStartPos!;
    final node = _findById(_draggingId!, currentScreen.nodes);
    if (node == null) return;
    final raw = _nodeStartPos! + delta / _canvasScale;
    final snapped = _snap(raw.dx, raw.dy);
    node.x = snapped.dx.clamp(0, currentScreen.canvasWidth - node.width);
    node.y = snapped.dy.clamp(0, currentScreen.canvasHeight - node.height);
    notifyListeners();
  }

  void onDragEnd() {
    if (!_isDragging || _draggingId == null) return;
    final node = _findById(_draggingId!, currentScreen.nodes);
    if (node != null && _nodeStartPos != null) {
      if (node.x != _nodeStartPos!.dx || node.y != _nodeStartPos!.dy) {
        // Record in history (already moved, just log)
        _history.record(MoveNodeCommand(
          nodeId: _draggingId!,
          oldX: _nodeStartPos!.dx, oldY: _nodeStartPos!.dy,
          newX: node.x, newY: node.y,
        ));
        _save();
      }
    }
    _isDragging = false;
    _draggingId = null;
    _dragStartPos = null;
    _nodeStartPos = null;
    notifyListeners();
  }

  // ── Resize Operations ─────────────────────────────────────

  void onResizeStart(String id, String handle, Offset pointer) {
    final node = _findById(id, currentScreen.nodes);
    if (node == null || node.locked) return;
    _isResizing = true;
    _resizingId = id;
    _resizeHandle = handle;
    _resizeStartPointer = pointer;
    _resizeStartX = node.x;
    _resizeStartY = node.y;
    _resizeStartW = node.width;
    _resizeStartH = node.height;
  }

  void onResizeUpdate(Offset pointer) {
    if (!_isResizing || _resizingId == null) return;
    final node = _findById(_resizingId!, currentScreen.nodes);
    if (node == null) return;

    final delta = (pointer - _resizeStartPointer!) / _canvasScale;
    final dx = delta.dx;
    final dy = delta.dy;
    const minSize = 16.0;

    double nx = _resizeStartX!, ny = _resizeStartY!;
    double nw = _resizeStartW!, nh = _resizeStartH!;

    switch (_resizeHandle) {
      case 'se': nw = (nw + dx).clamp(minSize, 1000); nh = (nh + dy).clamp(minSize, 1000); break;
      case 'sw': nw = (nw - dx).clamp(minSize, 1000); nx = nx + dx; nh = (nh + dy).clamp(minSize, 1000); break;
      case 'ne': nw = (nw + dx).clamp(minSize, 1000); nh = (nh - dy).clamp(minSize, 1000); ny = ny + dy; break;
      case 'nw': nw = (nw - dx).clamp(minSize, 1000); nx = nx + dx; nh = (nh - dy).clamp(minSize, 1000); ny = ny + dy; break;
      case 'e': nw = (nw + dx).clamp(minSize, 1000); break;
      case 'w': nw = (nw - dx).clamp(minSize, 1000); nx = nx + dx; break;
      case 's': nh = (nh + dy).clamp(minSize, 1000); break;
      case 'n': nh = (nh - dy).clamp(minSize, 1000); ny = ny + dy; break;
    }

    node.x = nx; node.y = ny;
    node.width = nw; node.height = nh;
    notifyListeners();
  }

  void onResizeEnd() {
    if (!_isResizing || _resizingId == null) return;
    final node = _findById(_resizingId!, currentScreen.nodes);
    if (node != null) {
      _history.record(ResizeNodeCommand(
        nodeId: _resizingId!,
        oldX: _resizeStartX!, oldY: _resizeStartY!,
        oldW: _resizeStartW!, oldH: _resizeStartH!,
        newX: node.x, newY: node.y,
        newW: node.width, newH: node.height,
      ));
      _save();
    }
    _isResizing = false;
    _resizingId = null;
    _resizeHandle = null;
    _resizeStartPointer = null;
    notifyListeners();
  }

  // ── Property Update ───────────────────────────────────────
  void updateProp(String nodeId, String key, dynamic value) {
    final node = _findById(nodeId, currentScreen.nodes);
    if (node == null) return;
    final old = node.props[key];
    final cmd = UpdatePropCommand(
        nodeId: nodeId, key: key, oldVal: old, newVal: value);
    _history.execute(cmd, _screens, _currentScreenIndex);
    _save();
    notifyListeners();
  }

  // Called by canvas during alignment-guided drag
  void applySnapPosition(String id, double x, double y) {
    final node = _findById(id, currentScreen.nodes);
    if (node == null) return;
    node.x = x; node.y = y;
    notifyListeners();
  }

  void updateNodeSize(String id, double w, double h) {
    final node = _findById(id, currentScreen.nodes);
    if (node == null) return;
    node.width = w.clamp(16, 1000);
    node.height = h.clamp(16, 1000);
    _save();
    notifyListeners();
  }

  void updateNodePos(String id, double x, double y) {
    final node = _findById(id, currentScreen.nodes);
    if (node == null) return;
    node.x = x; node.y = y;
    _save();
    notifyListeners();
  }

  // ── Layer Operations ──────────────────────────────────────
  void toggleVisibility(String id) {
    final node = _findById(id, currentScreen.nodes);
    if (node == null) return;
    final cmd = UpdateNodeFieldCommand(
        nodeId: id, field: 'visible',
        oldVal: node.visible, newVal: !node.visible);
    _history.execute(cmd, _screens, _currentScreenIndex);
    notifyListeners();
  }

  void toggleLock(String id) {
    final node = _findById(id, currentScreen.nodes);
    if (node == null) return;
    final cmd = UpdateNodeFieldCommand(
        nodeId: id, field: 'locked',
        oldVal: node.locked, newVal: !node.locked);
    _history.execute(cmd, _screens, _currentScreenIndex);
    notifyListeners();
  }

  void renameNode(String id, String name) {
    final node = _findById(id, currentScreen.nodes);
    if (node == null) return;
    node.name = name.isEmpty ? null : name;
    _save();
    notifyListeners();
  }

  void bringToFront(String id) {
    final node = _findById(id, currentScreen.nodes);
    if (node == null) return;
    node.zIndex = currentScreen.nextZIndex;
    _save();
    notifyListeners();
  }

  void sendToBack(String id) {
    final node = _findById(id, currentScreen.nodes);
    if (node == null) return;
    final minZ = currentScreen.nodes.isEmpty
        ? 0 : currentScreen.nodes.map((n) => n.zIndex).reduce((a,b) => a < b ? a : b);
    node.zIndex = minZ - 1;
    _save();
    notifyListeners();
  }

  void reorderLayer(int oldIdx, int newIdx) {
    final nodes = currentScreen.sortedNodes;
    if (oldIdx < 0 || oldIdx >= nodes.length) return;
    if (newIdx > oldIdx) newIdx--;
    final moved = nodes.removeAt(oldIdx);
    nodes.insert(newIdx, moved);
    for (int i = 0; i < nodes.length; i++) {
      final n = _findById(nodes[i].id, currentScreen.nodes);
      if (n != null) n.zIndex = i;
    }
    _save();
    notifyListeners();
  }

  // ── Canvas ────────────────────────────────────────────────
  void setCanvasScale(double scale) {
    _canvasScale = scale.clamp(0.2, 4.0);
    notifyListeners();
  }

  void setCanvasOffset(Offset offset) {
    _canvasOffset = offset;
    notifyListeners();
  }

  void resetCanvas() {
    _canvasScale = 1.0;
    _canvasOffset = Offset.zero;
    notifyListeners();
  }

  // ── Undo/Redo ─────────────────────────────────────────────
  void undo() {
    if (_history.undo(_screens, _currentScreenIndex)) {
      _save();
      notifyListeners();
    }
  }

  void redo() {
    if (_history.redo(_screens, _currentScreenIndex)) {
      _save();
      notifyListeners();
    }
  }

  // ── Panel Nav ─────────────────────────────────────────────
  void setSidePanel(int idx) {
    _activeSidePanel = idx;
    notifyListeners();
  }

  // ── Clear ─────────────────────────────────────────────────
  Future<void> clearAll() async {
    _screens = [ForgeScreen.defaultHome()];
    _currentScreenIndex = 0;
    _selectedNodeId = null;
    _history.clear();
    final p = await SharedPreferences.getInstance();
    await p.remove('gax_forge_v2');
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────
  WidgetNode? _findById(String id, List<WidgetNode> nodes) {
    for (final n in nodes) {
      if (n.id == id) return n;
      final f = _findById(id, n.children);
      if (f != null) return f;
    }
    return null;
  }

  Offset _snap(double x, double y) {
    if (!_snapToGrid) return Offset(x, y);
    return Offset(
      (x / _gridSize).round() * _gridSize,
      (y / _gridSize).round() * _gridSize,
    );
  }

  // ── Persistence ───────────────────────────────────────────
  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      final data = jsonEncode(_screens.map((s) => s.toJson()).toList());
      await p.setString('gax_forge_v2', data);
    } catch (e) {
      debugPrint('Save error: $e');
    }
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final data = p.getString('gax_forge_v2');
      if (data != null) {
        final list = jsonDecode(data) as List;
        _screens = list.map((s) =>
            ForgeScreen.fromJson(s as Map<String, dynamic>)).toList();
        if (_screens.isEmpty) _screens = [ForgeScreen.defaultHome()];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load error: $e');
      _screens = [ForgeScreen.defaultHome()];
    }
  }
}
