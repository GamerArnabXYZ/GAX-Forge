import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../core/providers/forge_provider.dart';
import '../core/models/widget_node.dart' hide colorToHex;
import '../ui/theme.dart';

class PropertyPanel extends StatelessWidget {
  const PropertyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ForgeProvider>(
      builder: (context, provider, _) {
        final node = provider.selectedNode;

        return Container(
          color: ForgeTheme.surface1,
          child: Column(
            children: [
              PanelHeader(
                title: node != null
                    ? '${node.type.name} Properties'
                    : 'Properties',
                icon: Icons.tune_rounded,
                iconColor: ForgeTheme.warning,
                actions: node != null
                    ? [
                        PanelIconBtn(
                          icon: Icons.copy_outlined,
                          onTap: () => provider.duplicate(node.id),
                          tooltip: 'Duplicate',
                        ),
                        PanelIconBtn(
                          icon: Icons.delete_outline,
                          onTap: () => provider.deleteNode(node.id),
                          tooltip: 'Delete',
                          color: ForgeTheme.danger,
                        ),
                      ]
                    : null,
              ),
              Expanded(
                child: node == null
                    ? _NoSelection()
                    : _PropertiesForm(node: node),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NoSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app_outlined,
              size: 36, color: ForgeTheme.textMuted),
          SizedBox(height: 12),
          Text('Select a widget',
              style: TextStyle(
                  color: ForgeTheme.textSecondary, fontSize: 13)),
          SizedBox(height: 4),
          Text('to edit properties',
              style: TextStyle(
                  color: ForgeTheme.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _PropertiesForm extends StatelessWidget {
  final WidgetNode node;
  const _PropertiesForm({required this.node});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ForgeProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      children: [
        // ── Position & Size ────────────────────────────────
        PropSectionLabel('Position & Size'),
        _XYWHEditor(node: node, provider: provider),

        // ── Common ────────────────────────────────────────
        PropSectionLabel('Common'),
        _PropSlider('Opacity', 'opacity', node, provider, min: 0, max: 1, decimals: 2),
        _PropSlider('Border Radius', 'borderRadius', node, provider, min: 0, max: 60),
        _PropSlider('Padding', 'padding', node, provider, min: 0, max: 64),

        // ── Type-specific ──────────────────────────────────
        ..._typeProps(context, node, provider),
      ],
    );
  }

  List<Widget> _typeProps(
      BuildContext context, WidgetNode node, ForgeProvider provider) {
    final p = node.props;
    switch (node.type) {
      case WType.container:
        return [
          PropSectionLabel('Fill'),
          _PropToggle('Gradient', 'gradientEnabled', node, provider),
          if (p['gradientEnabled'] != true) ...[
            _ColorPropRow(context, 'Color', 'color', node, provider),
          ] else ...[
            _ColorPropRow(context, 'Start Color', 'gradientStart', node, provider),
            _ColorPropRow(context, 'End Color', 'gradientEnd', node, provider),
            _PropDropdown('Direction', 'gradientAngle', node, provider,
                ['topLeft', 'topRight', 'bottomLeft', 'bottomRight']),
          ],
          PropSectionLabel('Border'),
          _PropSlider('Border Width', 'borderWidth', node, provider, min: 0, max: 8),
          if (((p['borderWidth'] as num?)?.toDouble() ?? 0) > 0)
            _ColorPropRow(context, 'Border Color', 'borderColor', node, provider),
          PropSectionLabel('Shadow'),
          _PropToggle('Shadow', 'shadowEnabled', node, provider),
          if (p['shadowEnabled'] == true) ...[
            _ColorPropRow(context, 'Shadow Color', 'shadowColor', node, provider),
            _PropSlider('Blur', 'shadowBlur', node, provider, min: 0, max: 30),
            _PropSlider('Offset X', 'shadowX', node, provider, min: -20, max: 20),
            _PropSlider('Offset Y', 'shadowY', node, provider, min: -20, max: 20),
          ],
        ];

      case WType.text:
        return [
          PropSectionLabel('Content'),
          _PropTextArea('Text', 'text', node, provider),
          PropSectionLabel('Typography'),
          _PropSlider('Font Size', 'fontSize', node, provider, min: 8, max: 72),
          _ColorPropRow(context, 'Color', 'color', node, provider),
          _PropDropdown('Font Weight', 'fontWeight', node, provider,
              ['normal', 'w300', 'w500', 'w600', 'bold', 'w700', 'w900']),
          _PropDropdown('Font Style', 'fontStyle', node, provider,
              ['normal', 'italic']),
          _PropDropdown('Align', 'textAlign', node, provider,
              ['left', 'center', 'right', 'justify']),
          _PropSlider('Letter Spacing', 'letterSpacing', node, provider,
              min: -2, max: 10, decimals: 1),
          _PropSlider('Line Height', 'lineHeight', node, provider,
              min: 0.8, max: 3.0, decimals: 1),
          _PropDropdown('Decoration', 'decoration', node, provider,
              ['none', 'underline', 'lineThrough', 'overline']),
          _PropDropdown('Overflow', 'overflow', node, provider,
              ['visible', 'ellipsis', 'clip', 'fade']),
        ];

      case WType.button:
        return [
          PropSectionLabel('Content'),
          _PropTextField('Label', 'label', node, provider),
          _PropTextField('Icon (name)', 'icon', node, provider),
          _PropDropdown('Icon Position', 'iconPosition', node, provider,
              ['left', 'right']),
          PropSectionLabel('Style'),
          _PropDropdown('Button Style', 'style', node, provider,
              ['elevated', 'outlined', 'text', 'filled']),
          _ColorPropRow(context, 'Background', 'backgroundColor', node, provider),
          _ColorPropRow(context, 'Text Color', 'foregroundColor', node, provider),
          _PropSlider('Font Size', 'fontSize', node, provider, min: 10, max: 24),
          _PropDropdown('Font Weight', 'fontWeight', node, provider,
              ['normal', 'w500', 'w600', 'bold']),
          _PropSlider('Elevation', 'elevation', node, provider, min: 0, max: 12),
        ];

      case WType.textField:
        return [
          PropSectionLabel('Content'),
          _PropTextField('Hint Text', 'hintText', node, provider),
          _PropTextField('Label', 'labelText', node, provider),
          _PropTextField('Helper Text', 'helperText', node, provider),
          _PropTextField('Prefix Icon', 'prefixIcon', node, provider),
          _PropTextField('Suffix Icon', 'suffixIcon', node, provider),
          PropSectionLabel('Style'),
          _PropDropdown('Border Type', 'borderType', node, provider,
              ['outline', 'underline', 'none']),
          _ColorPropRow(context, 'Fill Color', 'fillColor', node, provider),
          _ColorPropRow(context, 'Border Color', 'borderColor', node, provider),
          _PropToggle('Password', 'obscureText', node, provider),
          _PropDropdown('Keyboard', 'keyboardType', node, provider,
              ['text', 'number', 'email', 'phone', 'url']),
        ];

      case WType.image:
        return [
          PropSectionLabel('Source'),
          _PropTextField('Image URL', 'imageUrl', node, provider),
          _PropDropdown('Fit', 'fit', node, provider,
              ['cover', 'contain', 'fill', 'fitWidth', 'fitHeight', 'none']),
        ];

      case WType.card:
        return [
          PropSectionLabel('Style'),
          _ColorPropRow(context, 'Background', 'color', node, provider),
          _PropSlider('Elevation', 'elevation', node, provider, min: 0, max: 20),
          _ColorPropRow(context, 'Shadow Color', 'shadowColor', node, provider),
        ];

      case WType.icon:
      case WType.iconButton:
        return [
          PropSectionLabel('Icon'),
          _IconPicker('Icon', 'icon', node, provider),
          _ColorPropRow(context, 'Color', 'color', node, provider),
          _PropSlider('Size', 'size', node, provider, min: 12, max: 80),
          if (node.type == WType.iconButton) ...[
            _ColorPropRow(context, 'Background', 'backgroundColor', node, provider),
            _PropTextField('Tooltip', 'tooltip', node, provider),
          ],
        ];

      case WType.switchW:
        return [
          PropSectionLabel('Switch'),
          _PropToggle('Value (On)', 'value', node, provider),
          _ColorPropRow(context, 'Active Color', 'activeColor', node, provider),
          _ColorPropRow(context, 'Inactive Color', 'inactiveThumbColor', node, provider),
          _PropTextField('Label', 'label', node, provider),
        ];

      case WType.slider:
        return [
          PropSectionLabel('Slider'),
          _PropSlider('Value', 'value', node, provider, min: 0, max: 1, decimals: 2),
          _PropSlider('Min', 'min', node, provider, min: 0, max: 100),
          _PropSlider('Max', 'max', node, provider, min: 1, max: 1000),
          _ColorPropRow(context, 'Active Color', 'activeColor', node, provider),
          _ColorPropRow(context, 'Inactive Color', 'inactiveColor', node, provider),
          _PropTextField('Label', 'label', node, provider),
          _PropToggle('Show Label', 'showLabel', node, provider),
        ];

      case WType.checkbox:
        return [
          _PropToggle('Checked', 'value', node, provider),
          _ColorPropRow(context, 'Active Color', 'activeColor', node, provider),
          _PropTextField('Label', 'label', node, provider),
          _PropToggle('Tristate', 'tristate', node, provider),
        ];

      case WType.divider:
        return [
          _ColorPropRow(context, 'Color', 'color', node, provider),
          _PropSlider('Thickness', 'thickness', node, provider, min: 0.5, max: 8),
          _PropSlider('Indent', 'indent', node, provider, min: 0, max: 80),
          _PropSlider('End Indent', 'endIndent', node, provider, min: 0, max: 80),
          _PropToggle('Vertical', 'vertical', node, provider),
        ];

      case WType.listTile:
        return [
          _PropTextField('Title', 'title', node, provider),
          _PropTextField('Subtitle', 'subtitle', node, provider),
          _PropTextField('Leading Icon', 'leadingIcon', node, provider),
          _PropTextField('Trailing Icon', 'trailingIcon', node, provider),
          _ColorPropRow(context, 'Tile Color', 'tileColor', node, provider),
          _PropToggle('Dense', 'dense', node, provider),
        ];

      case WType.circleAvatar:
        return [
          _PropTextField('Image URL', 'imageUrl', node, provider),
          _PropTextField('Initials', 'initials', node, provider),
          _ColorPropRow(context, 'Background', 'backgroundColor', node, provider),
          _ColorPropRow(context, 'Foreground', 'foregroundColor', node, provider),
          _PropSlider('Radius', 'radius', node, provider, min: 12, max: 80),
          _PropSlider('Font Size', 'fontSize', node, provider, min: 10, max: 36),
        ];

      case WType.row:
      case WType.column:
        return [
          _PropDropdown('Main Axis', 'mainAxisAlignment', node, provider,
              ['start', 'center', 'end', 'spaceBetween', 'spaceAround', 'spaceEvenly']),
          _PropDropdown('Cross Axis', 'crossAxisAlignment', node, provider,
              ['start', 'center', 'end', 'stretch']),
          _ColorPropRow(context, 'Background', 'color', node, provider),
        ];

      case WType.stack:
        return [
          _ColorPropRow(context, 'Background', 'color', node, provider),
        ];

      case WType.listView:
        return [
          _PropSlider('Item Count', 'itemCount', node, provider, min: 1, max: 20),
          _PropSlider('Spacing', 'spacing', node, provider, min: 0, max: 32),
          _PropToggle('Horizontal', 'horizontal', node, provider),
        ];

      case WType.gridView:
        return [
          _PropSlider('Columns', 'crossAxisCount', node, provider, min: 1, max: 6),
          _PropSlider('Row Spacing', 'mainAxisSpacing', node, provider, min: 0, max: 32),
          _PropSlider('Col Spacing', 'crossAxisSpacing', node, provider, min: 0, max: 32),
          _PropSlider('Aspect Ratio', 'childAspectRatio', node, provider,
              min: 0.3, max: 3.0, decimals: 1),
        ];

      case WType.appBar:
        return [
          _PropTextField('Title', 'title', node, provider),
          _ColorPropRow(context, 'Background', 'backgroundColor', node, provider),
          _ColorPropRow(context, 'Foreground', 'foregroundColor', node, provider),
          _PropSlider('Elevation', 'elevation', node, provider, min: 0, max: 8),
          _PropToggle('Center Title', 'centerTitle', node, provider),
          _PropTextField('Leading Icon', 'leadingIcon', node, provider),
          _PropToggle('Show Leading', 'showLeading', node, provider),
          _PropToggle('Show Actions', 'showActions', node, provider),
        ];
    }
  }
}

// ── X/Y/W/H editor ──────────────────────────────────────────
class _XYWHEditor extends StatelessWidget {
  final WidgetNode node;
  final ForgeProvider provider;
  const _XYWHEditor({required this.node, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _NumField('X', node.x, (v) =>
            provider.updatePos(node.id, v, node.y))),
        const SizedBox(width: 6),
        Expanded(child: _NumField('Y', node.y, (v) =>
            provider.updatePos(node.id, node.x, v))),
        const SizedBox(width: 6),
        Expanded(child: _NumField('W', node.width, (v) =>
            provider.updateSize(node.id, v, node.height))),
        const SizedBox(width: 6),
        Expanded(child: _NumField('H', node.height, (v) =>
            provider.updateSize(node.id, node.width, v))),
      ],
    );
  }
}

class _NumField extends StatefulWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  const _NumField(this.label, this.value, this.onChanged);

  @override
  State<_NumField> createState() => _NumFieldState();
}

class _NumFieldState extends State<_NumField> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value.round().toString());
  }

