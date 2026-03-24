import 'package:flutter/material.dart';
import '../core/providers/forge_provider.dart';
import '../core/models/widget_node.dart';
import '../ui/theme.dart';

Future<void> showNodeContextMenu({
  required BuildContext context,
  required ForgeProvider provider,
  required WidgetNode node,
  required Offset globalPos,
}) async {
  final overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  final pos = RelativeRect.fromRect(
    Rect.fromPoints(
        overlay.globalToLocal(globalPos),
        overlay.globalToLocal(globalPos + const Offset(200, 0))),
    Offset.zero & overlay.size,
  );

  final result = await showMenu<String>(
    context: context,
    position: pos,
    color: ForgeTheme.surface2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: ForgeTheme.border),
    ),
    items: [
      // Header
      PopupMenuItem(
        enabled: false,
        height: 32,
        child: Row(children: [
          Icon(node.type.widgetIcon,
              size: 13, color: ForgeTheme.forWidget(node.type.name)),
          const SizedBox(width: 8),
          Text(node.displayName,
              style: const TextStyle(
                  color: ForgeTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
      const PopupMenuDivider(height: 1),

      // Actions
      _item('duplicate', Icons.copy_outlined, 'Duplicate  Ctrl+D'),
      _item('front', Icons.flip_to_front_outlined, 'Bring to Front  Ctrl+]'),
      _item('back', Icons.flip_to_back_outlined, 'Send to Back  Ctrl+['),

      const PopupMenuDivider(height: 1),

      _item(
        node.visible ? 'hide' : 'show',
        node.visible
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
        node.visible ? 'Hide' : 'Show',
      ),
      _item(
        node.locked ? 'unlock' : 'lock',
        node.locked ? Icons.lock_open_outlined : Icons.lock_outline,
        node.locked ? 'Unlock' : 'Lock',
      ),

      const PopupMenuDivider(height: 1),

      _item('delete', Icons.delete_outline_rounded, 'Delete',
          color: ForgeTheme.danger),
    ],
  );

  if (result == null) return;

  switch (result) {
    case 'duplicate':
      provider.duplicateNode(node.id);
      break;
    case 'front':
      provider.bringToFront(node.id);
      break;
    case 'back':
      provider.sendToBack(node.id);
      break;
    case 'hide':
    case 'show':
      provider.toggleVisibility(node.id);
      break;
    case 'lock':
    case 'unlock':
      provider.toggleLock(node.id);
      break;
    case 'delete':
      provider.deleteNode(node.id);
      break;
  }
}

PopupMenuItem<String> _item(String val, IconData icon, String label,
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
