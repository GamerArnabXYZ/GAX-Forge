// lib/screens/widgets/panels/widget_library_panel.dart
// GAX Forge - Widget Library (100+ widgets, 9 categories)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/app_models.dart';
import '../../../providers/project_provider.dart';

class WidgetLibraryPanel extends ConsumerStatefulWidget {
  final String projectId;
  const WidgetLibraryPanel({super.key, required this.projectId});
  @override
  ConsumerState<WidgetLibraryPanel> createState() => _WidgetLibraryPanelState();
}

class _WidgetLibraryPanelState extends ConsumerState<WidgetLibraryPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _search = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: WidgetCatalog.categories.length, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final editor = ref.watch(editorProvider(widget.projectId));
    final notifier = ref.read(editorProvider(widget.projectId).notifier);
    final scheme = Theme.of(context).colorScheme;
    final addedTypes = editor.activeWidgets.map((w) => w.type).toSet();
    final total = WidgetCatalog.totalCount();

    return Column(children: [
      // ── Search + stats ─────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
        child: Column(children: [
          Row(children: [
            Expanded(child: SearchBar(
              controller: _searchCtrl,
              hintText: 'Search $total+ widgets...',
              leading: const Icon(Icons.search_rounded, size: 18),
              elevation: const WidgetStatePropertyAll(0.5),
              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
              onChanged: (v) => setState(() => _search = v),
              trailing: _search.isNotEmpty ? [IconButton(
                icon: const Icon(Icons.clear_rounded, size: 16),
                onPressed: () { _searchCtrl.clear(); setState(() => _search = ''); },
              )] : null,
            )),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Chip(
              label: Text('${addedTypes.length} on canvas',
                style: TextStyle(fontSize: 11, color: scheme.onPrimaryContainer)),
              backgroundColor: scheme.primaryContainer,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 6),
            FilterChip(
              label: const Text('Used only', style: TextStyle(fontSize: 11)),
              selected: !editor.showAllWidgets,
              onSelected: (_) => notifier.toggleWidgetFilter(),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ]),
        ]),
      ),
      // ── Category Tabs ─────────────────────
      if (_search.isEmpty)
        TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: WidgetCatalog.categories.map((cat) => Tab(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(cat.icon, size: 14),
              const SizedBox(width: 5),
              Text(cat.name, style: const TextStyle(fontSize: 12)),
            ]),
          )).toList(),
        ),
      // ── Grid ──────────────────────────────
      Expanded(
        child: _search.isNotEmpty
          ? _buildSearch(context, addedTypes, editor, notifier, scheme)
          : TabBarView(
              controller: _tabCtrl,
              children: WidgetCatalog.categories.map((cat) {
                final widgets = editor.showAllWidgets
                  ? cat.widgets
                  : cat.widgets.where((w) => addedTypes.contains(w)).toList();
                return _buildGrid(context, widgets, addedTypes, notifier, scheme);
              }).toList(),
            ),
      ),
    ]);
  }

  Widget _buildSearch(BuildContext ctx, Set<String> added, EditorState editor,
      EditorNotifier notifier, ColorScheme scheme) {
    final all = WidgetCatalog.categories.expand((c) => c.widgets)
        .where((w) => w.toLowerCase().contains(_search.toLowerCase())).toList();
    final filtered = editor.showAllWidgets ? all : all.where((w) => added.contains(w)).toList();
    return _buildGrid(ctx, filtered, added, notifier, scheme);
  }

  Widget _buildGrid(BuildContext ctx, List<String> widgets, Set<String> added,
      EditorNotifier notifier, ColorScheme scheme) {
    if (widgets.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.search_off_rounded, size: 40, color: scheme.outlineVariant),
      const SizedBox(height: 8),
      Text('No widgets found', style: TextStyle(color: scheme.onSurfaceVariant)),
    ]));

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.05),
      itemCount: widgets.length,
      itemBuilder: (ctx, i) {
        final type = widgets[i];
        return _WidgetTile(
          type: type,
          isAdded: added.contains(type),
          scheme: scheme,
          onTap: () { notifier.addWidget(type); notifier.setTab(1); },
          onLongPress: () => _showWidgetInfo(ctx, type, scheme),
        );
      },
    );
  }

  void _showWidgetInfo(BuildContext ctx, String type, ColorScheme scheme) {
    final defaults = WidgetProperty.defaultProps(type);
    showModalBottomSheet(context: ctx, builder: (c) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(_iconForType(type), color: scheme.primary),
          const SizedBox(width: 10),
          Text(type, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Spacer(),
          FilledButton.icon(
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add'),
            onPressed: () {
              Navigator.pop(c);
              ref.read(editorProvider(widget.projectId).notifier).addWidget(type);
              ref.read(editorProvider(widget.projectId).notifier).setTab(1);
            },
          ),
        ]),
        const SizedBox(height: 10),
        Text('${defaults.length} properties available', style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(spacing: 6, runSpacing: 4, children: defaults.keys.take(12)
            .map((k) => Chip(label: Text(k, style: const TextStyle(fontSize: 10)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero, visualDensity: VisualDensity.compact))
            .toList()),
        const SizedBox(height: 8),
      ]),
    ));
  }
}

