import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

/// Canvas Tab - main editor area jahan user widgets design karta hai
/// Device frame ke andar interactive canvas dikhata hai
class CanvasTab extends ConsumerStatefulWidget {
  const CanvasTab({super.key});

  @override
  ConsumerState<CanvasTab> createState() => _CanvasTabState();
}

class _CanvasTabState extends ConsumerState<CanvasTab> {
  Offset? _dragStartPosition;
  Size? _initialSize;

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Stack(
            children: [
              // Canvas area with scroll
              Positioned.fill(
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(200),
                  minScale: 0.25,
                  maxScale: 3.0,
                  child: Center(
                    child: _buildCanvas(canvasState),
                  ),
                ),
              ),

              // Zoom controls
              Positioned(
                right: 16,
                bottom: 16,
                child: _buildZoomControls(),
              ),

              // Selected widget controls
              if (canvasState.selectedWidgetId != null)
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: _buildSelectionControls(canvasState),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Build the main canvas with device frame
  Widget _buildCanvas(CanvasState canvasState) {
    // Default Pixel 6 dimensions
    const canvasWidth = 412.0;
    const canvasHeight = 915.0;

    return Container(
      width: canvasWidth,
      height: canvasHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Grid background
            if (canvasState.showGrid) _buildGrid(),

            // Canvas widgets
            ...canvasState.widgets.map((widget) {
              return _CanvasWidgetWrapper(
                key: ValueKey(widget.id),
                widgetModel: widget,
                isSelected: widget.id == canvasState.selectedWidgetId,
                onTap: () => _selectWidget(widget.id),
                onDragUpdate: (details) => _onDragUpdate(widget, details),
                onDragEnd: (details) => _onDragEnd(widget),
                onScaleUpdate: (details) => _onScaleUpdate(widget, details),
                onScaleEnd: (details) => _onScaleEnd(widget),
                onLongPress: () => _showContextMenu(widget),
              );
            }),

            // Empty state
            if (canvasState.widgets.isEmpty)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pan_tool_alt_outlined,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap widgets from library to add',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build grid lines
  Widget _buildGrid() {
    return CustomPaint(
      size: const Size(412, 915),
      painter: _GridPainter(),
    );
  }

  /// Zoom controls
  Widget _buildZoomControls() {
    final canvasState = ref.watch(canvasProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ref.read(canvasProvider.notifier).setZoom(canvasState.zoom + 0.25);
            },
            tooltip: 'Zoom In',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${(canvasState.zoom * 100).toInt()}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              ref.read(canvasProvider.notifier).setZoom(canvasState.zoom - 0.25);
            },
            tooltip: 'Zoom Out',
          ),
          const Divider(height: 1),
          IconButton(
            icon: Icon(
              canvasState.showGrid ? Icons.grid_on : Icons.grid_off,
              color: canvasState.showGrid ? AppTheme.primaryColor : null,
            ),
            onPressed: () => ref.read(canvasProvider.notifier).toggleGrid(),
            tooltip: 'Toggle Grid',
          ),
        ],
      ),
    );
  }

  /// Selection controls
  Widget _buildSelectionControls(CanvasState canvasState) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.flip_to_front),
            onPressed: () {
              if (canvasState.selectedWidgetId != null) {
                ref.read(canvasProvider.notifier).bringToFront(canvasState.selectedWidgetId!);
              }
            },
            tooltip: 'Bring to Front',
          ),
          IconButton(
            icon: const Icon(Icons.flip_to_back),
            onPressed: () {
              if (canvasState.selectedWidgetId != null) {
                ref.read(canvasProvider.notifier).sendToBack(canvasState.selectedWidgetId!);
              }
            },
            tooltip: 'Send to Back',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              if (canvasState.selectedWidgetId != null) {
                ref.read(canvasProvider.notifier).duplicateWidget(canvasState.selectedWidgetId!);
              }
            },
            tooltip: 'Duplicate',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              if (canvasState.selectedWidgetId != null) {
                ref.read(canvasProvider.notifier).removeWidget(canvasState.selectedWidgetId!);
              }
            },
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  /// Select widget
  void _selectWidget(String widgetId) {
    ref.read(canvasProvider.notifier).selectWidget(widgetId);
  }

  /// Handle drag update (move)
  void _onDragUpdate(CanvasWidgetModel widget, DragUpdateDetails details) {
    final newPosition = Offset(
      widget.position.dx + details.delta.dx,
      widget.position.dy + details.delta.dy,
    );
    ref.read(canvasProvider.notifier).updateWidgetPosition(widget.id, newPosition);
  }

  /// Handle drag end
  void _onDragEnd(CanvasWidgetModel widget) {
    // Position saved automatically
  }

  /// Handle scale update (resize)
  void _onScaleUpdate(CanvasWidgetModel widget, ScaleUpdateDetails details) {
    if (_initialSize == null) {
      _initialSize = widget.size;
    }

    final scale = details.scale;
    final newWidth = (_initialSize!.width * scale).clamp(20.0, 500.0);
    final newHeight = (_initialSize!.height * scale).clamp(20.0, 500.0);

    ref.read(canvasProvider.notifier).updateWidgetSize(widget.id, Size(newWidth, newHeight));
  }

  /// Handle scale end
  void _onScaleEnd(CanvasWidgetModel widget) {
    _initialSize = null;
    ref.read(canvasProvider.notifier).commitTransformChange();
  }

  /// Show context menu on long press
  void _showContextMenu(CanvasWidgetModel widget) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(context);
                ref.read(canvasProvider.notifier).duplicateWidget(widget.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flip_to_front),
              title: const Text('Bring to Front'),
              onTap: () {
                Navigator.pop(context);
                ref.read(canvasProvider.notifier).bringToFront(widget.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flip_to_back),
              title: const Text('Send to Back'),
              onTap: () {
                Navigator.pop(context);
                ref.read(canvasProvider.notifier).sendToBack(widget.id);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ref.read(canvasProvider.notifier).removeWidget(widget.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid painter
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.lightSurfaceVariant.withOpacity(0.3)
      ..strokeWidth = 0.5;

    const gridSize = 20.0;

    // Vertical lines
    for (var x = 0.0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (var y = 0.0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Canvas widget wrapper - individual widget ko wrap karta hai
class _CanvasWidgetWrapper extends StatelessWidget {
  final CanvasWidgetModel widgetModel;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(DragUpdateDetails) onDragUpdate;
  final Function(DragEndDetails) onDragEnd;
  final Function(ScaleUpdateDetails) onScaleUpdate;
  final Function(ScaleEndDetails) onScaleEnd;
  final VoidCallback onLongPress;

  const _CanvasWidgetWrapper({
    super.key,
    required this.widgetModel,
    required this.isSelected,
    required this.onTap,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onScaleUpdate,
    required this.onScaleEnd,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widgetModel.position.dx,
      top: widgetModel.position.dy,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        onScaleUpdate: onScaleUpdate,
        onScaleEnd: onScaleEnd,
        child: GestureDetector(
          onPanUpdate: onDragUpdate,
          onPanEnd: onDragEnd,
          child: Transform.scale(
            scale: widgetModel.scale,
            child: Transform.rotate(
              angle: widgetModel.rotation,
              child: Container(
                width: widgetModel.size.width,
                height: widgetModel.size.height,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppTheme.selectionBorder : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    // Widget preview
                    _buildWidgetPreview(),
                    // Selection handles
                    if (isSelected) _buildSelectionHandles(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build widget preview
  Widget _buildWidgetPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        width: widgetModel.size.width,
        height: widgetModel.size.height,
        child: _buildWidgetContent(),
      ),
    );
  }

  /// Build widget content based on type
  Widget _buildWidgetContent() {
    final props = widgetModel.properties;
    final color = _colorFromHex(props['color'] ?? '#E0E0E0');

    switch (widgetModel.type) {
      case WidgetType.text:
        return Center(
          child: Text(
            props['text'] ?? 'Text',
            style: TextStyle(
              fontSize: (props['fontSize'] ?? 16.0).toDouble(),
              color: _colorFromHex(props['color'] ?? '#000000'),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );

      case WidgetType.icon:
        return Icon(
          _parseIcon(props['iconName'] ?? 'Icons.star'),
          size: (props['size'] ?? 24.0).toDouble(),
          color: _colorFromHex(props['color'] ?? '#757575'),
        );

      case WidgetType.image:
        return Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.image, color: Colors.grey),
          ),
        );

      case WidgetType.elevatedButton:
        return Container(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorFromHex(props['buttonColor'] ?? '#6750A4'),
            ),
            child: Text(
              props['label'] ?? 'Button',
              style: TextStyle(color: _colorFromHex(props['textColor'] ?? '#FFFFFF')),
            ),
          ),
        );

      case WidgetType.card:
        return Card(
          elevation: (props['elevation'] ?? 2.0).toDouble(),
          color: _colorFromHex(props['color'] ?? '#FFFFFF'),
          child: const Center(
            child: Text('Card'),
          ),
        );

      default:
        return Container(
          color: color,
          child: Center(
            child: Text(
              widgetModel.type.displayName,
              style: TextStyle(
                fontSize: 10,
                color: _getContrastColor(color),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
    }
  }

  /// Build selection handles
  Widget _buildSelectionHandles() {
    return Stack(
      children: [
        // Corner handles for resize
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onScaleUpdate: onScaleUpdate,
            onScaleEnd: onScaleEnd,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppTheme.selection,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.open_in_full,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Parse color from hex string
  Color _colorFromHex(String hex) {
    final hexCode = hex.replaceAll('#', '');
    if (hexCode.length == 6) {
      return Color(int.parse('FF$hexCode', radix: 16));
    }
    return Colors.grey;
  }

  /// Parse icon from string
  IconData _parseIcon(String iconName) {
    final iconMap = {
      'Icons.star': Icons.star,
      'Icons.favorite': Icons.favorite,
      'Icons.home': Icons.home,
      'Icons.settings': Icons.settings,
      'Icons.person': Icons.person,
      'Icons.add': Icons.add,
      'Icons.edit': Icons.edit,
      'Icons.delete': Icons.delete,
      'Icons.search': Icons.search,
      'Icons.menu': Icons.menu,
      'Icons.list': Icons.list,
    };
    return iconMap[iconName] ?? Icons.star;
  }

  /// Get contrast color for text
  Color _getContrastColor(Color bgColor) {
    final luminance = bgColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
