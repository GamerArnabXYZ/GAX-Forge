// lib/screens/widgets/canvas/canvas_widget_renderer.dart
// GAX Forge - Full Widget Renderer (100+ widgets)

import 'package:flutter/material.dart';
import '../../../models/app_models.dart';

class CanvasWidgetRenderer extends StatelessWidget {
  final WidgetProperty widgetProp;
  const CanvasWidgetRenderer({super.key, required this.widgetProp});

  @override
  Widget build(BuildContext context) {
    final p = widgetProp.props;

    Color col(String key, [int fb = 0xFF6750A4]) =>
        Color((p[key] as int?) ?? fb);
    double dbl(String key, [double fb = 0]) =>
        (p[key] as num?)?.toDouble() ?? fb;
    String str(String key, [String fb = '']) =>
        (p[key] as String?) ?? fb;
    bool bln(String key, [bool fb = false]) =>
        (p[key] as bool?) ?? fb;
    int num_(String key, [int fb = 0]) => (p[key] as num?)?.toInt() ?? fb;

    switch (widgetProp.type) {

      // ════════════════════════════════════════
      // BASIC WIDGETS
      // ════════════════════════════════════════

      case 'Container': {
        final hasGrad = bln('hasGradient');
        final hasShadow = bln('hasShadow');
        final hasBorder = bln('hasBorder');
        final tl = dbl('topLeftRadius', -1) < 0 ? dbl('borderRadius', 0) : dbl('topLeftRadius');
        final tr = dbl('topRightRadius', -1) < 0 ? dbl('borderRadius', 0) : dbl('topRightRadius');
        final bl = dbl('bottomLeftRadius', -1) < 0 ? dbl('borderRadius', 0) : dbl('bottomLeftRadius');
        final br = dbl('bottomRightRadius', -1) < 0 ? dbl('borderRadius', 0) : dbl('bottomRightRadius');
        final radius = BorderRadius.only(
          topLeft: Radius.circular(tl), topRight: Radius.circular(tr),
          bottomLeft: Radius.circular(bl), bottomRight: Radius.circular(br),
        );
        final pt = dbl('paddingTop', -1) < 0 ? dbl('padding', 0) : dbl('paddingTop');
        final pb = dbl('paddingBottom', -1) < 0 ? dbl('padding', 0) : dbl('paddingBottom');
        final pl = dbl('paddingLeft', -1) < 0 ? dbl('padding', 0) : dbl('paddingLeft');
        final pr = dbl('paddingRight', -1) < 0 ? dbl('padding', 0) : dbl('paddingRight');
        Decoration deco;
        if (hasGrad) {
          final angle = str('gradientAngle', 'vertical');
          deco = BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: angle == 'horizontal' ? Alignment.centerLeft : Alignment.topCenter,
              end: angle == 'horizontal' ? Alignment.centerRight : Alignment.bottomCenter,
              colors: [col('gradientStart'), col('gradientEnd')],
            ),
            border: hasBorder ? Border.all(color: col('borderColor', 0xFF000000), width: dbl('borderWidth', 1)) : null,
            boxShadow: hasShadow ? [BoxShadow(color: col('shadowColor', 0x40000000), blurRadius: dbl('shadowBlur', 8), offset: Offset(dbl('shadowX'), dbl('shadowY', 4)))] : null,
          );
        } else {
          deco = BoxDecoration(
            color: col('color').withOpacity(dbl('opacity', 1.0)),
            borderRadius: radius,
            border: hasBorder ? Border.all(color: col('borderColor', 0xFF000000), width: dbl('borderWidth', 1)) : null,
            boxShadow: hasShadow ? [BoxShadow(color: col('shadowColor', 0x40000000), blurRadius: dbl('shadowBlur', 8), offset: Offset(dbl('shadowX'), dbl('shadowY', 4)))] : null,
          );
        }
        return Container(
          width: widgetProp.width, height: widgetProp.height,
          padding: EdgeInsets.fromLTRB(pl, pt, pr, pb),
          decoration: deco,
        );
      }

      case 'Text': {
        final deco = str('decoration');
        return SizedBox(
          width: widgetProp.width, height: widgetProp.height,
          child: Align(
            alignment: _textAlignToAlignment(str('textAlign')),
            child: Text(
              str('text', 'Text'),
              maxLines: num_('maxLines') == 0 ? null : num_('maxLines'),
              overflow: _textOverflow(str('overflow', 'ellipsis')),
              softWrap: bln('softWrap', true),
              style: TextStyle(
                fontSize: dbl('fontSize', 16),
                color: col('color', 0xFF212121),
                fontWeight: str('fontWeight') == 'bold' ? FontWeight.bold
                    : str('fontWeight') == 'w300' ? FontWeight.w300
                    : str('fontWeight') == 'w500' ? FontWeight.w500
                    : str('fontWeight') == 'w600' ? FontWeight.w600
                    : str('fontWeight') == 'w800' ? FontWeight.w800
                    : FontWeight.normal,
                fontStyle: str('fontStyle') == 'italic' ? FontStyle.italic : FontStyle.normal,
                letterSpacing: dbl('letterSpacing'),
                height: dbl('lineHeight', 1.0) == 0 ? null : dbl('lineHeight', 1.0),
                decoration: deco == 'underline' ? TextDecoration.underline
                    : deco == 'lineThrough' ? TextDecoration.lineThrough
                    : deco == 'overline' ? TextDecoration.overline
                    : TextDecoration.none,
              ),
            ),
          ),
        );
      }

