// lib/screens/widgets/canvas/canvas_area.dart
// GAX Forge - Canvas with auto-fit, screen sizes, screen connector

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/app_models.dart';
import '../../../models/screen_sizes.dart';
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

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  // Auto-fit canvas to viewport
  void _fitToScreen(Size viewport, DeviceScreenSize device) {
    final scaleX = (viewport.width - 40) / device.width;
    final scaleY = (viewport.height - 80) / device.height;
    final scale = (scaleX < scaleY ? scaleX : scaleY).clamp(0.15, 1.0);
    final tx = (viewport.width - device.width * scale) / 2;
    final ty = 20.0;
    final m = Matrix4.identity();
    m.scale(scale, scale, 1.0);
    m.setEntry(0, 3, tx);
    m.setEntry(1, 3, ty);
    _transformCtrl.value = m;
  }

  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(editorProvider(widget.projectId));
    final notifier = ref.read(editorProvider(widget.projectId).notifier);
    final scheme = Theme.of(context).colorScheme;
    final device = ScreenSizeCatalog.findById(editor.activeScreen.screenSize);
    final isPreview = editor.previewMode || editor.activeTab == 2;

    return LayoutBuilder(builder: (ctx, constraints) {
      final viewport = Size(constraints.maxWidth, constraints.maxHeight);

      return Stack(children: [
        // ── Main canvas ──
        GestureDetector(
          onTap: () { if (editor.canvasLocked) notifier.selectWidget(null); },
          child: InteractiveViewer(
            transformationController: _transformCtrl,
            panEnabled: !editor.canvasLocked,
            scaleEnabled: !editor.canvasLocked,
            minScale: 0.15,
            maxScale: 4.0,
            constrained: false,
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: _DeviceFrame(
                device: device,
                isPreview: isPreview,
                scheme: scheme,
                child: _CanvasContent(
                  projectId: widget.projectId,
                  device: device,
                  editor: editor,
                  notifier: notifier,
                  isPreview: isPreview,
                  scheme: scheme,
                ),
              ),
            ),
          ),
        ),

        // ── Top toolbar (non-preview) ──
        if (!isPreview)
          Positioned(
            top: 8, left: 8, right: 8,
            child: _CanvasToolbar(
              projectId: widget.projectId,
              editor: editor,
              notifier: notifier,
              device: device,
              scheme: scheme,
              onFit: () => _fitToScreen(viewport, device),
            ),
          ),

        // ── Preview exit button ──
        if (isPreview)
          Positioned(
            top: 12, right: 12,
            child: FloatingActionButton.small(
              backgroundColor: scheme.errorContainer,
              foregroundColor: scheme.onErrorContainer,
              elevation: 4,
              tooltip: 'Exit Preview',
              onPressed: () => notifier.setTab(1),
              child: const Icon(Icons.close_rounded),
            ),
          ),
      ]);
    });
  }
}

// ── Device frame wrapper ──────────────────────
class _DeviceFrame extends StatelessWidget {
  final DeviceScreenSize device;
  final bool isPreview;
  final ColorScheme scheme;
  final Widget child;
  const _DeviceFrame({required this.device, required this.isPreview,
      required this.scheme, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      // Device label
      if (!isPreview)
        Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(device.icon, size: 12, color: scheme.onPrimaryContainer),
            const SizedBox(width: 4),
            Text('${device.name}  ${device.resolution}',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                    color: scheme.onPrimaryContainer)),
          ]),
        ),
      // Frame
      Container(
        width: device.width,
        height: device.height,
        decoration: BoxDecoration(
          border: isPreview ? null : Border.all(
              color: scheme.outline.withOpacity(0.5), width: 1),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 24, spreadRadius: 2)],
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    ]);
  }
}

// ── Canvas content ────────────────────────────
class _CanvasContent extends StatelessWidget {
  final String projectId;
  final DeviceScreenSize device;
  final EditorState editor;
  final EditorNotifier notifier;
  final bool isPreview;
  final ColorScheme scheme;
  const _CanvasContent({required this.projectId, required this.device,
      required this.editor, required this.notifier,
      required this.isPreview, required this.scheme});

