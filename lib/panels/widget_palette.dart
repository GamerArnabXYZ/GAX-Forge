import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/widget_node.dart';
import '../canvas/drag_chip.dart';
import '../ui/theme.dart';

class WidgetPalette extends StatefulWidget {
  const WidgetPalette({super.key});

  @override
  State<WidgetPalette> createState() => _WidgetPaletteState();
}

class _WidgetPaletteState extends State<WidgetPalette> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  static const _categories = ['All', 'Layout', 'Basic', 'Input', 'Material'];

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
          PanelHeader(
            title: 'Widgets',
            icon: Icons.widgets_outlined,
            iconColor: ForgeTheme.primary,
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(
                  color: ForgeTheme.textPrimary, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Search widgets...',
                hintStyle: const TextStyle(
                    color: ForgeTheme.textMuted, fontSize: 12),
                prefixIcon: const Icon(Icons.search,
                    size: 16, color: ForgeTheme.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () =>
                            setState(() => _searchQuery = ''),
                        child: const Icon(Icons.close,
                            size: 14, color: ForgeTheme.textMuted))
                    : null,
                isDense: true,
                filled: true,
                fillColor: ForgeTheme.surface3,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Category chips
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final active = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(
                        right: 6, top: 4, bottom: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10),
                    decoration: BoxDecoration(
                      color: active
                          ? ForgeTheme.primary
                          : ForgeTheme.surface3,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(cat,
                        style: TextStyle(
                          color: active
                              ? Colors.white
                              : ForgeTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.normal,
                        )),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 4),

          // Drag hint
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.drag_indicator,
                    size: 12, color: ForgeTheme.textMuted),
                const SizedBox(width: 4),
                const Text('Tap to add  ·  Long-press & drag to canvas',
                    style: TextStyle(
                        color: ForgeTheme.textMuted, fontSize: 9)),
              ],
            ),
          ),

          const Divider(height: 1, color: ForgeTheme.border),

          // Widget grid
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text('No widgets found',
                        style: TextStyle(
                            color: ForgeTheme.textMuted,
                            fontSize: 12)))
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 2.4,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) =>
                        DraggableWidgetChip(
                            type: _filtered[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