  @override
  void didUpdateWidget(_NumField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !_ctrl.selection.isValid) {
      _ctrl.text = widget.value.round().toString();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: const TextStyle(
                color: ForgeTheme.textMuted, fontSize: 9,
                fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 3),
        TextField(
          controller: _ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(
              color: ForgeTheme.textPrimary, fontSize: 12),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            filled: true,
            fillColor: ForgeTheme.surface3,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: ForgeTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: ForgeTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: ForgeTheme.primary),
            ),
          ),
          onSubmitted: (v) {
            final d = double.tryParse(v);
            if (d != null) widget.onChanged(d);
          },
        ),
      ],
    );
  }
}

// ── Reusable property widgets ────────────────────────────────

Widget _PropTextField(String label, String key, WidgetNode node, ForgeProvider provider) {
  return _FieldWrapper(label: label, child: _TextFieldProp(
    label: label, key_: key, node: node, provider: provider));
}

class _TextFieldProp extends StatefulWidget {
  final String label, key_;
  final WidgetNode node;
  final ForgeProvider provider;
  const _TextFieldProp({required this.label, required this.key_,
      required this.node, required this.provider});

  @override
  State<_TextFieldProp> createState() => _TextFieldPropState();
}

class _TextFieldPropState extends State<_TextFieldProp> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.node.props[widget.key_]?.toString() ?? '');
  }

  @override
  void didUpdateWidget(covariant _TextFieldProp old) {
    super.didUpdateWidget(old);
    if (old.node.id != widget.node.id) {
      _ctrl.text = widget.node.props[widget.key_]?.toString() ?? '';
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ForgePropField(
      controller: _ctrl,
      onChanged: (v) => widget.provider.updateProp(
          widget.node.id, widget.key_, v),
    );
  }
}

