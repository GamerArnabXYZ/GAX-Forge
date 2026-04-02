import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/forge_provider.dart';
import '../core/models/widget_node.dart';
import '../ui/theme.dart';

class ForgeSelectionOverlay extends StatefulWidget {
  final WidgetNode       node;
  final double           displayX, displayY; // live pos (may differ from node.x during drag)
  final double Function() getScale;
  final VoidCallback      onResizeStart;
  final VoidCallback      onResizeEnd;

  const ForgeSelectionOverlay({
    super.key,
    required this.node,
    required this.displayX,
    required this.displayY,
    required this.getScale,
    required this.onResizeStart,
    required this.onResizeEnd,
  });

  @override
  State<ForgeSelectionOverlay> createState() =>
      _ForgeSelectionOverlayState();
}

class _ForgeSelectionOverlayState extends State<ForgeSelectionOverlay> {
  String? _handle;
  double  _ox = 0, _oy = 0, _ow = 0, _oh = 0;
  double  _px = 0, _py = 0;
  // Local dimensions during resize
  double  _lw = 0, _lh = 0;
  bool    _resizing = false;

  @override
  void initState() {
    super.initState();
    _lw = widget.node.width;
    _lh = widget.node.height;
  }

  @override
  void didUpdateWidget(covariant ForgeSelectionOverlay old) {
    super.didUpdateWidget(old);
    if (!_resizing) {
      _lw = widget.node.width;
      _lh = widget.node.height;
    }
  }

  static const double _hs = 10.0;

  @override
  Widget build(BuildContext context) {
    final sc       = widget.getScale().clamp(0.05, 10.0);
    final hsS      = _hs / sc;
    final bw       = 1.5 / sc;
    final fontSize = (9.0 / sc).clamp(6.0, 13.0);

    // Use displayX/Y so overlay tracks dragged widget
    final lx = widget.displayX;
    final ly = widget.displayY;

    return Positioned(
      left:   lx - hsS / 2,
      top:    ly - hsS / 2,
      width:  _lw + hsS,
      height: _lh + hsS,
      child: Stack(clipBehavior: Clip.none, children: [

        // Border
        Positioned(
          left: hsS/2, top: hsS/2, right: hsS/2, bottom: hsS/2,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: ForgeTheme.primary, width: bw),
              ),
            ),
          ),
        ),

        // Dimension label
        Positioned(
          left: hsS / 2,
          top: -(fontSize + 3 / sc),
          child: IgnorePointer(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 4 / sc, vertical: 1.5 / sc),
              decoration: BoxDecoration(
                color: ForgeTheme.primary,
                borderRadius: BorderRadius.circular(3 / sc),
              ),
              child: Text(
                '${_lw.round()} × ${_lh.round()}',
                style: TextStyle(color: Colors.white,
                    fontSize: fontSize, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),

        // 8 handles
        ..._handleDefs(hsS, _lw, _lh).map((h) => Positioned(
          left: h.pos.dx, top: h.pos.dy,
          width: hsS, height: hsS,
          child: MouseRegion(
            cursor: h.cursor,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (d) {
                _handle = h.name;
                _ox = lx; _oy = ly;
                _ow = _lw; _oh = _lh;
                _px = d.globalPosition.dx;
                _py = d.globalPosition.dy;
                _resizing = true;
                widget.onResizeStart();
              },
              onPanUpdate: (d) {
                if (_handle == null) return;
                final liveSc = widget.getScale().clamp(0.05, 10.0);
                final dx = (d.globalPosition.dx - _px) / liveSc;
                final dy = (d.globalPosition.dy - _py) / liveSc;
                const mn = 20.0;

                double nx = _ox, ny = _oy, nw = _ow, nh = _oh;
                switch (_handle) {
                  case 'se':
                    nw = (nw + dx).clamp(mn, 1000.0);
                    nh = (nh + dy).clamp(mn, 1000.0);
                    break;
                  case 'sw':
                    nw = (nw - dx).clamp(mn, 1000.0);
                    nx = _ox + (_ow - nw);
                    nh = (nh + dy).clamp(mn, 1000.0);
                    break;
                  case 'ne':
                    nw = (nw + dx).clamp(mn, 1000.0);
                    nh = (nh - dy).clamp(mn, 1000.0);
                    ny = _oy + (_oh - nh);
                    break;
                  case 'nw':
                    nw = (nw - dx).clamp(mn, 1000.0);
                    nx = _ox + (_ow - nw);
                    nh = (nh - dy).clamp(mn, 1000.0);
                    ny = _oy + (_oh - nh);
                    break;
                  case 'e':
                    nw = (nw + dx).clamp(mn, 1000.0);
                    break;
                  case 'w':
                    nw = (nw - dx).clamp(mn, 1000.0);
                    nx = _ox + (_ow - nw);
                    break;
                  case 's':
                    nh = (nh + dy).clamp(mn, 1000.0);
                    break;
                  case 'n':
                    nh = (nh - dy).clamp(mn, 1000.0);
                    ny = _oy + (_oh - nh);
                    break;
                }
                setState(() { _lw = nw; _lh = nh; });
                context.read<ForgeProvider>()
                    .resizeNodeDirect(widget.node.id, nx, ny, nw, nh);
              },
              onPanEnd: (_) {
                _resizing = false;
                context.read<ForgeProvider>().commitResize(
                    widget.node.id, _ox, _oy, _ow, _oh);
                _handle = null;
                widget.onResizeEnd();
              },
              onPanCancel: () {
                _resizing = false;
                setState(() { _lw = _ow; _lh = _oh; });
                context.read<ForgeProvider>()
                    .resizeNodeDirect(widget.node.id, _ox, _oy, _ow, _oh);
                _handle = null;
                widget.onResizeEnd();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: ForgeTheme.primary, width: bw),
                  borderRadius: BorderRadius.circular(2 / sc),
                  boxShadow: [BoxShadow(
                    color: ForgeTheme.primary.withOpacity(0.4),
                    blurRadius: 4,
                  )],
                ),
              ),
            ),
          ),
        )),
      ]),
    );
  }

  List<_HD> _handleDefs(double hs, double w, double h) {
    final half = hs / 2;
    return [
      _HD('nw', Offset(0,          0),           SystemMouseCursors.resizeUpLeftDownRight),
      _HD('n',  Offset(w/2-half,   0),           SystemMouseCursors.resizeUpDown),
      _HD('ne', Offset(w,          0),           SystemMouseCursors.resizeUpRightDownLeft),
      _HD('e',  Offset(w,          h/2-half),    SystemMouseCursors.resizeLeftRight),
      _HD('se', Offset(w,          h),           SystemMouseCursors.resizeUpLeftDownRight),
      _HD('s',  Offset(w/2-half,   h),           SystemMouseCursors.resizeUpDown),
      _HD('sw', Offset(0,          h),           SystemMouseCursors.resizeUpRightDownLeft),
      _HD('w',  Offset(0,          h/2-half),    SystemMouseCursors.resizeLeftRight),
    ];
  }
}

class _HD {
  final String name; final Offset pos; final MouseCursor cursor;
  const _HD(this.name, this.pos, this.cursor);
}
