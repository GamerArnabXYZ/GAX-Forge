import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../core/providers/forge_provider.dart';
import '../core/models/widget_node.dart';
import '../ui/theme.dart';
import 'widget_renderer.dart';
import 'selection_handles.dart';
import 'alignment_guides.dart';

class ForgeCanvas extends StatefulWidget {
  const ForgeCanvas({super.key});
  @override
  State<ForgeCanvas> createState() => _ForgeCanvasState();
}

class _ForgeCanvasState extends State<ForgeCanvas> {
  final TransformationController _tc = TransformationController();
  bool _isDragOver = false;
  List<Guide> _activeGuides = [];

  // Active drag tracking (bypass InteractiveViewer)
  String? _activeDragId;
  Offset? _pointerStartGlobal;
  Offset? _nodeStartLocal; // node x,y in canvas coords at drag start

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  // Convert global screen position → canvas local position
  Offset _globalToCanvas(Offset global) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return global;
    final local = box.globalToLocal(global);
    // Use matrix storage directly to avoid Vector3 type conflict
    final m = Matrix4.inverted(_tc.value).storage;
    final x = m[0]*local.dx + m[4]*local.dy + m[12];
    final y = m[1]*local.dx + m[5]*local.dy + m[13];
    // subtract the 48px padding inside InteractiveViewer's Center+Padding
    return Offset(x - 48, y - 48);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgeProvider>(
      builder: (context, provider, _) {
        final screen = provider.currentScreen;
        final locked = provider.previewLocked;

        return Container(
          color: ForgeTheme.canvasBg,
          child: Stack(
            children: [
              // Grid
              if (provider.showGrid)
                Positioned.fill(
                  child: _GridPainter(
                      size: (provider.gridSize * provider.canvasScale)
                          .clamp(4.0, 64.0)),
                ),

              // ── Pointer Listener — intercepts touch before InteractiveViewer ──
              Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (e) => _onPointerDown(e, provider, screen),
                onPointerMove: (e) => _onPointerMove(e, provider, screen),
                onPointerUp: (e) => _onPointerUp(e, provider),
                onPointerCancel: (e) => _onPointerUp(
                    PointerUpEvent(
                      pointer: e.pointer,
                      position: e.position,
                    ),
                    provider),
                child: InteractiveViewer(
                  transformationController: _tc,
                  boundaryMargin: const EdgeInsets.all(500),
                  minScale: 0.15,
                  maxScale: 5.0,
                  // Pan/zoom disabled when dragging a widget OR canvas locked
                  panEnabled: _activeDragId == null && !locked,
                  scaleEnabled: !locked,
                  onInteractionUpdate: (_) {
                    provider.setCanvasScale(
                        _tc.value.getMaxScaleOnAxis());
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: DragTarget<WType>(
                        onWillAcceptWithDetails: (_) {
                          setState(() => _isDragOver = true);
                          return true;
                        },
                        onLeave: (_) =>
                            setState(() => _isDragOver = false),
                        onAcceptWithDetails: (details) {
                          setState(() => _isDragOver = false);
                          final type = details.data;
                          final box = context.findRenderObject() as RenderBox?;
                          if (box == null) {
                            provider.addNode(type,
                                x: screen.canvasWidth / 2 - 60,
                                y: screen.canvasHeight / 4);
                            return;
                          }
                          final c = _globalToCanvas(details.offset);
                          provider.addNode(type,
                              x: c.dx.clamp(0, screen.canvasWidth - 100),
                              y: c.dy.clamp(0, screen.canvasHeight - 60));
                        },
                        builder: (context, _, __) => GestureDetector(
                          onTap: provider.clearSelection,
                          behavior: HitTestBehavior.translucent,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: screen.canvasWidth,
                            height: screen.canvasHeight,
                            decoration: BoxDecoration(
                              color: parseColor(screen.backgroundColor,
                                  fallback: Colors.white),
                              boxShadow: [
                                BoxShadow(
                                  color: _isDragOver
                                      ? ForgeTheme.primary.withOpacity(0.35)
                                      : Colors.black.withOpacity(0.45),
                                  blurRadius: _isDragOver ? 60 : 40,
                                  spreadRadius: _isDragOver ? 8 : 4,
                                ),
                              ],
                              border: _isDragOver
                                  ? Border.all(
                                      color: ForgeTheme.primary, width: 2)
                                  : null,
                            ),
                            child: Stack(
                              clipBehavior: Clip.hardEdge,
                              children: [
                                // Render all visible nodes (IgnorePointer — Listener handles input)
                                ...screen.sortedNodes
                                    .where((n) => n.visible)
                                    .map((n) => Positioned(
                                          left: n.x, top: n.y,
                                          width: n.width, height: n.height,
                                          child: Stack(children: [
                                            IgnorePointer(
                                                child: WidgetRenderer(node: n)),
                                            // Selection ring
                                            if (provider.selectedNodeId == n.id && !locked)
                                              Positioned.fill(
                                                child: IgnorePointer(
                                                  child: DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: ForgeTheme.selection,
                                                          width: 1.5),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            // Locked badge
                                            if (n.locked)
                                              Positioned(
                                                top: 2, right: 2,
                                                child: Container(
                                                  padding: const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                      color: Colors.black54,
                                                      borderRadius:
                                                          BorderRadius.circular(3)),
                                                  child: const Icon(Icons.lock,
                                                      color: Colors.white, size: 10),
                                                ),
                                              ),
                                          ]),
                                        )),

                                // Alignment guides
                                if (_activeGuides.isNotEmpty)
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: AlignmentGuidePainter(
                                        guides: _activeGuides,
                                        canvasWidth: screen.canvasWidth,
                                        canvasHeight: screen.canvasHeight,
                                      ),
                                    ),
                                  ),

                                // Selection handles (edit mode only)
                                if (!locked && provider.selectedNode != null)
                                  ForgeSelectionOverlay(
                                    node: provider.selectedNode!,
                                    scale: provider.canvasScale,
                                  ),

                                if (_isDragOver)
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: ForgeTheme.primary.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('Drop here',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Info bar
              Positioned(
                bottom: 10, left: 10,
                child: _CanvasInfoBar(provider: provider),
              ),

              // Zoom controls
              if (!locked)
                Positioned(
                  bottom: 10, right: 10,
                  child: _ZoomControls(provider: provider, ctrl: _tc),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Hit test: which node is under pointer? ────────────────
  WidgetNode? _hitTest(Offset canvasPos, List<WidgetNode> nodes) {
    // Reverse order = top z-index first
    for (final n in nodes.reversed) {
      if (!n.visible || n.locked) continue;
      final rect = Rect.fromLTWH(n.x, n.y, n.width, n.height);
      if (rect.contains(canvasPos)) return n;
    }
    return null;
  }

  // ── Pointer handlers ──────────────────────────────────────
  void _onPointerDown(PointerDownEvent e, ForgeProvider provider,
      dynamic screen) {
    final canvasPos = _globalToCanvas(e.position);
    final node = _hitTest(canvasPos, screen.sortedNodes);

    if (node == null) {
      provider.clearSelection();
      return;
    }

    // Select it
    if (!provider.previewLocked) provider.selectNode(node.id);

    // Start drag
    _activeDragId = node.id;
    _pointerStartGlobal = e.position;
    _nodeStartLocal = Offset(node.x, node.y);
    setState(() {}); // disable InteractiveViewer pan
  }

  void _onPointerMove(PointerMoveEvent e, ForgeProvider provider,
      dynamic screen) {
    if (_activeDragId == null || _pointerStartGlobal == null ||
        _nodeStartLocal == null) return;

    final node = screen.sortedNodes
        .cast<WidgetNode?>()
        .firstWhere((n) => n?.id == _activeDragId, orElse: () => null);
    if (node == null) return;

    final scale = _tc.value.getMaxScaleOnAxis();
    final delta = (e.position - _pointerStartGlobal!) / scale;

    double nx = (_nodeStartLocal!.dx + delta.dx)
        .clamp(0.0, screen.canvasWidth - node.width) as double;
    double ny = (_nodeStartLocal!.dy + delta.dy)
        .clamp(0.0, screen.canvasHeight - node.height) as double;

    // Snap
    final result = computeSnap(
      dragging: node,
      others: screen.nodes,
      proposedX: nx,
      proposedY: ny,
    );
    nx = result.x;
    ny = result.y;

    node.x = nx;
    node.y = ny;

    setState(() => _activeGuides = result.guides);
    provider.notifyMove();
  }

  void _onPointerUp(PointerUpEvent e, ForgeProvider provider) {
    if (_activeDragId == null) return;

    // Save final position
    provider.commitDrag(_activeDragId!, _nodeStartLocal!);

    _activeDragId = null;
    _pointerStartGlobal = null;
    _nodeStartLocal = null;
    setState(() => _activeGuides = []);
  }
}

// ── Grid ──────────────────────────────────────────────────────
class _GridPainter extends StatelessWidget {
  final double size;
  const _GridPainter({required this.size});
  @override
  Widget build(BuildContext c) => CustomPaint(painter: _GridCP(size));
}

class _GridCP extends CustomPainter {
  final double size;
  _GridCP(this.size);
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()..color = ForgeTheme.canvasGrid..strokeWidth = 0.5;
    for (double x = 0; x < s.width; x += size)
      c.drawLine(Offset(x, 0), Offset(x, s.height), p);
    for (double y = 0; y < s.height; y += size)
      c.drawLine(Offset(0, y), Offset(s.width, y), p);
  }
  @override
  bool shouldRepaint(covariant _GridCP o) => o.size != size;
}

// ── Info bar ──────────────────────────────────────────────────
class _CanvasInfoBar extends StatelessWidget {
  final ForgeProvider provider;
  const _CanvasInfoBar({required this.provider});
  @override
  Widget build(BuildContext context) {
    final n = provider.selectedNode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        n != null
            ? '${n.displayName}  x:${n.x.round()}  y:${n.y.round()}  ${n.width.round()}×${n.height.round()}'
            : '${provider.currentScreen.name}  ·  ${provider.currentScreen.nodes.length} widgets',
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontFamily: 'monospace'),
      ),
    );
  }
}

// ── Zoom controls ─────────────────────────────────────────────
class _ZoomControls extends StatelessWidget {
  final ForgeProvider provider;
  final TransformationController ctrl;
  const _ZoomControls({required this.provider, required this.ctrl});

  void _zoom(double f) {
    final next = (ctrl.value.getMaxScaleOnAxis() * f).clamp(0.15, 5.0);
    ctrl.value = Matrix4.identity()..scale(next);
    provider.setCanvasScale(next);
  }

  void _reset() {
    ctrl.value = Matrix4.identity();
    provider.resetCanvas();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _ZBtn(Icons.remove, () => _zoom(0.8)),
        InkWell(
          onTap: _reset,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text('${(provider.canvasScale * 100).round()}%',
                style: const TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ),
        _ZBtn(Icons.add, () => _zoom(1.25)),
        _ZBtn(Icons.fit_screen_rounded, _reset),
      ]),
    );
  }
}

class _ZBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ZBtn(this.icon, this.onTap);
  @override
  Widget build(BuildContext c) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(6),
      child: Icon(icon, size: 14, color: Colors.white),
    ),
  );
}
