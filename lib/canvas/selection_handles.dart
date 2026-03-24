import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/forge_provider.dart';
import '../core/models/widget_node.dart';
import '../ui/theme.dart';

// Selection overlay — selected widget ke around border + resize handles
class ForgeSelectionOverlay extends StatelessWidget {
  final WidgetNode node;
  final double scale;

  const ForgeSelectionOverlay({
    super.key,
    required this.node,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ForgeProvider>();
    const hSize = 10.0; // handle size in screen pixels
    final hSizeScaled = hSize / scale;

    return Positioned(
      left: node.x - hSizeScaled / 2,
      top: node.y - hSizeScaled / 2,
      width: node.width + hSizeScaled,
      height: node.height + hSizeScaled,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Selection border
          Positioned.fill(
            left: hSizeScaled / 2,
            top: hSizeScaled / 2,
            right: hSizeScaled / 2,
            bottom: hSizeScaled / 2,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: ForgeTheme.selection,
                  width: 1.5 / scale,
                ),
              ),
            ),
          ),

          // 8 resize handles
          _Handle(handle: 'nw', hSize: hSizeScaled, node: node, provider: provider, scale: scale),
          _Handle(handle: 'n',  hSize: hSizeScaled, node: node, provider: provider, scale: scale),
          _Handle(handle: 'ne', hSize: hSizeScaled, node: node, provider: provider, scale: scale),
          _Handle(handle: 'e',  hSize: hSizeScaled, node: node, provider: provider, scale: scale),
          _Handle(handle: 'se', hSize: hSizeScaled, node: node, provider: provider, scale: scale),
          _Handle(handle: 's',  hSize: hSizeScaled, node: node, provider: provider, scale: scale),
          _Handle(handle: 'sw', hSize: hSizeScaled, node: node, provider: provider, scale: scale),
          _Handle(handle: 'w',  hSize: hSizeScaled, node: node, provider: provider, scale: scale),

          // Dimension label (top)
          Positioned(
            top: 0,
            left: hSizeScaled / 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: ForgeTheme.selection,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                '${node.width.round()} × ${node.height.round()}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9 / scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  final String handle;
  final double hSize;
  final WidgetNode node;
  final ForgeProvider provider;
  final double scale;

  const _Handle({
    required this.handle,
    required this.hSize,
    required this.node,
    required this.provider,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final pos = _position(handle, hSize, node.width, node.height);
    final cursor = _cursor(handle);

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      width: hSize,
      height: hSize,
      child: GestureDetector(
        onPanStart: (d) => provider.onResizeStart(
            node.id, handle, d.globalPosition),
        onPanUpdate: (d) => provider.onResizeUpdate(d.globalPosition),
        onPanEnd: (_) => provider.onResizeEnd(),
        child: MouseRegion(
          cursor: cursor,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: ForgeTheme.selection, width: 1.5),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: ForgeTheme.selection.withOpacity(0.4),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Position of each handle relative to the overlay container
  Offset _position(String h, double hs, double w, double nH) {
    final half = hs / 2;
    switch (h) {
      case 'nw': return Offset(0,           0);
      case 'n':  return Offset(w / 2,       0);
      case 'ne': return Offset(w + half,    0);
      case 'e':  return Offset(w + half,    nH / 2);
      case 'se': return Offset(w + half,    nH + half);
      case 's':  return Offset(w / 2,       nH + half);
      case 'sw': return Offset(0,           nH + half);
      case 'w':  return Offset(0,           nH / 2);
      default:   return Offset.zero;
    }
  }

  MouseCursor _cursor(String h) {
    switch (h) {
      case 'nw': case 'se': return SystemMouseCursors.resizeUpLeftDownRight;
      case 'ne': case 'sw': return SystemMouseCursors.resizeUpRightDownLeft;
      case 'n':  case 's':  return SystemMouseCursors.resizeUpDown;
      case 'e':  case 'w':  return SystemMouseCursors.resizeLeftRight;
      default: return SystemMouseCursors.basic;
    }
  }
}
