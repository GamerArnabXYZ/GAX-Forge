import 'package:flutter/material.dart';
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
  late TransformationController _transformController;
  bool _isDragOver = false;
  List<Guide> _activeGuides = [];

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgeProvider>(
      builder: (context, provider, _) {
        final screen = provider.currentScreen;

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

              // InteractiveViewer
              InteractiveViewer(
                transformationController: _transformController,
                boundaryMargin: const EdgeInsets.all(500),
                minScale: 0.15,
                maxScale: 5.0,
                panEnabled: !provider.isDragging && !provider.isResizing,
                onInteractionUpdate: (_) {
                  provider.setCanvasScale(
                      _transformController.value.getMaxScaleOnAxis());
                },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: DragTarget<WType>(
                      onWillAcceptWithDetails: (_) {
                        setState(() => _isDragOver = true);
                        return true;
                      },
                      onLeave: (_) => setState(() => _isDragOver = false),
                      onAcceptWithDetails: (details) {
                        setState(() => _isDragOver = false);
                        final type = details.data;
                        final box =
                            context.findRenderObject() as RenderBox?;
                        if (box == null) {
                          provider.addNode(type,
                              x: screen.canvasWidth / 2 - 60,
                              y: screen.canvasHeight / 4);
                          return;
                        }
                        final localDrop =
                            box.globalToLocal(details.offset);
                        final scale = _transformController.value
                            .getMaxScaleOnAxis();
                        final tx = _transformController.value
                            .getTranslation();
                        double cx =
                            (localDrop.dx - tx.x) / scale - 48;
                        double cy =
                            (localDrop.dy - tx.y) / scale - 48;
                        cx = cx.clamp(
                            0, screen.canvasWidth - 100);
                        cy = cy.clamp(
                            0, screen.canvasHeight - 60);
                        provider.addNode(type, x: cx, y: cy);
                      },
                      builder: (context, _, __) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: screen.canvasWidth,
                          height: screen.canvasHeight,
                          decoration: BoxDecoration(
                            color: parseColor(
                                screen.backgroundColor,
                                fallback: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                color: _isDragOver
                                    ? ForgeTheme.primary
                                        .withOpacity(0.4)
                                    : Colors.black.withOpacity(0.5),
                                blurRadius:
                                    _isDragOver ? 60 : 40,
                                spreadRadius:
                                    _isDragOver ? 8 : 4,
                              ),
                            ],
                            border: _isDragOver
                                ? Border.all(
                                    color: ForgeTheme.primary,
                                    width: 2)
                                : null,
                          ),
                          child: GestureDetector(
                            onTap: provider.clearSelection,
                            behavior: HitTestBehavior.translucent,
                            child: Stack(
                              clipBehavior: Clip.hardEdge,
                              children: [
                                ...screen.sortedNodes
                                    .where((n) => n.visible)
                                    .map((n) => _CanvasNode(
                                          node: n,
                                          allNodes: screen.nodes,
                                          onGuideUpdate: (g) =>
                                              setState(
                                                  () => _activeGuides = g),
                                          onDragEnd: () => setState(
                                              () => _activeGuides = []),
                                        )),

                                // Alignment guides
                                if (_activeGuides.isNotEmpty)
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: AlignmentGuidePainter(
                                        guides:
                                            _activeGuides,
                                        canvasWidth:
                                            screen.canvasWidth,
                                        canvasHeight:
                                            screen.canvasHeight,
                                      ),
                                    ),
                                  ),

                                // Selection handles
                                if (provider.selectedNode != null)
                                  SelectionOverlay(
                                    node: provider.selectedNode!,
                                    scale: provider.canvasScale,
                                  ),

                                // Drop hint
                                if (_isDragOver)
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets
                                          .symmetric(
                                              horizontal: 16,
                                              vertical: 8),
                                      decoration: BoxDecoration(
                                        color: ForgeTheme.primary
                                            .withOpacity(0.9),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: const Text('Drop here',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight:
                                                  FontWeight.w600)),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 10, left: 10,
                child: _CanvasInfoBar(provider: provider),
              ),
              Positioned(
                bottom: 10, right: 10,
                child: _ZoomControls(
                    provider: provider, ctrl: _transformController),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Canvas node ───────────────────────────────────────────────
class _CanvasNode extends StatelessWidget {
  final WidgetNode node;
  final List<WidgetNode> allNodes;
  final ValueChanged<List<Guide>> onGuideUpdate;
  final VoidCallback onDragEnd;

  const _CanvasNode({
    required this.node,
    required this.allNodes,
    required this.onGuideUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ForgeProvider>();
    final isSelected = provider.selectedNodeId == node.id;

    return Positioned(
      left: node.x, top: node.y,
      width: node.width, height: node.height,
      child: GestureDetector(
        onTap: () { if (!node.locked) provider.selectNode(node.id); },
        onPanStart: (d) {
          if (node.locked) return;
          provider.onDragStart(node.id, d.globalPosition);
        },
        onPanUpdate: (d) {
          if (node.locked) return;
          provider.onDragUpdate(d.globalPosition);
          if (provider.isDragging) {
            final result = computeSnap(
              dragging: node,
              others: allNodes,
              proposedX: node.x,
              proposedY: node.y,
            );
            onGuideUpdate(result.guides);
            if ((result.x - node.x).abs() < kSnapThreshold ||
                (result.y - node.y).abs() < kSnapThreshold) {
              provider.applySnapPosition(node.id, result.x, result.y);
            }
          }
        },
        onPanEnd: (_) { provider.onDragEnd(); onDragEnd(); },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            IgnorePointer(child: WidgetRenderer(node: node)),
            if (node.locked)
              Positioned(
                top: 2, right: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(3)),
                  child: const Icon(Icons.lock,
                      color: Colors.white, size: 10),
                ),
              ),
            if (isSelected)
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
          ],
        ),
      ),
    );
  }
}

// ── Grid ──────────────────────────────────────────────────────
class _GridPainter extends StatelessWidget {
  final double size;
  const _GridPainter({required this.size});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GridCP(size));
}

