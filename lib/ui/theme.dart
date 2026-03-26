import 'package:flutter/material.dart';

class ForgeTheme {
  // ── Blue Brand (matching screenshot) ─────────────────────
  static const Color primary       = Color(0xFF1976D2); // Material Blue 700
  static const Color primaryLight  = Color(0xFF42A5F5); // Blue 400
  static const Color primaryDark   = Color(0xFF0D47A1); // Blue 900
  static const Color accent        = Color(0xFF2196F3); // Blue 500
  static const Color fabColor      = Color(0xFF1565C0); // Blue 800

  static const Color danger        = Color(0xFFE53935);
  static const Color warning       = Color(0xFFFB8C00);
  static const Color success       = Color(0xFF43A047);
  static const Color secondary     = Color(0xFF78909C);

  // ── Surfaces ──────────────────────────────────────────────
  static const Color bg            = Color(0xFFF5F6FA);
  static const Color surface1      = Color(0xFFFFFFFF);
  static const Color surface2      = Color(0xFFF0F2F8);
  static const Color surface3      = Color(0xFFE8EAF0);
  static const Color surface4      = Color(0xFFDDE1EC);

  // ── Canvas ────────────────────────────────────────────────
  static const Color canvasBg      = Color(0xFFE8ECF4);
  static const Color canvasGrid    = Color(0xFFCDD3E0);
  static const Color phoneBg       = Color(0xFFFFFFFF);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF5C6380);
  static const Color textMuted     = Color(0xFF9BA3BF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Borders ───────────────────────────────────────────────
  static const Color border        = Color(0xFFDDE1EC);
  static const Color borderFocus   = Color(0xFF1976D2);

  // ── Selection ─────────────────────────────────────────────
  static const Color selection     = Color(0xFF1976D2);
  static const Color selectionBg   = Color(0x201976D2);
  static const Color handleColor   = Color(0xFF1976D2);

  // ── Widget palette colors ─────────────────────────────────
  static const Map<String, Color> widgetColors = {
    'Container'   : Color(0xFF5C6BC0),
    'Row'         : Color(0xFFFF7043),
    'Column'      : Color(0xFF26A69A),
    'Stack'       : Color(0xFF00ACC1),
    'Text'        : Color(0xFF1976D2),
    'Image'       : Color(0xFF2E7D32),
    'Button'      : Color(0xFFE53935),
    'IconButton'  : Color(0xFFFF5722),
    'TextField'   : Color(0xFF3949AB),
    'Card'        : Color(0xFF6D4C41),
    'Icon'        : Color(0xFFF9A825),
    'Switch'      : Color(0xFF558B2F),
    'Slider'      : Color(0xFF7B1FA2),
    'Checkbox'    : Color(0xFF1565C0),
    'Divider'     : Color(0xFF546E7A),
    'ListTile'    : Color(0xFFEF6C00),
    'CircleAvatar': Color(0xFFAD1457),
    'ListView'    : Color(0xFF4E342E),
    'GridView'    : Color(0xFF00695C),
    'AppBar'      : Color(0xFF1976D2),
  };

  static Color forWidget(String type) =>
      widgetColors[type] ?? primary;

  // ── ThemeData ─────────────────────────────────────────────
  static ThemeData get themeData => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: accent,
      surface: surface1,
    ),
    useMaterial3: true,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: textOnPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textOnPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      iconTheme: IconThemeData(color: textOnPrimary),
    ),
    dividerColor: border,
    cardTheme: const CardTheme(
      color: surface1,
      elevation: 2,
      shadowColor: Color(0x20000000),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: textOnPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: fabColor,
      foregroundColor: textOnPrimary,
      elevation: 4,
    ),
  );
}


// ── Reusable UI components ────────────────────────────────────

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
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: ForgeTheme.surface1,
        border: Border(bottom: BorderSide(color: ForgeTheme.border)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15,
              color: iconColor ?? ForgeTheme.textSecondary),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                color: ForgeTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              )),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: active
              ? ForgeTheme.primary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 17,
            color: active
                ? ForgeTheme.primary
                : (color ?? ForgeTheme.textSecondary)),
      ),
    );
    return tooltip != null
        ? Tooltip(message: tooltip!, child: btn)
        : btn;
  }
}

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
      style: const TextStyle(
          color: ForgeTheme.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
            color: ForgeTheme.textSecondary, fontSize: 12),
        hintStyle: const TextStyle(
            color: ForgeTheme.textMuted, fontSize: 13),
        isDense: dense,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: ForgeTheme.surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ForgeTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ForgeTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
              color: ForgeTheme.primary, width: 2),
        ),
      ),
    );
  }
}

class PropSectionLabel extends StatelessWidget {
  final String text;
  const PropSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          color: ForgeTheme.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
