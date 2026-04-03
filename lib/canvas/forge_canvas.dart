import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../core/providers/forge_provider.dart';
import '../core/models/widget_node.dart';
import '../ui/theme.dart';
import 'widget_renderer.dart';
import 'selection_handles.dart';

// ═══════════════════════════════════════════════════════════════
//  ForgeCanvas — complete rewrite of drag handling
//
//  ROOT CAUSE of all drag problems:
//  GestureDetector onPanStart fires AFTER the gesture arena
//  resolves. InteractiveViewer is an outer widget and wins
//  the arena first. Solution: use a top-level Listener that
//  intercepts raw pointer events BEFORE arena resolution.
//
//  Architecture:
//  • Listener (raw pointer) → hit-test which widget
//  • If widget hit → block InteractiveViewer via panEnabled=false
//  • Move widget directly using pointer delta / current scale
//  • On pointer up → commit to history + notify
// ═══════════════════════════════════════════════════════════════

class ForgeCanvas extends StatefulWidget {
  const ForgeCanvas({super.key});
  @override
  State<ForgeCanvas> createState() => _ForgeCanvasState();
}

class _ForgeCanvasState extends State<ForgeCanvas> {
  final _tc = TransformationController();

  // Active drag tracking
  String?  _dragId;          // id of node being dragged
  double   _dragStartNodeX = 0, _dragStartNodeY = 0;
  double   _dragStartPtrX  = 0, _dragStartPtrY  = 0;
  Offset   _nodeDisplayPos = Offset.zero; // for overlay sync

  // Active resize tracking (from handles)
  bool _isResizing = false;

  @override
  void dispose() { _tc.dispose(); super.dispose(); }

  // Current canvas scale
  double get _scale => _tc.value.getMaxScaleOnAxis();