class _GridCP extends CustomPainter {
  final double size;
  _GridCP(this.size);

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = ForgeTheme.canvasGrid
      ..strokeWidth = 0.5;
    for (double x = 0; x < s.width; x += size) {
      c.drawLine(Offset(x, 0), Offset(x, s.height), p);
    }
    for (double y = 0; y < s.height; y += size) {
      c.drawLine(Offset(0, y), Offset(s.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _GridCP old) => old.size != size;
}

// ── Canvas info bar ───────────────────────────────────────────
class _CanvasInfoBar extends StatelessWidget {
  final ForgeProvider provider;
  const _CanvasInfoBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final node = provider.selectedNode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ForgeTheme.surface2.withOpacity(0.92),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ForgeTheme.border),
      ),
      child: Text(
        node != null
            ? '${node.displayName}  x:${node.x.round()}  y:${node.y.round()}  ${node.width.round()}×${node.height.round()}'
            : '${provider.currentScreen.name}  ·  ${provider.currentScreen.nodes.length} widgets',
        style: const TextStyle(
            color: ForgeTheme.textSecondary,
            fontSize: 10,
            fontFamily: 'monospace'),
      ),
    );
  }
}

// ── Zoom controls ─────────────────────────────────────────────
class _ZoomControls extends StatelessWidget {
  final ForgeProvider provider;
  final TransformationController ctrl;
  const _ZoomControls({required this.provider, required this.ctrl});

  void _zoom(double factor) {
    final cur = ctrl.value.getMaxScaleOnAxis();
    final next = (cur * factor).clamp(0.15, 5.0);
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
        color: ForgeTheme.surface2.withOpacity(0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ForgeTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZBtn(Icons.remove, () => _zoom(0.8)),
          InkWell(
            onTap: _reset,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                '${(provider.canvasScale * 100).round()}%',
                style: const TextStyle(
                    color: ForgeTheme.textSecondary, fontSize: 11),
              ),
            ),
          ),
          _ZBtn(Icons.add, () => _zoom(1.25)),
          _ZBtn(Icons.fit_screen_rounded, _reset, tooltip: 'Reset view'),
        ],
      ),
    );
  }
}

class _ZBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  const _ZBtn(this.icon, this.onTap, {this.tooltip});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Tooltip(
        message: tooltip ?? '',
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon,
              size: 14, color: ForgeTheme.textSecondary),
        ),
      ),
    );
  }
}
