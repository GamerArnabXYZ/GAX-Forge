import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/widget_node.dart';
import '../models/screen_model.dart';
import '../commands/forge_commands.dart';

class ForgeProvider extends ChangeNotifier {

  List<ForgeScreen> _screens = [ForgeScreen.defaultHome()];
  int _screenIdx = 0;
  String? _selectedId;
  bool _showGrid = false;
  bool _snapToGrid = false;
  double _gridSize   = 8.0;
  bool _canvasLocked = false; // lock = pan/zoom off, drag ON
  double _scale = 1.0;
  int _activeSidePanel = 0;
  String? _projectId;
  final CommandHistory _history = CommandHistory();

  // ── Getters ───────────────────────────────────────────────
  List<ForgeScreen> get screens      => _screens;
  int    get screenIdx               => _screenIdx;
  ForgeScreen get screen             => _screens[_screenIdx];
  String? get selectedId             => _selectedId;
  bool   get showGrid                => _showGrid;
  bool   get snapToGrid              => _snapToGrid;
  bool   get canvasLocked            => _canvasLocked;
  double get scale                   => _scale;
  int    get activeSidePanel         => _activeSidePanel;
  bool   get canUndo                 => _history.canUndo;
  bool   get canRedo                 => _history.canRedo;
  String? get undoDesc               => _history.undoDescription;
  String? get redoDesc               => _history.redoDescription;

  WidgetNode? get selectedNode {
    if (_selectedId == null) return null;
    return _find(_selectedId!, screen.nodes);
  }

