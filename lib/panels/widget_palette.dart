import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/widget_node.dart';
import '../core/providers/forge_provider.dart';
import '../canvas/drag_chip.dart';
import '../ui/theme.dart';

class WidgetPalette extends StatefulWidget {
  const WidgetPalette({super.key});
  @override
  State<WidgetPalette> createState() => _WidgetPaletteState();
}

class _WidgetPaletteState extends State<WidgetPalette>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  static const _categories = ['All', 'Layout', 'Basic', 'Input', 'Material'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<WType> get _filtered => WType.values.where((t) {
        final matchSearch = _searchQuery.isEmpty ||
            t.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchCat =
            _selectedCategory == 'All' || t.category == _selectedCategory;
        return matchSearch && matchCat;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ForgeTheme.surface1,
      child: Column(
        children: [
          // Tab bar: Widgets | Added
          Container(
            color: ForgeTheme.surface1,
            child: TabBar(
              controller: _tab,
              indicatorColor: ForgeTheme.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: ForgeTheme.primary,
              unselectedLabelColor: ForgeTheme.textMuted,
              labelStyle: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              dividerColor: ForgeTheme.border,
              tabs: [
                const Tab(text: 'Widgets'),
                Tab(
                  child: Consumer<ForgeProvider>(
                    builder: (_, provider, __) {
                      final count = provider.currentScreen.nodes.length;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Added'),
                          if (count > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: ForgeTheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text('$count',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                // ── Tab 1: Widget Library ────────────────────
                _WidgetLibraryTab(
                  searchQuery: _searchQuery,
                  selectedCategory: _selectedCategory,
                  filtered: _filtered,
                  categories: _categories,
                  onSearchChanged: (v) =>
                      setState(() => _searchQuery = v),
                  onCategoryChanged: (c) =>
                      setState(() => _selectedCategory = c),
                ),
                // ── Tab 2: Added Widgets ─────────────────────
                const _AddedWidgetsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget Library Tab ────────────────────────────────────────
class _WidgetLibraryTab extends StatelessWidget {
  final String searchQuery;
  final String selectedCategory;
  final List<WType> filtered;
  final List<String> categories;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategoryChanged;

  const _WidgetLibraryTab({
    required this.searchQuery,
    required this.selectedCategory,
    required this.filtered,
    required this.categories,
    required this.onSearchChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: TextField(
            onChanged: onSearchChanged,
            style: const TextStyle(
                color: ForgeTheme.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search widgets...',
              hintStyle:
                  const TextStyle(color: ForgeTheme.textMuted, fontSize: 13),
              prefixIcon: const Icon(Icons.search,
                  size: 18, color: ForgeTheme.textMuted),
              suffixIcon: searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () => onSearchChanged(''),
                      child: const Icon(Icons.close,
                          size: 16, color: ForgeTheme.textMuted))
                  : null,
              isDense: true,
              filled: true,
              fillColor: ForgeTheme.surface2,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
            ),
          ),
        ),

        // Category chips
        SizedBox(
          height: 34,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final cat = categories[i];
              final active = selectedCategory == cat;
              return GestureDetector(
                onTap: () => onCategoryChanged(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin:
                      const EdgeInsets.only(right: 6, top: 4, bottom: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: active
                        ? ForgeTheme.primary : ForgeTheme.surface3,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(cat,
                      style: TextStyle(
                        color: active
                            ? Colors.white : ForgeTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: active
                            ? FontWeight.w700 : FontWeight.normal,
                      )),
                ),
              );
            },
          ),
        ),

        const Divider(height: 1, color: ForgeTheme.border),

        // Widget grid
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text('No widgets found',
                      style: TextStyle(
                          color: ForgeTheme.textMuted, fontSize: 12)))
              : GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      DraggableWidgetChip(type: filtered[index]),
                ),
        ),
      ],
    );
  }
}

// ── Added Widgets Tab ─────────────────────────────────────────
class _AddedWidgetsTab extends StatelessWidget {
  const _AddedWidgetsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgeProvider>(
      builder: (context, provider, _) {
        final nodes = provider.currentScreen.sortedNodes.reversed.toList();

        if (nodes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.widgets_outlined,
                    size: 48, color: ForgeTheme.textMuted),
                SizedBox(height: 12),
                Text('No widgets added yet',
                    style: TextStyle(
                        color: ForgeTheme.textSecondary, fontSize: 13)),
                SizedBox(height: 4),
                Text('Add from Widgets tab',
                    style: TextStyle(
                        color: ForgeTheme.textMuted, fontSize: 11)),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Header with clear all
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: ForgeTheme.border))),
              child: Row(
                children: [
                  Text('${nodes.length} widget${nodes.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: ForgeTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  const Spacer(),
                  // Clear all
                  GestureDetector(
                    onTap: () => _confirmClearAll(context, provider),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: ForgeTheme.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: ForgeTheme.danger.withOpacity(0.3)),
                      ),
                      child: const Text('Clear All',
                          style: TextStyle(
                              color: ForgeTheme.danger,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),

            // Widget list
            Expanded(
              child: ReorderableListView.builder(
                padding: EdgeInsets.zero,
                itemCount: nodes.length,
                onReorder: (oldIdx, newIdx) {
                  final total = nodes.length;
                  provider.reorderLayer(
                      total - 1 - oldIdx, total - 1 - newIdx);
                },
                itemBuilder: (context, idx) {
                  final node = nodes[idx];
                  return _AddedWidgetItem(
                    key: ValueKey(node.id),
                    node: node,
                    isSelected: provider.selectedNodeId == node.id,
                    onTap: () {
                      provider.selectNode(node.id);
                      // Switch to canvas on mobile
                      if (MediaQuery.of(context).size.width < 700) {
                        provider.setSidePanel(0);
                      }
                    },
                    onDelete: () => provider.deleteNode(node.id),
                    onDuplicate: () => provider.duplicateNode(node.id),
                    onToggleVisible: () =>
                        provider.toggleVisibility(node.id),
                    onToggleLock: () => provider.toggleLock(node.id),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmClearAll(BuildContext context, ForgeProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Widgets?'),
        content: const Text('Saare widgets delete ho jayenge.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete all nodes
              final ids = provider.currentScreen.nodes
                  .map((n) => n.id)
                  .toList();
              for (final id in ids) provider.deleteNode(id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: ForgeTheme.danger),
            child: const Text('Clear',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Single added widget row ───────────────────────────────────
class _AddedWidgetItem extends StatefulWidget {
  final WidgetNode node;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onToggleVisible;
  final VoidCallback onToggleLock;

  const _AddedWidgetItem({
    required super.key,
    required this.node,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onDuplicate,
    required this.onToggleVisible,
    required this.onToggleLock,
  });

  @override
  State<_AddedWidgetItem> createState() => _AddedWidgetItemState();
}

class _AddedWidgetItemState extends State<_AddedWidgetItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final n = widget.node;
    final color = ForgeTheme.forWidget(n.type.name);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 48,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? ForgeTheme.selectionBg
                : (_hovering
                    ? ForgeTheme.surface2
                    : Colors.transparent),
            border: Border(
              left: BorderSide(
                color: widget.isSelected
                    ? ForgeTheme.selection : Colors.transparent,
                width: 3,
              ),
              bottom: const BorderSide(color: ForgeTheme.border),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              // Drag handle
              const Icon(Icons.drag_indicator,
                  size: 16, color: ForgeTheme.textMuted),
              const SizedBox(width: 8),

              // Widget icon + color dot
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(n.type.widgetIcon, size: 15, color: color),
              ),
              const SizedBox(width: 10),

              // Name + type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      n.displayName,
                      style: TextStyle(
                        color: n.visible
                            ? ForgeTheme.textPrimary
                            : ForgeTheme.textMuted,
                        fontSize: 12,
                        fontWeight: widget.isSelected
                            ? FontWeight.w700 : FontWeight.w500,
                        decoration: !n.visible
                            ? TextDecoration.lineThrough : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${n.type.name}  ${n.width.round()}×${n.height.round()}',
                      style: const TextStyle(
                          color: ForgeTheme.textMuted, fontSize: 9),
                    ),
                  ],
                ),
              ),

              // Action buttons (show on hover/select)
              if (_hovering || widget.isSelected) ...[
                _ActionBtn(
                  icon: n.visible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: n.visible
                      ? ForgeTheme.textSecondary : ForgeTheme.textMuted,
                  onTap: widget.onToggleVisible,
                  tooltip: n.visible ? 'Hide' : 'Show',
                ),
                _ActionBtn(
                  icon: n.locked
                      ? Icons.lock_outline : Icons.lock_open_outlined,
                  color: n.locked
                      ? ForgeTheme.warning : ForgeTheme.textSecondary,
                  onTap: widget.onToggleLock,
                  tooltip: n.locked ? 'Unlock' : 'Lock',
                ),
                _ActionBtn(
                  icon: Icons.copy_outlined,
                  color: ForgeTheme.textSecondary,
                  onTap: widget.onDuplicate,
                  tooltip: 'Duplicate',
                ),
                _ActionBtn(
                  icon: Icons.delete_outline,
                  color: ForgeTheme.danger,
                  onTap: widget.onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