      case 'Icon':
        return SizedBox(
          width: widgetProp.width, height: widgetProp.height,
          child: Center(child: Icon(
            _safeIcon(p['iconCode'] as int?),
            color: col('color'), size: dbl('size', 32),
          )),
        );

      case 'Image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(dbl('borderRadius')),
          child: Container(
            width: widgetProp.width, height: widgetProp.height,
            color: col('color', 0xFFE0E0E0),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.image_rounded, size: 36, color: Colors.grey.shade500),
              const SizedBox(height: 4),
              Text('Image', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ]),
          ),
        );

      case 'SizedBox':
        return Container(
          width: widgetProp.width, height: widgetProp.height,
          decoration: bln('showBorder', true) ? BoxDecoration(
            border: Border.all(color: col('borderColor', 0xFFBBBBBB), style: BorderStyle.solid),
          ) : null,
          child: Center(child: Text('SizedBox',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11))),
        );

      case 'Divider': {
        final vert = bln('vertical');
        return SizedBox(
          width: widgetProp.width, height: widgetProp.height,
          child: Center(child: vert
            ? VerticalDivider(color: col('color', 0xFFCAC4D0), thickness: dbl('thickness', 1), indent: dbl('indent'), endIndent: dbl('endIndent'))
            : Divider(color: col('color', 0xFFCAC4D0), thickness: dbl('thickness', 1), indent: dbl('indent'), endIndent: dbl('endIndent'))),
        );
      }

      case 'Placeholder':
        return Placeholder(
          color: col('color', 0xFF6750A4),
          strokeWidth: dbl('strokeWidth', 2),
          fallbackWidth: widgetProp.width, fallbackHeight: widgetProp.height,
        );

      case 'Spacer':
        return Container(
          width: widgetProp.width, height: widgetProp.height,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Center(child: Text('flex: ${num_('flex', 1)}',
              style: const TextStyle(color: Colors.blue, fontSize: 11))),
        );

      // ════════════════════════════════════════
      // BUTTONS
      // ════════════════════════════════════════

      case 'ElevatedButton': {
        final iconCode = p['iconCode'] as int? ?? -1;
        final child = iconCode >= 0
          ? Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(_safeIcon(iconCode), size: 18, color: col('textColor', 0xFFFFFFFF)),
              const SizedBox(width: 6),
              Text(str('text', 'Button'), style: TextStyle(fontSize: dbl('fontSize', 14), fontWeight: str('fontWeight') == 'bold' ? FontWeight.bold : FontWeight.normal)),
            ])
          : Text(str('text', 'Button'), style: TextStyle(fontSize: dbl('fontSize', 14), fontWeight: str('fontWeight') == 'bold' ? FontWeight.bold : FontWeight.normal));
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: col('color'), foregroundColor: col('textColor', 0xFFFFFFFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dbl('borderRadius', 12))),
              elevation: dbl('elevation', 2), padding: EdgeInsets.symmetric(horizontal: dbl('padding', 16)),
            ),
            onPressed: bln('disabled') ? null : () {},
            child: child,
          ),
        );
      }

      case 'OutlinedButton':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: col('color'),
              side: BorderSide(color: col('color'), width: dbl('borderWidth', 1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dbl('borderRadius', 12))),
              padding: EdgeInsets.symmetric(horizontal: dbl('padding', 16)),
            ),
            onPressed: bln('disabled') ? null : () {},
            child: Text(str('text', 'Outlined'), style: TextStyle(fontSize: dbl('fontSize', 14))),
          ),
        );

      case 'TextButton':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: col('color'),
              padding: EdgeInsets.symmetric(horizontal: dbl('padding', 8)),
            ),
            onPressed: bln('disabled') ? null : () {},
            child: Text(str('text', 'Text Button'), style: TextStyle(
              fontSize: dbl('fontSize', 14),
              fontWeight: str('fontWeight') == 'bold' ? FontWeight.bold : FontWeight.normal,
            )),
          ),
        );

      case 'FilledButton':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: col('color'), foregroundColor: col('textColor', 0xFFFFFFFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dbl('borderRadius', 12))),
            ),
            onPressed: bln('disabled') ? null : () {},
            child: Text(str('text', 'Filled'), style: TextStyle(fontSize: dbl('fontSize', 14))),
          ),
        );

      case 'FilledTonalButton':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: FilledButton.tonal(
            style: FilledButton.styleFrom(
              backgroundColor: col('color', 0xFFE8DEF8),
              foregroundColor: col('textColor', 0xFF21005D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dbl('borderRadius', 12))),
            ),
            onPressed: () {},
            child: Text(str('text', 'Tonal'), style: TextStyle(fontSize: dbl('fontSize', 14))),
          ),
        );

      case 'IconButton': {
        final style = str('style', 'standard');
        final bg = col('bgColor', 0x00000000);
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: Center(child: style == 'filled'
            ? IconButton.filled(icon: Icon(_safeIcon(p['iconCode'] as int?), size: dbl('size', 24)), onPressed: bln('disabled') ? null : () {})
            : style == 'outlined'
            ? IconButton.outlined(icon: Icon(_safeIcon(p['iconCode'] as int?), size: dbl('size', 24)), onPressed: bln('disabled') ? null : () {})
            : IconButton(
                icon: Icon(_safeIcon(p['iconCode'] as int?), color: col('color'), size: dbl('size', 24)),
                style: bg.alpha > 0 ? IconButton.styleFrom(backgroundColor: bg) : null,
                onPressed: bln('disabled') ? null : () {},
              )),
        );
      }

      case 'FloatingActionButton': {
        final extended = bln('extended');
        return Center(child: extended
          ? FloatingActionButton.extended(
              backgroundColor: col('color'), foregroundColor: col('iconColor', 0xFFFFFFFF),
              elevation: dbl('elevation', 4),
              onPressed: () {},
              icon: Icon(_safeIcon(p['iconCode'] as int?)),
              label: Text(str('label', 'Create')),
            )
          : bln('mini')
          ? FloatingActionButton.small(backgroundColor: col('color'), foregroundColor: col('iconColor', 0xFFFFFFFF), onPressed: () {},
              child: Icon(_safeIcon(p['iconCode'] as int?)))
          : FloatingActionButton(backgroundColor: col('color'), foregroundColor: col('iconColor', 0xFFFFFFFF),
              elevation: dbl('elevation', 4), onPressed: () {},
              child: Icon(_safeIcon(p['iconCode'] as int?))),
        );
      }

      case 'SegmentedButton':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: Center(child: SegmentedButton<int>(
            segments: [
              ButtonSegment(value: 0, label: Text(str('seg1', 'Day'))),
              ButtonSegment(value: 1, label: Text(str('seg2', 'Week'))),
              ButtonSegment(value: 2, label: Text(str('seg3', 'Month'))),
            ],
            selected: {num_('selected')},
            onSelectionChanged: (_) {},
          )),
        );

      // ════════════════════════════════════════
      // INPUT WIDGETS
      // ════════════════════════════════════════

      case 'TextField': {
        final borderStyle = str('borderStyle', 'outline');
        InputBorder border;
        if (borderStyle == 'underline') {
          border = UnderlineInputBorder(borderSide: BorderSide(color: col('color')));
        } else if (borderStyle == 'none') {
          border = InputBorder.none;
        } else {
          border = OutlineInputBorder(borderRadius: BorderRadius.circular(dbl('borderRadius', 8)), borderSide: BorderSide(color: col('color')));
        }
        final pIcon = p['prefixIcon'] as int? ?? -1;
        final sIcon = p['suffixIcon'] as int? ?? -1;
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: TextField(
            maxLines: num_('maxLines', 1),
            obscureText: bln('obscureText'),
            enabled: bln('enabled', true),
            decoration: InputDecoration(
              hintText: str('hintText', 'Enter text...'),
              labelText: str('labelText', 'Label'),
              filled: bln('filled', true),
              fillColor: col('fillColor', 0xFFF3EFF4),
              border: border, focusedBorder: border, enabledBorder: border,
              prefixIcon: pIcon >= 0 ? Icon(_safeIcon(pIcon), color: col('color')) : null,
              suffixIcon: sIcon >= 0 ? Icon(_safeIcon(sIcon), color: col('color')) : null,
              helperText: str('helperText').isEmpty ? null : str('helperText'),
              errorText: str('errorText').isEmpty ? null : str('errorText'),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        );
      }

      case 'SearchBar':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: SearchBar(
            hintText: str('hintText', 'Search...'),
            backgroundColor: WidgetStateProperty.all(col('color', 0xFFF3EFF4)),
            elevation: WidgetStateProperty.all(dbl('elevation', 1)),
            padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: dbl('padding', 16))),
            leading: Icon(_safeIcon(p['leadingIcon'] as int?), size: 20),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(dbl('borderRadius', 28)))),
          ),
        );

      case 'Switch':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Switch(value: bln('value', true), activeColor: col('activeColor', 0xFF6750A4), onChanged: (_) {}),
            if (str('label').isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(str('label'), style: const TextStyle(fontSize: 14)),
            ],
          ]),
        );

      case 'Checkbox':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Checkbox(
              value: bln('value', true),
              activeColor: col('activeColor', 0xFF6750A4),
              checkColor: col('checkColor', 0xFFFFFFFF),
              shape: str('shape') == 'circle' ? const CircleBorder() : null,
              side: BorderSide(width: dbl('borderWidth', 2), color: col('activeColor', 0xFF6750A4)),
              tristate: bln('tristate'),
              onChanged: (_) {},
            ),
            if (str('label').isNotEmpty) Text(str('label'), style: const TextStyle(fontSize: 14)),
          ]),
        );

      case 'Slider':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: Slider(
            value: dbl('value', 0.5).clamp(dbl('min'), dbl('max', 1.0)),
            min: dbl('min'), max: dbl('max', 1.0),
            divisions: num_('divisions') > 0 ? num_('divisions') : null,
            label: bln('showLabel', true) ? dbl('value', 0.5).toStringAsFixed(2) : null,
            activeColor: col('activeColor', 0xFF6750A4),
            inactiveColor: col('inactiveColor', 0xFFE8DEF8),
            thumbColor: col('thumbColor', 0xFF6750A4),
            onChanged: (_) {},
          ),
        );

      case 'RangeSlider':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: RangeSlider(
            values: RangeValues(dbl('startValue', 0.2), dbl('endValue', 0.8)),
            min: dbl('min'), max: dbl('max', 1.0),
            divisions: num_('divisions') > 0 ? num_('divisions') : null,
            labels: RangeLabels(dbl('startValue', 0.2).toStringAsFixed(1), dbl('endValue', 0.8).toStringAsFixed(1)),
            activeColor: col('activeColor', 0xFF6750A4),
            inactiveColor: col('inactiveColor', 0xFFE8DEF8),
            onChanged: (_) {},
          ),
        );

      case 'RadioButton':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Radio<String>(value: 'a', groupValue: 'a', activeColor: col('color', 0xFF6750A4), onChanged: (_) {}),
            Text(str('label', 'Option 1'), style: const TextStyle(fontSize: 14)),
          ]),
        );

      case 'DropdownButton':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: DropdownButtonFormField<String>(
            value: str('value', 'Option 1'),
            decoration: InputDecoration(
              labelText: str('labelText', 'Select'),
              filled: bln('filled', true),
              fillColor: col('fillColor', 0xFFF3EFF4),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(dbl('borderRadius', 8))),
              isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: str('items', 'Option 1,Option 2,Option 3')
                .split(',')
                .map((s) => DropdownMenuItem(value: s.trim(), child: Text(s.trim())))
                .toList(),
            onChanged: (_) {},
          ),
        );

      case 'DatePicker':
      case 'TimePicker':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: col('color', 0xFF6750A4),
              side: BorderSide(color: col('color', 0xFF6750A4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dbl('borderRadius', 8))),
            ),
            onPressed: () {},
            icon: Icon(widgetProp.type == 'DatePicker' ? Icons.calendar_today_rounded : Icons.access_time_rounded, size: 18),
            label: Text(str('label', widgetProp.type == 'DatePicker' ? 'Pick Date' : 'Pick Time')),
          ),
        );

      // ════════════════════════════════════════
      // DISPLAY WIDGETS
      // ════════════════════════════════════════

      case 'Card': {
        final variant = str('variant', 'elevated');
        return Card(
          color: col('color', 0xFFFFFFFF),
          elevation: variant == 'flat' ? 0 : dbl('elevation', 4),
          shadowColor: col('shadowColor', 0x40000000),
          margin: EdgeInsets.all(dbl('margin', 4)),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dbl('borderRadius', 12)),
            side: variant == 'outlined' ? BorderSide(color: col('borderColor', 0xFFCAC4D0), width: dbl('borderWidth', 1)) : BorderSide.none,
          ),
          child: SizedBox(width: widgetProp.width, height: widgetProp.height),
        );
      }

      case 'Chip': {
        final hasAvatar = bln('avatar');
        return Padding(
          padding: const EdgeInsets.all(2),
          child: Chip(
            label: Text(str('label', 'Chip'), style: TextStyle(color: col('textColor', 0xFF6750A4), fontSize: 13)),
            backgroundColor: col('color', 0xFFE8DEF8),
            elevation: dbl('elevation'),
            padding: EdgeInsets.symmetric(horizontal: dbl('padding', 8) / 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dbl('borderRadius', 8))),
            avatar: hasAvatar ? CircleAvatar(backgroundColor: col('avatarColor', 0xFF6750A4),
                child: Text(str('avatarText', 'A'), style: const TextStyle(fontSize: 11, color: Colors.white))) : null,
            deleteIcon: (p['trailingIcon'] as int? ?? -1) >= 0 ? Icon(_safeIcon(p['trailingIcon'] as int?), size: 16) : null,
            onDeleted: (p['trailingIcon'] as int? ?? -1) >= 0 ? () {} : null,
          ),
        );
      }

      case 'Badge':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: Center(child: Badge(
            label: Text(str('label', '9+'), style: TextStyle(fontSize: dbl('fontSize', 12), color: col('textColor', 0xFFFFFFFF))),
            backgroundColor: col('color', 0xFFB3261E),
            padding: EdgeInsets.all(dbl('padding', 4)),
            child: Chip(label: Text(str('childText', 'Inbox'))),
          )),
        );

      case 'CircleAvatar':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: Center(child: CircleAvatar(
            backgroundColor: col('color', 0xFF6750A4),
            radius: dbl('radius', 30),
            child: Text(str('text', 'A'), style: TextStyle(
              color: col('textColor', 0xFFFFFFFF),
              fontSize: dbl('fontSize', 18),
              fontWeight: str('fontWeight') == 'bold' ? FontWeight.bold : FontWeight.normal,
            )),
          )),
        );

      case 'LinearProgressIndicator':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(dbl('borderRadius', 4)),
              child: LinearProgressIndicator(
                value: bln('indeterminate') ? null : dbl('value', 0.6),
                color: col('color', 0xFF6750A4),
                backgroundColor: col('backgroundColor', 0xFFE8DEF8),
                minHeight: dbl('minHeight', 4),
              ),
            ),
            if (bln('valueLabel')) ...[
              const SizedBox(height: 4),
              Text('${(dbl('value', 0.6) * 100).round()}%', style: const TextStyle(fontSize: 11)),
            ],
          ]),
        );

      case 'CircularProgressIndicator':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: Center(child: SizedBox(
            width: dbl('size', 40) > 0 ? dbl('size', 40) : 40,
            height: dbl('size', 40) > 0 ? dbl('size', 40) : 40,
            child: CircularProgressIndicator(
              value: bln('indeterminate', true) ? null : dbl('value', 0.7),
              color: col('color', 0xFF6750A4),
              backgroundColor: col('backgroundColor', 0xFFE8DEF8),
              strokeWidth: dbl('strokeWidth', 4),
              strokeCap: str('strokeCap') == 'round' ? StrokeCap.round : StrokeCap.butt,
            ),
          )),
        );

      case 'Tooltip':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: Center(child: Tooltip(
            message: str('message', 'Tooltip text'),
            decoration: BoxDecoration(color: col('color', 0xFF323232), borderRadius: BorderRadius.circular(dbl('borderRadius', 4))),
            textStyle: TextStyle(color: col('textColor', 0xFFFFFFFF)),
            preferBelow: bln('preferBelow', true),
            padding: EdgeInsets.all(dbl('padding', 8)),
            child: Chip(label: Text(str('childText', 'Hover me'))),
          )),
        );

      case 'ExpansionTile':
        return Container(
          width: widgetProp.width, height: widgetProp.height,
          color: col('color', 0xFFFFFFFF),
          child: ExpansionTile(
            title: Text(str('title', 'Expandable Item'), style: TextStyle(color: col('textColor', 0xFF212121))),
            subtitle: str('subtitle').isNotEmpty ? Text(str('subtitle'), style: TextStyle(color: col('textColor', 0xFF212121).withOpacity(0.6))) : null,
            iconColor: col('iconColor', 0xFF6750A4),
            initiallyExpanded: bln('expanded'),
            children: List.generate(num_('childCount', 3), (i) =>
              ListTile(dense: true, title: Text('${str('childLabel', 'Item')} ${i + 1}'))),
          ),
        );

      case 'DataTable':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: SingleChildScrollView(scrollDirection: Axis.horizontal,
            child: DataTable(
              decoration: BoxDecoration(
                color: col('color', 0xFFFFFFFF),
                borderRadius: BorderRadius.circular(dbl('borderRadius', 8)),
                border: Border.all(color: col('dividerColor', 0xFFE0E0E0)),
              ),
              headingRowColor: WidgetStateProperty.all(col('headerColor', 0xFFF3EFF4)),
              dividerThickness: 1,
              columns: str('columns', 'Name,Age,City').split(',')
                  .map((c) => DataColumn(label: Text(c.trim(), style: TextStyle(fontWeight: FontWeight.bold, color: col('textColor', 0xFF212121)))))
                  .toList(),
              rows: List.generate(int.tryParse(str('rows', '3')) ?? 3, (i) =>
                DataRow(cells: str('columns', 'Name,Age,City').split(',')
                    .map((_) => DataCell(Text('Data ${i + 1}', style: TextStyle(color: col('textColor', 0xFF212121)))))
                    .toList())),
            ),
          ),
        );

      case 'StepperWidget':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: Stepper(
            type: str('type') == 'horizontal' ? StepperType.horizontal : StepperType.vertical,
            currentStep: num_('currentStep', 1),
            steps: List.generate(num_('steps', 3), (i) => Step(
              title: Text('Step ${i + 1}'),
              content: const SizedBox.shrink(),
              isActive: i <= num_('currentStep', 1),
              state: i < num_('currentStep', 1) ? StepState.complete : StepState.indexed,
            )),
            onStepTapped: (_) {},
            controlsBuilder: (_, __) => const SizedBox.shrink(),
          ),
        );

      // ════════════════════════════════════════
      // NAVIGATION WIDGETS
      // ════════════════════════════════════════

      case 'AppBar': {
        final leading = str('leading', 'menu');
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: AppBar(
            backgroundColor: col('color', 0xFF6750A4),
            foregroundColor: col('textColor', 0xFFFFFFFF),
            centerTitle: bln('centerTitle', true),
            elevation: dbl('elevation'),
            title: Text(str('title', 'App Bar'), style: TextStyle(
              fontSize: dbl('titleFontSize', 20),
              fontWeight: str('titleFontWeight') == 'bold' ? FontWeight.bold : FontWeight.normal,
            )),
            leading: leading == 'back' ? const Icon(Icons.arrow_back_rounded)
                : leading == 'none' ? null
                : const Icon(Icons.menu_rounded),
            actions: List.generate(num_('actions', 1).clamp(0, 3), (i) =>
              const Icon(Icons.more_vert_rounded)),
          ),
        );
      }

      case 'BottomNavigationBar': {
        final itemCount = num_('itemCount', 3).clamp(2, 5);
        return Container(
          width: widgetProp.width, height: widgetProp.height,
          color: col('color', 0xFFFFFFFF),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(itemCount, (i) {
              final label = str('item${i + 1}', 'Item ${i + 1}');
              final iconCode = p['icon${i + 1}'] as int? ?? -1;
              final isSelected = i == num_('currentIndex');
              final ic = iconCode >= 0 ? _safeIcon(iconCode) : Icons.circle;
              return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(ic, color: isSelected ? col('selectedColor', 0xFF6750A4) : col('unselectedColor', 0xFF9E9E9E), size: 24),
                if (bln('showLabels', true)) ...[
                  const SizedBox(height: 2),
                  Text(label, style: TextStyle(fontSize: 10, color: isSelected ? col('selectedColor', 0xFF6750A4) : col('unselectedColor', 0xFF9E9E9E))),
                ],
              ]);
            }),
          ),
        );
      }

      case 'NavigationBar': {
        return Container(
          width: widgetProp.width, height: widgetProp.height,
          decoration: BoxDecoration(color: col('color', 0xFFFFFFFF)),
          child: NavigationBar(
            selectedIndex: num_('currentIndex'),
            backgroundColor: col('color', 0xFFFFFFFF),
            indicatorColor: col('indicatorColor', 0xFFE8DEF8),
            height: dbl('height', 80),
            onDestinationSelected: (_) {},
            destinations: [
              NavigationDestination(icon: const Icon(Icons.home_rounded), label: str('item1', 'Home')),
              NavigationDestination(icon: const Icon(Icons.explore_rounded), label: str('item2', 'Explore')),
              NavigationDestination(icon: const Icon(Icons.book_rounded), label: str('item3', 'Library')),
            ],
          ),
        );
      }

      case 'TabBar':
        return Container(
          width: widgetProp.width, height: widgetProp.height,
          color: col('color', 0xFF6750A4),
          child: DefaultTabController(
            length: num_('tabCount', 3).clamp(2, 5),
            child: TabBar(
              tabs: List.generate(num_('tabCount', 3).clamp(2, 5), (i) => Tab(text: str('tab${i + 1}', 'Tab ${i + 1}'))),
              labelColor: col('labelColor', 0xFFFFFFFF),
              unselectedLabelColor: col('unselectedColor', 0xCCFFFFFF),
              indicatorColor: col('indicatorColor', 0xFFFFFFFF),
              indicatorWeight: dbl('indicatorWeight', 3),
              isScrollable: bln('isScrollable'),
              dividerHeight: 0,
            ),
          ),
        );

      case 'NavigationDrawer':
        return Container(
          width: widgetProp.width, height: widgetProp.height,
          color: col('color', 0xFFFFFBFE),
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (bln('showHeader', true)) ...[
              Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: col('headerColor', 0xFF6750A4), borderRadius: BorderRadius.circular(12)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(str('title', 'Menu'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  if (str('subtitle').isNotEmpty) Text(str('subtitle'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ),
              const SizedBox(height: 8),
            ],
            ...List.generate(num_('itemCount', 3).clamp(1, 5), (i) {
              final ic = p['icon${i + 1}'] as int? ?? -1;
              return ListTile(
                dense: true, leading: Icon(_safeIcon(ic >= 0 ? ic : null), color: i == num_('selectedIndex') ? col('selectedColor', 0xFF6750A4) : null),
                title: Text(str('item${i + 1}', 'Item ${i + 1}')),
                selected: i == num_('selectedIndex'),
                selectedColor: col('selectedColor', 0xFF6750A4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                onTap: () {},
              );
            }),
          ]),
        );

      case 'Breadcrumb':
        return SizedBox(width: widgetProp.width, height: widgetProp.height,
          child: Center(child: Row(mainAxisSize: MainAxisSize.min,
            children: str('items', 'Home > Products > Detail').split('>')
              .expand((item) => [
                GestureDetector(onTap: () {}, child: Text(item.trim(), style: TextStyle(color: col('color', 0xFF6750A4), fontSize: dbl('fontSize', 13)))),
                const Text(' › ', style: TextStyle(color: Colors.grey)),
              ])
              .take(str('items', 'Home > Products > Detail').split('>').length * 2 - 1)
              .toList(),
          )),
        );

      // ════════════════════════════════════════
      // LAYOUT HINTS
      // ════════════════════════════════════════

      case 'Column':
      case 'Row':
      case 'Stack':
      case 'Wrap':
      case 'Expanded':
      case 'Padding':
      case 'Center':
      case 'Align':
      case 'FractionallySizedBox':
      case 'AspectRatio':
      case 'ConstrainedBox':
      case 'IntrinsicWidth':
      case 'IntrinsicHeight':
      case 'GridView':
      case 'ListView':
      case 'SingleChildScrollView':
      case 'CustomScrollView':
      case 'PageView':
      case 'TabBarView':
        return _LayoutHint(type: widgetProp.type, size: Size(widgetProp.width, widgetProp.height), color: Color((p['color'] as int?) ?? 0x0F6750A4));

      case 'AnimatedContainer':
        return AnimatedContainer(
          duration: Duration(milliseconds: dbl('duration', 500).round()),
          width: widgetProp.width, height: widgetProp.height,
          decoration: BoxDecoration(
            color: col('color', 0xFF6750A4),
            borderRadius: BorderRadius.circular(dbl('borderRadius', 8)),
          ),
          child: Center(child: Text('Animated', style: const TextStyle(color: Colors.white, fontSize: 12))),
        );

      case 'AnimatedOpacity':
        return Opacity(
          opacity: dbl('opacity', 0.5),
          child: Container(
            width: widgetProp.width, height: widgetProp.height,
            color: col('color', 0xFF6750A4),
            child: Center(child: Text('Opacity: ${dbl('opacity', 0.5).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 11))),
          ),
        );

      // ════════════════════════════════════════
      // OVERLAY WIDGETS
      // ════════════════════════════════════════

      case 'AlertDialog':
        return Container(
          width: widgetProp.width, height: widgetProp.height,
          decoration: BoxDecoration(
            color: col('color', 0xFFFFFFFF),
            borderRadius: BorderRadius.circular(dbl('borderRadius', 16)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 8))],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if ((p['icon'] as int? ?? -1) >= 0) ...[
              Center(child: Icon(_safeIcon(p['icon'] as int?), color: col('buttonColor', 0xFF6750A4), size: 28)),
              const SizedBox(height: 12),
            ],
            Text(str('title', 'Alert Dialog'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: col('titleColor', 0xFF212121))),
            const SizedBox(height: 8),
            Text(str('content', 'This is the dialog content.'), style: TextStyle(fontSize: 14, color: col('contentColor', 0xFF757575))),
            const Spacer(),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () {}, child: Text(str('cancelText', 'Cancel'), style: TextStyle(color: col('buttonColor', 0xFF6750A4)))),
              const SizedBox(width: 8),
              FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: col('buttonColor', 0xFF6750A4)), child: Text(str('confirmText', 'Confirm'))),
            ]),
          ]),
        );

      case 'SnackBar':
        return Container(
          width: widgetProp.width, height: widgetProp.height,
          decoration: BoxDecoration(
            color: col('color', 0xFF323232),
            borderRadius: BorderRadius.circular(str('behavior') == 'floating' ? dbl('borderRadius', 8) : 0),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Expanded(child: Text(str('message', 'Snackbar message'), style: TextStyle(color: col('textColor', 0xFFFFFFFF), fontSize: 14))),
            if (bln('hasAction', true)) TextButton(onPressed: () {},
              child: Text(str('actionLabel', 'UNDO'), style: TextStyle(color: col('actionColor', 0xFF6750A4), fontWeight: FontWeight.bold))),
          ]),
        );

      case 'BottomSheet':
        return Container(
          width: widgetProp.width, height: widgetProp.height,
          decoration: BoxDecoration(
            color: col('color', 0xFFFFFFFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(dbl('borderRadius', 28))),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, -4))],
          ),
          child: Column(children: [
            if (bln('showHandle', true)) Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6), width: 32, height: 4,
              decoration: BoxDecoration(color: col('handleColor', 0xFFCAC4D0), borderRadius: BorderRadius.circular(2)),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(str('title', 'Bottom Sheet'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            ...List.generate(num_('itemCount', 3), (i) => ListTile(
              dense: true, leading: const Icon(Icons.circle, size: 12),
              title: Text('Option ${i + 1}'), onTap: () {},
            )),
          ]),
        );

      case 'PopupMenu':
        return Container(
          width: widgetProp.width, height: widgetProp.height,
          decoration: BoxDecoration(
            color: col('color', 0xFFFFFFFF),
            borderRadius: BorderRadius.circular(dbl('borderRadius', 8)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min,
            children: List.generate(num_('itemCount', 3), (i) => ListTile(
              dense: true, title: Text('Option ${i + 1}', style: const TextStyle(fontSize: 14)),
              leading: const Icon(Icons.radio_button_unchecked, size: 16), onTap: () {},
            ))),
        );

      case 'BannerWidget':
        return Container(
          width: widgetProp.width, height: widgetProp.height,
          color: col('color', 0xFFE8DEF8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Icon(_safeIcon(p['icon'] as int? ?? 0xe3b4), color: col('actionColor', 0xFF6750A4)),
            const SizedBox(width: 12),
            Expanded(child: Text(str('message', 'This is a Material Banner'), style: TextStyle(color: col('textColor', 0xFF21005D), fontSize: 14))),
            TextButton(onPressed: () {}, child: Text(str('actionLabel', 'Dismiss'), style: TextStyle(color: col('actionColor', 0xFF6750A4)))),
          ]),
        );

      case 'Dialog':
        return Container(
          width: widgetProp.width, height: widgetProp.height,
          decoration: BoxDecoration(
            color: col('color', 0xFFFFFFFF),
            borderRadius: BorderRadius.circular(dbl('borderRadius', 16)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12)],
          ),
          child: Center(child: Text(str('title', 'Dialog'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        );

      // ════════════════════════════════════════
      // SCROLL / LIST
      // ════════════════════════════════════════

      case 'ListTile':
        return Container(
          width: widgetProp.width, height: widgetProp.height,
          color: col('color', 0xFFFFFFFF),
          child: ListTile(
            dense: bln('dense'),
            selected: bln('selected'),
            enabled: bln('enabled', true),
            selectedColor: col('selectedColor', 0xFF6750A4),
            contentPadding: EdgeInsets.symmetric(horizontal: dbl('contentPadding', 16)),
            minTileHeight: dbl('minHeight', 56),
            isThreeLine: bln('isThreeLine'),
            leading: Icon(_safeIcon(p['leadingIcon'] as int? ?? 0xe318), color: col('iconColor', 0xFF6750A4)),
            title: Text(str('title', 'List Item'), style: TextStyle(color: col('textColor', 0xFF212121))),
            subtitle: str('subtitle').isNotEmpty ? Text(str('subtitle'), style: TextStyle(color: col('subtitleColor', 0xFF757575))) : null,
            trailing: (p['trailingIcon'] as int? ?? -1) >= 0 ? Icon(_safeIcon(p['trailingIcon'] as int?)) : null,
            onTap: () {},
          ),
        );

      // ════════════════════════════════════════
      // CUSTOM WIDGET
      // ════════════════════════════════════════

      case 'CustomWidget': {
        final hasGrad = bln('hasGradient');
        final hasBorder = bln('hasBorder', true);
        final showIcon = bln('showIcon');
        final iconCode = p['icon'] as int? ?? -1;
        return Container(
          width: widgetProp.width, height: widgetProp.height,
          padding: EdgeInsets.all(dbl('padding', 16)),
          decoration: BoxDecoration(
            color: hasGrad ? null : col('color', 0xFF6750A4).withOpacity(dbl('opacity', 1.0)),
            gradient: hasGrad ? LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [col('gradientStart', 0xFF6750A4), col('gradientEnd', 0xFF03DAC6)],
            ) : null,
            borderRadius: BorderRadius.circular(dbl('borderRadius', 12)),
            border: hasBorder ? Border.all(color: col('borderColor', 0xFF6750A4), width: dbl('borderWidth', 2)) : null,
            boxShadow: [BoxShadow(color: col('color', 0xFF6750A4).withOpacity(0.3), blurRadius: dbl('elevation', 4), offset: const Offset(0, 2))],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (showIcon && iconCode >= 0) ...[
              Icon(_safeIcon(iconCode), color: col('iconColor', 0xFFFFFFFF), size: 32),
              const SizedBox(height: 8),
            ],
            Text(
              str('text', widgetProp.customName ?? 'Custom Widget'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: col('textColor', 0xFFFFFFFF),
                fontSize: dbl('fontSize', 14),
                fontWeight: str('fontWeight') == 'bold' ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ]),
        );
      }

      // ════════════════════════════════════════
      // DEFAULT FALLBACK
      // ════════════════════════════════════════

      default:
        return Container(
          width: widgetProp.width, height: widgetProp.height,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.widgets_rounded, color: Colors.grey.shade400, size: 24),
            const SizedBox(height: 4),
            Text(widgetProp.type, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ])),
        );
    }
  }

  Alignment _textAlignToAlignment(String align) {
    switch (align) {
      case 'center': return Alignment.center;
      case 'right': return Alignment.centerRight;
      default: return Alignment.centerLeft;
    }
  }

  TextOverflow _textOverflow(String v) {
    switch (v) {
      case 'clip': return TextOverflow.clip;
      case 'fade': return TextOverflow.fade;
      case 'visible': return TextOverflow.visible;
      default: return TextOverflow.ellipsis;
    }
  }
}