class _WidgetTile extends StatelessWidget {
  final String type;
  final bool isAdded;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ColorScheme scheme;
  const _WidgetTile({required this.type, required this.isAdded, required this.onTap,
    required this.onLongPress, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isAdded ? scheme.primaryContainer : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap, onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(_iconForType(type), size: 26,
              color: isAdded ? scheme.onPrimaryContainer : scheme.onSurfaceVariant),
            const SizedBox(height: 5),
            Text(_shortName(type), textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w500,
                color: isAdded ? scheme.onPrimaryContainer : scheme.onSurfaceVariant),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            if (isAdded) ...[
              const SizedBox(height: 3),
              Container(width: 14, height: 2.5,
                decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(2))),
            ],
          ]),
        ),
      ),
    );
  }

  String _shortName(String type) =>
      type.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}').trim();
}

IconData _iconForType(String type) {
  const map = <String, IconData>{
    'Container': Icons.crop_square_rounded, 'Text': Icons.text_fields_rounded,
    'Icon': Icons.star_rounded, 'Image': Icons.image_rounded,
    'SizedBox': Icons.straighten_rounded, 'Divider': Icons.horizontal_rule_rounded,
    'Spacer': Icons.space_bar_rounded, 'Placeholder': Icons.crop_landscape_rounded,
    'ElevatedButton': Icons.smart_button_rounded, 'OutlinedButton': Icons.radio_button_unchecked_rounded,
    'TextButton': Icons.text_snippet_rounded, 'IconButton': Icons.touch_app_rounded,
    'FloatingActionButton': Icons.add_circle_rounded, 'FilledButton': Icons.crop_rounded,
    'FilledTonalButton': Icons.tonality_rounded, 'SegmentedButton': Icons.view_week_rounded,
    'TextField': Icons.edit_rounded, 'SearchBar': Icons.search_rounded,
    'Switch': Icons.toggle_on_rounded, 'Checkbox': Icons.check_box_rounded,
    'Slider': Icons.linear_scale_rounded, 'RangeSlider': Icons.tune_rounded,
    'RadioButton': Icons.radio_button_checked_rounded, 'DropdownButton': Icons.arrow_drop_down_circle_rounded,
    'DatePicker': Icons.calendar_today_rounded, 'TimePicker': Icons.access_time_rounded,
    'Card': Icons.credit_card_rounded, 'Chip': Icons.label_rounded,
    'Badge': Icons.notifications_rounded, 'CircleAvatar': Icons.account_circle_rounded,
    'LinearProgressIndicator': Icons.bar_chart_rounded, 'CircularProgressIndicator': Icons.donut_large_rounded,
    'Tooltip': Icons.info_rounded, 'ExpansionTile': Icons.expand_more_rounded,
    'DataTable': Icons.table_chart_rounded, 'StepperWidget': Icons.checklist_rounded,
    'AppBar': Icons.web_asset_rounded, 'BottomNavigationBar': Icons.navigation_rounded,
    'NavigationBar': Icons.dock_rounded, 'TabBar': Icons.tab_rounded,
    'NavigationDrawer': Icons.menu_rounded, 'Breadcrumb': Icons.more_horiz_rounded,
    'AlertDialog': Icons.warning_rounded, 'SnackBar': Icons.announcement_rounded,
    'BottomSheet': Icons.upload_rounded, 'PopupMenu': Icons.more_vert_rounded,
    'Dialog': Icons.open_in_new_rounded, 'BannerWidget': Icons.campaign_rounded,
    'ListTile': Icons.format_list_bulleted_rounded, 'Column': Icons.view_column_rounded,
    'Row': Icons.view_week_rounded, 'Stack': Icons.layers_rounded,
    'Wrap': Icons.wrap_text_rounded, 'GridView': Icons.grid_view_rounded,
    'ListView': Icons.list_rounded, 'Expanded': Icons.open_in_full_rounded,
    'Padding': Icons.padding_rounded, 'Center': Icons.center_focus_strong_rounded,
    'Align': Icons.align_horizontal_center_rounded, 'FractionallySizedBox': Icons.photo_size_select_small_rounded,
    'AspectRatio': Icons.aspect_ratio_rounded, 'ConstrainedBox': Icons.border_style_rounded,
    'IntrinsicWidth': Icons.swap_horiz_rounded, 'IntrinsicHeight': Icons.swap_vert_rounded,
    'SingleChildScrollView': Icons.swipe_rounded, 'CustomScrollView': Icons.view_day_rounded,
    'PageView': Icons.auto_stories_rounded, 'TabBarView': Icons.table_rows_rounded,
    'AnimatedContainer': Icons.animation_rounded, 'AnimatedOpacity': Icons.opacity_rounded,
    'CustomWidget': Icons.auto_awesome_rounded,
  };
  return map[type] ?? Icons.widgets_rounded;
}