Widget _PropTextArea(String label, String key, WidgetNode node, ForgeProvider provider) {
  return _FieldWrapper(label: label, child: _TextAreaProp(
    key_: key, node: node, provider: provider));
}

class _TextAreaProp extends StatefulWidget {
  final String key_;
  final WidgetNode node;
  final ForgeProvider provider;
  const _TextAreaProp({required this.key_, required this.node, required this.provider});

  @override
  State<_TextAreaProp> createState() => _TextAreaPropState();
}

class _TextAreaPropState extends State<_TextAreaProp> {
  late TextEditingController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
        text: widget.node.props[widget.key_]?.toString() ?? '');
  }
  @override
  void didUpdateWidget(covariant _TextAreaProp old) {
    super.didUpdateWidget(old);
    if (old.node.id != widget.node.id) {
      _ctrl.text = widget.node.props[widget.key_]?.toString() ?? '';
    }
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      maxLines: 3,
      style: const TextStyle(color: ForgeTheme.textPrimary, fontSize: 12),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.all(10),
        filled: true, fillColor: ForgeTheme.surface3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: ForgeTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: ForgeTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: ForgeTheme.primary),
        ),
      ),
      onChanged: (v) => widget.provider.updateProp(widget.node.id, widget.key_, v),
    );
  }
}

