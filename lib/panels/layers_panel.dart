import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/forge_provider.dart';
import '../core/models/widget_node.dart';
import '../ui/theme.dart';

class LayersPanel extends StatelessWidget {
  const LayersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgeProvider>(
      builder: (context, provider, _) {
        final nodes = provider.screen.sortedNodes.reversed.toList();

        return Container(
          color: ForgeTheme.surface1,
          child: Column(
            children: [
              PanelHeader(
                title: 'Layers',
                icon: Icons.layers_outlined,
                iconColor: ForgeTheme.secondary,
                actions: [
                  PanelIconBtn(
                    icon: Icons.grid_on_outlined,
                    onTap: provider.toggleGrid,
                    tooltip: 'Toggle grid',
                    active: provider.showGrid,
                  ),
                  PanelIconBtn(
                    icon: Icons.grid_4x4,
                    onTap: provider.toggleSnap,
                    tooltip: 'Snap to grid',
                    active: provider.snapToGrid,
                  ),
                ],
              ),
              Expanded(
                child: nodes.isEmpty
                    ? _EmptyLayers()
                    : ReorderableListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: nodes.length,
                        onReorder: (old, nw) {
                          // Reversed index convert
                          final total = nodes.length;
                          provider.reorderLayer(total - 1 - old, total - 1 - nw);
                        },
                        itemBuilder: (context, index) {
                          final node = nodes[index];
                          return _LayerItem(
                            key: ValueKey(node.id),
                            node: node,
                            isSelected: provider.selectedId == node.id,
                            onTap: () => provider.select(node.id),
                            onVisibility: () => provider.toggleVisible(node.id),
                            onLock: () => provider.toggleLock(node.id),
                            onDelete: () => provider.deleteNode(node.id),
                            onDuplicate: () => provider.duplicate(node.id),
                            onBringFront: () => provider.bringToFront(node.id),
                            onSendBack: () => provider.sendToBack(node.id),
                            onRename: (name) => provider.renameNode(node.id, name),
                          );
                        },
                      ),
              ),
              // Screen bg color
              _ScreenBgRow(provider: provider),
            ],
          ),
        );
      },
    );
  }
}

class _LayerItem extends StatefulWidget {
  final WidgetNode node;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onVisibility;
  final VoidCallback onLock;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onBringFront;
  final VoidCallback onSendBack;
  final ValueChanged<String> onRename;

  const _LayerItem({
    required super.key,
    required this.node,
    required this.isSelected,
    required this.onTap,
    required this.onVisibility,
    required this.onLock,
    required this.onDelete,
    required this.onDuplicate,
    required this.onBringFront,
    required this.onSendBack,
    required this.onRename,
  });

  @override
  State<_LayerItem> createState() => _LayerItemState();
}

