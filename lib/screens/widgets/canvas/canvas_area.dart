// lib/screens/widgets/canvas/canvas_area.dart
// GAX Forge - Interactive Canvas with gesture support

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/app_models.dart';
import '../../../providers/project_provider.dart';
import 'canvas_widget_renderer.dart';

class CanvasArea extends ConsumerStatefulWidget {
  final String projectId;
  const CanvasArea({super.key, required this.projectId});

  @override
  ConsumerState<CanvasArea> createState() => _CanvasAreaState();
}

class _CanvasAreaState extends ConsumerState<CanvasArea> {
  final TransformationController _transformCtrl = TransformationController();
  static const double _canvasW = 390.0; // iPhone 15 width
  static const double _canvasH = 844.0; // iPhone 15 height

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(editorProvider(widget.projectId));
    final notifier = ref.read(editorProvider(widget.projectId).notifier);
    final scheme = Theme.of(context).colorScheme;

    final isPreview = editor.previewMode || editor.activeTab == 2;
    final bgColor = Color(editor.activeScreen.backgroundColor);

    return GestureDetector(
      onTap: () {
        if (editor.canvasLocked) notifier.selectWidget(null);
      },
      child: InteractiveViewer(
        transformationController: _transformCtrl,
        panEnabled: !editor.canvasLocked,
        scaleEnabled: !editor.canvasLocked,
        minScale: 0.3,
        maxScale: 3.0,
        constrained: false,
        child: SizedBox(
          width: _canvasW + 80,
          height: _canvasH + 80,
          child: Center(
            child: Container(
              width: _canvasW,
              height: _canvasH,
              decoration: BoxDecoration(
                color: bgColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
                border: isPreview
                    ? null
                    : Border.all(
                        color: scheme.outline.withOpacity(0.5),
                        width: 1,
                      ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // ── Dot Grid Background ──────────
                  if (!isPreview)
                    Positioned.fill(child: _DotGrid(color: scheme.outline)),

                  // ── Canvas size label ────────────
                  if (!isPreview)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '390 × 844',
                          style: TextStyle(
                              fontSize: 10, color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ),

                  // ── Widgets ──────────────────────
                  ..._buildSortedWidgets(
                      editor, notifier, isPreview, scheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSortedWidgets(
    EditorState editor,
    EditorNotifier notifier,
    bool isPreview,
    ColorScheme scheme,
  ) {
    final sorted = [...editor.activeWidgets]
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return sorted.map((widget) {
      final isSelected = editor.selectedWidgetId == widget.id;
      return _DraggableWidget(
        key: ValueKey(widget.id),
        widgetProp: widget,
        isSelected: isSelected,
        isLocked: editor.canvasLocked,
        isPreview: isPreview,
        scheme: scheme,
        onTap: () {
          if (editor.canvasLocked) {
            notifier.selectWidget(
                isSelected ? null : widget.id);
          }
        },
        onMove: (dx, dy) => notifier.moveWidget(widget.id, dx, dy),
        onDelete: () => notifier.deleteWidget(widget.id),
        onDuplicate: () => notifier.duplicateWidget(widget.id),
        onBringFront: () => notifier.bringToFront(widget.id),
        onResize: (w, h) => notifier.resizeWidget(widget.id, w, h),
      );
    }).toList();
  }
}

// ── Draggable Widget Wrapper ────────────────────
class _DraggableWidget extends StatefulWidget {
  final WidgetProperty widgetProp;
  final bool isSelected;
  final bool isLocked;
  final bool isPreview;
  final ColorScheme scheme;
  final VoidCallback onTap;
  final Function(double dx, double dy) onMove;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onBringFront;
  final Function(double w, double h) onResize;

  const _DraggableWidget({
    super.key,
    required this.widgetProp,
    required this.isSelected,
    required this.isLocked,
    required this.isPreview,
    required this.scheme,
    required this.onTap,
    required this.onMove,
    required this.onDelete,
    required this.onDuplicate,
    required this.onBringFront,
    required this.onResize,
  });

  @override
  State<_DraggableWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<_DraggableWidget> {
  double _resizeStartW = 0, _resizeStartH = 0;

  @override
  Widget build(BuildContext context) {
    final w = widget.widgetProp;
    final isEditable = widget.isLocked; // Can interact when locked

    return Positioned(
      left: w.x,
      top: w.y,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: isEditable
            ? null
            : () => _showContextMenu(context),
        onPanStart: widget.isLocked
            ? null
            : (details) {
                _startX = w.x;
                _startY = w.y;
              },
        onPanUpdate: widget.isLocked
            ? null
            : (details) {
                widget.onMove(details.delta.dx, details.delta.dy);
              },
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // ── Selection border ──
            if (widget.isSelected && !widget.isPreview)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.scheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

            // ── Widget content ──
            SizedBox(
              width: w.width,
              height: w.height,
              child: CanvasWidgetRenderer(widgetProp: w),
            ),

            // ── Selection handles ──
            if (widget.isSelected && !widget.isPreview) ...[
              // Top-right: delete
              Positioned(
                top: -14,
                right: -14,
                child: _CornerButton(
                  icon: Icons.close_rounded,
                  color: widget.scheme.error,
                  onTap: widget.onDelete,
                ),
              ),
              // Top-left: duplicate
              Positioned(
                top: -14,
                left: -14,
                child: _CornerButton(
                  icon: Icons.copy_rounded,
                  color: widget.scheme.secondary,
                  onTap: widget.onDuplicate,
                ),
              ),
              // Bottom-left: bring to front
              Positioned(
                bottom: -14,
                left: -14,
                child: _CornerButton(
                  icon: Icons.flip_to_front_rounded,
                  color: widget.scheme.tertiary,
                  onTap: widget.onBringFront,
                ),
              ),
              // Bottom-right: resize handle
              Positioned(
                bottom: -8,
                right: -8,
                child: GestureDetector(
                  onPanStart: (d) {
                    _resizeStartW = w.width;
                    _resizeStartH = w.height;
                  },
                  onPanUpdate: (d) {
                    widget.onResize(
                      (_resizeStartW + d.localPosition.dx).clamp(40, 800),
                      (_resizeStartH + d.localPosition.dy).clamp(20, 800),
                    );
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: widget.scheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.open_in_full_rounded,
                        size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.copy_rounded),
            title: const Text('Duplicate'),
            onTap: () { Navigator.pop(ctx); widget.onDuplicate(); },
          ),
          ListTile(
            leading: const Icon(Icons.flip_to_front_rounded),
            title: const Text('Bring to Front'),
            onTap: () { Navigator.pop(ctx); widget.onBringFront(); },
          ),
          ListTile(
            leading: Icon(Icons.delete_rounded,
                color: Theme.of(ctx).colorScheme.error),
            title: Text('Delete',
                style: TextStyle(
                    color: Theme.of(ctx).colorScheme.error)),
            onTap: () { Navigator.pop(ctx); widget.onDelete(); },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CornerButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CornerButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.4), blurRadius: 4),
          ],
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }
}

// ── Dot Grid Painter ────────────────────────────
class _DotGrid extends StatelessWidget {
  final Color color;
  const _DotGrid({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotGridPainter(color: color));
  }
}

class _DotGridPainter extends CustomPainter {
  final Color color;
  const _DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotRadius = 1.0;

    for (double x = 0; x <= size.width; x += spacing) {
      for (double y = 0; y <= size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
