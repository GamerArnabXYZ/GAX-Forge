import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/forge_provider.dart';
import '../core/models/widget_node.dart';
import '../ui/theme.dart';

// Draggable chip — palette se canvas pe drag karne ke liye
class DraggableWidgetChip extends StatefulWidget {
  final WType type;
  const DraggableWidgetChip({super.key, required this.type});

  @override
  State<DraggableWidgetChip> createState() => _DraggableWidgetChipState();
}

class _DraggableWidgetChipState extends State<DraggableWidgetChip> {
  bool _pressing = false;

  @override
  Widget build(BuildContext context) {
    final color = ForgeTheme.forWidget(widget.type.name);

    return LongPressDraggable<WType>(
      data: widget.type,
      delay: const Duration(milliseconds: 200),
      feedback: Material(
        color: Colors.transparent,
        child: _DragFeedback(type: widget.type, color: color),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _ChipBody(
            type: widget.type, color: color, pressing: false),
      ),
      onDragStarted: () => setState(() => _pressing = true),
      onDragEnd: (_) => setState(() => _pressing = false),
      onDraggableCanceled: (_, __) => setState(() => _pressing = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressing = true),
        onTapUp: (_) => setState(() => _pressing = false),
        onTapCancel: () => setState(() => _pressing = false),
        onTap: () {
          final provider = context.read<ForgeProvider>();
          final screen = provider.screen;
          provider.addNode(
            widget.type,
            x: screen.canvasWidth / 2 - 60,
            y: screen.canvasHeight / 4,
          );
          if (MediaQuery.of(context).size.width <= 900) {
            provider.setSidePanel(0);
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${widget.type.name} added ✓'),
            duration: const Duration(milliseconds: 1000),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ));
        },
        child: _ChipBody(
            type: widget.type, color: color, pressing: _pressing),
      ),
    );
  }
}

class _ChipBody extends StatelessWidget {
  final WType type;
  final Color color;
  final bool pressing;
  const _ChipBody(
      {required this.type, required this.color, required this.pressing});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      transform:
          pressing ? (Matrix4.identity()..scale(0.95)) : Matrix4.identity(),
      decoration: BoxDecoration(
        color: color.withOpacity(pressing ? 0.22 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(pressing ? 0.8 : 0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(type.widgetIcon, color: color, size: 14),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.name,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis),
                Text(type.category,
                    style: const TextStyle(
                        color: ForgeTheme.textMuted, fontSize: 9)),
              ],
            ),
          ),
          Icon(Icons.drag_indicator,
              size: 12, color: color.withOpacity(0.4)),
        ],
      ),
    );
  }
}

class _DragFeedback extends StatelessWidget {
  final WType type;
  final Color color;
  const _DragFeedback({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 16,
              spreadRadius: 2)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(type.widgetIcon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(type.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