  // ── Project persistence ───────────────────────────────────
  Future<void> loadProject(String id) async {
    _projectId = id;
    _history.clear();
    _selectedId = null;
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString('proj_$id');
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _screens = list.map((s) => ForgeScreen.fromJson(s)).toList();
        if (_screens.isEmpty) _screens = [ForgeScreen.defaultHome()];
        _screenIdx = 0;
        notifyListeners();
        return;
      }
    } catch (e) { debugPrint('load: $e'); }
    _screens = [ForgeScreen.defaultHome()];
    _screenIdx = 0;
    notifyListeners();
  }

  Future<void> saveProject() async {
    if (_projectId == null) return;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('proj_$_projectId',
          jsonEncode(_screens.map((s) => s.toJson()).toList()));
    } catch (e) { debugPrint('save: $e'); }
  }

  void _autoSave() => saveProject();

  // ── Screens ───────────────────────────────────────────────
  void switchScreen(int i) {
    _screenIdx = i; _selectedId = null; notifyListeners();
  }

  void addScreen({String? name}) {
    _screens.add(ForgeScreen(name: name ?? 'Screen${_screens.length + 1}'));
    _screenIdx = _screens.length - 1;
    _selectedId = null;
    _autoSave(); notifyListeners();
  }

  void deleteScreen(int i) {
    if (_screens.length <= 1) return;
    _screens.removeAt(i);
    if (_screenIdx >= _screens.length) _screenIdx = _screens.length - 1;
    _selectedId = null;
    _autoSave(); notifyListeners();
  }

  void renameScreen(int i, String name) {
    _screens[i].name = name;
    _autoSave(); notifyListeners();
  }

  void updateScreenBg(String hex) {
    screen.backgroundColor = hex;
    _autoSave(); notifyListeners();
  }

  // ── Selection ─────────────────────────────────────────────
  void select(String? id) {
    if (_selectedId == id) return;
    _selectedId = id;
    if (id != null) _activeSidePanel = 2;
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedId == null) return;
    _selectedId = null;
    notifyListeners();
  }

  // ── Add widget ────────────────────────────────────────────
  void addNode(WType type, {double x = 40, double y = 60}) {
    final snapped = _snap(x, y);
    final node = WidgetNode(type: type, x: snapped.dx, y: snapped.dy);
    _exec(AddNodeCommand(node));
    _selectedId = node.id;
    _activeSidePanel = 2;
    _autoSave(); notifyListeners();
  }

  // ── Delete ────────────────────────────────────────────────
  void deleteNode(String id) {
    final i = screen.nodes.indexWhere((n) => n.id == id);
    if (i < 0) return;
    _exec(DeleteNodeCommand(screen.nodes[i].copyWith(), i));
    if (_selectedId == id) _selectedId = null;
    _autoSave(); notifyListeners();
  }

  void deleteSelected() { if (_selectedId != null) deleteNode(_selectedId!); }

  void duplicate(String id) {
    final orig = _find(id, screen.nodes);
    if (orig == null) return;
    final copy = orig.copyWith(id: null, x: orig.x+16, y: orig.y+16,
        props: Map.from(orig.props));
    _exec(AddNodeCommand(copy));
    _selectedId = copy.id;
    _autoSave(); notifyListeners();
  }

  // ── Move widget (called from canvas on drag) ──────────────
  // Direct update — no notify (canvas calls setState itself)
  void moveNodeDirect(String id, double x, double y) {
    final node = _find(id, screen.nodes);
    if (node == null || node.locked) return;
    final s = _snap(x, y);
    node.x = s.dx.clamp(0.0, screen.canvasWidth  - node.width);
    node.y = s.dy.clamp(0.0, screen.canvasHeight - node.height);
  }

  // Called when drag ends — record in history + save + notify
  void commitMove(String id, double oldX, double oldY) {
    final node = _find(id, screen.nodes);
    if (node == null) return;
    if (node.x != oldX || node.y != oldY) {
      _history.record(MoveNodeCommand(
          nodeId: id, oldX: oldX, oldY: oldY, newX: node.x, newY: node.y));
      _autoSave();
    }
    notifyListeners();
  }

  // ── Resize ────────────────────────────────────────────────
  void resizeNodeDirect(String id, double x, double y, double w, double h) {
    final node = _find(id, screen.nodes);
    if (node == null || node.locked) return;
    node.x = x; node.y = y;
    node.width  = w.clamp(20.0, 1000.0);
    node.height = h.clamp(20.0, 1000.0);
  }

  void commitResize(String id, double ox, double oy, double ow, double oh) {
    final node = _find(id, screen.nodes);
    if (node == null) return;
    _history.record(ResizeNodeCommand(nodeId: id,
        oldX: ox, oldY: oy, oldW: ow, oldH: oh,
        newX: node.x, newY: node.y, newW: node.width, newH: node.height));
    _autoSave(); notifyListeners();
  }

  // ── Property update ───────────────────────────────────────
  void updateProp(String id, String key, dynamic val) {
    final node = _find(id, screen.nodes);
    if (node == null) return;
    _exec(UpdatePropCommand(nodeId: id, key: key,
        oldVal: node.props[key], newVal: val));
    _autoSave(); notifyListeners();
  }

  void updateSize(String id, double w, double h) {
    final node = _find(id, screen.nodes);
    if (node == null) return;
    node.width  = w.clamp(20.0, 1000.0);
    node.height = h.clamp(20.0, 1000.0);
    _autoSave(); notifyListeners();
  }

  void updatePos(String id, double x, double y) {
    final node = _find(id, screen.nodes);
    if (node == null) return;
    node.x = x; node.y = y;
    _autoSave(); notifyListeners();
  }

  // ── Layer ops ─────────────────────────────────────────────
  void toggleVisible(String id) {
    final n = _find(id, screen.nodes); if (n == null) return;
    _exec(UpdateNodeFieldCommand(nodeId: id, field: 'visible',
        oldVal: n.visible, newVal: !n.visible));
    notifyListeners();
  }

  void toggleLock(String id) {
    final n = _find(id, screen.nodes); if (n == null) return;
    _exec(UpdateNodeFieldCommand(nodeId: id, field: 'locked',
        oldVal: n.locked, newVal: !n.locked));
    notifyListeners();
  }

  void renameNode(String id, String name) {
    final n = _find(id, screen.nodes); if (n == null) return;
    n.name = name.isEmpty ? null : name;
    _autoSave(); notifyListeners();
  }

  void bringToFront(String id) {
    final n = _find(id, screen.nodes); if (n == null) return;
    n.zIndex = screen.nextZIndex;
    _autoSave(); notifyListeners();
  }

  void sendToBack(String id) {
    final n = _find(id, screen.nodes); if (n == null) return;
    final minZ = screen.nodes.map((x) => x.zIndex).reduce((a,b) => a<b?a:b);
    n.zIndex = minZ - 1;
    _autoSave(); notifyListeners();
  }

  void reorderLayer(int oldIdx, int newIdx) {
    final nodes = screen.sortedNodes;
    if (oldIdx < 0 || oldIdx >= nodes.length) return;
    if (newIdx > oldIdx) newIdx--;
    final moved = nodes.removeAt(oldIdx);
    nodes.insert(newIdx, moved);
    for (int i = 0; i < nodes.length; i++) {
      _find(nodes[i].id, screen.nodes)?.zIndex = i;
    }
    _autoSave(); notifyListeners();
  }

  // ── Canvas state ──────────────────────────────────────────
  void toggleGrid() {
    _showGrid = !_showGrid; notifyListeners();
  }

  void toggleSnap() {
    _snapToGrid = !_snapToGrid; notifyListeners();
  }

  void toggleCanvasLock() {
    _canvasLocked = !_canvasLocked;
    _selectedId = null;
    notifyListeners();
  }

  void setScale(double s) {
    _scale = s.clamp(0.15, 5.0); // no notify — canvas handles this locally
  }

  void resetCanvas() {
    _scale = 1.0; notifyListeners();
  }

  // ── Undo / Redo ───────────────────────────────────────────
  void undo() {
    if (_history.undo(_screens, _screenIdx)) {
      _autoSave(); notifyListeners();
    }
  }

  void redo() {
    if (_history.redo(_screens, _screenIdx)) {
      _autoSave(); notifyListeners();
    }
  }

  // ── Panel nav ─────────────────────────────────────────────
  void setSidePanel(int i) {
    _activeSidePanel = i; notifyListeners();
  }

  // ── Clear ─────────────────────────────────────────────────
  Future<void> clearAll() async {
    _screens    = [ForgeScreen.defaultHome()];
    _screenIdx  = 0;
    _selectedId = null;
    _canvasLocked = false;
    _history.clear();
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────
  WidgetNode? _find(String id, List<WidgetNode> nodes) {
    for (final n in nodes) {
      if (n.id == id) return n;
      final f = _find(id, n.children);
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

  void _exec(ForgeCommand cmd) =>
      _history.execute(cmd, _screens, _screenIdx);
}