  // Convert screen global → canvas local coordinates
  Offset _toCanvas(Offset global) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return global;
    final local = box.globalToLocal(global);
    // Undo transform: inverse of tc
    final inv = Matrix4.inverted(_tc.value);
    final s = inv.storage;
    final x = s[0]*local.dx + s[4]*local.dy + s[12];
    final y = s[1]*local.dx + s[5]*local.dy + s[13];
    // Subtract the 48px margin from InteractiveViewer's Center+Padding
    return Offset(x - 48, y - 48);
  }

  // Hit-test: which node is under a canvas coordinate?
  WidgetNode? _hitTest(Offset canvasPos, ForgeProvider p) {
    final nodes = p.screen.sortedNodes;
    // Top-most (highest zIndex) first
    for (int i = nodes.length - 1; i >= 0; i--) {
      final n = nodes[i];
      if (!n.visible || n.locked) continue;
      final r = Rect.fromLTWH(n.x, n.y, n.width, n.height);
      if (r.inflate(4).contains(canvasPos)) return n;
    }
    return null;
  }

  void _onPointerDown(PointerDownEvent e, ForgeProvider p) {
    if (_isResizing) return;
    final canvas = _toCanvas(e.position);
    final hit = _hitTest(canvas, p);
    if (hit == null) {
      p.clearSelection();
      return;
    }
    // Claim this drag
    _dragId         = hit.id;
    _dragStartNodeX = hit.x;
    _dragStartNodeY = hit.y;
    _dragStartPtrX  = e.position.dx;
    _dragStartPtrY  = e.position.dy;
    _nodeDisplayPos = Offset(hit.x, hit.y);
    p.select(hit.id); // select always — needed for resize in lock mode
    // Disable IV pan immediately (synchronous, before any frame)
    if (mounted) setState(() {});
  }

  void _onPointerMove(PointerMoveEvent e, ForgeProvider p) {
    if (_dragId == null || _isResizing) return;
    final sc  = _scale.clamp(0.05, 10.0);
    final dx  = (e.position.dx - _dragStartPtrX) / sc;
    final dy  = (e.position.dy - _dragStartPtrY) / sc;
    final scr = p.screen;

    final nx = (_dragStartNodeX + dx)
        .clamp(0.0, scr.canvasWidth  - _nodeW(p));
    final ny = (_dragStartNodeY + dy)
        .clamp(0.0, scr.canvasHeight - _nodeH(p));

    _nodeDisplayPos = Offset(nx, ny);
    p.moveNodeDirect(_dragId!, nx, ny);
    // Rebuild only the canvas state (not entire tree via provider)
    if (mounted) setState(() {});
  }

  void _onPointerUp(PointerUpEvent e, ForgeProvider p) {
    if (_dragId == null) return;
    p.commitMove(_dragId!, _dragStartNodeX, _dragStartNodeY);
    _dragId = null;
    if (mounted) setState(() {});
  }

  void _onPointerCancel(PointerCancelEvent e, ForgeProvider p) {
    if (_dragId == null) return;
    // Restore original pos
    p.moveNodeDirect(_dragId!, _dragStartNodeX, _dragStartNodeY);
    p.notifyListeners_public();
    _dragId = null;
    if (mounted) setState(() {});
  }

  double _nodeW(ForgeProvider p) {
    if (_dragId == null) return 0;
    final n = p.screen.nodes.firstWhere(
        (x) => x.id == _dragId, orElse: () => p.screen.nodes.first);
    return n.width;
  }
  double _nodeH(ForgeProvider p) {
    if (_dragId == null) return 0;
    final n = p.screen.nodes.firstWhere(
        (x) => x.id == _dragId, orElse: () => p.screen.nodes.first);
    return n.height;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgeProvider>(
      builder: (_, p, __) {
        final s      = p.screen;
        final locked = p.canvasLocked;
        final isDragging = _dragId != null;

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown:  (e) => _onPointerDown(e, p),
          onPointerMove:  (e) => _onPointerMove(e, p),
          onPointerUp:    (e) => _onPointerUp(e, p),
          onPointerCancel:(e) => _onPointerCancel(e, p),
          child: Container(
            color: ForgeTheme.canvasBg,
            child: Stack(children: [

              // Grid
              if (p.showGrid)
                Positioned.fill(child: _GridWidget(
                    cellSize: (8.0 * _scale).clamp(6.0, 48.0))),

              InteractiveViewer(
                transformationController: _tc,
                boundaryMargin: const EdgeInsets.all(600),
                minScale: 0.1,
                maxScale: 5.0,
                // CRITICAL: Disable when dragging OR locked
                panEnabled:   !isDragging,  // always allow pan (locked or not)
                scaleEnabled: true,           // always allow zoom
                onInteractionUpdate: (_) =>
                    p.setScale(_tc.value.getMaxScaleOnAxis()),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(48),
                    width:  s.canvasWidth,
                    height: s.canvasHeight,
                    decoration: BoxDecoration(
                      color: parseColor(s.backgroundColor,
                          fallback: Colors.white),
                      boxShadow: const [BoxShadow(
                          color: Color(0x55000000), blurRadius: 30)],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none, // handles can go outside
                      children: [

                        // Content clip
                        ClipRect(
                          child: SizedBox(
                            width: s.canvasWidth,
                            height: s.canvasHeight,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: p.clearSelection,
                              child: Stack(
                                children: s.sortedNodes
                                    .where((n) => n.visible)
                                    .map((n) => _WidgetTile(
                                          key:      ValueKey(n.id),
                                          node:     n,
                                          // Use local display pos for dragged node
                                          overrideX: _dragId == n.id
                                              ? _nodeDisplayPos.dx : null,
                                          overrideY: _dragId == n.id
                                              ? _nodeDisplayPos.dy : null,
                                          selectedId: p.selectedId,
                                          locked:   locked,
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),

                        // Selection handles — outside clip
                        // Show handles always — resize works in both modes
                        if (p.selectedId != null)
                          _buildHandles(p),
                      ],
                    ),
                  ),
                ),
              ),

              // Info bar
              Positioned(left: 8, bottom: 8, child: _InfoBar(p: p,
                  dragId: _dragId, nodePos: _nodeDisplayPos)),

              // Zoom controls
              if (!locked)
                Positioned(right: 8, bottom: 8,
                    child: _ZoomBar(tc: _tc, p: p)),


            ]),
          ),
        );
      },
    );
  }

  Widget _buildHandles(ForgeProvider p) {
    final node = p.screen.nodes
        .cast<WidgetNode?>()
        .firstWhere((n) => n?.id == p.selectedId, orElse: () => null);
    if (node == null) return const SizedBox.shrink();

    // Use display pos if this node is being dragged
    final dispX = (_dragId == node.id) ? _nodeDisplayPos.dx : node.x;
    final dispY = (_dragId == node.id) ? _nodeDisplayPos.dy : node.y;

    return ForgeSelectionOverlay(
      node:     node,
      displayX: dispX,
      displayY: dispY,
      getScale: () => _tc.value.getMaxScaleOnAxis(),
      onResizeStart: () => setState(() => _isResizing = true),
      onResizeEnd:   () => setState(() => _isResizing = false),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  _WidgetTile — pure display widget, no gesture handling
//  (all gestures handled by ForgeCanvas Listener)
// ─────────────────────────────────────────────────────────────
class _WidgetTile extends StatelessWidget {
  final WidgetNode node;
  final double?   overrideX, overrideY;
  final String?   selectedId;
  final bool      locked;

  const _WidgetTile({
    required super.key,
    required this.node,
    this.overrideX, this.overrideY,
    required this.selectedId,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    final x = overrideX ?? node.x;
    final y = overrideY ?? node.y;
    final isSelected = selectedId == node.id;

    return Positioned(
      left: x, top: y,
      width: node.width, height: node.height,
      child: Stack(clipBehavior: Clip.none, children: [
        SizedBox(
          width: node.width, height: node.height,
          child: IgnorePointer(child: WidgetRenderer(node: node)),
        ),
        if (isSelected && !locked)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: ForgeTheme.selection, width: 1.5),
                ),
              ),
            ),
          ),
        if (node.locked)
          Positioned(top: 3, right: 3,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4)),
              child: const Icon(Icons.lock, color: Colors.white, size: 9),
            ),
          ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Grid
// ─────────────────────────────────────────────────────────────
class _GridWidget extends StatelessWidget {
  final double cellSize;
  const _GridWidget({required this.cellSize});
  @override
  Widget build(BuildContext c) => CustomPaint(painter: _GridP(cellSize));
}

class _GridP extends CustomPainter {
  final double cell;
  _GridP(this.cell);
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = ForgeTheme.canvasGrid..strokeWidth = 0.5;
    for (double x = 0; x < s.width; x += cell)
      c.drawLine(Offset(x, 0), Offset(x, s.height), p);
    for (double y = 0; y < s.height; y += cell)
      c.drawLine(Offset(0, y), Offset(s.width, y), p);
  }
  @override
  bool shouldRepaint(_GridP o) => o.cell != cell;
}

// ─────────────────────────────────────────────────────────────
//  Info bar
// ─────────────────────────────────────────────────────────────
class _InfoBar extends StatelessWidget {
  final ForgeProvider p;
  final String? dragId;
  final Offset  nodePos;
  const _InfoBar({required this.p, required this.dragId, required this.nodePos});

  @override
  Widget build(BuildContext context) {
    final n = p.selectedNode;
    final double x = (dragId != null && n?.id == dragId) ? nodePos.dx : (n?.x ?? 0);
    final double y = (dragId != null && n?.id == dragId) ? nodePos.dy : (n?.y ?? 0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        n != null
            ? '${n.displayName}  ${x.round()},${y.round()}  ${n.width.round()}×${n.height.round()}'
            : '${p.screen.name}  ·  ${p.screen.nodes.length} widgets',
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontFamily: 'monospace'),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Zoom bar
// ─────────────────────────────────────────────────────────────
class _ZoomBar extends StatelessWidget {
  final TransformationController tc;
  final ForgeProvider p;
  const _ZoomBar({required this.tc, required this.p});

  void _zoom(double f) {
    final s = (tc.value.getMaxScaleOnAxis() * f).clamp(0.1, 5.0);
    tc.value = Matrix4.identity()..scale(s);
    p.setScale(s);
  }
  void _reset() { tc.value = Matrix4.identity(); p.resetCanvas(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _Zb(Icons.remove, () => _zoom(0.8)),
        GestureDetector(
          onTap: _reset,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text('${(p.scale * 100).round()}%',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ),
        _Zb(Icons.add, () => _zoom(1.25)),
        _Zb(Icons.fit_screen, _reset),
      ]),
    );
  }
}

class _Zb extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _Zb(this.icon, this.onTap);
  @override
  Widget build(BuildContext c) => GestureDetector(
    onTap: onTap,
    child: Padding(padding: const EdgeInsets.all(7),
        child: Icon(icon, size: 14, color: Colors.white)),
  );
}