// ── Layout Hint ─────────────────────────────────
class _LayoutHint extends StatelessWidget {
  final String type;
  final Size size;
  final Color color;
  const _LayoutHint({required this.type, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width, height: size.height,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.view_quilt_rounded, color: color.withOpacity(0.6), size: 22),
        Text(type, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8), fontWeight: FontWeight.w500)),
      ])),
    );
  }
}

// ── Icon map (tree-shake safe) ──────────────────
IconData _safeIcon(int? code) {
  const map = <int, IconData>{
    0xe318: Icons.star_rounded, 0xe145: Icons.add_rounded,
    0xe3af: Icons.image_rounded, 0xe88a: Icons.home_rounded,
    0xe5c4: Icons.arrow_back_rounded, 0xe5d2: Icons.arrow_forward_rounded,
    0xe876: Icons.check_rounded, 0xe5cd: Icons.close_rounded,
    0xe3b4: Icons.info_rounded, 0xe88e: Icons.settings_rounded,
    0xe7fd: Icons.person_rounded, 0xe0be: Icons.email_rounded,
    0xe61c: Icons.phone_rounded, 0xe0b0: Icons.lock_rounded,
    0xe0c8: Icons.visibility_rounded, 0xe8b6: Icons.search_rounded,
    0xe148: Icons.edit_rounded, 0xe872: Icons.delete_rounded,
    0xe5d3: Icons.menu_rounded, 0xe5c3: Icons.more_vert_rounded,
    0xe7f4: Icons.notifications_rounded, 0xe8b8: Icons.share_rounded,
    0xe2c7: Icons.favorite_rounded, 0xe838: Icons.bookmark_rounded,
    0xe1bc: Icons.camera_rounded, 0xe04b: Icons.play_arrow_rounded,
    0xe047: Icons.pause_rounded, 0xe5d5: Icons.refresh_rounded,
    0xe8b5: Icons.send_rounded, 0xe5cf: Icons.chevron_right_rounded,
    0xe5ce: Icons.chevron_left_rounded, 0xe5c5: Icons.arrow_upward_rounded,
    0xe5db: Icons.arrow_downward_rounded, 0xe8dc: Icons.star,
    0xe0af: Icons.download_rounded, 0xe2c4: Icons.upload_rounded,
    0xe1db: Icons.folder_rounded, 0xe24d: Icons.attach_file_rounded,
    0xe040: Icons.mic_rounded, 0xe04f: Icons.stop_rounded,
    0xe8f4: Icons.volume_up_rounded, 0xe04a: Icons.playlist_play_rounded,
    0xe80d: Icons.location_on_rounded, 0xe1c4: Icons.flight_rounded,
    0xe532: Icons.directions_car_rounded, 0xe1d5: Icons.restaurant_rounded,
    0xe8cc: Icons.shopping_cart_rounded, 0xe8ef: Icons.account_balance_rounded,
    0xe8f9: Icons.work_rounded, 0xe80c: Icons.calendar_today_rounded,
    0xe192: Icons.bar_chart_rounded, 0xe6df: Icons.pie_chart_rounded,
  };
  return map[code] ?? Icons.widgets_rounded;
}
