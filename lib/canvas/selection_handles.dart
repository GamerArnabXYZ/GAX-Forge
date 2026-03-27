import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/forge_provider.dart';
import '../core/models/widget_node.dart';
import '../ui/theme.dart';

class ForgeSelectionOverlay extends StatefulWidget {
  final WidgetNode node;
  final double     scale;

  const ForgeSelectionOverlay({
    super.key, required this.node, required this.scale,
  });

  @override
  State<ForgeSelectionOverlay> createState() => _ForgeSelectionOverlayState();
}

class _ForgeSelectionOverlayState extends State<ForgeSelectionOverlay> {
  // Resize state
  String? _handle;
  double _ox = 0, _oy = 0, _ow = 0, _oh = 0;
  double _px = 0, _py = 0;

  // Local values during resize (smooth)
  double _lx = 0, _ly = 0, _lw = 0, _lh = 0;
  bool   _resizing = false;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant ForgeSelectionOverlay old) {
    super.didUpdateWidget(old);
    if (!_resizing) _sync();
  }

  void _sync() {
    _lx = widget.node.x; _ly = widget.node.y;
    _lw = widget.node.width; _lh = widget.node.height;
  }

  static const double _hs = 10.0; // handle size px

  @override
  Widget build(BuildContext context) {
    final sc = widget.scale.clamp(0.1, 5.0);
    final hsScaled = _hs / sc;

    return Positioned(
      left:   _lx - hsScaled / 2,
      top:    _ly - hsScaled / 2,
      width:  _lw + hsScaled,
      height: _lh + hsScaled,
      child: Stack(clipBehavior: Clip.none, children: [

        // Border
        Positioned(
          left: hsScaled / 2, top: hsScaled / 2,
          right: hsScaled / 2, bottom: hsScaled / 2,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: ForgeTheme.primary, width: 1.5 / sc),
              ),
            ),
          ),
        ),

        // Size label
        Positioned(
          left: hsScaled / 2, top: 0,
          child: IgnorePointer(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 4 / sc, vertical: 1 / sc),
              decoration: BoxDecoration(
                color: ForgeTheme.primary,
                borderRadius: BorderRadius.circular(3 / sc),
              ),
              child: Text(
                '${_lw.round()} × ${_lh.round()}',
                style: TextStyle(color: Colors.white,
                    fontSize: 9 / sc, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),

        // 8 handles
        for (final h in _handles(hsScaled, _lw, _lh))
          _Handle(
            key: ValueKey(h.name),
            name: h.name, pos: h.pos, size: hsScaled,
            cursor: h.cursor,
            onPanStart: (d) {
              _handle = h.name;
              _ox = _lx; _oy = _ly; _ow = _lw; _oh = _lh;
              _px = d.globalPosition.dx;
              _py = d.globalPosition.dy;
              _resizing = true;
            },
            onPanUpdate: (d) {
              if (_handle == null) return;
              final dx = (d.globalPosition.dx - _px) / sc;
              final dy = (d.globalPosition.dy - _py) / sc;
              const mn = 20.0;
              double nx = _ox, ny = _oy, nw = _ow, nh = _oh;
              switch (_handle) {
                case 'se': nw=(nw+dx).clamp(mn,1e3); nh=(nh+dy).clamp(mn,1e3);
                case 'sw': nw=(nw-dx).clamp(mn,1e3); nx=_ox+(_ow-nw); nh=(nh+dy).clamp(mn,1e3);
                case 'ne': nw=(nw+dx).clamp(mn,1e3); nh=(nh-dy).clamp(mn,1e3); ny=_oy+(_oh-nh);
                case 'nw': nw=(nw-dx).clamp(mn,1e3); nx=_ox+(_ow-nw); nh=(nh-dy).clamp(mn,1e3); ny=_oy+(_oh-nh);
                case 'e':  nw=(nw+dx).clamp(mn,1e3);
                case 'w':  nw=(nw-dx).clamp(mn,1e3); nx=_ox+(_ow-nw);
                case 's':  nh=(nh+dy).clamp(mn,1e3);
                case 'n':  nh=(nh-dy).clamp(mn,1e3); ny=_oy+(_oh-nh);
              }
              setState(() { _lx=nx; _ly=ny; _lw=nw; _lh=nh; });
              // Update model silently
              context.read<ForgeProvider>()
                  .resizeNodeDirect(widget.node.id, nx, ny, nw, nh);
            },
            onPanEnd: (_) {
              _resizing = false;
              context.read<ForgeProvider>().commitResize(
                  widget.node.id, _ox, _oy, _ow, _oh);
              _handle = null;
            },
          ),
      ]),
    );
  }

  // ── Handle positions ──────────────────────────────────────
  List<_HData> _handles(double hs, double w, double h) {
    final half = hs / 2;
    return [
      _HData('nw', Offset(0, 0),          SystemMouseCursors.resizeUpLeftDownRight),
      _HData('n',  Offset(w/2, 0),        SystemMouseCursors.resizeUpDown),
      _HData('ne', Offset(w+half, 0),     SystemMouseCursors.resizeUpRightDownLeft),
      _HData('e',  Offset(w+half, h/2),   SystemMouseCursors.resizeLeftRight),
      _HData('se', Offset(w+half, h+half),SystemMouseCursors.resizeUpLeftDownRight),
      _HData('s',  Offset(w/2, h+half),   SystemMouseCursors.resizeUpDown),
      _HData('sw', Offset(0, h+half),     SystemMouseCursors.resizeUpRightDownLeft),
      _HData('w',  Offset(0, h/2),        SystemMouseCursors.resizeLeftRight),
    ];
  }
}

class _HData {
  final String name; final Offset pos; final MouseCursor cursor;
  const _HData(this.name, this.pos, this.cursor);
}

class _Handle extends StatelessWidget {
  final String name;
  final Offset pos;
  final double size;
  final MouseCursor cursor;
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;

  const _Handle({
    super.key, required this.name, required this.pos,
    required this.size, required this.cursor,
    required this.onPanStart, required this.onPanUpdate, required this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: pos.dx, top: pos.dy,
      width: size, height: size,
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: ForgeTheme.primary, width: 1.5),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(color: ForgeTheme.primary.withOpacity(0.3),
                    blurRadius: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