  @override
  Widget build(BuildContext context) {
    final bgColor = Color(editor.activeScreen.backgroundColor);
    final sorted = [...editor.activeWidgets]
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return Container(
      width: device.width,
      height: device.height,
      color: bgColor,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Dot grid
          if (!isPreview) const Positioned.fill(child: _DotGrid()),

          // Canvas size watermark
          if (!isPreview)
            Positioned(
              bottom: 8, right: 8,
              child: Text('${device.width.round()}×${device.height.round()}',
                  style: TextStyle(fontSize: 9,
                      color: scheme.onSurface.withOpacity(0.2))),
            ),

          // Widgets
          ...sorted.map((w) => _DraggableWidget(
            key: ValueKey(w.id),
            widgetProp: w,
            isSelected: editor.selectedWidgetId == w.id,
            isLocked: editor.canvasLocked,
            isPreview: isPreview,
            scheme: scheme,
            projectId: projectId,
            allScreens: editor.project.screens,
            onTap: () {
              if (editor.canvasLocked) {
                notifier.selectWidget(
                    editor.selectedWidgetId == w.id ? null : w.id);
              }
            },
            onMove: (dx, dy) => notifier.moveWidget(w.id, dx, dy),
            onDelete: () => notifier.deleteWidget(w.id),
            onDuplicate: () => notifier.duplicateWidget(w.id),
            onBringFront: () => notifier.bringToFront(w.id),
            onResize: (ww, hh) => notifier.resizeWidget(w.id, ww, hh),
            onResizeStart: () => notifier.pushUndoForResize(),
            onNavigateToScreen: (idx) => notifier.switchScreen(idx),
            onUpdateProp: (key, val) => notifier.updateWidgetProp(w.id, key, val),
          )),
        ],
      ),
    );
  }
}

// ── Draggable Widget ──────────────────────────
class _DraggableWidget extends StatefulWidget {
  final WidgetProperty widgetProp;
  final bool isSelected, isLocked, isPreview;
  final ColorScheme scheme;
  final String projectId;
  final List<CanvasScreen> allScreens;
  final VoidCallback onTap, onDelete, onDuplicate, onBringFront, onResizeStart;
  final Function(double, double) onMove, onResize;
  final Function(int) onNavigateToScreen;
  final Function(String, dynamic) onUpdateProp;

  const _DraggableWidget({
    super.key, required this.widgetProp, required this.isSelected,
    required this.isLocked, required this.isPreview, required this.scheme,
    required this.projectId, required this.allScreens,
    required this.onTap, required this.onDelete, required this.onDuplicate,
    required this.onBringFront, required this.onResizeStart,
    required this.onMove, required this.onResize,
    required this.onNavigateToScreen, required this.onUpdateProp,
  });

