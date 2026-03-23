import 'package:flutter/material.dart';
import '../core/models/widget_node.dart';

// Har WidgetNode ko live Flutter widget mein render karta hai
class WidgetRenderer extends StatelessWidget {
  final WidgetNode node;
  final bool isPreview; // true = canvas, false = code preview

  const WidgetRenderer({
    super.key,
    required this.node,
    this.isPreview = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!node.visible) return const SizedBox.shrink();

    Widget w = _build(context, node);

    // Apply opacity
    final opacity = (node.props['opacity'] as num?)?.toDouble() ?? 1.0;
    if (opacity < 1.0) w = Opacity(opacity: opacity, child: w);

    return w;
  }

  Widget _build(BuildContext context, WidgetNode n) {
    final p = n.props;

    switch (n.type) {
      case WType.container:
        return _buildContainer(n, p);
      case WType.text:
        return _buildText(n, p);
      case WType.image:
        return _buildImage(n, p);
      case WType.button:
        return _buildButton(n, p);
      case WType.iconButton:
        return _buildIconButton(n, p);
      case WType.textField:
        return _buildTextField(n, p);
      case WType.card:
        return _buildCard(n, p);
      case WType.icon:
        return _buildIcon(n, p);
      case WType.switchW:
        return _buildSwitch(n, p);
      case WType.slider:
        return _buildSlider(n, p);
      case WType.checkbox:
        return _buildCheckbox(n, p);
      case WType.divider:
        return _buildDivider(n, p);
      case WType.listTile:
        return _buildListTile(n, p);
      case WType.circleAvatar:
        return _buildCircleAvatar(n, p);
      case WType.row:
        return _buildFlex(n, p, isRow: true);
      case WType.column:
        return _buildFlex(n, p, isRow: false);
      case WType.stack:
        return _buildStack(n, p);
      case WType.listView:
        return _buildListView(n, p);
      case WType.gridView:
        return _buildGridView(n, p);
      case WType.appBar:
        return _buildAppBar(n, p);
    }
  }

  // ── Container ─────────────────────────────────────────────
  Widget _buildContainer(WidgetNode n, Map p) {
    final grad = p['gradientEnabled'] == true;
    final radius = (p['borderRadius'] as num?)?.toDouble() ?? 0;
    final borderW = (p['borderWidth'] as num?)?.toDouble() ?? 0;
    final shadowEnabled = p['shadowEnabled'] == true;

    BoxDecoration deco;
    if (grad) {
      final angle = _gradientAngle(p['gradientAngle']);
      deco = BoxDecoration(
        gradient: LinearGradient(
          begin: angle[0], end: angle[1],
          colors: [
            parseColor(p['gradientStart'], fallback: Colors.purple),
            parseColor(p['gradientEnd'], fallback: Colors.teal),
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: borderW > 0
            ? Border.all(color: parseColor(p['borderColor']), width: borderW)
            : null,
        boxShadow: shadowEnabled ? [_shadow(p)] : null,
      );
    } else {
      deco = BoxDecoration(
        color: parseColor(p['color'], fallback: Colors.blue.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(radius),
        border: borderW > 0
            ? Border.all(color: parseColor(p['borderColor']), width: borderW)
            : null,
        boxShadow: shadowEnabled ? [_shadow(p)] : null,
      );
    }

    final pad = (p['padding'] as num?)?.toDouble() ?? 0;
    final children = n.children;

    return Container(
      width: n.width, height: n.height,
      padding: EdgeInsets.all(pad),
      decoration: deco,
      child: children.isEmpty
          ? const SizedBox.shrink()
          : children.length == 1
              ? WidgetRenderer(node: children.first)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: children.map((c) => WidgetRenderer(node: c)).toList(),
                ),
    );
  }

  // ── Text ──────────────────────────────────────────────────
  Widget _buildText(WidgetNode n, Map p) {
    final decoration = _textDecoration(p['decoration']);
    final style = p['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal;

    return SizedBox(
      width: n.width, height: n.height,
      child: Text(
        p['text']?.toString() ?? 'Text',
        textAlign: _textAlign(p['textAlign']),
        maxLines: (p['maxLines'] as num?)?.toInt() == 0
            ? null : (p['maxLines'] as num?)?.toInt(),
        overflow: _overflow(p['overflow']),
        style: TextStyle(
          fontSize: (p['fontSize'] as num?)?.toDouble() ?? 16,
          color: parseColor(p['color'], fallback: Colors.black87),
          fontWeight: _fontWeight(p['fontWeight']),
          fontStyle: style,
          letterSpacing: (p['letterSpacing'] as num?)?.toDouble() ?? 0,
          height: (p['lineHeight'] as num?)?.toDouble() ?? 1.4,
          decoration: decoration,
          backgroundColor: p['backgroundColor']?.toString().isNotEmpty == true
              ? parseColor(p['backgroundColor']) : null,
        ),
      ),
    );
  }

  // ── Image ─────────────────────────────────────────────────
  Widget _buildImage(WidgetNode n, Map p) {
    final radius = (p['borderRadius'] as num?)?.toDouble() ?? 0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        p['imageUrl']?.toString() ?? 'https://picsum.photos/seed/gax/400/300',
        width: n.width, height: n.height,
        fit: _boxFit(p['fit']),
        errorBuilder: (_, __, ___) => Container(
          width: n.width, height: n.height,
          color: Colors.grey.shade200,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image_outlined, color: Colors.grey, size: 32),
              SizedBox(height: 4),
              Text('Image', style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Button ────────────────────────────────────────────────
  Widget _buildButton(WidgetNode n, Map p) {
    final label = p['label']?.toString() ?? 'Button';
    final bg = parseColor(p['backgroundColor'], fallback: Colors.blue);
    final fg = parseColor(p['foregroundColor'], fallback: Colors.white);
    final radius = (p['borderRadius'] as num?)?.toDouble() ?? 8;
    final fontSize = (p['fontSize'] as num?)?.toDouble() ?? 14;
    final style = p['style']?.toString() ?? 'elevated';
    final iconName = p['icon']?.toString() ?? '';

    Widget child = iconName.isNotEmpty
        ? Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(iconFromName(iconName), size: fontSize + 2),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: fontSize,
                fontWeight: _fontWeight(p['fontWeight']))),
          ])
        : Text(label, style: TextStyle(fontSize: fontSize,
              fontWeight: _fontWeight(p['fontWeight'])));

    final shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius));

