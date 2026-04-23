// lib/screens/widgets/panels/widget_library_panel.dart
// GAX Forge - Widget Library with Categories

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/app_models.dart';
import '../../../providers/project_provider.dart';

class WidgetLibraryPanel extends ConsumerStatefulWidget {
  final String projectId;
  const WidgetLibraryPanel({super.key, required this.projectId});

  @override
  ConsumerState<WidgetLibraryPanel> createState() =>
      _WidgetLibraryPanelState();
}

class _WidgetLibraryPanelState extends ConsumerState<WidgetLibraryPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(
        length: WidgetCatalog.categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(editorProvider(widget.projectId));
    final notifier = ref.read(editorProvider(widget.projectId).notifier);
    final scheme = Theme.of(context).colorScheme;

    final addedTypes =
        editor.activeWidgets.map((w) => w.type).toSet();

    return Column(
      children: [
        // ── Filter Toggle ─────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: SearchBar(
                  controller: _searchCtrl,
                  hintText: 'Search widgets...',
                  leading: const Icon(Icons.search_rounded, size: 20),
                  onChanged: (v) => setState(() => _search = v),
                  trailing: _search.isNotEmpty
                      ? [
                          IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _search = '');
                            },
                          )
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Used'),
                selected: !editor.showAllWidgets,
                onSelected: (_) => notifier.toggleWidgetFilter(),
                avatar: Icon(
                  editor.showAllWidgets
                      ? Icons.widgets_outlined
                      : Icons.check_rounded,
                  size: 16,
                ),
              ),
            ],
          ),
        ),

        // ── Category Tabs ─────────────────────
        if (_search.isEmpty)
          TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: WidgetCatalog.categories.map((cat) {
              return Tab(
                child: Row(
                  children: [
                    Icon(cat.icon, size: 16),
                    const SizedBox(width: 6),
                    Text(cat.name),
                  ],
                ),
              );
            }).toList(),
          ),

        // ── Widget Grid ───────────────────────
        Expanded(
          child: _search.isNotEmpty
              ? _buildSearchResults(
                  context, scheme, addedTypes, editor, notifier)
              : TabBarView(
                  controller: _tabCtrl,
                  children: WidgetCatalog.categories.map((cat) {
                    final widgets = editor.showAllWidgets
                        ? cat.widgets
                        : cat.widgets
                            .where((w) => addedTypes.contains(w))
                            .toList();
                    return _buildWidgetGrid(
                        context, widgets, addedTypes, notifier, scheme);
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    ColorScheme scheme,
    Set<String> addedTypes,
    EditorState editor,
    EditorNotifier notifier,
  ) {
    final all = WidgetCatalog.categories
        .expand((c) => c.widgets)
        .where((w) => w.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    final filtered = editor.showAllWidgets
        ? all
        : all.where((w) => addedTypes.contains(w)).toList();

    return _buildWidgetGrid(context, filtered, addedTypes, notifier, scheme);
  }

  Widget _buildWidgetGrid(
    BuildContext context,
    List<String> widgets,
    Set<String> addedTypes,
    EditorNotifier notifier,
    ColorScheme scheme,
  ) {
    if (widgets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.widgets_outlined,
                size: 48, color: scheme.outlineVariant),
            const SizedBox(height: 8),
            Text('No widgets',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      itemCount: widgets.length,
      itemBuilder: (ctx, i) {
        final type = widgets[i];
        final isAdded = addedTypes.contains(type);
        return _WidgetTile(
          type: type,
          isAdded: isAdded,
          onTap: () {
            notifier.addWidget(type);
            notifier.setTab(1); // Switch to Canvas
          },
          scheme: scheme,
        );
      },
    );
  }
}

// ── Widget Tile ─────────────────────────────────
class _WidgetTile extends StatelessWidget {
  final String type;
  final bool isAdded;
  final VoidCallback onTap;
  final ColorScheme scheme;

  const _WidgetTile({
    required this.type,
    required this.isAdded,
    required this.onTap,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isAdded
          ? scheme.primaryContainer
          : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _iconForType(type),
                size: 28,
                color: isAdded
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                _shortName(type),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isAdded
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isAdded)
                const SizedBox(height: 2),
              if (isAdded)
                Container(
                  width: 16,
                  height: 3,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _shortName(String type) {
    // CamelCase → spaced
    return type.replaceAllMapped(
        RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}').trim();
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'Container': return Icons.crop_square_rounded;
      case 'Text': return Icons.text_fields_rounded;
      case 'Icon': return Icons.star_rounded;
      case 'Image': return Icons.image_rounded;
      case 'SizedBox': return Icons.straighten_rounded;
      case 'Divider': return Icons.horizontal_rule_rounded;
      case 'Spacer': return Icons.space_bar_rounded;
      case 'ElevatedButton': return Icons.smart_button_rounded;
      case 'OutlinedButton': return Icons.radio_button_unchecked_rounded;
      case 'TextButton': return Icons.text_snippet_rounded;
      case 'IconButton': return Icons.touch_app_rounded;
      case 'FloatingActionButton': return Icons.add_circle_rounded;
      case 'FilledButton': return Icons.crop_rounded;
      case 'TextField': return Icons.edit_rounded;
      case 'SearchBar': return Icons.search_rounded;
      case 'Switch': return Icons.toggle_on_rounded;
      case 'Checkbox': return Icons.check_box_rounded;
      case 'Slider': return Icons.linear_scale_rounded;
      case 'RadioButton': return Icons.radio_button_checked_rounded;
      case 'DropdownButton': return Icons.arrow_drop_down_circle_rounded;
      case 'Card': return Icons.credit_card_rounded;
      case 'Chip': return Icons.label_rounded;
      case 'Badge': return Icons.notifications_rounded;
      case 'CircleAvatar': return Icons.account_circle_rounded;
      case 'LinearProgressIndicator': return Icons.bar_chart_rounded;
      case 'CircularProgressIndicator': return Icons.donut_large_rounded;
      case 'Tooltip': return Icons.info_rounded;
      case 'Placeholder': return Icons.crop_landscape_rounded;
      case 'Column': return Icons.view_column_rounded;
      case 'Row': return Icons.view_week_rounded;
      case 'Stack': return Icons.layers_rounded;
      case 'Wrap': return Icons.wrap_text_rounded;
      case 'GridView': return Icons.grid_view_rounded;
      case 'ListView': return Icons.list_rounded;
      case 'Expanded': return Icons.open_in_full_rounded;
      case 'Padding': return Icons.padding_rounded;
      case 'AppBar': return Icons.web_asset_rounded;
      case 'BottomNavigationBar': return Icons.navigation_rounded;
      case 'TabBar': return Icons.tab_rounded;
      case 'NavigationDrawer': return Icons.menu_rounded;
      case 'NavigationBar': return Icons.dock_rounded;
      case 'AlertDialog': return Icons.warning_rounded;
      case 'SnackBar': return Icons.announcement_rounded;
      case 'BottomSheet': return Icons.upload_rounded;
      case 'PopupMenu': return Icons.more_vert_rounded;
      case 'Dialog': return Icons.open_in_new_rounded;
      case 'ListTile': return Icons.format_list_bulleted_rounded;
      case 'SingleChildScrollView': return Icons.swap_vert_rounded;
      case 'CustomScrollView': return Icons.view_day_rounded;
      case 'PageView': return Icons.auto_stories_rounded;
      case 'TabBarView': return Icons.table_rows_rounded;
      default: return Icons.widgets_rounded;
    }
  }
}
