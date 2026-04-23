import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import '../theme/app_theme.dart';

/// Widgets Tab - Widget library aur property editor dikhata hai
/// Left side mein widget library, right side mein property editor
class WidgetsTab extends ConsumerWidget {
  const WidgetsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedWidget = ref.watch(selectedWidgetProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if we're on a wide screen (tablet/desktop)
        final isWideScreen = constraints.maxWidth > 800;

        if (isWideScreen) {
          // Split view for wide screens
          return Row(
            children: [
              // Widget library
              SizedBox(
                width: 280,
                child: _WidgetLibrary(),
              ),
              const VerticalDivider(width: 1),
              // Property editor
              Expanded(
                child: selectedWidget != null
                    ? PropertyEditor(widgetModel: selectedWidget)
                    : _buildNoSelection(context),
              ),
            ],
          );
        } else {
          // Vertical layout for narrow screens
          return Column(
            children: [
              // Widget library (horizontal scrollable)
              SizedBox(
                height: 120,
                child: _WidgetLibrary(isHorizontal: true),
              ),
              const Divider(height: 1),
              // Property editor
              Expanded(
                child: selectedWidget != null
                    ? PropertyEditor(widgetModel: selectedWidget)
                    : _buildNoSelection(context),
              ),
            ],
          );
        }
      },
    );
  }

  /// Message shown when no widget is selected
  Widget _buildNoSelection(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a widget to edit properties',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Or tap a widget in the library to add it',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget library - available widgets ki list dikhata hai
class _WidgetLibrary extends ConsumerWidget {
  final bool isHorizontal;

  const _WidgetLibrary({this.isHorizontal = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(widgetSearchQueryProvider);
    final filteredWidgets = ref.watch(filteredWidgetLibraryProvider);

    // Group widgets by category
    final layoutWidgets = filteredWidgets.where((w) => w.category == WidgetCategory.layout).toList();
    final basicWidgets = filteredWidgets.where((w) => w.category == WidgetCategory.basic).toList();
    final complexWidgets = filteredWidgets.where((w) => w.category == WidgetCategory.complex).toList();

    if (isHorizontal) {
      return _buildHorizontalLayout(context, ref, filteredWidgets);
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search widgets...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
            ),
            onChanged: (value) {
              ref.read(widgetSearchQueryProvider.notifier).state = value;
            },
          ),
        ),
        // Widget list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              if (searchQuery.isEmpty) ...[
                _buildCategoryHeader(context, 'Layout', Icons.view_week),
                _buildWidgetGrid(context, ref, layoutWidgets),
                const SizedBox(height: 16),
                _buildCategoryHeader(context, 'Basic', Icons.widgets),
                _buildWidgetGrid(context, ref, basicWidgets),
                const SizedBox(height: 16),
                _buildCategoryHeader(context, 'Complex', Icons.extension),
                _buildWidgetGrid(context, ref, complexWidgets),
              ] else ...[
                _buildWidgetGrid(context, ref, filteredWidgets),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Horizontal layout for narrow screens
  Widget _buildHorizontalLayout(BuildContext context, WidgetRef ref, List<WidgetLibraryItem> widgets) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8),
      itemCount: widgets.length,
      itemBuilder: (context, index) {
        final widget = widgets[index];
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _WidgetLibraryItemCard(
            item: widget,
            onTap: () => _addWidgetToCanvas(ref, widget),
          ),
        );
      },
    );
  }

  /// Category header
  Widget _buildCategoryHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget grid
  Widget _buildWidgetGrid(BuildContext context, WidgetRef ref, List<WidgetLibraryItem> widgets) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widgets.map((widget) {
        return _WidgetLibraryItemCard(
          item: widget,
          onTap: () => _addWidgetToCanvas(ref, widget),
        );
      }).toList(),
    );
  }

  /// Add widget to canvas
  void _addWidgetToCanvas(WidgetRef ref, WidgetLibraryItem item) {
    final widget = CanvasWidgetModel(
      type: item.type,
      position: const Offset(50, 50),
      size: Size(
        item.type == WidgetType.image ? 100 : 100,
        item.type == WidgetType.text ? 40 : 50,
      ),
    );

    ref.read(canvasProvider.notifier).addWidget(widget);

    ScaffoldMessenger.of(ref.context).showSnackBar(
      SnackBar(
        content: Text('${item.displayName} added'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

/// Widget library item card
class _WidgetLibraryItemCard extends StatelessWidget {
  final WidgetLibraryItem item;
  final VoidCallback onTap;

  const _WidgetLibraryItemCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.displayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
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
}