  @override
  State<_DraggableWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<_DraggableWidget> {
  double _resizeW = 0, _resizeH = 0;

  static const _navigableTypes = {
    'ElevatedButton', 'OutlinedButton', 'TextButton', 'FilledButton',
    'FilledTonalButton', 'IconButton', 'FloatingActionButton',
    'ListTile', 'Card', 'Chip', 'NavigationDrawer',
  };

  @override
  Widget build(BuildContext context) {
    final w = widget.widgetProp;
    final hasNav = _navigableTypes.contains(w.type);
    final navigateTo = (w.props['navigateTo'] as String?) ?? '';
    final isConnected = navigateTo.isNotEmpty;

    return Positioned(
      left: w.x, top: w.y,
      child: GestureDetector(
        onTap: widget.isPreview && isConnected
            ? () => _navigateToScreen(context, navigateTo)
            : widget.onTap,
        onLongPress: widget.isLocked ? null
            : () => _showContextMenu(context),
        onPanUpdate: widget.isLocked ? null
            : (d) => widget.onMove(d.delta.dx, d.delta.dy),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Selection border
            if (widget.isSelected && !widget.isPreview)
              Positioned.fill(child: IgnorePointer(child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: widget.scheme.primary, width: 2),
                ),
              ))),

            // Widget content
            SizedBox(width: w.width, height: w.height,
                child: CanvasWidgetRenderer(widgetProp: w)),

            // Screen connector badge (non-preview)
            if (!widget.isPreview && isConnected)
              Positioned(
                top: -8, left: w.width / 2 - 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.scheme.tertiary,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: widget.scheme.tertiary.withOpacity(0.4),
                        blurRadius: 4)],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.arrow_forward_rounded, size: 9,
                        color: widget.scheme.onTertiary),
                    const SizedBox(width: 2),
                    Text(_screenName(navigateTo),
                        style: TextStyle(fontSize: 8,
                            color: widget.scheme.onTertiary,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),

            // Selection handles
            if (widget.isSelected && !widget.isPreview) ...[
              // Delete (top-right)
              _CornerBtn(top: -13, right: -13,
                  icon: Icons.close_rounded, color: widget.scheme.error,
                  onTap: widget.onDelete),
              // Duplicate (top-left)
              _CornerBtn(top: -13, left: -13,
                  icon: Icons.copy_rounded, color: widget.scheme.secondary,
                  onTap: widget.onDuplicate),
              // Bring front (bottom-left)
              _CornerBtn(bottom: -13, left: -13,
                  icon: Icons.flip_to_front_rounded, color: widget.scheme.tertiary,
                  onTap: widget.onBringFront),
              // Screen link (bottom-center) — only for navigable types
              if (hasNav)
                Positioned(
                  bottom: -13, left: w.width / 2 - 13,
                  child: GestureDetector(
                    onTap: () => _showScreenLinkPicker(context),
                    child: Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        color: isConnected ? widget.scheme.tertiary : widget.scheme.outline,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.2), blurRadius: 4)],
                      ),
                      child: Icon(Icons.link_rounded, size: 13,
                          color: Colors.white),
                    ),
                  ),
                ),
              // Resize (bottom-right)
              Positioned(
                bottom: -10, right: -10,
                child: GestureDetector(
                  onPanStart: (_) {
                    widget.onResizeStart();
                    _resizeW = w.width;
                    _resizeH = w.height;
                  },
                  onPanUpdate: (d) {
                    _resizeW += d.delta.dx;
                    _resizeH += d.delta.dy;
                    widget.onResize(
                        _resizeW.clamp(20, 2000), _resizeH.clamp(10, 2000));
                  },
                  child: Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      color: widget.scheme.primary,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [BoxShadow(
                          color: widget.scheme.primary.withOpacity(0.4),
                          blurRadius: 4)],
                    ),
                    child: const Icon(Icons.open_in_full_rounded,
                        size: 13, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _screenName(String screenId) {
    try {
      return widget.allScreens.firstWhere((s) => s.id == screenId).name;
    } catch (_) {
      return '?';
    }
  }

  void _navigateToScreen(BuildContext context, String screenId) {
    final idx = widget.allScreens.indexWhere((s) => s.id == screenId);
    if (idx >= 0) widget.onNavigateToScreen(idx);
  }

  void _showScreenLinkPicker(BuildContext context) {
    final w = widget.widgetProp;
    final current = w.props['navigateTo'] as String? ?? '';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _ScreenLinkSheet(
        screens: widget.allScreens,
        currentScreenId: current,
        onSelect: (id) {
          widget.onUpdateProp('navigateTo', id);
          Navigator.pop(ctx);
        },
        onClear: () {
          widget.onUpdateProp('navigateTo', '');
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        ListTile(leading: const Icon(Icons.copy_rounded), title: const Text('Duplicate'),
            onTap: () { Navigator.pop(ctx); widget.onDuplicate(); }),
        ListTile(leading: const Icon(Icons.flip_to_front_rounded), title: const Text('Bring to Front'),
            onTap: () { Navigator.pop(ctx); widget.onBringFront(); }),
        ListTile(
            leading: Icon(Icons.delete_rounded, color: Theme.of(ctx).colorScheme.error),
            title: Text('Delete', style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
            onTap: () { Navigator.pop(ctx); widget.onDelete(); }),
        const SizedBox(height: 16),
      ]),
    );
  }
}

// ── Corner button ──────────────────────────────
class _CornerBtn extends StatelessWidget {
  final double? top, bottom, left, right;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CornerBtn({this.top, this.bottom, this.left, this.right,
      required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Positioned(
    top: top, bottom: bottom, left: left, right: right,
    child: GestureDetector(onTap: onTap, child: Container(
      width: 26, height: 26,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4)]),
      child: Icon(icon, size: 13, color: Colors.white),
    )),
  );
}

// ── Screen Link Sheet ─────────────────────────
class _ScreenLinkSheet extends StatelessWidget {
  final List<CanvasScreen> screens;
  final String currentScreenId;
  final Function(String) onSelect;
  final VoidCallback onClear;
  const _ScreenLinkSheet({required this.screens, required this.currentScreenId,
      required this.onSelect, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(2))),
        Row(children: [
          Icon(Icons.link_rounded, color: scheme.primary),
          const SizedBox(width: 8),
          Text('Link to Screen', style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        ...screens.map((s) {
          final isSelected = s.id == currentScreenId;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected ? scheme.primary : scheme.surfaceContainerHighest,
              radius: 16,
              child: Icon(Icons.phone_android_rounded, size: 16,
                  color: isSelected ? scheme.onPrimary : scheme.onSurfaceVariant),
            ),
            title: Text(s.name, style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : null,
                color: isSelected ? scheme.primary : null)),
            trailing: isSelected ? Icon(Icons.check_rounded, color: scheme.primary) : null,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: isSelected ? scheme.primaryContainer.withOpacity(0.3) : null,
            onTap: () => onSelect(s.id),
          );
        }),
        const Divider(height: 16),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: scheme.errorContainer, radius: 16,
            child: Icon(Icons.link_off_rounded, size: 16, color: scheme.error)),
          title: const Text('Remove Link'),
          onTap: onClear,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ]),
    );
  }
}

