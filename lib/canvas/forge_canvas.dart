import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/forge_provider.dart';
import '../core/models/widget_node.dart';
import '../ui/theme.dart';
import 'widget_renderer.dart';
import 'selection_handles.dart';

// ─────────────────────────────────────────────────────────────
//  ForgeCanvas
//  • InteractiveViewer handles zoom/pan
//  • Each widget is individually draggable via GestureDetector
//  • panEnabled = false while ANY widget is being dragged
//  • canvasLocked = pan/zoom off, drag still works
// ─────────────────────────────────────────────────────────────
class ForgeCanvas extends StatefulWidget {
  const ForgeCanvas({super.key});
  @override
  State<ForgeCanvas> createState() => _ForgeCanvasState();
}

class _ForgeCanvasState extends State<ForgeCanvas> {
  final _tc = TransformationController();
  String? _dragging;   // id of node being dragged

  @override
  void dispose() { _tc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgeProvider>(
      builder: (_, p, __) {
        final s = p.screen;
        final locked = p.canvasLocked;

        return Container(
          color: ForgeTheme.canvasBg,
          child: Stack(children: [

            // Grid dots
            if (p.showGrid)
              Positioned.fill(child: _GridWidget(
                  cellSize: (8.0 * p.scale).clamp(6.0, 48.0))),

            // Main viewer
            InteractiveViewer(
              transformationController: _tc,
              boundaryMargin: const EdgeInsets.all(600),
              minScale: 0.1,
              maxScale: 5.0,
              panEnabled:  _dragging == null && !locked,
              scaleEnabled: !locked,
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
                    boxShadow: const [
                      BoxShadow(color: Color(0x44000000),
                          blurRadius: 32, spreadRadius: 4),
                    ],
                  ),
                  // Tap canvas bg = deselect
                  child: GestureDetector(
                    onTap: p.clearSelection,
                    behavior: HitTestBehavior.translucent,
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [

                        // ── Widgets ──────────────────────────
                        ...s.sortedNodes.where((n) => n.visible).map((n) =>
                          _DraggableNode(
                            key: ValueKey(n.id),
                            node:     n,
                            provider: p,
                            locked:   locked,
                            scale:    _tc.value.getMaxScaleOnAxis(),
                            onDragStart: () =>
                                setState(() => _dragging = n.id),
                            onDragEnd: () =>
                                setState(() => _dragging = null),
                          ),
                        ),

                        // ── Selection handles ─────────────────
                        if (!locked && p.selectedNode != null)
                          _HandlesOverlay(
                            node:     p.selectedNode!,
                            provider: p,
                            scale:    _tc.value.getMaxScaleOnAxis(),
                            canvasW:  s.canvasWidth,
                            canvasH:  s.canvasHeight,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Info bar
            Positioned(
              left: 8, bottom: 8,
              child: _InfoBar(p: p),
            ),

            // Zoom bar (hidden when locked)
            if (!locked)
              Positioned(
                right: 8, bottom: 8,
                child: _ZoomBar(tc: _tc, p: p),
              ),

            // Lock banner
            if (locked)
              Positioned(
                top: 0, left: 0, right: 0,
                child: _LockBanner(onUnlock: p.toggleCanvasLock),
              ),
          ]),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  _DraggableNode
//  GestureDetector wrapping each widget — pan events here
//  WILL win over InteractiveViewer because panEnabled=false
//  during drag.
// ─────────────────────────────────────────────────────────────
class _DraggableNode extends StatefulWidget {
  final WidgetNode   node;
  final ForgeProvider provider;
  final bool         locked;
  final double       scale;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;

  const _DraggableNode({
    required super.key,
    required this.node,
    required this.provider,
    required this.locked,
    required this.scale,
    required this.onDragStart,
    required this.onDragEnd,
  });

  @override
  State<_DraggableNode> createState() => _DraggableNodeState();
}

class _DraggableNodeState extends State<_DraggableNode> {
  double _startNodeX = 0, _startNodeY = 0;
  double _startPtrX  = 0, _startPtrY  = 0;
  bool   _dragging   = false;

  // Local position during drag (smooth — no provider notify)
  double _lx = 0, _ly = 0;

  @override
  void initState() {
    super.initState();
    _lx = widget.node.x;
    _ly = widget.node.y;
  }

  @override
  void didUpdateWidget(covariant _DraggableNode old) {
    super.didUpdateWidget(old);
    // Sync local pos when NOT dragging (e.g. undo)
    if (!_dragging) {
      _lx = widget.node.x;
      _ly = widget.node.y;
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.node;
    final p = widget.provider;
    final isSelected = p.selectedId == n.id;

    return Positioned(
      left: _lx, top: _ly,
      width: n.width, height: n.height,
      child: GestureDetector(
        onTap: () {
          if (!widget.locked && !n.locked) p.select(n.id);
        },
        onPanStart: (d) {
          if (n.locked) return;
          if (!widget.locked) p.select(n.id);
          _dragging = true;
          _startNodeX = n.x; _startNodeY = n.y;
          _startPtrX  = d.globalPosition.dx;
          _startPtrY  = d.globalPosition.dy;
          widget.onDragStart();
        },
        onPanUpdate: (d) {
          if (!_dragging || n.locked) return;
          final sc = widget.scale.clamp(0.1, 5.0);
          final dx = (d.globalPosition.dx - _startPtrX) / sc;
          final dy = (d.globalPosition.dy - _startPtrY) / sc;

          final screen = p.screen;
          final nx = (_startNodeX + dx)
              .clamp(0.0, screen.canvasWidth  - n.width);
          final ny = (_startNodeY + dy)
              .clamp(0.0, screen.canvasHeight - n.height);

          // Update locally for smooth rendering
          setState(() { _lx = nx; _ly = ny; });
          // Update model silently (no notify)
          p.moveNodeDirect(n.id, nx, ny);
        },
        onPanEnd: (_) {
          if (!_dragging) return;
          _dragging = false;
          // Commit to history + save + notify
          p.commitMove(n.id, _startNodeX, _startNodeY);
          widget.onDragEnd();
        },
        onPanCancel: () {
          if (!_dragging) return;
          _dragging = false;
          // Restore original position
          setState(() { _lx = _startNodeX; _ly = _startNodeY; });
          p.moveNodeDirect(n.id, _startNodeX, _startNodeY);
          p.commitMove(n.id, _startNodeX, _startNodeY);
          widget.onDragEnd();
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Widget content
            SizedBox(
              width: n.width, height: n.height,
              child: IgnorePointer(child: WidgetRenderer(node: n)),
            ),

            // Selection highlight
            if (isSelected && !widget.locked)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: ForgeTheme.selection, width: 1.5),
                    ),
                  ),
                ),
              ),

            // Locked badge
            if (n.locked)
              Positioned(
                top: 3, right: 3,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4)),
                  child: const Icon(Icons.lock,
                      color: Colors.white, size: 9),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  _HandlesOverlay  — 8-point resize handles
// ─────────────────────────────────────────────────────────────
class _HandlesOverlay extends StatelessWidget {
  final WidgetNode    node;
  final ForgeProvider provider;
  final double        scale;
  final double        canvasW, canvasH;

  const _HandlesOverlay({
    required this.node, required this.provider,
    required this.scale, required this.canvasW, required this.canvasH,
  });

  @override
  Widget build(BuildContext context) {
    return ForgeSelectionOverlay(
      node: node, scale: scale,
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Grid dots
// ─────────────────────────────────────────────────────────────
class _GridWidget extends StatelessWidget {
  final double cellSize;
  const _GridWidget({required this.cellSize});

  @override
  Widget build(BuildContext c) =>
      CustomPaint(painter: _GridPainter(cellSize));
}

class _GridPainter extends CustomPainter {
  final double cell;
  _GridPainter(this.cell);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ForgeTheme.canvasGrid
      ..strokeWidth = 0.6;
    for (double x = 0; x < size.width; x += cell)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += cell)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.cell != cell;
}

// ─────────────────────────────────────────────────────────────
//  Info bar
// ─────────────────────────────────────────────────────────────
class _InfoBar extends StatelessWidget {
  final ForgeProvider p;
  const _InfoBar({required this.p});

  @override
  Widget build(BuildContext context) {
    final n = p.selectedNode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        n != null
            ? '${n.displayName}  ${n.x.round()}, ${n.y.round()}  ${n.width.round()}×${n.height.round()}'
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

  void _zoom(double factor) {
    final s = (tc.value.getMaxScaleOnAxis() * factor).clamp(0.1, 5.0);
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

// ─────────────────────────────────────────────────────────────
//  Lock banner
// ─────────────────────────────────────────────────────────────
class _LockBanner extends StatelessWidget {
  final VoidCallback onUnlock;
  const _LockBanner({required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCC1A1A2E),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        child: Row(children: [
          const Icon(Icons.lock, color: Colors.yellowAccent, size: 14),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Canvas locked — zoom/pan off, widgets draggable',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
          GestureDetector(
            onTap: onUnlock,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.yellowAccent.withOpacity(0.6)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text('Unlock',
                  style: TextStyle(color: Colors.yellowAccent,
                      fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }
}