class _LayerItemState extends State<_LayerItem> {
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
        onLongPress: () => _showContextMenu(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 36,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? ForgeTheme.selectionBg
                : (_hovering ? ForgeTheme.surface3 : Colors.transparent),
            border: widget.isSelected
                ? const Border(
                    left: BorderSide(color: ForgeTheme.selection, width: 2))
                : const Border(left: BorderSide(color: Colors.transparent, width: 2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              // Drag handle
              const Icon(Icons.drag_indicator,
                  size: 14, color: ForgeTheme.textMuted),
              const SizedBox(width: 4),

              // Widget icon
              Icon(n.type.widgetIcon, size: 14, color: color),
              const SizedBox(width: 8),

              // Name
              Expanded(
                child: Text(
                  n.displayName,
                  style: TextStyle(
                    color: n.visible
                        ? ForgeTheme.textPrimary
                        : ForgeTheme.textMuted,
                    fontSize: 12,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600 : FontWeight.normal,
                    decoration: !n.visible
                        ? TextDecoration.lineThrough : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Actions (always show on selected, hover on others)
              if (_hovering || widget.isSelected) ...[
                _LayerBtn(
                  icon: n.visible ? Icons.visibility : Icons.visibility_off,
                  onTap: widget.onVisibility,
                  color: n.visible ? ForgeTheme.textSecondary : ForgeTheme.textMuted,
                ),
                _LayerBtn(
                  icon: n.locked ? Icons.lock : Icons.lock_open,
                  onTap: widget.onLock,
                  color: n.locked ? ForgeTheme.warning : ForgeTheme.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    showMenu(
      context: context,
      color: ForgeTheme.surface2,
      position: RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx + 200, pos.dy + 40),
      items: <PopupMenuEntry<String>>[
        _menuItem('rename', Icons.edit, 'Rename'),
        _menuItem('duplicate', Icons.copy, 'Duplicate'),
        _menuItem('front', Icons.flip_to_front, 'Bring to Front'),
        _menuItem('back', Icons.flip_to_back, 'Send to Back'),
        const PopupMenuDivider(),
        _menuItem('delete', Icons.delete_outline, 'Delete',
            color: ForgeTheme.danger),
      ],
    ).then((val) {
      if (!mounted) return;
      switch (val) {
        case 'rename': _showRenameDialog(context); break;
        case 'duplicate': widget.onDuplicate(); break;
        case 'front': widget.onBringFront(); break;
        case 'back': widget.onSendBack(); break;
        case 'delete': widget.onDelete(); break;
      }
    });
  }

  PopupMenuItem<String> _menuItem(String val, IconData icon, String label,
      {Color? color}) {
    return PopupMenuItem(
      value: val,
      height: 36,
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? ForgeTheme.textSecondary),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color: color ?? ForgeTheme.textPrimary, fontSize: 12)),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final ctrl = TextEditingController(text: widget.node.name ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ForgeTheme.surface2,
        title: const Text('Rename Layer',
            style: TextStyle(color: ForgeTheme.textPrimary, fontSize: 14)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: ForgeTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Layer name...',
            hintStyle: TextStyle(color: ForgeTheme.textMuted),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ForgeTheme.border)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ForgeTheme.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: ForgeTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              widget.onRename(ctrl.text);
              Navigator.pop(context);
            },
            child: const Text('Save',
                style: TextStyle(color: ForgeTheme.primary)),
          ),
        ],
      ),
    );
  }
}

class _LayerBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  const _LayerBtn({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Icon(icon, size: 13, color: color),
      ),
    );
  }
}

class _EmptyLayers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.layers, size: 32, color: ForgeTheme.textMuted),
          SizedBox(height: 8),
          Text('No layers yet',
              style: TextStyle(color: ForgeTheme.textMuted, fontSize: 12)),
          SizedBox(height: 4),
          Text('Add from Palette →',
              style: TextStyle(
                  color: ForgeTheme.secondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ScreenBgRow extends StatelessWidget {
  final ForgeProvider provider;
  const _ScreenBgRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final bg = parseColor(provider.screen.backgroundColor,
        fallback: Colors.white);
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: ForgeTheme.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone_android, size: 13,
              color: ForgeTheme.textMuted),
          const SizedBox(width: 8),
          const Text('Background', style: TextStyle(
              color: ForgeTheme.textSecondary, fontSize: 11)),
          const Spacer(),
          GestureDetector(
            onTap: () => _pickColor(context),
            child: Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: ForgeTheme.border),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(provider.screen.backgroundColor,
              style: const TextStyle(
                  color: ForgeTheme.textMuted, fontSize: 10,
                  fontFamily: 'monospace')),
        ],
      ),
    );
  }

  void _pickColor(BuildContext context) {
    // Simple color input dialog
    final ctrl = TextEditingController(
        text: provider.screen.backgroundColor);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ForgeTheme.surface2,
        title: const Text('Background Color',
            style: TextStyle(color: ForgeTheme.textPrimary, fontSize: 14)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              style: const TextStyle(color: ForgeTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: '#FFFFFF',
                hintStyle: TextStyle(color: ForgeTheme.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: [
                '#FFFFFF', '#F5F5F5', '#E3E8FF', '#FFF3F3',
                '#F0FFF0', '#0E0E14', '#1A1A2E', '#0D0D1A',
              ].map((hex) => GestureDetector(
                onTap: () { ctrl.text = hex; },
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: parseColor(hex),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: ForgeTheme.border),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.updateScreenBg(ctrl.text);
              Navigator.pop(context);
            },
            child: const Text('Apply',
                style: TextStyle(color: ForgeTheme.primary)),
          ),
        ],
      ),
    );
  }
}