// ── Canvas Toolbar ────────────────────────────
class _CanvasToolbar extends StatelessWidget {
  final String projectId;
  final EditorState editor;
  final EditorNotifier notifier;
  final DeviceScreenSize device;
  final ColorScheme scheme;
  final VoidCallback onFit;
  const _CanvasToolbar({required this.projectId, required this.editor,
      required this.notifier, required this.device,
      required this.scheme, required this.onFit});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        // Screen size picker
        GestureDetector(
          onTap: () => _showScreenSizePicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scheme.outline.withOpacity(0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(device.icon, size: 13, color: scheme.primary),
              const SizedBox(width: 4),
              Text(device.name, style: TextStyle(fontSize: 11,
                  fontWeight: FontWeight.w600, color: scheme.onSurface)),
              const SizedBox(width: 2),
              Icon(Icons.arrow_drop_down_rounded, size: 16, color: scheme.onSurface),
            ]),
          ),
        ),
        const SizedBox(width: 6),
        // Fit button
        _ToolBtn(icon: Icons.fit_screen_rounded, tooltip: 'Fit to Screen', onTap: onFit, scheme: scheme),
        const SizedBox(width: 6),
        // Lock toggle
        _ToolBtn(
          icon: editor.canvasLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
          tooltip: editor.canvasLocked ? 'Unlock' : 'Lock Canvas',
          onTap: notifier.toggleLock,
          scheme: scheme,
          active: editor.canvasLocked,
        ),
      ]),
    );
  }

  void _showScreenSizePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7, maxChildSize: 0.92, minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => _ScreenSizePicker(
          currentId: editor.activeScreen.screenSize,
          onSelect: (id) {
            notifier.setScreenSize(editor.activeScreenIndex, id);
            Navigator.pop(ctx);
          },
          scrollController: ctrl,
        ),
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final ColorScheme scheme;
  final bool active;
  const _ToolBtn({required this.icon, required this.tooltip,
      required this.onTap, required this.scheme, this.active = false});
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: active ? scheme.primaryContainer : scheme.surfaceContainerHighest.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withOpacity(0.3)),
      ),
      child: Icon(icon, size: 15,
          color: active ? scheme.onPrimaryContainer : scheme.onSurface),
    )),
  );
}

// ── Screen Size Picker ────────────────────────
class _ScreenSizePicker extends StatefulWidget {
  final String currentId;
  final Function(String) onSelect;
  final ScrollController scrollController;
  const _ScreenSizePicker({required this.currentId, required this.onSelect,
      required this.scrollController});
  @override
  State<_ScreenSizePicker> createState() => _ScreenSizePickerState();
}

class _ScreenSizePickerState extends State<_ScreenSizePicker>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final cats = ScreenSizeCatalog.categories;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: cats.length, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(children: [
      const SizedBox(height: 8),
      Container(width: 36, height: 4,
          decoration: BoxDecoration(color: scheme.outlineVariant,
              borderRadius: BorderRadius.circular(2))),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(children: [
          Icon(Icons.phone_android_rounded, color: scheme.primary),
          const SizedBox(width: 8),
          Text('Screen Size', style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold)),
        ]),
      ),
      TabBar(
        controller: _tabCtrl,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: cats.map((c) => Tab(text: c)).toList(),
      ),
      Expanded(child: TabBarView(
        controller: _tabCtrl,
        children: cats.map((cat) {
          final sizes = ScreenSizeCatalog.byCategory(cat);
          return ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: sizes.length,
            itemBuilder: (ctx, i) {
              final s = sizes[i];
              final isSelected = s.id == widget.currentId;
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                color: isSelected ? scheme.primaryContainer : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  dense: true,
                  leading: Icon(s.icon, color: isSelected ? scheme.primary : null),
                  title: Text(s.name, style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : null,
                      color: isSelected ? scheme.primary : null)),
                  subtitle: Text('${s.brand}  •  ${s.resolution}',
                      style: const TextStyle(fontSize: 11)),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded, color: scheme.primary)
                      : Text('${s.width.round()}×${s.height.round()}',
                          style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
                  onTap: () => widget.onSelect(s.id),
                ),
              );
            },
          );
        }).toList(),
      )),
    ]);
  }
}

// ── Dot Grid ──────────────────────────────────
class _DotGrid extends StatelessWidget {
  const _DotGrid();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _DotGridPainter(
          color: Theme.of(context).colorScheme.outline));
}

class _DotGridPainter extends CustomPainter {
  final Color color;
  const _DotGridPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.15)..style = PaintingStyle.fill;
    const step = 20.0;
    for (double x = 0; x <= size.width; x += step) {
      for (double y = 0; y <= size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}


