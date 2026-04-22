import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';

/// Widget Library Item Card - widget library mein dikhata hai
/// Har widget ka preview aur tap-to-add functionality
class WidgetLibraryItemCard extends ConsumerWidget {
  final WidgetLibraryItem item;
  final VoidCallback onTap;

  const WidgetLibraryItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getCategoryColor(item.category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  color: _getCategoryColor(item.category),
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.displayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(WidgetCategory category) {
    switch (category) {
      case WidgetCategory.layout:
        return Colors.blue;
      case WidgetCategory.basic:
        return Colors.green;
      case WidgetCategory.complex:
        return Colors.orange;
    }
  }
}

/// Canvas Widget Wrapper - canvas pe drag-drop ke liye
/// Gesture detection aur selection state handle karta hai
class CanvasWidgetWrapper extends ConsumerWidget {
  final CanvasWidgetModel widgetModel;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(DragUpdateDetails) onDragUpdate;
  final Function(DragEndDetails) onDragEnd;
  final VoidCallback onDelete;

  const CanvasWidgetWrapper({
    super.key,
    required this.widgetModel,
    required this.isSelected,
    required this.onTap,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      left: widgetModel.position.dx,
      top: widgetModel.position.dy,
      child: GestureDetector(
        onTap: onTap,
        onPanUpdate: onDragUpdate,
        onPanEnd: onDragEnd,
        child: Container(
          width: widgetModel.size.width,
          height: widgetModel.size.height,
          decoration: BoxDecoration(
            color: _getWidgetColor(),
            border: Border.all(
              color: isSelected ? Colors.purple : Colors.grey.shade400,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              // Widget content
              _buildWidgetContent(),

              // Selection overlay
              if (isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.purple.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

              // Delete button
              if (isSelected)
                Positioned(
                  right: -8,
                  top: -8,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getWidgetColor() {
    final props = widgetModel.properties;
    final colorHex = props['color'] as String?;
    if (colorHex != null) {
      try {
        final hexCode = colorHex.replaceAll('#', '');
        if (hexCode.length == 6) {
          return Color(int.parse('FF$hexCode', radix: 16));
        }
      } catch (_) {}
    }
    return Colors.grey.shade200;
  }

  Widget _buildWidgetContent() {
    // Return widget preview based on type
    return Center(
      child: Text(
        widgetModel.type.displayName,
        style: TextStyle(
          fontSize: 10,
          color: _getContrastColor(_getWidgetColor()),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _getContrastColor(Color bgColor) {
    final luminance = bgColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
