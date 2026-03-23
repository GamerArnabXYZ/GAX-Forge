import 'package:flutter/material.dart';

// GAX Forge Pro Dark Theme — FlutterFlow inspired
class ForgeTheme {
  // ── Brand Colors ──────────────────────────────────────────
  static const Color primary    = Color(0xFF6C63FF);   // Purple accent
  static const Color secondary  = Color(0xFF03DAC6);   // Teal accent
  static const Color danger     = Color(0xFFFF5370);   // Red
  static const Color warning    = Color(0xFFFFCB6B);   // Yellow
  static const Color success    = Color(0xFF89DDFF);   // Cyan

  // ── Surface Colors ────────────────────────────────────────
  static const Color bg         = Color(0xFF0E0E14);   // Deepest bg
  static const Color surface1   = Color(0xFF13131A);   // Panel bg
  static const Color surface2   = Color(0xFF1A1A25);   // Card bg
  static const Color surface3   = Color(0xFF22222F);   // Elevated card
  static const Color surface4   = Color(0xFF2A2A3A);   // Hover state

  // ── Canvas ────────────────────────────────────────────────
  static const Color canvasBg   = Color(0xFF080810);
  static const Color canvasGrid = Color(0xFF1A1A28);
  static const Color phoneBg    = Color(0xFFFFFFFF);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFE8E8F0);
  static const Color textSecondary = Color(0xFF8888A8);
  static const Color textMuted     = Color(0xFF4A4A6A);

  // ── Borders ───────────────────────────────────────────────
  static const Color border     = Color(0xFF2A2A3E);
  static const Color borderFocus= Color(0xFF6C63FF);

  // ── Selection ─────────────────────────────────────────────
  static const Color selection  = Color(0xFF6C63FF);
  static const Color selectionBg= Color(0x206C63FF);
  static const Color handleColor= Color(0xFF6C63FF);

  // ── Widget type colors (palette) ─────────────────────────
  static const Map<String, Color> widgetColors = {
    'Container'  : Color(0xFF6C63FF),
    'Row'        : Color(0xFFFF9800),
    'Column'     : Color(0xFF4CAF50),
    'Stack'      : Color(0xFF00BCD4),
    'Text'       : Color(0xFFE91E63),
    'Image'      : Color(0xFF009688),
    'Button'     : Color(0xFFF44336),
    'IconButton' : Color(0xFFFF5722),
    'TextField'  : Color(0xFF3F51B5),
    'Card'       : Color(0xFF795548),
    'Icon'       : Color(0xFFFFEB3B),
    'Switch'     : Color(0xFF8BC34A),
    'Slider'     : Color(0xFF9C27B0),
    'Checkbox'   : Color(0xFF2196F3),
    'Divider'    : Color(0xFF607D8B),
    'ListTile'   : Color(0xFFFF9800),
    'CircleAvatar': Color(0xFFE91E63),
    'ListView'   : Color(0xFF795548),
    'GridView'   : Color(0xFF009688),
    'AppBar'     : Color(0xFF6C63FF),
  };

  static Color forWidget(String type) =>
      widgetColors[type] ?? primary;

  // ── ThemeData ─────────────────────────────────────────────
  static ThemeData get themeData => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: surface2,
      error: danger,
    ),
    useMaterial3: true,
    fontFamily: 'Roboto',
    dividerColor: border,
    dividerTheme: const DividerThemeData(color: border, thickness: 1),
    popupMenuTheme: const PopupMenuThemeData(color: surface2),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: surface3,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      textStyle: const TextStyle(color: textPrimary, fontSize: 12),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(surface4),
      thickness: WidgetStateProperty.all(4),
    ),
  );
}

// ── Reusable UI components ────────────────────────────────────

// Panel section header
class PanelHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final List<Widget>? actions;

  const PanelHeader({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: ForgeTheme.surface1,
        border: Border(bottom: BorderSide(color: ForgeTheme.border)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor ?? ForgeTheme.textSecondary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: ForgeTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

// Compact icon button for panels
class PanelIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final Color? color;
  final bool active;

  const PanelIconBtn({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.color,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: active ? ForgeTheme.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 15,
          color: active
              ? ForgeTheme.primary
              : (color ?? ForgeTheme.textSecondary),
        ),
      ),
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: btn);
    }
    return btn;
  }
}

// Dark text field for property editor
class ForgePropField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool dense;

  const ForgePropField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.dense = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: const TextStyle(color: ForgeTheme.textPrimary, fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
            color: ForgeTheme.textSecondary, fontSize: 11),
        hintStyle:
            const TextStyle(color: ForgeTheme.textMuted, fontSize: 12),
        isDense: dense,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        filled: true,
        fillColor: ForgeTheme.surface3,
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
    );
  }
}

// Section label inside property editor
class PropSectionLabel extends StatelessWidget {
  final String text;
  const PropSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4, left: 2),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: ForgeTheme.textMuted,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