    switch (style) {
      case 'outlined':
        return SizedBox(
          width: n.width, height: n.height,
          child: OutlinedButton(
            onPressed: null,
            style: OutlinedButton.styleFrom(
              foregroundColor: bg,
              side: BorderSide(
                  color: parseColor(p['borderColor'], fallback: bg),
                  width: (p['borderWidth'] as num?)?.toDouble() ?? 1.5),
              shape: shape,
            ),
            child: child,
          ),
        );
      case 'text':
        return SizedBox(
          width: n.width, height: n.height,
          child: TextButton(
            onPressed: null,
            style: TextButton.styleFrom(foregroundColor: bg, shape: shape),
            child: child,
          ),
        );
      case 'filled':
        return SizedBox(
          width: n.width, height: n.height,
          child: FilledButton(
            onPressed: null,
            style: FilledButton.styleFrom(
                backgroundColor: bg, foregroundColor: fg, shape: shape),
            child: child,
          ),
        );
      default: // elevated
        return SizedBox(
          width: n.width, height: n.height,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: bg, foregroundColor: fg,
              elevation: (p['elevation'] as num?)?.toDouble() ?? 2,
              shape: shape,
            ),
            child: child,
          ),
        );
    }
  }

  // ── IconButton ────────────────────────────────────────────
  Widget _buildIconButton(WidgetNode n, Map p) {
    final bg = p['backgroundColor']?.toString().isNotEmpty == true
        ? parseColor(p['backgroundColor']) : Colors.transparent;
    return Container(
      width: n.width, height: n.height,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(
        iconFromName(p['icon']?.toString() ?? 'favorite'),
        color: parseColor(p['color'], fallback: Colors.blue),
        size: (p['size'] as num?)?.toDouble() ?? 24,
      ),
    );
  }

  // ── TextField ─────────────────────────────────────────────
  Widget _buildTextField(WidgetNode n, Map p) {
    InputBorder border;
    final bColor = parseColor(p['borderColor'], fallback: Colors.grey.shade400);
    final bType = p['borderType']?.toString() ?? 'outline';
    if (bType == 'underline') {
      border = UnderlineInputBorder(borderSide: BorderSide(color: bColor));
    } else if (bType == 'none') {
      border = InputBorder.none;
    } else {
      border = OutlineInputBorder(
        borderSide: BorderSide(color: bColor),
        borderRadius: BorderRadius.circular(
            (p['borderRadius'] as num?)?.toDouble() ?? 8),
      );
    }

    return SizedBox(
      width: n.width, height: n.height,
      child: TextField(
        enabled: false,
        obscureText: p['obscureText'] == true,
        maxLines: (p['maxLines'] as num?)?.toInt() ?? 1,
        decoration: InputDecoration(
          hintText: p['hintText']?.toString() ?? '',
          labelText: p['labelText']?.toString() ?? '',
          helperText: p['helperText']?.toString().isEmpty == true
              ? null : p['helperText']?.toString(),
          filled: true,
          fillColor: parseColor(p['fillColor'], fallback: Colors.white),
          border: border,
          enabledBorder: border,
          isDense: true,
          prefixIcon: p['prefixIcon']?.toString().isNotEmpty == true
              ? Icon(iconFromName(p['prefixIcon'])) : null,
          suffixIcon: p['suffixIcon']?.toString().isNotEmpty == true
              ? Icon(iconFromName(p['suffixIcon'])) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  // ── Card ──────────────────────────────────────────────────
  Widget _buildCard(WidgetNode n, Map p) {
    final radius = (p['borderRadius'] as num?)?.toDouble() ?? 12;
    return Card(
      elevation: (p['elevation'] as num?)?.toDouble() ?? 4,
      color: parseColor(p['color'], fallback: Colors.white),
      shadowColor: parseColor(p['shadowColor'], fallback: Colors.black26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: n.width, height: n.height,
        child: n.children.isEmpty
            ? const Center(
                child: Text('Card', style: TextStyle(color: Colors.grey)))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: n.children.map((c) => WidgetRenderer(node: c)).toList(),
              ),
      ),
    );
  }

  // ── Icon ──────────────────────────────────────────────────
  Widget _buildIcon(WidgetNode n, Map p) {
    final bg = p['backgroundColor']?.toString().isNotEmpty == true
        ? parseColor(p['backgroundColor']) : Colors.transparent;
    return Container(
      width: n.width, height: n.height,
      color: bg,
      child: Center(
        child: Icon(
          iconFromName(p['icon']?.toString() ?? 'star'),
          color: parseColor(p['color'], fallback: Colors.blue),
          size: (p['size'] as num?)?.toDouble() ?? 32,
        ),
      ),
    );
  }

  // ── Switch ────────────────────────────────────────────────
  Widget _buildSwitch(WidgetNode n, Map p) {
    return SizedBox(
      width: n.width, height: n.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if ((p['label']?.toString() ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(p['label'], style: const TextStyle(fontSize: 13)),
            ),
          Switch(
            value: p['value'] == true,
            onChanged: null,
            activeColor: parseColor(p['activeColor'], fallback: Colors.blue),
            inactiveThumbColor: parseColor(p['inactiveThumbColor'], fallback: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ── Slider ────────────────────────────────────────────────
  Widget _buildSlider(WidgetNode n, Map p) {
    return SizedBox(
      width: n.width, height: n.height,
      child: SliderTheme(
        data: SliderThemeData(
          activeTrackColor: parseColor(p['activeColor'], fallback: Colors.blue),
          inactiveTrackColor: parseColor(p['inactiveColor'], fallback: Colors.grey.shade300),
          thumbColor: parseColor(p['activeColor'], fallback: Colors.blue),
        ),
        child: Slider(
          value: ((p['value'] as num?)?.toDouble() ?? 0.5)
              .clamp((p['min'] as num?)?.toDouble() ?? 0.0,
                     (p['max'] as num?)?.toDouble() ?? 1.0),
          min: (p['min'] as num?)?.toDouble() ?? 0.0,
          max: (p['max'] as num?)?.toDouble() ?? 1.0,
          onChanged: null,
        ),
      ),
    );
  }

  // ── Checkbox ──────────────────────────────────────────────
  Widget _buildCheckbox(WidgetNode n, Map p) {
    return SizedBox(
      width: n.width, height: n.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: p['value'] == true,
            onChanged: null,
            activeColor: parseColor(p['activeColor'], fallback: Colors.blue),
          ),
          if ((p['label']?.toString() ?? '').isNotEmpty)
            Text(p['label'], style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  // ── Divider ───────────────────────────────────────────────
  Widget _buildDivider(WidgetNode n, Map p) {
    final vertical = p['vertical'] == true;
    final color = parseColor(p['color'], fallback: Colors.grey.shade300);
    final thickness = (p['thickness'] as num?)?.toDouble() ?? 1.0;
    if (vertical) {
      return SizedBox(
        width: n.width, height: n.height,
        child: VerticalDivider(color: color, thickness: thickness),
      );
    }
    return SizedBox(
      width: n.width, height: n.height,
      child: Divider(
        color: color, thickness: thickness,
        indent: (p['indent'] as num?)?.toDouble() ?? 0,
        endIndent: (p['endIndent'] as num?)?.toDouble() ?? 0,
      ),
    );
  }

  // ── ListTile ──────────────────────────────────────────────
  Widget _buildListTile(WidgetNode n, Map p) {
    return SizedBox(
      width: n.width, height: n.height,
      child: ListTile(
        leading: Icon(iconFromName(p['leadingIcon']?.toString() ?? 'circle'), size: 20),
        title: Text(p['title']?.toString() ?? 'Title',
            style: const TextStyle(fontSize: 14)),
        subtitle: (p['subtitle']?.toString() ?? '').isNotEmpty
            ? Text(p['subtitle'], style: const TextStyle(fontSize: 12)) : null,
        trailing: (p['trailingIcon']?.toString() ?? '').isNotEmpty
            ? Icon(iconFromName(p['trailingIcon']), size: 18) : null,
        tileColor: p['tileColor']?.toString().isNotEmpty == true
            ? parseColor(p['tileColor']) : null,
        dense: p['dense'] == true,
      ),
    );
  }

  // ── CircleAvatar ──────────────────────────────────────────
  Widget _buildCircleAvatar(WidgetNode n, Map p) {
    final radius = (p['radius'] as num?)?.toDouble() ?? 28;
    final bg = parseColor(p['backgroundColor'], fallback: Colors.blue);
    final fg = parseColor(p['foregroundColor'], fallback: Colors.white);
    final url = p['imageUrl']?.toString() ?? '';

    return SizedBox(
      width: n.width, height: n.height,
      child: Center(
        child: CircleAvatar(
          radius: radius,
          backgroundColor: bg,
          backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
          child: url.isEmpty
              ? Text(p['initials']?.toString() ?? 'GX',
                  style: TextStyle(
                      color: fg,
                      fontSize: (p['fontSize'] as num?)?.toDouble() ?? 18,
                      fontWeight: FontWeight.bold))
              : null,
        ),
      ),
    );
  }

  // ── Row / Column ──────────────────────────────────────────
  Widget _buildFlex(WidgetNode n, Map p, {required bool isRow}) {
    final main = _mainAxis(p['mainAxisAlignment']);
    final cross = _crossAxis(p['crossAxisAlignment']);
    final pad = (p['padding'] as num?)?.toDouble() ?? 0;
    final color = p['color']?.toString().isNotEmpty == true
        ? parseColor(p['color']) : Colors.transparent;

    final childrenW = n.children.isEmpty
        ? <Widget>[_LayoutPlaceholder(
            isRow: isRow, color: isRow ? Colors.orange : Colors.green)]
        : n.children.map((c) => WidgetRenderer(node: c)).toList();

    Widget flex = isRow
        ? Row(mainAxisAlignment: main, crossAxisAlignment: cross,
              mainAxisSize: MainAxisSize.min, children: childrenW)
        : Column(mainAxisAlignment: main, crossAxisAlignment: cross,
                 mainAxisSize: MainAxisSize.min, children: childrenW);

    return Container(
      width: n.width, height: n.height,
      color: color,
      padding: EdgeInsets.all(pad),
      child: flex,
    );
  }

  // ── Stack ─────────────────────────────────────────────────
  Widget _buildStack(WidgetNode n, Map p) {
    final color = p['color']?.toString().isNotEmpty == true
        ? parseColor(p['color']) : Colors.transparent;
    return Container(
      width: n.width, height: n.height,
      color: color,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: n.children.isEmpty
            ? [const _StackPlaceholder()]
            : n.children.map((c) => WidgetRenderer(node: c)).toList(),
      ),
    );
  }

  // ── ListView ──────────────────────────────────────────────
  Widget _buildListView(WidgetNode n, Map p) {
    final count = ((p['itemCount'] as num?)?.toInt() ?? 5).clamp(1, 20);
    final spacing = (p['spacing'] as num?)?.toDouble() ?? 8;
    return SizedBox(
      width: n.width, height: n.height,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (_, __) => SizedBox(height: spacing),
        itemBuilder: (_, i) => Container(
          height: 52,
          decoration: BoxDecoration(
            color: i.isEven ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: Text('Item ${i + 1}', style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }

  // ── GridView ──────────────────────────────────────────────
  Widget _buildGridView(WidgetNode n, Map p) {
    final cols = ((p['crossAxisCount'] as num?)?.toInt() ?? 2).clamp(1, 6);
    return SizedBox(
      width: n.width, height: n.height,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: (p['mainAxisSpacing'] as num?)?.toDouble() ?? 8,
          crossAxisSpacing: (p['crossAxisSpacing'] as num?)?.toDouble() ?? 8,
          childAspectRatio: (p['childAspectRatio'] as num?)?.toDouble() ?? 1,
        ),
        itemCount: cols * 2,
        itemBuilder: (_, i) => Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text('${i + 1}', style: const TextStyle(
                color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────
  Widget _buildAppBar(WidgetNode n, Map p) {
    final bg = parseColor(p['backgroundColor'], fallback: Colors.blue);
    final fg = parseColor(p['foregroundColor'], fallback: Colors.white);
    return Container(
      width: n.width, height: n.height,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (p['showLeading'] == true)
            Icon(iconFromName(p['leadingIcon']?.toString() ?? 'menu'),
                color: fg, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              p['title']?.toString() ?? 'Title',
              textAlign: p['centerTitle'] == true
                  ? TextAlign.center : TextAlign.left,
              style: TextStyle(color: fg, fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
          ),
          if (p['showActions'] == true)
            Icon(Icons.more_vert, color: fg, size: 22),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────
  BoxShadow _shadow(Map p) => BoxShadow(
    color: parseColor(p['shadowColor'], fallback: Colors.black26),
    blurRadius: (p['shadowBlur'] as num?)?.toDouble() ?? 8,
    offset: Offset(
      (p['shadowX'] as num?)?.toDouble() ?? 0,
      (p['shadowY'] as num?)?.toDouble() ?? 4,
    ),
  );

  List<AlignmentGeometry> _gradientAngle(dynamic val) {
    switch (val) {
      case 'topRight': return [Alignment.topLeft, Alignment.topRight];
      case 'bottomLeft': return [Alignment.topRight, Alignment.bottomLeft];
      case 'bottomRight': return [Alignment.topLeft, Alignment.bottomRight];
      default: return [Alignment.topLeft, Alignment.bottomRight];
    }
  }

  TextAlign _textAlign(dynamic v) {
    switch (v) {
      case 'center': return TextAlign.center;
      case 'right': return TextAlign.right;
      case 'justify': return TextAlign.justify;
      default: return TextAlign.left;
    }
  }

  TextOverflow _overflow(dynamic v) {
    switch (v) {
      case 'ellipsis': return TextOverflow.ellipsis;
      case 'clip': return TextOverflow.clip;
      case 'fade': return TextOverflow.fade;
      default: return TextOverflow.visible;
    }
  }

  TextDecoration _textDecoration(dynamic v) {
    switch (v) {
      case 'underline': return TextDecoration.underline;
      case 'lineThrough': return TextDecoration.lineThrough;
      case 'overline': return TextDecoration.overline;
      default: return TextDecoration.none;
    }
  }

  FontWeight _fontWeight(dynamic v) {
    switch (v) {
      case 'bold': return FontWeight.bold;
      case 'w300': return FontWeight.w300;
      case 'w500': return FontWeight.w500;
      case 'w600': return FontWeight.w600;
      case 'w700': return FontWeight.w700;
      case 'w900': return FontWeight.w900;
      default: return FontWeight.normal;
    }
  }

  BoxFit _boxFit(dynamic v) {
    switch (v) {
      case 'contain': return BoxFit.contain;
      case 'fill': return BoxFit.fill;
      case 'fitWidth': return BoxFit.fitWidth;
      case 'fitHeight': return BoxFit.fitHeight;
      case 'none': return BoxFit.none;
      default: return BoxFit.cover;
    }
  }

  MainAxisAlignment _mainAxis(dynamic v) {
    switch (v) {
      case 'center': return MainAxisAlignment.center;
      case 'end': return MainAxisAlignment.end;
      case 'spaceBetween': return MainAxisAlignment.spaceBetween;
      case 'spaceAround': return MainAxisAlignment.spaceAround;
      case 'spaceEvenly': return MainAxisAlignment.spaceEvenly;
      default: return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment _crossAxis(dynamic v) {
    switch (v) {
      case 'start': return CrossAxisAlignment.start;
      case 'end': return CrossAxisAlignment.end;
      case 'stretch': return CrossAxisAlignment.stretch;
      default: return CrossAxisAlignment.center;
    }
  }
}

// ── Placeholder widgets for empty layouts ────────────────────
class _LayoutPlaceholder extends StatelessWidget {
  final bool isRow;
  final Color color;
  const _LayoutPlaceholder({required this.isRow, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isRow ? '← Row →' : '↕ Column ↕',
        style: TextStyle(color: color.withOpacity(0.7), fontSize: 11),
      ),
    );
  }
}

class _StackPlaceholder extends StatelessWidget {
  const _StackPlaceholder();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Stack', style: TextStyle(color: Colors.grey, fontSize: 13)),
    );
  }
}