Widget _PropSlider(String label, String key, WidgetNode node, ForgeProvider provider,
    {required double min, required double max, int decimals = 0}) {
  return _PropSliderWidget(
      label: label, key_: key, node: node, provider: provider,
      min: min, max: max, decimals: decimals);
}

class _PropSliderWidget extends StatelessWidget {
  final String label, key_;
  final WidgetNode node;
  final ForgeProvider provider;
  final double min, max;
  final int decimals;

  const _PropSliderWidget({required this.label, required this.key_,
      required this.node, required this.provider,
      required this.min, required this.max, this.decimals = 0});

  @override
  Widget build(BuildContext context) {
    final val = ((node.props[key_] as num?)?.toDouble() ?? min).clamp(min, max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(
                  color: ForgeTheme.textSecondary, fontSize: 11)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ForgeTheme.surface3,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  decimals > 0
                      ? val.toStringAsFixed(decimals)
                      : val.round().toString(),
                  style: const TextStyle(
                      color: ForgeTheme.primary, fontSize: 10,
                      fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: ForgeTheme.primary,
            inactiveTrackColor: ForgeTheme.surface4,
            thumbColor: ForgeTheme.primary,
            overlayColor: ForgeTheme.primary.withOpacity(0.1),
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: val, min: min, max: max,
            // Visual update immediately, save only on release
            onChanged: (v) {
              provider.updatePropSilent(node.id, key_, v);
            },
            onChangeEnd: (v) => provider.updateProp(node.id, key_, v),
          ),
        ),
      ],
    );
  }
}

