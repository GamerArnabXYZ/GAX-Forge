import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

/// Widget Tree Panel - canvas pe widgets ki hierarchy dikhata hai
/// User nesting samajh sakta hai aur tree view mein widgets select kar sakta hai
class WidgetTreePanel extends ConsumerWidget {
  const WidgetTreePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(canvasProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.account_tree, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Widget Tree',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${canvasState.widgets.length} widgets',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Tree view
          Expanded(
            child: canvasState.widgets.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: canvasState.widgets.length,
                    itemBuilder: (context, index) {
                      // Reverse order so top widgets appear first
                      final widget = canvasState.widgets[canvasState.widgets.length - 1 - index];
                      final isSelected = widget.id == canvasState.selectedWidgetId;

                      return _WidgetTreeItem(
                        widget: widget,
                        index: index,
                        totalWidgets: canvasState.widgets.length,
                        isSelected: isSelected,
                        onTap: () {
                          ref.read(canvasProvider.notifier).selectWidget(widget.id);
                        },
                        onDelete: () {
                          ref.read(canvasProvider.notifier).removeWidget(widget.id);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.widgets_outlined,
              size: 32,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'No widgets added',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget tree item
class _WidgetTreeItem extends StatelessWidget {
  final CanvasWidgetModel widget;
  final int index;
  final int totalWidgets;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _WidgetTreeItem({
    required this.widget,
    required this.index,
    required this.totalWidgets,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : null,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppTheme.primaryColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            // Widget type icon
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _getColorForType(widget.type).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                _getIconForType(widget.type),
                size: 14,
                color: _getColorForType(widget.type),
              ),
            ),
            const SizedBox(width: 10),

            // Widget info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.type.displayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${widget.position.dx.toInt()}, ${widget.position.dy.toInt()} • ${widget.size.width.toInt()}×${widget.size.height.toInt()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            // Z-index indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${totalWidgets - index}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Delete button
            if (isSelected)
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                color: Colors.red.shade400,
              ),
          ],
        ),
      ),
    );
  }

  /// Get icon for widget type
  IconData _getIconForType(WidgetType type) {
    switch (type) {
      case WidgetType.container:
        return Icons.crop_square;
      case WidgetType.text:
        return Icons.text_fields;
      case WidgetType.icon:
        return Icons.star;
      case WidgetType.image:
        return Icons.image;
      case WidgetType.elevatedButton:
        return Icons.smart_button;
      case WidgetType.card:
        return Icons.credit_card;
      case WidgetType.row:
        return Icons.view_week;
      case WidgetType.column:
        return Icons.view_agenda;
      case WidgetType.stack:
        return Icons.layers;
      default:
        return Icons.widgets;
    }
  }

  /// Get color for widget type
  Color _getColorForType(WidgetType type) {
    switch (type.category) {
      case WidgetCategory.layout:
        return Colors.blue;
      case WidgetCategory.basic:
        return Colors.green;
      case WidgetCategory.complex:
        return Colors.orange;
    }
  }
}
