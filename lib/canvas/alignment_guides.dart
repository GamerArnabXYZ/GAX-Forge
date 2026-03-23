import 'package:flutter/material.dart';
import '../core/models/widget_node.dart';
import '../ui/theme.dart';

// Snap threshold in logical pixels (canvas space)
const double kSnapThreshold = 6.0;
const double kSnapStrength = kSnapThreshold;

// Alignment guide result
class SnapResult {
  final double x;
  final double y;
  final List<Guide> guides;
  const SnapResult(this.x, this.y, this.guides);
}

class Guide {
  final bool isVertical; // true = vertical line (x fixed), false = horizontal
  final double position; // x or y in canvas coords
  const Guide(this.isVertical, this.position);
}

/// Computes snapped position and guides for a dragged node
SnapResult computeSnap({
  required WidgetNode dragging,
  required List<WidgetNode> others,
  required double proposedX,
  required double proposedY,
}) {
  double snapX = proposedX;
  double snapY = proposedY;
  final guides = <Guide>[];

  final dW = dragging.width;
  final dH = dragging.height;

  // Candidate edges of the dragged node
  final dLeft = proposedX;
  final dRight = proposedX + dW;
  final dCenterX = proposedX + dW / 2;
  final dTop = proposedY;
  final dBottom = proposedY + dH;
  final dCenterY = proposedY + dH / 2;

  double bestDx = kSnapThreshold + 1;
  double bestDy = kSnapThreshold + 1;

  for (final other in others) {
    if (other.id == dragging.id || !other.visible) continue;

    // Other node's edges
    final oLeft = other.x;
    final oRight = other.x + other.width;
    final oCenterX = other.x + other.width / 2;
    final oTop = other.y;
    final oBottom = other.y + other.height;
    final oCenterY = other.y + other.height / 2;

    // ── Horizontal snaps (affect X) ──────────────────────
    final xPairs = [
      [dLeft, oLeft],
      [dLeft, oRight],
      [dRight, oLeft],
      [dRight, oRight],
      [dCenterX, oCenterX],
    ];
    for (final pair in xPairs) {
      final diff = (pair[0] - pair[1]).abs();
      if (diff < kSnapThreshold && diff < bestDx) {
        bestDx = diff;
        snapX = proposedX - (pair[0] - pair[1]);
        guides.removeWhere((g) => g.isVertical);
        guides.add(Guide(true, pair[1]));
      }
    }

    // ── Vertical snaps (affect Y) ─────────────────────────
    final yPairs = [
      [dTop, oTop],
      [dTop, oBottom],
      [dBottom, oTop],
      [dBottom, oBottom],
      [dCenterY, oCenterY],
    ];
    for (final pair in yPairs) {
      final diff = (pair[0] - pair[1]).abs();
      if (diff < kSnapThreshold && diff < bestDy) {
        bestDy = diff;
        snapY = proposedY - (pair[0] - pair[1]);
        guides.removeWhere((g) => !g.isVertical);
        guides.add(Guide(false, pair[1]));
      }
    }
  }

  return SnapResult(snapX, snapY, guides);
}

/// Paints alignment guides on the canvas
class AlignmentGuidePainter extends StatelessWidget {
  final List<Guide> guides;
  final double canvasWidth;
  final double canvasHeight;

  const AlignmentGuidePainter({
    super.key,
    required this.guides,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (guides.isEmpty) return const SizedBox.shrink();
    return CustomPaint(
      size: Size(canvasWidth, canvasHeight),
      painter: _GuidePainter(guides: guides),
    );
  }
}

class _GuidePainter extends CustomPainter {
  final List<Guide> guides;
  _GuidePainter({required this.guides});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF4081)
      ..strokeWidth = 0.75
      ..style = PaintingStyle.stroke;

    const dashLen = 6.0;
    const gapLen = 3.0;

    for (final g in guides) {
      if (g.isVertical) {
        _drawDashedLine(canvas, paint,
            Offset(g.position, 0), Offset(g.position, size.height),
            dashLen, gapLen);
      } else {
        _drawDashedLine(canvas, paint,
            Offset(0, g.position), Offset(size.width, g.position),
            dashLen, gapLen);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Paint paint,
      Offset start, Offset end, double dashLen, double gapLen) {
    final total = (end - start).distance;
    final dir = (end - start) / total;
    double drawn = 0;
    while (drawn < total) {
      final segEnd = (drawn + dashLen).clamp(0.0, total);
      canvas.drawLine(
          start + dir * drawn, start + dir * segEnd, paint);
      drawn += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(covariant _GuidePainter old) => true;
}