Widget _PropDropdown(String label, String key, WidgetNode node,
    ForgeProvider provider, List<String> options) {
  return _FieldWrapper(
    label: label,
    child: _DropdownPropWidget(
        key_: key, node: node, provider: provider, options: options),
  );
}

class _DropdownPropWidget extends StatelessWidget {
  final String key_;
  final WidgetNode node;
  final ForgeProvider provider;
  final List<String> options;

  const _DropdownPropWidget({required this.key_, required this.node,
      required this.provider, required this.options});

  @override
  Widget build(BuildContext context) {
    final val = node.props[key_]?.toString() ?? options.first;
    final current = options.contains(val) ? val : options.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: ForgeTheme.surface3,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ForgeTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          isExpanded: true,
          dropdownColor: ForgeTheme.surface2,
          style: const TextStyle(color: ForgeTheme.textPrimary, fontSize: 12),
          icon: const Icon(Icons.expand_more, color: ForgeTheme.textSecondary, size: 16),
          items: options.map((o) => DropdownMenuItem(value: o,
              child: Text(o))).toList(),
          onChanged: (v) { if (v != null) provider.updateProp(node.id, key_, v); },
        ),
      ),
    );
  }
}

Widget _PropToggle(String label, String key, WidgetNode node, ForgeProvider provider) {
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(
            color: ForgeTheme.textSecondary, fontSize: 11)),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: node.props[key] == true,
            activeColor: ForgeTheme.primary,
            inactiveThumbColor: ForgeTheme.textMuted,
            onChanged: (v) => provider.updateProp(node.id, key, v),
          ),
        ),
      ],
    ),
  );
}

Widget _ColorPropRow(BuildContext context, String label, String key,
    WidgetNode node, ForgeProvider provider) {
  return _ColorRowWidget(
      context_: context, label: label, key_: key, node: node, provider: provider);
}

class _ColorRowWidget extends StatelessWidget {
  final BuildContext context_;
  final String label, key_;
  final WidgetNode node;
  final ForgeProvider provider;

  const _ColorRowWidget({required this.context_, required this.label,
      required this.key_, required this.node, required this.provider});

  @override
  Widget build(BuildContext context) {
    final hex = node.props[key_]?.toString() ?? '';
    final color = parseColor(hex, fallback: Colors.transparent);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: ForgeTheme.textSecondary, fontSize: 11)),
          ),
          // Color swatch + click to pick
          GestureDetector(
            onTap: () => _pickColor(context),
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: ForgeTheme.border),
              ),
              child: hex.isEmpty
                  ? const Icon(Icons.block, size: 14, color: ForgeTheme.textMuted)
                  : null,
            ),
          ),
          const SizedBox(width: 6),
          // Hex text
          SizedBox(
            width: 80,
            child: _HexInput(hex: hex, onChanged: (v) =>
                provider.updateProp(node.id, key_, v)),
          ),
        ],
      ),
    );
  }

  void _pickColor(BuildContext context) {
    Color currentColor = parseColor(
        node.props[key_]?.toString(), fallback: Colors.blue);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: ForgeTheme.surface2,
        contentPadding: const EdgeInsets.all(16),
        title: Text(label,
            style: const TextStyle(
                color: ForgeTheme.textPrimary, fontSize: 14)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (c) { currentColor = c; },
            enableAlpha: false,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: ForgeTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final r = (currentColor.red).toRadixString(16).padLeft(2,'0');
              final g = (currentColor.green).toRadixString(16).padLeft(2,'0');
              final b = (currentColor.blue).toRadixString(16).padLeft(2,'0');
              final hex = '#' + r + g + b;
              provider.updateProp(node.id, key_, hex);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: ForgeTheme.primary),
            child: const Text('Apply',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _HexInput extends StatefulWidget {
  final String hex;
  final ValueChanged<String> onChanged;
  const _HexInput({required this.hex, required this.onChanged});

  @override
  State<_HexInput> createState() => _HexInputState();
}

class _HexInputState extends State<_HexInput> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.hex);
  }

  @override
  void didUpdateWidget(_HexInput old) {
    super.didUpdateWidget(old);
    if (old.hex != widget.hex && !_ctrl.selection.isValid) {
      _ctrl.text = widget.hex;
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      style: const TextStyle(
          color: ForgeTheme.textPrimary, fontSize: 11,
          fontFamily: 'monospace'),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        filled: true,
        fillColor: ForgeTheme.surface3,
        hintText: '#RRGGBB',
        hintStyle: const TextStyle(color: ForgeTheme.textMuted, fontSize: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: ForgeTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: ForgeTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: ForgeTheme.primary),
        ),
      ),
      onChanged: (v) {
        if (v.isEmpty || (v.startsWith('#') && v.length == 7)) {
          widget.onChanged(v);
        }
      },
    );
  }
}

Widget _IconPicker(String label, String key, WidgetNode node, ForgeProvider provider) {
  return _FieldWrapper(
    label: label,
    child: _IconPickerWidget(key_: key, node: node, provider: provider),
  );
}

class _IconPickerWidget extends StatefulWidget {
  final String key_;
  final WidgetNode node;
  final ForgeProvider provider;
  const _IconPickerWidget({required this.key_, required this.node, required this.provider});

  @override
  State<_IconPickerWidget> createState() => _IconPickerWidgetState();
}

class _IconPickerWidgetState extends State<_IconPickerWidget> {
  static const _commonIcons = [
    'star', 'favorite', 'home', 'settings', 'person', 'search',
    'add', 'close', 'check', 'edit', 'delete', 'share',
    'menu', 'arrow_back', 'arrow_forward', 'notifications',
    'email', 'phone', 'location_on', 'camera', 'play_arrow',
    'thumb_up', 'comment', 'send', 'lock', 'visibility',
  ];

  @override
  Widget build(BuildContext context) {
    final current = widget.node.props[widget.key_]?.toString() ?? 'star';
    return Column(
      children: [
        // Current selection
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ForgeTheme.surface3,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: ForgeTheme.border),
          ),
          child: Row(
            children: [
              Icon(iconFromName(current),
                  color: ForgeTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(current,
                  style: const TextStyle(
                      color: ForgeTheme.textPrimary, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Icon grid
        Wrap(
          spacing: 4, runSpacing: 4,
          children: _commonIcons.map((name) {
            final selected = name == current;
            return GestureDetector(
              onTap: () => widget.provider.updateProp(
                  widget.node.id, widget.key_, name),
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: selected
                      ? ForgeTheme.primary.withOpacity(0.2)
                      : ForgeTheme.surface3,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: selected
                        ? ForgeTheme.primary : ForgeTheme.border,
                  ),
                ),
                child: Icon(iconFromName(name),
                    size: 16,
                    color: selected
                        ? ForgeTheme.primary : ForgeTheme.textSecondary),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Field wrapper with label
class _FieldWrapper extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldWrapper({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(label,
              style: const TextStyle(
                  color: ForgeTheme.textSecondary, fontSize: 11)),
        ),
        child,
      ],
    );
  }
}
